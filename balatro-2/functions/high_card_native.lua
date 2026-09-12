local HCM_MOD_ROOT = 'tools/extracted/High_Card_Mod/HighCardMod/'
local HCM_SOURCE_FILE = HCM_MOD_ROOT .. 'HighCard.lua'

local function hcm_is_noisy_info_message(message)
    local text = tostring(message or '')
    text = text:gsub('^%s+', ''):gsub('%s+$', '')
    if text:find('Booster!', 1, true) then return true end
    if text:find('Changed!', 1, true) then return true end
    if text:match('^Ability:%s*') then return true end
    if text:find('Jumbo Arcana Pack', 1, true) then return true end
    if text:find('Low Light Cigarette Pack', 1, true) then return true end
    return false
end

local function install_hcm_popup_safety(vanilla_card_h_popup)
    if not (G and G.UIDEF and type(G.UIDEF.card_h_popup) == 'function') then
        return
    end
    if G.UIDEF.__HCM_POPUP_SAFE_WRAPPED__ then
        return
    end

    local high_card_popup = G.UIDEF.card_h_popup
    G.UIDEF.card_h_popup = function(card)
        -- Hard bypass: High Card's custom booster hover path is unstable in web/collection contexts.
        if card and card.ability and card.ability.set == 'Booster' and type(vanilla_card_h_popup) == 'function' then
            local booster_ok, booster_popup = xpcall(function()
                return vanilla_card_h_popup(card)
            end, function(err)
                return tostring(err) .. '\n' .. debug.traceback('', 2)
            end)
            if booster_ok then
                return booster_popup
            end
            print('[HighCard] vanilla booster popup failed; trying HighCard popup: ' .. tostring(booster_popup))
        end

        local ok, popup_or_err = xpcall(function()
            return high_card_popup(card)
        end, function(err)
            return tostring(err) .. '\n' .. debug.traceback('', 2)
        end)

        if ok then
            return popup_or_err
        end

        print('[HighCard] card_h_popup failed; falling back to vanilla popup: ' .. tostring(popup_or_err))
        if type(vanilla_card_h_popup) == 'function' then
            local fallback_ok, fallback_popup = xpcall(function()
                return vanilla_card_h_popup(card)
            end, function(err)
                return tostring(err) .. '\n' .. debug.traceback('', 2)
            end)
            if fallback_ok then
                return fallback_popup
            end
            print('[HighCard] vanilla card_h_popup fallback also failed: ' .. tostring(fallback_popup))
        end

        return nil
    end

    G.UIDEF.__HCM_POPUP_SAFE_WRAPPED__ = true
end

