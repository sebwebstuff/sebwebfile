local nativefs = {}

local redirects = {}
local working_directory = ''

local function nfs_log(...)
  print('[SMODS WEB NFS]', ...)
end

nfs_log('module init begin', 'lua=' .. tostring(_VERSION), 'type(string)=' .. tostring(type(string)), 'type(getmetatable(\'\'))=' .. tostring(type(getmetatable(''))))

local function resolve_string_lib()
  local mt = nil
  local ok_mt = pcall(function() mt = getmetatable('') end)
  nfs_log('resolve_string_lib', 'ok_mt=' .. tostring(ok_mt), 'type(mt)=' .. tostring(type(mt)), 'type(string)=' .. tostring(type(string)))
  if ok_mt and type(mt) == 'table' then
    nfs_log('resolve_string_lib mt table', 'type(mt.__index)=' .. tostring(type(mt.__index)), 'type(mt.gsub)=' .. tostring(type(mt.gsub)))
    if type(mt.__index) == 'table' then
      nfs_log('resolve_string_lib using mt.__index')
      return mt.__index
    end
    if type(mt.gsub) == 'function' and type(mt.sub) == 'function' and type(mt.match) == 'function' and type(mt.gmatch) == 'function' then
      nfs_log('resolve_string_lib using mt function table')
      return mt
    end
  end

  if type(string) == 'table' and type(string.gsub) == 'function' and type(string.sub) == 'function' and type(string.match) == 'function' and type(string.gmatch) == 'function' then
    nfs_log('resolve_string_lib using global string table')
    return string
  end

  nfs_log('resolve_string_lib failure', 'type(string.gsub)=' .. tostring(type(type(string) == 'table' and string.gsub or nil)))
  error('SMODS web nativefs: string library unavailable')
end

local STR = resolve_string_lib()
nfs_log('module init complete', 'type(STR)=' .. tostring(type(STR)), 'type(STR.gsub)=' .. tostring(type(STR and STR.gsub)))

local function normalize(path)
  path = tostring(path or '')
  path = STR.gsub(path, '\\', '/')
  path = STR.gsub(path, '/+', '/')
  path = STR.gsub(path, '/%./', '/')
  if STR.sub(path, 1, 2) == './' then path = STR.sub(path, 3) end
  if STR.sub(path, 1, 1) == '/' then path = STR.sub(path, 2) end
  return path
end

