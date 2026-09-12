local MOR_MOD_ROOT = 'tools/extracted/Mor_Jokers/'
local MOR_JOKERS_FILE = MOR_MOD_ROOT .. 'morjokers.lua'
local MOR_TAROTS_FILE = MOR_MOD_ROOT .. 'morjokerTarots.lua'

local MOR_JOKER_OVERRIDES = {
    j_copymachine = {
        name = 'Copy Machine', rarity = 1, cost = 6, pos = {x = 1, y = 0}, atlas = 'MorJokers',
        text = {'Randomly copies the effects of your', 'other {C:attention}Jokers{}'}
    },
    j_mysteryportal = {
        name = 'Mystery Portal', rarity = 1, cost = 4, pos = {x = 6, y = 4}, atlas = 'MorJokers', omit = true,
        text = {'Does something random based on other', '{C:attention}Jokers{}', 'Prepare for a lot of clicking...'}
    },
    j_betterboots = {
        name = 'Better Boots', rarity = 3, cost = 7, pos = {x = 0, y = 2}, atlas = 'MorJokers',
        text = {'Upgrades already upgraded cards by #1#'}
    },
    j_everythingjoker = {
        name = 'Everything Joker', rarity = 2, cost = 6, pos = {x = 1, y = 2}, atlas = 'MorJokers',
        text = {'Played cards give {C:mult}+#2# Mult{}'}
    },
    j_sevenoclocknews = {
        name = "Seven O'Clock News", rarity = 2, cost = 5, pos = {x = 2, y = 2}, atlas = 'MorJokers',
        text = {'Scored {C:attention}7s{} without', 'a seal have a {C:green}#1# in #2#{}', 'chance to recieve a {C:purple}random seal{}.', '{C:inactive}Idea by {C:green}NEWTU{C:inactive} on the Balatro Discord'}
    },
    j_extrabattery = {
        name = 'Extra Battery', rarity = 4, cost = 10, pos = {x = 4, y = 0}, atlas = 'MorJokers',
        text = {'{C:attention}Retrigger all played cards #1# time{}'}
    }
}

local function mor_make_loc_entry(name, text)
    local loc = {name = name, text = text}
    if type(loc_parse_string) == 'function' then
        loc.text_parsed = {}
        for _, line in ipairs(text or {}) do
            loc.text_parsed[#loc.text_parsed + 1] = loc_parse_string(line)
        end
        loc.name_parsed = {}
        for _, line in ipairs({name}) do
            loc.name_parsed[#loc.name_parsed + 1] = loc_parse_string(line)
        end
    end
    return loc
end

local function mor_apply_center_overrides()
    if not (G and G.P_CENTERS) then return end

    if type(ensure_native_smods_atlas) == 'function' then
        ensure_native_smods_atlas('MorJokers')
    end

    for key, override in pairs(MOR_JOKER_OVERRIDES) do
        local center = G.P_CENTERS[key]
        if center then
            center.set = 'Joker'
            center.key = key
            center._native_smods = true
            center.name = override.name
            center.rarity = override.rarity
            center.cost = override.cost
            center.atlas = override.atlas
            center.pos = {x = override.pos.x, y = override.pos.y}
            center.discovered = true
            center.unlocked = true
            center.omit = override.omit == true

            local loc = mor_make_loc_entry(override.name, override.text)
            center.loc_txt = loc

            if G.localization and G.localization.descriptions then
                G.localization.descriptions.Joker = G.localization.descriptions.Joker or {}
                G.localization.descriptions.Joker[key] = loc
            end

            if SMODS and SMODS.Jokers then
                SMODS.Jokers[key] = center
            end
        end
    end
end

local function mor_run_source(path)
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

function init_mor_jokers_native_content()
    if _G.__MOR_JOKERS_NATIVE_LOADED__ then
        return true
    end

    if not love.filesystem.getInfo(MOR_JOKERS_FILE) then
        return false
    end

    install_smods_native_compat()
    register_native_smods_mod('mor_jokers', MOR_MOD_ROOT)
    register_native_smods_mod('morjkrs', MOR_MOD_ROOT)
    register_native_smods_mod('morjokerTarots', MOR_MOD_ROOT)
    set_native_smods_active_mod('mor_jokers')

    local ok_jokers, jokers_err = mor_run_source(MOR_JOKERS_FILE)
    if not ok_jokers then
        print('[MorJokers] ' .. tostring(jokers_err))
        set_native_smods_active_mod(nil)
        return false
    end

    if love.filesystem.getInfo(MOR_TAROTS_FILE) then
        local ok_tarots, tarots_err = mor_run_source(MOR_TAROTS_FILE)
        if not ok_tarots then
            print('[MorJokerTarots] ' .. tostring(tarots_err))
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

    if SMODS and SMODS.INIT and type(SMODS.INIT.MorJokers) == 'function' then
        local ok_init_j, init_err_j = xpcall(function()
            SMODS.INIT.MorJokers()
        end, function(err)
            return tostring(err) .. '\n' .. debug.traceback('', 2)
        end)
        if not ok_init_j then
            print('[MorJokers] init failed: ' .. tostring(init_err_j))
            init_localization = init_localization_original
            set_native_smods_active_mod(nil)
            return false
        end
    end

    if G and G.P_CENTERS and G.P_CENTERS.j_mysteryportal then
        G.P_CENTERS.j_mysteryportal.omit = true
    end

    if SMODS and SMODS.INIT and type(SMODS.INIT.MorJokerTarots) == 'function' then
        local ok_init_t, init_err_t = xpcall(function()
            SMODS.INIT.MorJokerTarots()
        end, function(err)
            return tostring(err) .. '\n' .. debug.traceback('', 2)
        end)
        if not ok_init_t then
            print('[MorJokerTarots] init failed: ' .. tostring(init_err_t))
            init_localization = init_localization_original
            set_native_smods_active_mod(nil)
            return false
        end
    end

    init_localization = init_localization_original
    if localization_guard then
        print('[MorJokers] Ignored extracted init_localization() call during startup')
    end

    mor_apply_center_overrides()

    set_native_smods_active_mod(nil)
    _G.__MOR_JOKERS_NATIVE_LOADED__ = true
    return true
end