local function ensure_hcm_xplaying_back_center()
    if not (G and G.P_CENTERS) then return end

    local center = G.P_CENTERS.b_hcm_xplaying or G.P_CENTERS.b_xplaying
    if not center then return end

    center.key = 'b_hcm_xplaying'
    center.name = 'X-Playing Deck'
    center.set = 'Back'
    center.atlas = 'centers'
    center.pos = {x = 1, y = 5}
    center.order = center.order or 18
    center.unlocked = true
    center.discovered = true
    center.omit = false
    center.config = center.config or {}
    center.config.XPlayingDeck = true
    center.config.booster = nil

    -- Keep one canonical Back center key to avoid duplicate deck entries in pool construction.
    G.P_CENTERS.b_hcm_xplaying = center
    if G.P_CENTERS.b_xplaying == center then
        G.P_CENTERS.b_xplaying = nil
    end

    if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Back then
        local back_pool = G.P_CENTER_POOLS.Back
        local found = false
        local i = 1
        while i <= #back_pool do
            local entry = back_pool[i]
            if entry == center or (entry and (entry.key == 'b_hcm_xplaying' or entry.key == 'b_xplaying')) then
                if not found then
                    back_pool[i] = center
                    found = true
                    i = i + 1
                else
                    table.remove(back_pool, i)
                end
            else
                i = i + 1
            end
        end
        if not found then
            back_pool[#back_pool + 1] = center
        end
        table.sort(back_pool, function(a, b)
            return (a.order - (a.unlocked and 100 or 0)) < (b.order - (b.unlocked and 100 or 0))
        end)
    end
end

local function ensure_hcm_xplaying_localization()
    if not (G and G.localization) then return end
    G.localization.descriptions = G.localization.descriptions or {}
    G.localization.descriptions.Back = G.localization.descriptions.Back or {}

    local entry = {
        name = 'X-Playing Deck',
        text = {
            'High Card Mod native MVP:',
            'enables the {C:attention}X-Playing Deck',
            'back design',
        },
    }

    -- Provide both keys as localization aliases for compatibility with old saves/cache.
    G.localization.descriptions.Back.b_hcm_xplaying = entry
    G.localization.descriptions.Back.b_xplaying = entry
end

local function ensure_hcm_lowlight_localization()
    if not (G and G.localization) then return end
    G.localization.descriptions = G.localization.descriptions or {}
    G.localization.descriptions.Other = G.localization.descriptions.Other or {}
    G.localization.misc = G.localization.misc or {}
    G.localization.misc.dictionary = G.localization.misc.dictionary or {}

    -- Always overwrite to avoid stale cached/previously-registered Arcana-style text.
    G.localization.descriptions.Other.p_lowlight_normal = {
        name = 'Cigarette Pack...?',
        text = {
            'Choose {C:attention}#1#{} of up to',
            '{C:attention}#2#{} {C:attention}X-Playing Cards{}',
            'to add to your deck'
        }
    }

    G.localization.misc.dictionary.k_cigarette_pack = 'Cigarette Pack'
end

local function ensure_hcm_lowlight_center()
    if not (G and G.P_CENTERS) then return end

    local center = G.P_CENTERS.p_lowlight_normal
    if not center then
        center = {
            key = 'p_lowlight_normal',
            set = 'Booster',
            name = 'Cigarette Pack...?',
            atlas = 'p_lowlight_normal',
            pos = {x = 0, y = 0},
            cost = 5,
            config = {choose = 1, extra = 3},
            discovered = true,
            unlocked = true,
            kind = 'Celestial',
        }
    end

    center.key = 'p_lowlight_normal'
    center.set = 'Booster'
    center.name = center.name or 'Cigarette Pack...?'
    center.atlas = 'p_lowlight_normal'
    center.pos = center.pos or {x = 0, y = 0}
    center.cost = center.cost or 5
    center.config = center.config or {}
    center.config.choose = center.config.choose or 1
    center.config.extra = center.config.extra or 3
    center.discovered = true
    center.unlocked = true

    G.P_CENTERS.p_lowlight_normal = center

    if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Booster then
        local pool = G.P_CENTER_POOLS.Booster
        local found = false
        local i = 1
        while i <= #pool do
            local entry = pool[i]
            local is_lowlight = entry == center or
                (entry and (entry.key == 'p_lowlight_normal' or entry.atlas == 'p_lowlight_normal' or entry.name == 'Low Light Cigarette Pack' or entry.name == 'Cigarette Pack...?'))
            if is_lowlight then
                if not found then
                    pool[i] = center
                    found = true
                    i = i + 1
                else
                    table.remove(pool, i)
                end
            else
                i = i + 1
            end
        end
        if not found then
            pool[#pool + 1] = center
        end
    end
end

local function install_hcm_lowlight_ui_safety()
    if type(_G.generate_card_ui) ~= 'function' then return end
    if _G.__HCM_LOWLIGHT_UI_SAFE__ then return end

    local original_generate_card_ui = _G.generate_card_ui
    _G.generate_card_ui = function(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end)
        if _c and _c.set == 'Booster' then
            local name = tostring(_c.name or '')
            local looks_like_lowlight =
                _c.key == 'p_lowlight_normal' or
                _c.atlas == 'p_lowlight_normal' or
                name == 'Low Light Cigarette Pack' or
                name == 'Cigarette Pack...?' or
                name:find('Cigarette', 1, true)

            if looks_like_lowlight then
                _c.key = 'p_lowlight_normal'
                _c.name = 'Cigarette Pack...?'
                _c.atlas = 'p_lowlight_normal'
                _c.config = _c.config or {}
                _c.config.choose = _c.config.choose or 1
                _c.config.extra = _c.config.extra or 3
            end
        end

        return original_generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end)
    end

    _G.__HCM_LOWLIGHT_UI_SAFE__ = true
end

local function sync_hcm_xplaying_pool_flag()
    if not (G and G.GAME) then return end
    G.GAME.pool_flags = G.GAME.pool_flags or {}

    local selected_back = G.GAME.selected_back
    local has_xplaying_deck =
        selected_back and
        selected_back.effect and
        selected_back.effect.config and
        selected_back.effect.config.XPlayingDeck == true

    G.GAME.pool_flags['X-Playing Card'] = has_xplaying_deck and true or nil
end

local function install_hcm_pool_flag_sync()
    if _G.__HCM_POOL_FLAG_SYNC_INSTALLED__ then
        sync_hcm_xplaying_pool_flag()
        return
    end

    if type(Back) == 'table' and type(Back.apply_to_run) == 'function' then
        local original_apply_to_run = Back.apply_to_run
        Back.apply_to_run = function(self, ...)
            local out = original_apply_to_run(self, ...)
            sync_hcm_xplaying_pool_flag()
            return out
        end
    end

    if type(_G.get_current_pool) == 'function' then
        local original_get_current_pool = _G.get_current_pool
        _G.get_current_pool = function(...)
            sync_hcm_xplaying_pool_flag()
            return original_get_current_pool(...)
        end
    end

    _G.__HCM_POOL_FLAG_SYNC_INSTALLED__ = true
    sync_hcm_xplaying_pool_flag()
end

function init_high_card_native_content()
    if _G.__HCM_NATIVE_LOADED__ then
        return true
    end

    if not love.filesystem.getInfo(HCM_SOURCE_FILE) then
        return false
    end

    install_smods_native_compat()
    local vanilla_card_h_popup = G and G.UIDEF and G.UIDEF.card_h_popup
    register_native_smods_mod('high_card_mod', HCM_MOD_ROOT)
    register_native_smods_mod('HighCardMod', HCM_MOD_ROOT)
    set_native_smods_active_mod('high_card_mod')

    if not sendInfoMessage then
        function sendInfoMessage(message)
            if hcm_is_noisy_info_message(message) then return end
            print('[HighCard]', tostring(message))
        end
    else
        local existing_send_info = sendInfoMessage
        sendInfoMessage = function(message, ...)
            if hcm_is_noisy_info_message(message) then return end
            return existing_send_info(message, ...)
        end
    end

    if not sendDebugMessage then
        function sendDebugMessage(message)
            print('[HighCard:DEBUG]', tostring(message))
        end
    end

    local source = love.filesystem.read(HCM_SOURCE_FILE)
    if not source or source == '' then
        set_native_smods_active_mod(nil)
        return false
    end

    local chunk, load_err = loadstring(source, '@' .. HCM_SOURCE_FILE)
    if not chunk then
        print('[HighCard] failed to compile source: ' .. tostring(load_err))
        set_native_smods_active_mod(nil)
        return false
    end

    local ok_run, run_err = xpcall(chunk, function(err)
        return tostring(err) .. '\n' .. debug.traceback('', 2)
    end)
    if not ok_run then
        print('[HighCard] failed while executing source: ' .. tostring(run_err))
        set_native_smods_active_mod(nil)
        return false
    end

    if SMODS and SMODS.INIT and type(SMODS.INIT.HighCardMod) == 'function' then
        local ok_init, init_err = xpcall(function()
            SMODS.INIT.HighCardMod()
        end, function(err)
            return tostring(err) .. '\n' .. debug.traceback('', 2)
        end)

        if not ok_init then
            print('[HighCard] init failed: ' .. tostring(init_err))
            set_native_smods_active_mod(nil)
            return false
        end

        ensure_hcm_xplaying_back_center()
        ensure_hcm_xplaying_localization()
        ensure_hcm_lowlight_localization()
        ensure_hcm_lowlight_center()
        install_hcm_lowlight_ui_safety()
        install_hcm_popup_safety(vanilla_card_h_popup)
        install_hcm_pool_flag_sync()
    else
        set_native_smods_active_mod(nil)
        return false
    end

    set_native_smods_active_mod(nil)
    _G.__HCM_NATIVE_LOADED__ = true
    return true
end
