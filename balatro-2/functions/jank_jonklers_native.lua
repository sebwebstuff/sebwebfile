local JANK_MOD_ROOT = 'tools/extracted/JankJonklers/'
local JANK_JOKERS_FILE = JANK_MOD_ROOT .. 'JankJonklers.lua'
local JANK_CHALLENGES_FILE = JANK_MOD_ROOT .. 'JankChallenges.lua'

local function jank_make_loc_entry(loc)
    if type(loc) ~= 'table' then return nil end
    local out = {
        name = loc.name,
        text = loc.text or {}
    }
    if type(loc_parse_string) == 'function' then
        out.text_parsed = {}
        for _, line in ipairs(out.text) do
            out.text_parsed[#out.text_parsed + 1] = loc_parse_string(line)
        end
        out.name_parsed = {}
        for _, line in ipairs({out.name}) do
            out.name_parsed[#out.name_parsed + 1] = loc_parse_string(line)
        end
    end
    return out
end

local function jank_resolve_sprite_path(slug)
    if type(slug) ~= 'string' or slug == '' then return nil end
    local file = 'j_' .. slug .. '.png'
    local texture_scale = (G and G.SETTINGS and G.SETTINGS.GRAPHICS and tonumber(G.SETTINGS.GRAPHICS.texture_scaling)) or 1
    local preferred_dir = texture_scale >= 2 and 'assets/2x/' or 'assets/1x/'
    local fallback_dir = preferred_dir == 'assets/2x/' and 'assets/1x/' or 'assets/2x/'
    local candidates = {
        JANK_MOD_ROOT .. file,
        JANK_MOD_ROOT .. preferred_dir .. file,
        JANK_MOD_ROOT .. fallback_dir .. file,
    }
    for i = 1, #candidates do
        if love.filesystem.getInfo(candidates[i]) then
            return candidates[i]
        end
    end
    return nil
end

local function jank_apply_sprite_atlas_overrides()
    if not (G and G.P_CENTERS) then return end
    _G.__SMODS_NATIVE_SPRITES = _G.__SMODS_NATIVE_SPRITES or {}

    local keys = {}
    if type(get_native_mod_center_keys) == 'function' then
        keys = get_native_mod_center_keys('jank_jonklers')
    end

    for i = 1, #keys do
        local key = keys[i]
        local center = G.P_CENTERS[key]
        if center and center.set == 'Joker' then
            local slug = string.sub(key, 3)
            local sprite_path = jank_resolve_sprite_path(slug)
            if sprite_path then
                _G.__SMODS_NATIVE_SPRITES[key] = {
                    name = key,
                    path = sprite_path,
                    px = 71,
                    py = 95,
                }
                center.atlas = key
                if type(ensure_native_smods_atlas) == 'function' then
                    ensure_native_smods_atlas(key)
                end
            end

            if center.loc_txt then
                local loc = jank_make_loc_entry(center.loc_txt)
                if loc then
                    center.loc_txt = loc
                    center.name = loc.name or center.name
                    if G.localization and G.localization.descriptions then
                        G.localization.descriptions.Joker = G.localization.descriptions.Joker or {}
                        G.localization.descriptions.Joker[key] = loc
                    end
                end
            end
        end
    end
end

local function jank_run_source(path)
    local source = love.filesystem.read(path)
    if not source or source == '' then
        return false, 'missing or empty source: ' .. tostring(path)
    end

    local chunk, load_err = loadstring(source, '@' .. path)
    if not chunk then
        return false, 'compile failed: ' .. tostring(load_err)
    end

    local ok_run, run_err = xpcall(chunk, function(err)
        return tostring(err) .. '\n' .. debug.traceback('', 2)
    end)
    if not ok_run then
        return false, 'runtime failed: ' .. tostring(run_err)
    end

    return true
end

function init_jank_jonklers_native_content()
    if _G.__JANK_JONKLERS_NATIVE_LOADED__ then
        return true
    end

    if not love.filesystem.getInfo(JANK_JOKERS_FILE) then
        return false
    end

    install_smods_native_compat()
    register_native_smods_mod('jank_jonklers', JANK_MOD_ROOT)
    register_native_smods_mod('JankJonklersMod', JANK_MOD_ROOT)
    register_native_smods_mod('JankChallenges', JANK_MOD_ROOT)
    set_native_smods_active_mod('jank_jonklers')

    local ok_jokers, jokers_err = jank_run_source(JANK_JOKERS_FILE)
    if not ok_jokers then
        print('[JankJonklers] ' .. tostring(jokers_err))
        set_native_smods_active_mod(nil)
        return false
    end

    if love.filesystem.getInfo(JANK_CHALLENGES_FILE) then
        local ok_challenges, challenges_err = jank_run_source(JANK_CHALLENGES_FILE)
        if not ok_challenges then
            print('[JankChallenges] ' .. tostring(challenges_err))
            set_native_smods_active_mod(nil)
            return false
        end
    end

    local init_localization_original = init_localization
    local localization_guard = false
    init_localization = function(...)
        localization_guard = true
        return true
    end

    if SMODS and SMODS.INIT and type(SMODS.INIT.JankJonklersMod) == 'function' then
        local ok_init_j, init_err_j = xpcall(function()
            SMODS.INIT.JankJonklersMod()
        end, function(err)
            return tostring(err) .. '\n' .. debug.traceback('', 2)
        end)
        if not ok_init_j then
            print('[JankJonklers] init failed: ' .. tostring(init_err_j))
            init_localization = init_localization_original
            set_native_smods_active_mod(nil)
            return false
        end
    end

    if SMODS and SMODS.INIT and type(SMODS.INIT.JankChallenges) == 'function' then
        local ok_init_c, init_err_c = xpcall(function()
            SMODS.INIT.JankChallenges()
        end, function(err)
            return tostring(err) .. '\n' .. debug.traceback('', 2)
        end)
        if not ok_init_c then
            print('[JankChallenges] init failed: ' .. tostring(init_err_c))
            init_localization = init_localization_original
            set_native_smods_active_mod(nil)
            return false
        end
    end

    init_localization = init_localization_original
    if localization_guard then
        print('[JankJonklers] Ignored extracted init_localization() call during startup')
    end

    if type(apply_native_smods_localization) == 'function' then
        pcall(function()
            apply_native_smods_localization()
        end)
    end

    jank_apply_sprite_atlas_overrides()

    set_native_smods_active_mod(nil)
    _G.__JANK_JONKLERS_NATIVE_LOADED__ = true
    return true
end