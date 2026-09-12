if (love.system.getOS() == 'OS X' ) and (jit.arch == 'arm64' or jit.arch == 'arm') then jit.off() end

-- This build is always for web
IS_WEB = true

-- Reduce log-induced frame spikes in web builds by silencing noisy debug channels unless explicitly enabled.
do
	local raw_print = print
	local muted_prefixes = {
		'[DEBUG]',
		'[PACK DEBUG]',
		'[RARITY DEBUG]',
		'[DRAW]',
		'LONG DT @'
	}

	local function should_mute(first)
		if _G.FORCE_VERBOSE_LOGS then return false end
		if type(first) ~= 'string' then return false end
		for i = 1, #muted_prefixes do
			local p = muted_prefixes[i]
			if string.sub(first, 1, #p) == p then
				return true
			end
		end
		return false
	end

	print = function(...)
		if should_mute(select(1, ...)) then return end
		return raw_print(...)
	end
end

require "engine/object"

-- Polyfill for bit library if not available (for web version)
if not bit then
    bit = {}
    bit.bxor = function(a, b)
        local result = 0
        local bitval = 1
        while a > 0 or b > 0 do
            local a_bit = a % 2
            local b_bit = b % 2
            if a_bit ~= b_bit then
                result = result + bitval
            end
            bitval = bitval * 2
            a = math.floor(a / 2)
            b = math.floor(b / 2)
        end
        return result
    end
    
    bit.lshift = function(x, n)
        return math.floor(x) * (2 ^ n)
    end
    
    bit.rshift = function(x, n)
        return math.floor(math.floor(x) / (2 ^ n))
    end
else
    require "bit"
end
require "engine/string_packer"
require "engine/controller"
require "back"
require "tag"
require "engine/event"
require "engine/node"
require "engine/moveable"
require "engine/sprite"
require "engine/animatedsprite"
require "functions/misc_functions"
require "game"
require "globals"
require "engine/ui"
require "functions/UI_definitions"
require "functions/state_events"
require "functions/common_events"
require "functions/button_callbacks"
require "functions/smods_native_compat"
require "functions/mor_jokers_native"
require "functions/jank_jonklers_native"
require "functions/mikas_native"
require "functions/qol_native"
require "functions/misc_functions"
require "functions/test_functions"
require "card"
require "cardarea"
require "blind"
require "card_character"
require "engine/particles"
require "engine/text"
require "challenges"

local SMODS_WEB_BOOT_DONE = false
local SMODS_WEB_ROOT = 'smods-1.0.0-beta-1501a/smods-1.0.0-beta-1501a/'

local function smods_web_log(...)
	print('[SMODS WEB]', ...)
end

local function smods_web_xpcall(label, fn)
	return xpcall(fn, function(err)
		local tb = (debug and debug.traceback and debug.traceback('', 2)) or '(no traceback)'
		return tostring(err) .. '\n' .. tostring(tb)
	end)
end

local function smods_load_chunk_from_path(path, chunk_name, patch_preflight_core)
	local source = love.filesystem.read(path)
	if not source or source == '' then
		return nil, 'missing source: ' .. tostring(path)
	end

	if patch_preflight_core then
		source = source:gsub(
			"local lovely_path = false %-%- This line is patched, don't edit it",
			"local lovely_path = rawget(_G, '__SMODS_LOVELY_PATH__') or false"
		)
	end

	local loader, load_err = loadstring(source, chunk_name or ('@' .. path))
	if not loader then return nil, load_err end
	return loader
end

local function install_smods_web_bootstrap()
	if SMODS_WEB_BOOT_DONE then return true end
	if not IS_WEB then return false end

	smods_web_log('bootstrap begin', 'root=' .. tostring(SMODS_WEB_ROOT), 'lua=' .. tostring(_VERSION), 'type(string)=' .. tostring(type(string)))

	if not _G.__SMODS_WEB_LOAD_COMPAT_INSTALLED__ and type(loadstring) == 'function' then
		local supports_string_load = pcall(function()
			local fn = load('return true')
			return type(fn) == 'function'
		end)

		if not supports_string_load then
			local raw_load = _G.load
			_G.__SMODS_WEB_RAW_LOAD__ = raw_load
			_G.load = function(ld, source, mode, env)
				if type(ld) == 'string' then
					local chunk, err = loadstring(ld, source)
					if not chunk then return nil, err end
					if env ~= nil and type(setfenv) == 'function' then
						setfenv(chunk, env)
					end
					return chunk
				end

				if ld == nil then
					smods_web_log('load shim received nil chunk', 'source=' .. tostring(source))
					return nil, 'load: nil chunk source for ' .. tostring(source)
				end

				if type(ld) ~= 'function' then
					smods_web_log('load shim rejecting non-string/non-function', 'type=' .. tostring(type(ld)), 'source=' .. tostring(source), 'value=' .. tostring(ld))
					return nil, 'load: unsupported chunk source type ' .. tostring(type(ld))
				end

				if type(raw_load) == 'function' then
					if env ~= nil then
						local chunk, err = raw_load(ld, source)
						if chunk and type(setfenv) == 'function' then
							setfenv(chunk, env)
						end
						return chunk, err
					end
					return raw_load(ld, source)
				end

				return nil, 'load is unavailable'
			end
			smods_web_log('installed load() string compatibility shim')
		end

		_G.__SMODS_WEB_LOAD_COMPAT_INSTALLED__ = true
	end

	if not love.filesystem.getInfo(SMODS_WEB_ROOT .. 'src/preflight/core.lua') then
		smods_web_log('Steamodded source not found at', tostring(SMODS_WEB_ROOT))
		return false
	end

	local searchers = package.searchers or package.loaders

	package.preload['SMODS.nativefs'] = function()
		smods_web_log('preload require begin', 'engine/smods_web_nativefs')
		local ok_mod, mod_or_err = smods_web_xpcall('require_smods_nativefs', function()
			return require('engine/smods_web_nativefs')
		end)
		if not ok_mod then
			smods_web_log('preload require failed', tostring(mod_or_err))
			error(mod_or_err)
		end
		smods_web_log('preload require success', 'engine/smods_web_nativefs')
		return mod_or_err
	end

	package.preload['nativefs'] = function()
		return require('SMODS.nativefs')
	end

	package.preload['json'] = function()
		local json_loader = assert(smods_load_chunk_from_path(
			SMODS_WEB_ROOT .. 'libs/json/json.lua',
			'=[SMODS json "libs/json/json.lua"]'
		))
		return json_loader()
	end

	package.preload['lovely'] = function()
		local lovely_vars = {}
		local save_dir = love.filesystem.getSaveDirectory() or ''
		local mod_dir_abs = save_dir .. '/Mods'
		local log_file_abs = save_dir .. '/Mods/lovely/logs/web.log'

		pcall(function()
			love.filesystem.createDirectory('Mods')
			love.filesystem.createDirectory('Mods/lovely')
			love.filesystem.createDirectory('Mods/lovely/logs')
			if not love.filesystem.getInfo('Mods/lovely/logs/web.log') then
				love.filesystem.write('Mods/lovely/logs/web.log', '')
			end
		end)

		return {
			version = '0.9.0-web',
			mod_dir = mod_dir_abs,
			log_file = log_file_abs,
			get_var = function(name) return lovely_vars[name] end,
			set_var = function(name, val) lovely_vars[name] = tostring(val); return true end,
			remove_var = function(name) local v = lovely_vars[name]; lovely_vars[name] = nil; return v end,
			reload_patches = function() return true end,
		}
	end

	local searcher_installed = false
	for _, searcher in ipairs(searchers) do
		if searcher == _G.__SMODS_WEB_SEARCHER__ then
			searcher_installed = true
			break
		end
	end

	if not searcher_installed then
		_G.__SMODS_WEB_SEARCHER__ = function(module_name)
			if string.sub(module_name, 1, 6) ~= 'SMODS.' then return nil end

			local relative = string.gsub(string.sub(module_name, 7), '%.', '/') .. '.lua'
			local full_path = nil
			local candidate_1 = SMODS_WEB_ROOT .. relative
			local candidate_2 = SMODS_WEB_ROOT .. 'src/' .. relative

			if love.filesystem.getInfo(candidate_1) then
				full_path = candidate_1
			elseif love.filesystem.getInfo(candidate_2) then
				full_path = candidate_2
			else
				return nil
			end

			local is_preflight_core = (module_name == 'SMODS.preflight.core')
			local loader, load_err = smods_load_chunk_from_path(
				full_path,
				string.format('=[%s "%s"]', module_name, relative),
				is_preflight_core
			)

			if not loader then
				return "\n\t[SMODS web] failed loading " .. module_name .. ": " .. tostring(load_err)
			end

			return loader, full_path
		end
		table.insert(searchers, 1, _G.__SMODS_WEB_SEARCHER__)
	end

	_G.__SMODS_LOVELY_PATH__ = SMODS_WEB_ROOT

	local ok_core, core_err = smods_web_xpcall('require_preflight_core', function()
		return require('SMODS.preflight.core')
	end)
	if not ok_core then
		smods_web_log('preflight core failed:', tostring(core_err))
		return false
	end

	local ok_loader, loader_or_err = smods_web_xpcall('require_preflight_loader', function()
		return require('SMODS.preflight.loader')
	end)
	if not ok_loader then
		smods_web_log('preflight loader failed:', tostring(loader_or_err))
		return false
	end

	local ok_smods_core, smods_core_err = smods_web_xpcall('require_smods_core', function()
		return require('SMODS.core')
	end)
	if not ok_smods_core then
		smods_web_log('SMODS core failed:', tostring(smods_core_err))
		return false
	end

	if loader_or_err and loader_or_err.initSteamodded then
		local ok_init, init_err = smods_web_xpcall('initSteamodded', loader_or_err.initSteamodded)
		if not ok_init then
			smods_web_log('Steamodded init failed:', tostring(init_err))
			return false
		end
	end

	SMODS_WEB_BOOT_DONE = true
	smods_web_log('Steamodded bootstrap complete')
	return true
end

local function read_local_mod_toggles_boot()
	local out = {}
	local path = 'webbridge/local_mod_toggles.txt'
	if not love.filesystem.getInfo(path) then return out end
	local raw = love.filesystem.read(path) or ''
	if raw == '' then return out end
	raw = raw:gsub('\r', '')
	for line in string.gmatch(raw, '([^\n]+)') do
		local id, state = line:match('^([^\t]+)\t([01])$')
		if id and state then out[id] = (state == '1') end
	end
	return out
end

-- Use RandomLua for deterministic/true randomness if available
local ok_randomlua, RandomLua = pcall(require, 'engine.randomlua')
if ok_randomlua and RandomLua and type(RandomLua.set_as_global) == 'function' then
	RandomLua.set_as_global()
	-- By default, don't reseed the global RNG deterministically every run.
	-- If a deterministic seed is desired (for reproducible behavior), set
	-- G.F_DETERMINISTIC_RNG = true before startup.
	if type(math.randomseed) == 'function' then
		if G.F_DETERMINISTIC_RNG then
			math.randomseed(G.SEED)
		else
			-- Mix the configured seed with a time-varying value so runs differ
			local t = (os and os.time and os.time()) or 0
			local offset = math.floor((love and love.timer and love.timer.getTime and love.timer.getTime() or 0) * 1000) % 1000000
			math.randomseed((G.SEED or 0) + t + offset)
		end
	end
else
	-- fallback to builtin RNG; behave the same re: deterministic flag
	if G.F_DETERMINISTIC_RNG then
		math.randomseed(G.SEED)
	else
		local t = (os and os.time and os.time()) or 0
		local offset = math.floor((love and love.timer and love.timer.getTime and love.timer.getTime() or 0) * 1000) % 1000000
		math.randomseed((G.SEED or 0) + t + offset)
	end
end

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0
	local dt_smooth = 1/100
	local run_time = 0

	-- Main loop time.
	return function()
		run_time = love.timer.getTime()
		-- Process events.
		if love.event and G and G.CONTROLLER then
			love.event.pump()
			local _n,_a,_b,_c,_d,_e,_f,touched
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				if name == 'touchpressed' then
					touched = true
				elseif name == 'mousepressed' then 
					_n,_a,_b,_c,_d,_e,_f = name,a,b,c,d,e,f
				else
					love.handlers[name](a,b,c,d,e,f)
				end
			end
			if _n then 
				love.handlers['mousepressed'](_a,_b,_c,touched)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end
		dt_smooth = math.min(0.8*dt_smooth + 0.2*dt, 0.1)
		-- Call update and draw
		if love.update then love.update(dt_smooth) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			if love.draw then love.draw() end
			love.graphics.present()
		end

		run_time = math.min(love.timer.getTime() - run_time, 0.1)
		G.FPS_CAP = G.FPS_CAP or 500
		if run_time < 1./G.FPS_CAP then love.timer.sleep(1./G.FPS_CAP - run_time) end
	end
end

function love.load() 
	if IS_WEB then
		print('[SMODS WEB] disabled: native-only mode (no Steamodded runtime bootstrap)')
	end

	print("[DEBUG] love.load() START")
	G:start_up()
	print("[DEBUG] G:start_up() COMPLETE")

	--Set the mouse to invisible immediately, this visibility is handled in the G.CONTROLLER
	love.mouse.setVisible(false)
	
	-- Initialize virtual cursor system for web with pointer lock
	if IS_WEB then
		G.VIRTUAL_CURSOR = {
			enabled = false,
			x = love.graphics.getWidth() / 2,
			y = love.graphics.getHeight() / 2,
			image = nil,
			scale = 0.5  -- Scale down the cursor for display
		}
		
		-- Load cursor image from resources
		local cursor_path = "resources/textures/2x/Cursor.png"
		local success, err = pcall(function()
			if love.filesystem.getInfo(cursor_path) then
				G.VIRTUAL_CURSOR.image = love.graphics.newImage(cursor_path)
				print("[DEBUG] Virtual cursor image loaded from " .. cursor_path)
			else
				print("[DEBUG] Virtual cursor image not found at " .. cursor_path)
			end
		end)
		if not success then
			print("[DEBUG] Error loading cursor image: " .. tostring(err))
		end
		
		-- Wrap the original love.mouse.getPosition
		local original_getPosition = love.mouse.getPosition
		love.mouse.getPosition = function()
			if G.VIRTUAL_CURSOR and G.VIRTUAL_CURSOR.enabled then
				return G.VIRTUAL_CURSOR.x, G.VIRTUAL_CURSOR.y
			end
			return original_getPosition()
		end
		
		print("[DEBUG] Virtual cursor system initialized")
	end
	
	print("[DEBUG] love.load() COMPLETE")
end

function love.quit()
	--Steam integration
	if G.SOUND_MANAGER and G.SOUND_MANAGER.channel then 
		G.SOUND_MANAGER.channel:push({type = 'stop'}) 
	end
	if G.STEAM then G.STEAM:shutdown() end
end

function love.update( dt )
	--Perf monitoring checkpoint
    timer_checkpoint(nil, 'update', true)
	-- Only print state info every 60 frames when debugging
	if G.DEBUG and G.F_VERBOSE then
		if not G.debug_frame_count then G.debug_frame_count = 0 end
		G.debug_frame_count = G.debug_frame_count + 1
		if G.debug_frame_count % 60 == 0 then
			print("[DEBUG] love.update() dt=" .. tostring(dt) .. " | STATE=" .. tostring(G.STATE) .. " | STAGE=" .. tostring(G.STAGE))
		end
	end
    G:update(dt)
end

function love.draw()
	--Perf monitoring checkpoint
    timer_checkpoint(nil, 'draw', true)
	G:draw()
end

function love.keypressed(key)
	-- On web builds, first user gesture must resume the AudioContext. Use a near-silent sound to unlock audio.
	if G and G.IS_WEB and not G.audio_unlocked then
		G.audio_unlocked = true
		-- audio unlock gesture (log removed)
		pcall(function() play_sound('whoosh1', 1, 0.001) end)
		-- Ensure music sources are created / restarted after the unlock so browsers actually play streamed/static music
		pcall(function()
			RESTART_MUSIC({sound_settings = G.SETTINGS.SOUND, dt = 0.016, pitch_mod = G.PITCH_MOD, state = G.STATE, overlay_menu = not not G.OVERLAY_MENU, splash_vol = G.SPLASH_VOL})
		end)
	end
	if not _RELEASE_MODE and G.keybind_mapping[key] then love.gamepadpressed(G.CONTROLLER.keyboard_controller, G.keybind_mapping[key])
	else
		G.CONTROLLER:set_HID_flags('mouse')
		G.CONTROLLER:key_press(key)
	end
end

function love.keyreleased(key)
	if not _RELEASE_MODE and G.keybind_mapping[key] then love.gamepadreleased(G.CONTROLLER.keyboard_controller, G.keybind_mapping[key])
	else
		G.CONTROLLER:set_HID_flags('mouse')
		G.CONTROLLER:key_release(key)
	end
end

function love.gamepadpressed(joystick, button)
	button = G.button_mapping[button] or button
	G.CONTROLLER:set_gamepad(joystick)
    G.CONTROLLER:set_HID_flags('button', button)
    G.CONTROLLER:button_press(button)

	-- Unlock audio on first gamepad input for web builds
	if G and G.IS_WEB and not G.audio_unlocked then
		G.audio_unlocked = true
		-- audio unlock gesture (log removed)
		pcall(function() play_sound('whoosh1', 1, 0.001) end)
		-- Restart/create music after unlock
		pcall(function()
			RESTART_MUSIC({sound_settings = G.SETTINGS.SOUND, dt = 0.016, pitch_mod = G.PITCH_MOD, state = G.STATE, overlay_menu = not not G.OVERLAY_MENU, splash_vol = G.SPLASH_VOL})
		end)
	end
end

function love.gamepadreleased(joystick, button)
	button = G.button_mapping[button] or button
    G.CONTROLLER:set_gamepad(joystick)
    G.CONTROLLER:set_HID_flags('button', button)
    G.CONTROLLER:button_release(button)
end

function love.mousepressed(x, y, button, touch)
    -- Use virtual cursor position if enabled
    if IS_WEB and G.VIRTUAL_CURSOR and G.VIRTUAL_CURSOR.enabled then
        x, y = G.VIRTUAL_CURSOR.x, G.VIRTUAL_CURSOR.y
    end
    
	-- Unlock audio on first mouse/touch click for web builds
	if G and G.IS_WEB and not G.audio_unlocked then
		G.audio_unlocked = true
		-- audio unlock gesture (log removed)
		pcall(function() play_sound('whoosh1', 1, 0.001) end)
		-- Restart/create music after unlock (safe call)
		pcall(function()
			RESTART_MUSIC({sound_settings = G.SETTINGS.SOUND, dt = 0.016, pitch_mod = G.PITCH_MOD, state = G.STATE, overlay_menu = not not G.OVERLAY_MENU, splash_vol = G.SPLASH_VOL})
		end)
	end
	G.CONTROLLER:set_HID_flags(touch and 'touch' or 'mouse')
    if button == 1 then 
		G.CONTROLLER:queue_L_cursor_press(x, y)
	end
	if button == 2 then
		G.CONTROLLER:queue_R_cursor_press(x, y)
	end
end


function love.mousereleased(x, y, button)
    -- Use virtual cursor position if enabled
    if IS_WEB and G.VIRTUAL_CURSOR and G.VIRTUAL_CURSOR.enabled then
        x, y = G.VIRTUAL_CURSOR.x, G.VIRTUAL_CURSOR.y
    end
    
    if button == 1 then G.CONTROLLER:L_cursor_release(x, y) end
end

function love.mousemoved(x, y, dx, dy, istouch)
	G.CONTROLLER.last_touch_time = G.CONTROLLER.last_touch_time or -1
	if next(love.touch.getTouches()) ~= nil then
		G.CONTROLLER.last_touch_time = G.TIMERS.UPTIME
	end
	G.CONTROLLER:set_HID_flags(G.CONTROLLER.last_touch_time > G.TIMERS.UPTIME - 0.2 and 'touch' or 'mouse')
    
    -- Update virtual cursor on web
    if IS_WEB and G.VIRTUAL_CURSOR then
        -- Use movement delta for pointer lock
        if dx and dy and (dx ~= 0 or dy ~= 0) then
            -- Apply sensitivity multiplier (50 = 1x, 100 = 2x, 10 = 0.2x)
            local sensitivity = (G.SETTINGS and G.SETTINGS.mouse_sensitivity or 50) / 50
            G.VIRTUAL_CURSOR.x = G.VIRTUAL_CURSOR.x + (dx * sensitivity)
            G.VIRTUAL_CURSOR.y = G.VIRTUAL_CURSOR.y + (dy * sensitivity)
            
            -- Clamp to screen bounds
            local w, h = love.graphics.getDimensions()
            G.VIRTUAL_CURSOR.x = math.max(0, math.min(w, G.VIRTUAL_CURSOR.x))
            G.VIRTUAL_CURSOR.y = math.max(0, math.min(h, G.VIRTUAL_CURSOR.y))
            
            -- Enable virtual cursor when we get movement deltas (pointer lock active)
            G.VIRTUAL_CURSOR.enabled = true
            
            -- Use virtual cursor position
            x, y = G.VIRTUAL_CURSOR.x, G.VIRTUAL_CURSOR.y
        else
            -- No delta means normal mouse mode
            G.VIRTUAL_CURSOR.enabled = false
            G.VIRTUAL_CURSOR.x = x
            G.VIRTUAL_CURSOR.y = y
        end
    end
    
    -- Store the mouse position
    G.CONTROLLER.cursor_position.x = x
    G.CONTROLLER.cursor_position.y = y
end

function love.joystickaxis( joystick, axis, value )
    if math.abs(value) > 0.2 and joystick:isGamepad() then
		G.CONTROLLER:set_gamepad(joystick)
        G.CONTROLLER:set_HID_flags('axis')
    end
end

function love.errhand(msg)
	if G.F_NO_ERROR_HAND then return end
	msg = tostring(msg)

	if G.SETTINGS.crashreports and _RELEASE_MODE and G.F_CRASH_REPORTS then 
		local http_thread = love.thread.newThread([[
			local https = require('https')
			CHANNEL = love.thread.getChannel("http_channel")

			while true do
				--Monitor the channel for any new requests
				local request = CHANNEL:demand()
				if request then
					https.request(request)
				end
			end
		]])
		local http_channel = love.thread.getChannel('http_channel')
		http_thread:start()
		local httpencode = function(str)
			local char_to_hex = function(c)
				return string.format("%%%02X", string.byte(c))
			end
			str = str:gsub("\n", "\r\n"):gsub("([^%w _%%%-%.~])", char_to_hex):gsub(" ", "+")
			return str
		end
		

		local error = msg
		local file = string.sub(msg, 0,  string.find(msg, ':'))
		local function_line = string.sub(msg, string.len(file)+1)
		function_line = string.sub(function_line, 0, string.find(function_line, ':')-1)
		file = string.sub(file, 0, string.len(file)-1)
		local trace = debug.traceback()
		local boot_found, func_found = false, false
		for l in string.gmatch(trace, "(.-)\n") do
			if string.match(l, "boot.lua") then
				boot_found = true
			elseif boot_found and not func_found then
				func_found = true
				trace = ''
				function_line = string.sub(l, string.find(l, 'in function')+12)..' line:'..function_line
			end

			if boot_found and func_found then 
				trace = trace..l..'\n'
			end
		end

		http_channel:push('https://958ha8ong3.execute-api.us-east-2.amazonaws.com/?error='..httpencode(error)..'&file='..httpencode(file)..'&function_line='..httpencode(function_line)..'&trace='..httpencode(trace)..'&version='..(G.VERSION))
	end

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
	local font = love.graphics.setNewFont("resources/fonts/m6x11plus.ttf", 20)

	love.graphics.clear(G.C.BLACK)
	love.graphics.origin()


	local p = 'Oops! Something went wrong:\n'..msg..'\n\n'..(not _RELEASE_MODE and debug.traceback() or G.SETTINGS.crashreports and
		'Since you are opted in to sending crash reports, LocalThunk HQ was sent some useful info about what happened.\nDon\'t worry! There is no identifying or personal information. If you would like\nto opt out, change the \'Crash Report\' setting to Off' or
		'Crash Reports are set to Off. If you would like to send crash reports, please opt in in the Game settings.\nThese crash reports help us avoid issues like this in the future')

	local function draw()
		local pos = love.window.toPixels(70)
		love.graphics.push()
		love.graphics.clear(G.C.BLACK)
		love.graphics.setColor(1., 1., 1., 1.)
		love.graphics.printf(p, font, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.pop()
		love.graphics.present()

	end

	while true do
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			elseif e == "keypressed" and a == "escape" then
				return
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end

function love.resize(w, h)
	if w/h < 1 then --Dont allow the screen to be too square, since pop in occurs above and below screen
		h = w/1
	end

	--When the window is resized, this code resizes the Canvas, then places the 'room' or gamearea into the middle without streching it
	if w/h < G.window_prev.orig_ratio then
		G.TILESCALE = G.window_prev.orig_scale*w/G.window_prev.w
	else
		G.TILESCALE = G.window_prev.orig_scale*h/G.window_prev.h
	end

	if G.ROOM then
		G.ROOM.T.w = G.TILE_W
		G.ROOM.T.h = G.TILE_H
		G.ROOM_ATTACH.T.w = G.TILE_W
		G.ROOM_ATTACH.T.h = G.TILE_H		

		if w/h < G.window_prev.orig_ratio then
			G.ROOM.T.x = G.ROOM_PADDING_W
			G.ROOM.T.y = (h/(G.TILESIZE*G.TILESCALE) - (G.ROOM.T.h+G.ROOM_PADDING_H))/2 + G.ROOM_PADDING_H/2
		else
			G.ROOM.T.y = G.ROOM_PADDING_H
			G.ROOM.T.x = (w/(G.TILESIZE*G.TILESCALE) - (G.ROOM.T.w+G.ROOM_PADDING_W))/2 + G.ROOM_PADDING_W/2
		end

		G.ROOM_ORIG = {
            x = G.ROOM.T.x,
            y = G.ROOM.T.y,
            r = G.ROOM.T.r
        }

		if G.buttons then G.buttons:recalculate() end
		if G.HUD then G.HUD:recalculate() end
	end

	G.WINDOWTRANS = {
		x = 0, y = 0,
		w = G.TILE_W+2*G.ROOM_PADDING_W, 
		h = G.TILE_H+2*G.ROOM_PADDING_H,
		real_window_w = w,
		real_window_h = h
	}

	G.CANV_SCALE = 1

	if love.system.getOS() == 'Windows' and false then --implement later if needed
		local render_w, render_h = love.window.getDesktopDimensions(G.SETTINGS.WINDOW.selcted_display)
		local unscaled_dims = love.window.getFullscreenModes(G.SETTINGS.WINDOW.selcted_display)[1]

		local DPI_scale = math.floor((0.5*unscaled_dims.width/render_w + 0.5*unscaled_dims.height/render_h)*500 + 0.5)/500

		if DPI_scale > 1.1 then
			G.CANV_SCALE = 1.5

			G.AA_CANVAS = love.graphics.newCanvas(G.WINDOWTRANS.real_window_w*G.CANV_SCALE, G.WINDOWTRANS.real_window_h*G.CANV_SCALE, {type = '2d', readable = true})
			G.AA_CANVAS:setFilter('linear', 'linear')
		else
			G.AA_CANVAS = nil
		end
	end

	G.CANVAS = love.graphics.newCanvas(w*G.CANV_SCALE, h*G.CANV_SCALE, {type = '2d', readable = true})
	G.CANVAS:setFilter('linear', 'linear')
end 
