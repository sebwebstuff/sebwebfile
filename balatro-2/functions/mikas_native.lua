local MIKAS_MOD_ROOT = 'tools/extracted/MikasModCollection/'
local MIKAS_SOURCE_FILE = MIKAS_MOD_ROOT .. 'MikasModCollection.lua'

local function mikas_copy(value)
    if type(value) ~= 'table' then return value end
    local out = {}
    for k, v in pairs(value) do
        out[k] = mikas_copy(v)
    end
    return out
end

local function mikas_next_center_order(set_name)
    local max_order = 0
    if G and G.P_CENTERS then
        for _, center in pairs(G.P_CENTERS) do
            if center and center.set == set_name and type(center.order) == 'number' and center.order > max_order then
                max_order = center.order
            end
        end
    end
    return max_order + 1
end

local function mikas_prepare_loc(loc)
    if type(loc) ~= 'table' then return nil end
    local out = mikas_copy(loc)
    if type(loc_parse_string) == 'function' then
        out.text_parsed = {}
        for _, line in ipairs(out.text or {}) do
            out.text_parsed[#out.text_parsed + 1] = loc_parse_string(line)
        end
        out.name_parsed = {}
        local name_lines = type(out.name) == 'table' and out.name or {out.name}
        for _, line in ipairs(name_lines) do
            out.name_parsed[#out.name_parsed + 1] = loc_parse_string(line)
        end
    end
    return out
end

local function mikas_add_loc(set_name, key, loc)
    if not (G and G.localization and G.localization.descriptions) then return end
    G.localization.descriptions[set_name] = G.localization.descriptions[set_name] or {}
    G.localization.descriptions[set_name][key] = mikas_prepare_loc(loc)
end

local function mikas_register_center_key(key)
    _G.__MIKAS_NATIVE_CENTER_KEYS = _G.__MIKAS_NATIVE_CENTER_KEYS or {}
    local keys = _G.__MIKAS_NATIVE_CENTER_KEYS
    for i = 1, #keys do
        if keys[i] == key then return end
    end
    keys[#keys + 1] = key
end

local function mikas_resolve_sprite_path(file_name)
    if type(file_name) ~= 'string' or file_name == '' then return nil end
    local texture_scale = (G and G.SETTINGS and G.SETTINGS.GRAPHICS and tonumber(G.SETTINGS.GRAPHICS.texture_scaling)) or 1
    local preferred_dir = texture_scale >= 2 and 'assets/2x/' or 'assets/1x/'
    local fallback_dir = preferred_dir == 'assets/2x/' and 'assets/1x/' or 'assets/2x/'

    local candidates = {
        MIKAS_MOD_ROOT .. file_name,
        MIKAS_MOD_ROOT .. preferred_dir .. file_name,
        MIKAS_MOD_ROOT .. fallback_dir .. file_name,
    }

    for i = 1, #candidates do
        if love.filesystem.getInfo(candidates[i]) then
            return candidates[i]
        end
    end

    return nil
end

local function mikas_register_sprite(key, file_name, px, py)
    local path = mikas_resolve_sprite_path(file_name)
    if not path then
        path = mikas_resolve_sprite_path('j_' .. tostring(file_name))
    end
    if not path then
        local prefixed = file_name and ('j_' .. tostring(file_name):gsub('^j_', '')) or nil
        path = mikas_resolve_sprite_path(prefixed)
    end
    if not path then return end

    _G.__MIKAS_NATIVE_SPRITES = _G.__MIKAS_NATIVE_SPRITES or {}
    _G.__MIKAS_NATIVE_SPRITES[key] = {
        name = key,
        path = path,
        px = px or 71,
        py = py or 95,
    }

    if G and G.P_CENTERS then
        local center = G.P_CENTERS[key] or G.P_CENTERS['j_' .. tostring(key)] or G.P_CENTERS['c_' .. tostring(key)]
        if center and (center.set == 'Joker' or center.set == 'Tarot' or center.set == 'Spectral') then
            center.atlas = key
        end
    end
end

function append_mikas_native_asset_atlases(asset_atli)
    if type(asset_atli) ~= 'table' then return end
    local sprites = _G.__MIKAS_NATIVE_SPRITES
    if type(sprites) ~= 'table' then return end

    local existing = {}
    for i = 1, #asset_atli do
        if asset_atli[i] and asset_atli[i].name then
            existing[asset_atli[i].name] = true
        end
    end

    for name, data in pairs(sprites) do
        if not existing[name] and data and data.path and love.filesystem.getInfo(data.path) then
            asset_atli[#asset_atli + 1] = {
                name = name,
                path = data.path,
                px = data.px or 71,
                py = data.py or 95,
            }
            existing[name] = true
        end
    end
end

function ensure_mikas_native_atlas(atlas_name)
    if type(atlas_name) ~= 'string' or atlas_name == '' then return false end
    if G and G.ASSET_ATLAS and G.ASSET_ATLAS[atlas_name] then return true end

    local sprites = _G.__MIKAS_NATIVE_SPRITES
    local data = sprites and sprites[atlas_name]
    if not data or not data.path or not love.filesystem.getInfo(data.path) then return false end

    local px = data.px or 71
    local py = data.py or 95
    local texture_scaling = (G and G.SETTINGS and G.SETTINGS.GRAPHICS and G.SETTINGS.GRAPHICS.texture_scaling) or 1
    local use_mipmaps = not (G and G.IS_WEB)

    local ok_img, image = pcall(love.graphics.newImage, data.path, {mipmaps = use_mipmaps, dpiscale = texture_scaling})
    if not ok_img or not image then
        ok_img, image = pcall(love.graphics.newImage, data.path)
    end
    if not ok_img or not image then return false end

    G.ASSET_ATLAS[atlas_name] = {
        name = atlas_name,
        image = image,
        type = 0,
        px = px,
        py = py,
    }

    return true
end

local function mikas_register_deck(deck)
    local key = string.sub(deck.slug, 1, 2) == 'b_' and deck.slug or ('b_' .. tostring(deck.slug))
    local center = G.P_CENTERS[key] or {}

    center.key = key
    center.name = deck.name or key
    center.set = 'Back'
    center.config = mikas_copy(deck.config or {})
    center.pos = mikas_copy(deck.pos or {x = 0, y = 0})
    center.atlas = (deck.config and deck.config.atlas) or center.atlas or 'centers'
    center.order = center.order or mikas_next_center_order('Back')
    center.stake = center.stake or 1
    center.unlocked = deck.unlocked ~= false
    center.discovered = deck.discovered ~= false

    if deck.loc then
        center.loc_txt = mikas_prepare_loc(deck.loc)
        mikas_add_loc('Back', key, deck.loc)
    end

    G.P_CENTERS[key] = center
    mikas_register_center_key(key)

    return center
end

local function mikas_register_joker(joker)
    local key = string.sub(joker.slug, 1, 2) == 'j_' and joker.slug or ('j_' .. tostring(joker.slug))
    local center = G.P_CENTERS[key] or {}

    center.key = key
    center.name = (joker.loc and joker.loc.name) or joker.ability_name or key
    center.set = 'Joker'
    center.rarity = joker.rarity or center.rarity or 1
    center.cost = joker.cost or center.cost or 0
    center.unlocked = joker.unlocked ~= false
    center.discovered = joker.discovered ~= false
    center.blueprint_compat = joker.blueprint_compat ~= false
    center.eternal_compat = joker.eternal_compat ~= false
    center.pos = mikas_copy(joker.pos or {x = 0, y = 0})
    center.order = center.order or mikas_next_center_order('Joker')
    center.config = mikas_copy(joker.ability or {})
    center.effect = joker.effect
    center.soul_pos = joker.soul_pos
    center._mikas_native = true

    local sprite_key = joker.slug
    center.atlas = sprite_key or 'Joker'

    if joker.loc then
        center.loc_txt = mikas_prepare_loc(joker.loc)
        mikas_add_loc('Joker', key, joker.loc)
    end

    G.P_CENTERS[key] = center
    SMODS.Jokers[key] = center
    SMODS.Jokers[joker.slug] = center
    mikas_register_center_key(key)

    return center
end

local function mikas_register_tarot(tarot)
    local key = string.sub(tarot.slug, 1, 2) == 'c_' and tarot.slug or ('c_' .. tostring(tarot.slug))
    local center = G.P_CENTERS[key] or {}

    center.key = key
    center.name = tarot.name or key
    center.set = 'Tarot'
    center.pos = mikas_copy(tarot.pos or {x = 0, y = 0})
    center.config = mikas_copy(tarot.config or {})
    center.cost = tarot.cost or center.cost or 3
    center.cost_mult = tarot.cost_mult or center.cost_mult or 1
    center.effect = tarot.effect
    center.consumeable = tarot.consumeable ~= false
    center.discovered = tarot.discovered ~= false
    center.unlocked = tarot.unlocked ~= false
    center.order = center.order or mikas_next_center_order('Tarot')
    center._mikas_native = true
    center.atlas = tarot.slug or 'Tarot'

    if tarot.loc then
        center.loc_txt = mikas_prepare_loc(tarot.loc)
        mikas_add_loc('Tarot', key, tarot.loc)
    end

    G.P_CENTERS[key] = center
    SMODS.Tarots[key] = center
    SMODS.Tarots[tarot.slug] = center
    mikas_register_center_key(key)

    return center
end

local function mikas_register_spectral(spectral)
    local key = string.sub(spectral.slug, 1, 2) == 'c_' and spectral.slug or ('c_' .. tostring(spectral.slug))
    local center = G.P_CENTERS[key] or {}

    center.key = key
    center.name = spectral.name or key
    center.set = 'Spectral'
    center.pos = mikas_copy(spectral.pos or {x = 0, y = 0})
    center.config = mikas_copy(spectral.config or {})
    center.cost = spectral.cost or center.cost or 4
    center.effect = spectral.effect
    center.consumeable = spectral.consumeable ~= false
    center.discovered = spectral.discovered ~= false
    center.unlocked = spectral.unlocked ~= false
    center.order = center.order or mikas_next_center_order('Spectral')
    center._mikas_native = true
    center.atlas = spectral.slug or 'Tarot'

    if spectral.loc then
        center.loc_txt = mikas_prepare_loc(spectral.loc)
        mikas_add_loc('Spectral', key, spectral.loc)
    end

    G.P_CENTERS[key] = center
    SMODS.Spectrals[key] = center
    SMODS.Spectrals[spectral.slug] = center
    mikas_register_center_key(key)

    return center
end

local function mikas_install_api()
    _G.SMODS = _G.SMODS or {}
    SMODS.INIT = SMODS.INIT or {}
    SMODS.Jokers = SMODS.Jokers or {}
    SMODS.Tarots = SMODS.Tarots or {}
    SMODS.Spectrals = SMODS.Spectrals or {}

    function SMODS.findModByID(_id)
        return {path = MIKAS_MOD_ROOT}
    end

    function SMODS.end_calculate_context(context)
        return context and context.joker_main
    end

    local sprite_mt = {}
    sprite_mt.__index = sprite_mt
    function sprite_mt:register()
        mikas_register_sprite(self.key, self.file_name, self.px, self.py)
        return self
    end

    local deck_mt = {}
    deck_mt.__index = deck_mt
    function deck_mt:register()
        local center = mikas_register_deck(self)
        self.key = center and center.key or self.key
        return self
    end

    local joker_mt = {}
    joker_mt.__index = joker_mt
    function joker_mt:register()
        local center = mikas_register_joker(self)
        self.key = center and center.key or self.key
        return self
    end

    local tarot_mt = {}
    tarot_mt.__index = tarot_mt
    function tarot_mt:register()
        local center = mikas_register_tarot(self)
        self.key = center and center.key or self.key
        return self
    end

    local spectral_mt = {}
    spectral_mt.__index = spectral_mt
    function spectral_mt:register()
        local center = mikas_register_spectral(self)
        self.key = center and center.key or self.key
        return self
    end

    SMODS.Sprite = SMODS.Sprite or {}
    function SMODS.Sprite:new(key, mod_path, file_name, px, py)
        local sprite = {
            key = key,
            mod_path = mod_path,
            file_name = file_name,
            px = px,
            py = py,
        }
        return setmetatable(sprite, sprite_mt)
    end

    SMODS.Deck = SMODS.Deck or {}
    function SMODS.Deck:new(name, slug, config, pos, loc)
        local deck = {
            name = name,
            slug = slug,
            config = config,
            pos = pos,
            loc = loc,
            unlocked = true,
            discovered = true,
        }
        return setmetatable(deck, deck_mt)
    end

    SMODS.Joker = SMODS.Joker or {}
    function SMODS.Joker:new(ability_name, slug, ability, pos, loc, rarity, cost, unlocked, discovered, blueprint_compat, eternal_compat, effect, atlas, soul_pos)
        local joker = {
            ability_name = ability_name,
            slug = slug,
            ability = ability,
            pos = pos,
            loc = loc,
            rarity = rarity,
            cost = cost,
            unlocked = unlocked,
            discovered = discovered,
            blueprint_compat = blueprint_compat,
            eternal_compat = eternal_compat,
            effect = effect,
            atlas = atlas,
            soul_pos = soul_pos,
        }
        return setmetatable(joker, joker_mt)
    end

    SMODS.Tarot = SMODS.Tarot or {}
    function SMODS.Tarot:new(name, slug, config, pos, loc, cost, cost_mult, effect, consumeable, discovered, atlas)
        local tarot = {
            name = name,
            slug = slug,
            config = config,
            pos = pos,
            loc = loc,
            cost = cost,
            cost_mult = cost_mult,
            effect = effect,
            consumeable = consumeable,
            discovered = discovered,
            unlocked = true,
            atlas = atlas,
        }
        return setmetatable(tarot, tarot_mt)
    end

    SMODS.Spectral = SMODS.Spectral or {}
    function SMODS.Spectral:new(name, slug, config, pos, loc, cost, consumeable, discovered, atlas)
        local spectral = {
            name = name,
            slug = slug,
            config = config,
            pos = pos,
            loc = loc,
            cost = cost,
            consumeable = consumeable,
            discovered = discovered,
            unlocked = true,
            atlas = atlas,
        }
        return setmetatable(spectral, spectral_mt)
    end
end

function get_mikas_native_center_keys()
    local src = _G.__MIKAS_NATIVE_CENTER_KEYS or {}
    local out = {}
    for i = 1, #src do out[i] = src[i] end
    table.sort(out)
    return out
end

function apply_mikas_native_localization()
    if not (G and G.localization and G.localization.descriptions and G.P_CENTERS) then return false end

    local keys = get_mikas_native_center_keys()
    for i = 1, #keys do
        local key = keys[i]
        local center = G.P_CENTERS[key]
        if center and center.loc_txt then
            if center.set == 'Joker' then
                mikas_add_loc('Joker', key, center.loc_txt)
            elseif center.set == 'Tarot' then
                mikas_add_loc('Tarot', key, center.loc_txt)
            elseif center.set == 'Spectral' then
                mikas_add_loc('Spectral', key, center.loc_txt)
            elseif center.set == 'Back' then
                mikas_add_loc('Back', key, center.loc_txt)
            end
        end
    end

    return true
end

function init_mikas_native_content()
    if _G.__MIKAS_NATIVE_LOADED__ then
        return true
    end

    if not love.filesystem.getInfo(MIKAS_SOURCE_FILE) then
        return false
    end

    mikas_install_api()

    local source = love.filesystem.read(MIKAS_SOURCE_FILE)
    if not source or source == '' then
        return false
    end

    local chunk, load_err = loadstring(source, '@' .. MIKAS_SOURCE_FILE)
    if not chunk then
        print('[MikasMods] compile failed: ' .. tostring(load_err))
        return false
    end

    local ok_run, run_err = xpcall(chunk, function(err)
        return tostring(err) .. '\n' .. debug.traceback('', 2)
    end)
    if not ok_run then
        print('[MikasMods] runtime failed: ' .. tostring(run_err))
        return false
    end

    if SMODS and SMODS.INIT and type(SMODS.INIT.MikasModCollection) == 'function' then
        local ok_init, init_err = xpcall(function()
            SMODS.INIT.MikasModCollection()
        end, function(err)
            return tostring(err) .. '\n' .. debug.traceback('', 2)
        end)
        if not ok_init then
            print('[MikasMods] init failed: ' .. tostring(init_err))
            return false
        end
    end

    pcall(function()
        apply_mikas_native_localization()
    end)

    _G.__MIKAS_NATIVE_LOADED__ = true
    return true
end
