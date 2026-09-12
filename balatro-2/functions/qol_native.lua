local JOKER_DISPLAY_ROOT = 'tools/extracted/jokerdisplay/'
local JOKER_DISPLAY_CONFIG = 'config/JokerDisplay.jkr'

local function qn_read(path)
    return love.filesystem.read(path)
end

local function qn_load_file(path, chunk_name)
    local source = qn_read(path)
    if not source or source == '' then
        return nil, 'missing source: ' .. tostring(path)
    end
    local fn, err = loadstring(source, chunk_name or ('@' .. path))
    if not fn then
        return nil, tostring(err)
    end
    return fn
end

local function qn_merge_table(target, source)
    if type(target) ~= 'table' or type(source) ~= 'table' then return target end
    for k, v in pairs(source) do
        if type(v) == 'table' and type(target[k]) == 'table' then
            qn_merge_table(target[k], v)
        else
            target[k] = v
        end
    end
    return target
end

local function qn_load_joker_display_config(JokerDisplay)
    local default_loader = qn_load_file(JOKER_DISPLAY_ROOT .. 'config.lua', '=[JokerDisplay config.lua]')
    local default_cfg = (default_loader and default_loader()) or {}
    JokerDisplay.config = default_cfg

    if love.filesystem.getInfo(JOKER_DISPLAY_CONFIG) then
        local saved_loader = qn_load_file(JOKER_DISPLAY_CONFIG, '=[JokerDisplay saved config]')
        local ok_saved, saved_cfg = pcall(function()
            return saved_loader and saved_loader() or {}
        end)
        if ok_saved and type(saved_cfg) == 'table' then
            qn_merge_table(JokerDisplay.config, saved_cfg)
        end
    end

    JokerDisplay.save_config = function()
        local ok, data = pcall(function()
            local function serialize(value)
                if type(value) == 'number' then return tostring(value) end
                if type(value) == 'boolean' then return value and 'true' or 'false' end
                if type(value) == 'string' then return string.format('%q', value) end
                if type(value) ~= 'table' then return 'nil' end
                local out = {'{'}
                for k, v in pairs(value) do
                    local key = '[' .. string.format('%q', tostring(k)) .. ']'
                    out[#out + 1] = key .. ' = ' .. serialize(v) .. ','
                end
                out[#out + 1] = '}'
                return table.concat(out, '\n')
            end

            love.filesystem.createDirectory('config')
            local payload = 'return ' .. serialize(JokerDisplay.config or {})
            love.filesystem.write(JOKER_DISPLAY_CONFIG, payload)
            return true
        end)
        return ok and data
    end
end

local function qn_load_joker_display_source()
    if _G.__JOKER_DISPLAY_NATIVE_LOADED__ then return true end
    if not love.filesystem.getInfo(JOKER_DISPLAY_ROOT .. 'config.lua') then return false end

    local JokerDisplay = rawget(_G, 'JokerDisplay')
    if type(JokerDisplay) ~= 'table' then
        JokerDisplay = {}
        _G.JokerDisplay = JokerDisplay
    end

    JokerDisplay.path = JOKER_DISPLAY_ROOT
    JokerDisplay.load_file = function(path, target)
        local full = JOKER_DISPLAY_ROOT .. path
        local chunk, err = qn_load_file(full, ('=[JokerDisplay %s]'):format(target or path))
        assert(chunk, err)
        return chunk
    end

    qn_load_joker_display_config(JokerDisplay)

    JokerDisplay.load_file('src/utils.lua')()
    JokerDisplay.load_file('src/ui.lua')()
    JokerDisplay.load_file('src/display_functions.lua')()
    JokerDisplay.load_file('src/api_helper_functions.lua')()
    JokerDisplay.load_file('src/controller.lua')()
    JokerDisplay.load_file('src/config_tab.lua')()

    local base_main_menu = Game.main_menu
    Game.main_menu = function(self, ...)
        init_localization()
        if not JokerDisplay.Global_Definitions then
            JokerDisplay.Global_Definitions = JokerDisplay.load_file('definitions/global_definitions.lua')() or {}
            JokerDisplay.Definitions = JokerDisplay.load_file('definitions/display_definitions.lua')() or {}
            JokerDisplay.Blind_Definitions = JokerDisplay.load_file('definitions/blind_definitions.lua')() or {}
            JokerDisplay.Edition_Definitions = JokerDisplay.load_file('definitions/edition_definitions.lua')() or {}
        end
        return base_main_menu(self, ...)
    end

    local base_init_localization = init_localization
    init_localization = function(...)
        local ok_en, en_loc = pcall(function()
            return JokerDisplay.load_file('localization/en-us.lua')()
        end)
        if ok_en and G and G.localization then
            qn_merge_table(G.localization, en_loc or {})
        end

        if G and G.SETTINGS and G.SETTINGS.language and G.SETTINGS.language ~= 'en-us' then
            local ok_lang, lang_loc = pcall(function()
                return JokerDisplay.load_file('localization/' .. G.SETTINGS.language .. '.lua')()
            end)
            if ok_lang and G and G.localization then
                qn_merge_table(G.localization, lang_loc or {})
            end
        end

        JokerDisplay.init_loc = true
        return base_init_localization(...)
    end

    JokerDisplay.Global_Definitions = JokerDisplay.load_file('definitions/global_definitions.lua')() or {}
    JokerDisplay.Definitions = JokerDisplay.load_file('definitions/display_definitions.lua')() or {}
    JokerDisplay.Blind_Definitions = JokerDisplay.load_file('definitions/blind_definitions.lua')() or {}
    JokerDisplay.Edition_Definitions = JokerDisplay.load_file('definitions/edition_definitions.lua')() or {}

    _G.__JOKER_DISPLAY_NATIVE_LOADED__ = true
    return true
end

local function qn_install_mobile_card_methods()
    if _G.__MOBILE_LIKE_DRAGGING_CARD_PATCHED__ then return end

    if type(Card) == 'table' then
        local base_can_use_consumeable = Card.can_use_consumeable
        if type(base_can_use_consumeable) == 'function' then
            Card.can_use_consumeable = function(self, any_state, skip_check)
                if not (self and self.ability and self.ability.consumeable) then return false end
                return base_can_use_consumeable(self, any_state, skip_check)
            end
        end

        Card.simple_touch = Card.simple_touch or function()
            return false
        end

        Card.can_long_press = Card.can_long_press or function(self)
            if self.area and (self.area == G.hand or (self.area == G.deck and self.area.cards and self.area.cards[1] == self)) then
                return true
            end
            return false
        end

        Card.can_hover_on_drag = Card.can_hover_on_drag or function()
            return false
        end

        Card.single_tap = Card.single_tap or function(self)
            if self.area and self.area.can_highlight and self.area:can_highlight(self) then
                if (self.area == G.hand) and (G.STATE == G.STATES.HAND_PLAYED) then return end
                if self.highlighted ~= true then
                    self.area:add_to_highlighted(self)
                else
                    self.area:remove_from_highlighted(self)
                    play_sound('cardSlide2', nil, 0.3)
                end
            end
            if self.area and self.area == G.deck and self.area.cards and self.area.cards[1] == self then
                G.FUNCS.deck_info()
            end
            G.MOBILE_VIBRATION_QUEUE = math.max(G.MOBILE_VIBRATION_QUEUE or 0, 1)
        end

        Card.swipe_up = Card.swipe_up or function(self)
            G.MOBILE_VIBRATION_QUEUE = math.max(G.MOBILE_VIBRATION_QUEUE or 0, 2)
            if self.area and self.area == G.hand and self.area.can_highlight and self.area:can_highlight(self) then
                if (self.area == G.hand) and (G.STATE == G.STATES.HAND_PLAYED) then return end
                if self.highlighted ~= true then
                    self.area:add_to_highlighted(self)
                end
            end
            if self.ability and (not self.ability.consumeable) and self.area and self.area == G.pack_cards and G.FUNCS.can_select_card(self) then
                G.FUNCS.use_card({config = {ref_table = self}})
                return
            end
            if self.area and (self.area == G.shop_jokers or self.area == G.shop_booster or self.area == G.shop_vouchers) then
                if G.FUNCS.can_buy_check and G.FUNCS.can_buy_check(self) then
                    if self.ability and (self.ability.set == 'Booster' or self.ability.set == 'Voucher') then
                        G.FUNCS.use_card({config = {ref_table = self}})
                        return
                    end
                    if self.area == G.shop_jokers then
                        G.FUNCS.buy_from_shop({config = {ref_table = self, id = 'buy'}})
                        return
                    end
                end
            end
            if self.ability and self.ability.consumeable and self.area and (self.area == G.consumeables or self.area == G.pack_cards) and self:can_use_consumeable() then
                G.FUNCS.use_card({config = {ref_table = self}})
            end
        end

        Card.swipe_down = Card.swipe_down or function(self)
            G.MOBILE_VIBRATION_QUEUE = math.max(G.MOBILE_VIBRATION_QUEUE or 0, 3)
            if self.area and self.area.can_highlight and self.area:can_highlight(self) then
                if (self.area == G.hand) and (G.STATE == G.STATES.HAND_PLAYED) then return end
                if self.highlighted == true then
                    self.area:remove_from_highlighted(self)
                    play_sound('cardSlide2', nil, 0.3)
                end
            end
            if G.FUNCS.can_buy_and_use_check and G.FUNCS.can_buy_and_use_check(self) then
                G.FUNCS.buy_from_shop({config = {ref_table = self, id = 'buy_and_use'}})
                return
            end
            if self.area and (self.area == G.jokers or self.area == G.consumeables) then
                self:sell_card()
            end
        end
    end

    _G.__MOBILE_LIKE_DRAGGING_CARD_PATCHED__ = true
end

local function qn_install_mobile_fun_checks()
    if not (G and G.FUNCS) then return end

    G.FUNCS.can_buy_check = function(_card)
        local is_cryptid = to_big ~= nil
        if is_cryptid then
            if to_big(_card.cost) > (to_big(G.GAME.dollars) - to_big(G.GAME.bankrupt_at)) and (to_big(_card.cost) > to_big(0)) then
                return false
            end
            return true
        end
        if _card.cost > (G.GAME.dollars - G.GAME.bankrupt_at) and (_card.cost > 0) then
            return false
        end
        return true
    end

    G.FUNCS.can_buy_and_use_check = function(_card)
        local is_cryptid = to_big ~= nil
        if is_cryptid then
            if ((to_big(_card.cost) > to_big(G.GAME.dollars) - to_big(G.GAME.bankrupt_at)) and (to_big(_card.cost) > to_big(0))) or (not _card:can_use_consumeable()) then
                return false
            end
            return true
        end
        if (((_card.cost > G.GAME.dollars - G.GAME.bankrupt_at) and (_card.cost > 0)) or (not _card:can_use_consumeable())) then
            return false
        end
        return true
    end

    G.FUNCS.can_select_card_check = function(_card)
        if _card.ability.set ~= 'Joker' or (_card.edition and _card.edition.negative) or #G.jokers.cards < G.jokers.config.card_limit then
            return true
        end
        return false
    end

    G.FUNCS.check_drag_target_active = function(e)
        if not (e and e.config and e.config.args) then return end
        local args = e.config.args
        if args.active_check and args.active_check(args.card) then
            if (not e.config.pulse_border) or not args.init then
                e.config.pulse_border = true
                e.config.colour = args.colour
                args.text_colour[4] = 1
                e.config.release_func = args.release_func
            end
        else
            if (e.config.pulse_border) or not args.init then
                e.config.pulse_border = nil
                e.config.colour = adjust_alpha(G.C.L_BLACK, 0.9)
                args.text_colour[4] = 0.5
                e.config.release_func = nil
            end
        end
        args.init = true
    end

    if type(_G.drag_target) ~= 'function' then
        _G.drag_target = function(args)
            args = args or {}
            args.text = args.text or {'BUY'}
            args.colour = copy_table(args.colour or G.C.UI.TRANSPARENT_DARK)
            args.cover = args.cover or nil
            args.emboss = args.emboss or nil
            args.active_check = args.active_check or function() return true end
            args.release_func = args.release_func or function() end
            args.text_colour = copy_table(G.C.WHITE)
            args.uibox_config = {
                align = args.align or 'tli',
                offset = args.offset or {x = 0, y = 0},
                major = args.cover or args.major or nil,
            }

            local drag_area_width = (args.T and args.T.w or (args.cover and args.cover.T.w) or 0.001) + (args.cover_padding or 0)
            local text_rows = {}
            for i = 1, #args.text do
                text_rows[#text_rows + 1] = {
                    n = G.UIT.R,
                    config = {align = 'cm', padding = 0.05, maxw = drag_area_width - 0.1},
                    nodes = {{
                        n = G.UIT.O,
                        config = {
                            object = DynaText({
                                scale = args.scale,
                                string = args.text[i],
                                maxw = args.maxw or (drag_area_width - 0.1),
                                colours = {args.text_colour},
                                float = true,
                                shadow = true,
                                silent = not args.noisy,
                                pop_in = 0,
                                pop_in_rate = 6,
                                rotate = args.rotate,
                            })
                        }
                    }}
                }
            end

            args.DT = UIBox{
                T = {0, 0, 0, 0},
                definition = {
                    n = G.UIT.ROOT,
                    config = {
                        align = 'cm',
                        args = args,
                        can_collide = true,
                        hover = true,
                        release_func = args.release_func,
                        func = 'check_drag_target_active',
                        minw = drag_area_width,
                        minh = (args.cover and args.cover.T.h or 0.001) + (args.cover_padding or 0),
                        padding = 0.03,
                        r = 0.1,
                        emboss = args.emboss,
                        colour = G.C.CLEAR,
                    },
                    nodes = text_rows,
                },
                config = args.uibox_config,
            }
            args.DT.attention_text = true

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0,
                blockable = false,
                blocking = false,
                func = function()
                    if not G.CONTROLLER.dragging.target and args.DT then
                        args.DT:remove()
                        return true
                    end
                end,
            }))
        end
    end

    if type(_G.create_drag_target_from_card) ~= 'function' then
        _G.create_drag_target_from_card = function(_card)
            if not _card or not G or G.STAGE ~= G.STAGES.RUN then return end
            if not (G.QOL_FLAGS and G.QOL_FLAGS.mobile_like_dragging) then return end
            if not (G.SETTINGS and G.SETTINGS.enable_action_buttons ~= false) then return end

            G.DRAG_TARGETS = G.DRAG_TARGETS or {
                S_buy = Moveable{T = {x = G.jokers.T.x, y = G.jokers.T.y - 0.1, w = G.consumeables.T.x + G.consumeables.T.w - G.jokers.T.x, h = G.jokers.T.h + 0.6}},
                S_buy_and_use = Moveable{T = {x = G.deck.T.x + 0.2, y = G.deck.T.y - 5.1, w = G.deck.T.w - 0.1, h = 4.5}},
                C_sell = Moveable{T = {x = G.jokers.T.x, y = G.jokers.T.y - 0.2, w = G.jokers.T.w, h = G.jokers.T.h + 0.6}},
                J_sell = Moveable{T = {x = G.consumeables.T.x + 0.3, y = G.consumeables.T.y - 0.2, w = G.consumeables.T.w - 0.3, h = G.consumeables.T.h + 0.6}},
                C_use = Moveable{T = {x = G.deck.T.x + 0.2, y = G.deck.T.y - 5.1, w = G.deck.T.w - 0.1, h = 4.5}},
                P_select = Moveable{T = {x = G.play.T.x, y = G.play.T.y - 2, w = G.play.T.w + 2, h = G.play.T.h + 1}},
            }

            local area_alpha = (tonumber(G.SETTINGS.drag_area_opacity) or 90) / 100
            if _card.area and (_card.area == G.shop_jokers or _card.area == G.shop_vouchers or _card.area == G.shop_booster) then
                local buy_loc = copy_table(localize((_card.area == G.shop_vouchers and 'ml_redeem_target') or (_card.area == G.shop_booster and 'ml_open_target') or 'ml_buy_target'))
                buy_loc[#buy_loc + 1] = '$' .. tostring(_card.cost or 0)
                drag_target({
                    cover = G.DRAG_TARGETS.S_buy,
                    colour = adjust_alpha(G.C.GREEN, area_alpha),
                    text = buy_loc,
                    card = _card,
                    active_check = function(other) return G.FUNCS.can_buy_check(other) end,
                    release_func = function(other)
                        if other.area == G.shop_jokers and G.FUNCS.can_buy_check(other) then
                            G.FUNCS.buy_from_shop({config = {ref_table = other, id = 'buy'}})
                            return
                        elseif other.area == G.shop_vouchers and G.FUNCS.can_buy_check(other) then
                            G.FUNCS.use_card({config = {ref_table = other}})
                        elseif other.area == G.shop_booster and G.FUNCS.can_buy_check(other) then
                            G.FUNCS.use_card({config = {ref_table = other}})
                        end
                    end,
                })

                if G.FUNCS.can_buy_and_use_check(_card) then
                    local buy_use_loc = copy_table(localize('ml_buy_and_use_target'))
                    buy_use_loc[#buy_use_loc + 1] = '$' .. tostring(_card.cost or 0)
                    drag_target({
                        cover = G.DRAG_TARGETS.S_buy_and_use,
                        colour = adjust_alpha(G.C.ORANGE, area_alpha),
                        text = buy_use_loc,
                        card = _card,
                        active_check = function(other) return G.FUNCS.can_buy_and_use_check(other) end,
                        release_func = function(other)
                            if G.FUNCS.can_buy_and_use_check(other) then
                                G.FUNCS.buy_from_shop({config = {ref_table = other, id = 'buy_and_use'}})
                            end
                        end,
                    })
                end
            end

            if _card.area and (_card.area == G.pack_cards) then
                if _card.ability and _card.ability.consumeable and not (_card.ability.set == 'Planet') then
                    drag_target({
                        cover = G.DRAG_TARGETS.C_use,
                        colour = adjust_alpha(G.C.RED, area_alpha),
                        text = {localize('b_use')},
                        card = _card,
                        active_check = function(other) return other:can_use_consumeable() end,
                        release_func = function(other)
                            if other:can_use_consumeable() then
                                G.FUNCS.use_card({config = {ref_table = other}})
                            end
                        end,
                    })
                else
                    local select_cover = (G.SETTINGS.move_select_joker_drag_area and _card.ability and _card.ability.set == 'Joker') and G.DRAG_TARGETS.S_buy or G.DRAG_TARGETS.P_select
                    drag_target({
                        cover = select_cover,
                        colour = adjust_alpha(G.C.GREEN, area_alpha),
                        text = {localize('b_select')},
                        card = _card,
                        active_check = function(other) return G.FUNCS.can_select_card_check(other) end,
                        release_func = function(other)
                            if G.FUNCS.can_select_card_check(other) then
                                G.FUNCS.use_card({config = {ref_table = other}})
                            end
                        end,
                    })
                end
            end

            if _card.area and (_card.area == G.jokers or _card.area == G.consumeables) then
                local sell_loc = copy_table(localize('ml_sell_target'))
                sell_loc[#sell_loc + 1] = '$' .. tostring((_card.facing == 'back' and '?') or _card.sell_cost or 0)
                drag_target({
                    cover = (_card.area == G.consumeables) and G.DRAG_TARGETS.C_sell or G.DRAG_TARGETS.J_sell,
                    colour = adjust_alpha(G.C.GOLD, area_alpha),
                    text = sell_loc,
                    card = _card,
                    active_check = function(other) return other:can_sell_card() end,
                    release_func = function(other) G.FUNCS.sell_card({config = {ref_table = other}}) end,
                })

                if _card.area == G.consumeables then
                    drag_target({
                        cover = G.DRAG_TARGETS.C_use,
                        colour = adjust_alpha(G.C.RED, area_alpha),
                        text = {localize('b_use')},
                        card = _card,
                        active_check = function(other) return other:can_use_consumeable() end,
                        release_func = function(other)
                            if other:can_use_consumeable() then
                                G.FUNCS.use_card({config = {ref_table = other}})
                            end
                        end,
                    })
                end
            end
        end
    end
end

function set_joker_display_enabled(enabled)
    local is_enabled = enabled == true
    _G.__JOKER_DISPLAY_NATIVE_ENABLED__ = is_enabled

    if is_enabled then
        pcall(qn_load_joker_display_source)
    end

    if _G.JokerDisplay and _G.JokerDisplay.config then
        _G.JokerDisplay.config.enabled = is_enabled
    end
    if _G.JokerDisplay then
        _G.JokerDisplay.visible = is_enabled
    end

    if G then
        G.QOL_FLAGS = G.QOL_FLAGS or {}
        G.QOL_FLAGS.joker_display = is_enabled

        if G.jokers and G.jokers.cards then
            for i = 1, #G.jokers.cards do
                local card = G.jokers.cards[i]
                if card and type(card.update_joker_display) == 'function' then
                    pcall(function()
                        card:update_joker_display(true, true, 'toggle')
                    end)
                end
            end
        end
    end
end

function set_mobile_like_dragging_enabled(enabled)
    local is_enabled = enabled == true
    _G.__MOBILE_LIKE_DRAGGING_ENABLED__ = is_enabled

    if is_enabled then
        qn_install_mobile_card_methods()
    end

    if G then
        G.QOL_FLAGS = G.QOL_FLAGS or {}
        G.QOL_FLAGS.mobile_like_dragging = is_enabled

        if G._default_min_click_dist == nil then
            G._default_min_click_dist = G.MIN_CLICK_DIST
        end

        if is_enabled then
            G.MIN_CLICK_DIST = 0.1
            G.SETTINGS.enable_drag_select = (G.SETTINGS.enable_drag_select ~= false)
            G.SETTINGS.enable_action_buttons = (G.SETTINGS.enable_action_buttons ~= false)
            G.SETTINGS.move_select_joker_drag_area = (G.SETTINGS.move_select_joker_drag_area == true)
            G.SETTINGS.drag_area_opacity = tonumber(G.SETTINGS.drag_area_opacity) or 90
            qn_install_mobile_fun_checks()
        else
            G.MIN_CLICK_DIST = G._default_min_click_dist or G.MIN_CLICK_DIST
        end

        if G.CONTROLLER then
            G.CONTROLLER.dragSelectActive = G.CONTROLLER.dragSelectActive or {active = false, mode = nil}
            if is_enabled then
                G.CONTROLLER.last_touch_time = (G.TIMERS and G.TIMERS.UPTIME) or 0
            end
        end
    end
end

function apply_qol_native_mod_toggles(toggles)
    local active = (G and G.ACTIVE_MOD_TOGGLES) or {}
    toggles = toggles or {}

    local mobile_enabled = toggles.mobile_like_dragging
    if mobile_enabled == nil then
        mobile_enabled = active.mobile_like_dragging == true
    end

    local joker_display_enabled = toggles.joker_display
    if joker_display_enabled == nil then
        joker_display_enabled = active.joker_display == true
    end

    set_mobile_like_dragging_enabled(mobile_enabled == true)
    set_joker_display_enabled(joker_display_enabled == true)
end