local function strip_known_root(path)
  local save_dir = normalize((love.filesystem.getSaveDirectory and love.filesystem.getSaveDirectory()) or '')
  local src_dir = normalize((love.filesystem.getSourceBaseDirectory and love.filesystem.getSourceBaseDirectory()) or '')
  local p = normalize(path)

  if save_dir ~= '' and STR.sub(p, 1, #save_dir) == save_dir then
    p = STR.sub(p, #save_dir + 1)
    p = normalize(p)
  elseif src_dir ~= '' and STR.sub(p, 1, #src_dir) == src_dir then
    p = STR.sub(p, #src_dir + 1)
    p = normalize(p)
  end
  return p
end

local function resolve_redirect(path)
  for from_path, to_path in pairs(redirects) do
    local from_norm = normalize(from_path)
    local path_norm = normalize(path)
    if path_norm == from_norm then return normalize(to_path) end
    if STR.sub(path_norm, 1, #from_norm + 1) == from_norm .. '/' then
      return normalize(to_path) .. '/' .. STR.sub(path_norm, #from_norm + 2)
    end
  end
  return nil
end

local function resolve(path)
  local redirected = resolve_redirect(path)
  if redirected then return redirected end

  local p = strip_known_root(path)
  if p == '' then return normalize(working_directory) end

  if working_directory ~= '' and STR.sub(p, 1, #working_directory) ~= working_directory then
    p = normalize(working_directory .. '/' .. p)
  end
  return normalize(p)
end

local function ensure_dir(path)
  local p = normalize(path)
  if p == '' then return true end
  local acc = ''
  for part in STR.gmatch(p, '[^/]+') do
    acc = (acc == '') and part or (acc .. '/' .. part)
    love.filesystem.createDirectory(acc)
  end
  return true
end

function nativefs.smodsAddRedirect(realPath, lfsPath)
  local key = normalize(realPath)
  if redirects[key] then return false, 'redirect exists' end
  redirects[key] = normalize(lfsPath)
  return true
end

function nativefs.getWorkingDirectory()
  return working_directory
end

function nativefs.setWorkingDirectory(path)
  working_directory = strip_known_root(path)
  ensure_dir(working_directory)
  return true
end

function nativefs.read(containerOrName, nameOrSize, sizeOrNil)
  local read_path_hint = nil
  if type(containerOrName) == 'string' and nameOrSize == nil then
    read_path_hint = resolve(containerOrName)
  elseif type(nameOrSize) == 'string' and sizeOrNil == nil then
    read_path_hint = resolve(nameOrSize)
  end

  local function do_read(...)
    local ok, a, b = pcall(love.filesystem.read, ...)
    if ok then
      if type(a) == 'boolean' then
        if read_path_hint and STR.match(read_path_hint, '^config/') then
          nfs_log('read result(bool-form)', 'path=' .. tostring(read_path_hint), 'ok=' .. tostring(a), 'type(payload)=' .. tostring(type(b)))
        end
        if a then return b end
        return nil, b
      end
      if read_path_hint and STR.match(read_path_hint, '^config/') then
        nfs_log('read result', 'path=' .. tostring(read_path_hint), 'type(payload)=' .. tostring(type(a)))
      end
      return a, b
    end
    nfs_log(
      'read failed',
      'containerOrName=' .. tostring(containerOrName),
      'nameOrSize=' .. tostring(nameOrSize),
      'sizeOrNil=' .. tostring(sizeOrNil),
      'err=' .. tostring(a)
    )
    error(a)
  end

  if sizeOrNil ~= nil then
    return do_read(containerOrName, resolve(nameOrSize), sizeOrNil)
  end

  if nameOrSize == nil then
    return do_read('string', resolve(containerOrName))
  end

  if type(nameOrSize) == 'number' then
    return do_read('string', resolve(containerOrName), nameOrSize)
  end

  if nameOrSize == 'all' then
    return do_read('string', resolve(containerOrName))
  end

  return do_read(containerOrName, resolve(nameOrSize))
end

function nativefs.write(name, data, size)
  local path = resolve(name)
  local dir = STR.match(path, '^(.*)/[^/]+$') or ''
  if dir ~= '' then ensure_dir(dir) end
  if size and type(data) == 'string' then
    data = STR.sub(data, 1, size)
  end
  return love.filesystem.write(path, data)
end

function nativefs.append(name, data, size)
  local path = resolve(name)
  local dir = STR.match(path, '^(.*)/[^/]+$') or ''
  if dir ~= '' then ensure_dir(dir) end
  if size and type(data) == 'string' then
    data = STR.sub(data, 1, size)
  end
  return love.filesystem.append(path, data)
end

function nativefs.lines(name)
  local content = love.filesystem.read(resolve(name)) or ''
  local i = 1
  local lines = {}
  for line in STR.gmatch((content .. '\n'), '(.-)\n') do
    lines[#lines + 1] = line
  end
  return function()
    local out = lines[i]
    i = i + 1
    return out
  end
end

function nativefs.load(name)
  local content, err = love.filesystem.read(resolve(name))
  if not content then return nil, err end
  local chunk, load_err = loadstring(content, '@' .. resolve(name))
  if not chunk then return nil, load_err end
  return chunk
end

function nativefs.getDirectoryItems(dir)
  return love.filesystem.getDirectoryItems(resolve(dir))
end

function nativefs.getDirectoryItemsInfo(path, filtertype)
  local out = {}
  for _, item in ipairs(nativefs.getDirectoryItems(path)) do
    local p = resolve(path) .. '/' .. item
    local info = love.filesystem.getInfo(p, filtertype)
    if info then
      info.name = item
      out[#out + 1] = info
    end
  end
  return out
end

function nativefs.getInfo(path, filtertype)
  return love.filesystem.getInfo(resolve(path), filtertype)
end

function nativefs.createDirectory(path)
  return ensure_dir(resolve(path))
end

function nativefs.remove(path)
  return love.filesystem.remove(resolve(path))
end

function nativefs.mount(archive, mountPoint, appendToPath)
  local archive_path = resolve(archive)
  local mount_path = resolve(mountPoint)
  local parent = STR.match(mount_path, '^(.*)/[^/]+$') or ''
  if parent ~= '' then ensure_dir(parent) end
  return love.filesystem.mount(archive_path, mount_path, appendToPath)
end

function nativefs.unmount(archive)
  return love.filesystem.unmount(resolve(archive))
end

function nativefs.newFile(path)
  return love.filesystem.newFile(resolve(path))
end

function nativefs.newFileData(path)
  return love.filesystem.newFileData(resolve(path))
end

return nativefs
