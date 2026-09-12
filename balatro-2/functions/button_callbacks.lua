--Moves the tutorial to the next step in queue
--
---@param e {}
--**e** Is the UIE that called this function
G.FUNCS.tut_next = function(e)
  if G.OVERLAY_TUTORIAL then
    G.OVERLAY_TUTORIAL.Jimbo:remove_button()
    G.OVERLAY_TUTORIAL.Jimbo:remove_speech_bubble()
    G.OVERLAY_TUTORIAL.step_complete = false
    G.OVERLAY_TUTORIAL.step = G.OVERLAY_TUTORIAL.step+1
  end
end

--Ensures the compatibility indicator for the Blueprint and Brainstorm Jokers
--matches with any new changes of compatibility determined by the Joker
--
---@param e {}
--**e** Is the UIE that called this function\
--**e.config.ref_table** points to the joker
G.FUNCS.blueprint_compat = function(e)
  if e.config.ref_table.ability.blueprint_compat ~= e.config.ref_table.ability.blueprint_compat_check then 
    if e.config.ref_table.ability.blueprint_compat == 'compatible' then 
        e.config.colour = mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8)
    elseif e.config.ref_table.ability.blueprint_compat == 'incompatible' then
        e.config.colour = mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8)
    end
    e.config.ref_table.ability.blueprint_compat_ui = ' '..localize('k_'..e.config.ref_table.ability.blueprint_compat)..' '
    e.config.ref_table.ability.blueprint_compat_check = e.config.ref_table.ability.blueprint_compat
  end
end

--Sorts G.hand in descending order by suit (spades, hearts, clubs, diamonds, then rank)
--
---@param e {}
--**e** Is the UIE that called this function
G.FUNCS.sort_hand_suit = function(e)
    G.hand:sort('suit desc')
    play_sound('paper1')
end
  
--Sorts G.hand in descending order by rank (rank, then spades, hearts, clubs, diamonds)
--
---@param e {}
--**e** Is the UIE that called this function
G.FUNCS.sort_hand_value = function(e)
    G.hand:sort('desc')
    play_sound('paper1')
end

--Checks if the cost of a non voucher card is greater than what the player can afford and changes the 
--buy button visuals accordingly
--
---@param e {}
--**e** Is the UIE that called this function
G.FUNCS.can_buy = function(e)
    if (e.config.ref_table.cost > G.GAME.dollars - G.GAME.bankrupt_at) and (e.config.ref_table.cost > 0) then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = G.C.ORANGE
        e.config.button = 'buy_from_shop'
    end
    if e.config.ref_parent and e.config.ref_parent.children.buy_and_use then
      if e.config.ref_parent.children.buy_and_use.states.visible then
        e.UIBox.alignment.offset.y = -0.6
      else
        e.UIBox.alignment.offset.y = 0
      end
    end
end

--Checks if the cost of a non voucher card is greater than what the player can afford and changes the 
--buy button visuals accordingly
--
---@param e {}
--**e** Is the UIE that called this function
G.FUNCS.can_buy_and_use = function(e)
    if (((e.config.ref_table.cost > G.GAME.dollars - G.GAME.bankrupt_at) and (e.config.ref_table.cost > 0)) or (not e.config.ref_table:can_use_consumeable())) then
        e.UIBox.states.visible = false
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        if e.config.ref_table.highlighted then
          e.UIBox.states.visible = true
        end
        e.config.colour = G.C.SECONDARY_SET.Voucher
        e.config.button = 'buy_from_shop'
    end
end

--Checks if the cost of a voucher card is greater than what the player can afford and changes the 
--redeem button visuals accordingly
--
---@param e {}
--**e** Is the UIE that called this function
G.FUNCS.can_redeem = function(e)
  if e.config.ref_table.cost > G.GAME.dollars - G.GAME.bankrupt_at then
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
  else
    e.config.colour = G.C.GREEN
    e.config.button = 'use_card'
  end
end

--Checks if the cost of a booster pack is too much 
--adjusts booster button visuals accordingly
--
---@param e {}
--**e** Is the UIE that called this function
G.FUNCS.can_open = function(e)
  if (e.config.ref_table.cost) > 0 and (e.config.ref_table.cost > G.GAME.dollars - G.GAME.bankrupt_at) then
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
  else
    e.config.colour = G.C.GREEN
    e.config.button = 'use_card'
  end
end

--ensures that the HUD blind section is only visible when there is an active blind
--
---@param e {}
--**e** Is the UIE that called this function
G.FUNCS.HUD_blind_visible = function(e)
  if G.GAME.blind and (G.GAME.blind.name ~= '' and G.GAME.blind.blind_set) then
      G.GAME.blind.states.visible = true
  elseif G.GAME.blind then
      G.GAME.blind.states.visible = false
  end
end

--Expands or contracts the 'debuff text' area of the blind HUD when it changes,
--either bigger with a new boss or smaller when it is disabled, or for a smaller blind
--
---@param e {}
--**e** Is the UIE that called this function
G.FUNCS.HUD_blind_debuff = function(e)
  if G.GAME.blind and G.GAME.blind.loc_debuff_text and G.GAME.blind.loc_debuff_text ~= '' then
    if e.parent.config.minh == 0 or e.config.prev_loc ~= G.GAME.blind.loc_debuff_text then  
      e.parent.config.minh = 0.35
      e.config.scale = 0.36
      if G.GAME.blind.loc_debuff_lines[e.config.ref_value] == '' then e.config.scale = 0.0; e.parent.config.minh = 0.001 end
      e.config.prev_loc = G.GAME.blind.loc_debuff_text
      e.UIBox:recalculate(true)
    end
  else
    if e.parent.config.minh > 0 then  
      e.parent.config.minh = 0
      e.config.scale = 0
      e.UIBox:recalculate(true)
    end
  end
end

--Adds the prefix for the debuff text for the wheel blind
--
---@param e {}
--**e** Is the UIE that called this function
G.FUNCS.HUD_blind_debuff_prefix = function(e)
  if (G.GAME.blind and G.GAME.blind.name == 'The Wheel' and not G.GAME.blind.disabled) or
    e.config.id == 'bl_wheel' then
    e.config.ref_table.val = ''..G.GAME.probabilities.normal
    e.config.scale = 0.32
  else
    e.config.ref_table.val = ''
    e.config.scale = 0
  end
end

G.FUNCS.HUD_blind_reward = function(e)
  if G.GAME.modifiers.no_blind_reward and (G.GAME.blind and G.GAME.modifiers.no_blind_reward[G.GAME.blind:get_type()]) then
    if e.config.minh > 0.44 then 
      e.config.minh = 0.4
      e.children[1].config.text = localize('k_no_reward')
      --e.children[2].states.visible = false
      e.UIBox:recalculate(true)
    end
  else
    if e.config.minh < 0.45 then 
      e.config.minh = 0.45
      e.children[1].config.text = localize('k_reward')..': '
      e.children[2].states.visible = true
      e.UIBox:recalculate(true)
    end
  end
end

--Determines if there is a valid save file to load and continue from main menu
--
---@param e {}
--**e** Is the UIE that called this function
G.FUNCS.can_continue = function(e)
  if not e or not e.config or not e.config.func then return nil end

  local can_continue = false
  local savefile = love.filesystem.getInfo(G.SETTINGS.profile..'/'..'save.jkr')

  if savefile ~= nil then
    if type(G.SAVED_GAME) ~= 'table' then
      local raw = get_compressed(G.SETTINGS.profile..'/'..'save.jkr')
      if raw ~= nil then
        local ok_unpack, unpacked = pcall(STR_UNPACK, raw)
        if ok_unpack and type(unpacked) == 'table' then
          G.SAVED_GAME = unpacked
        else
          G.SAVED_GAME = nil
        end
      end
    end

    if type(G.SAVED_GAME) == 'table' and type(G.SAVED_GAME.GAME) == 'table' and type(G.SAVED_GAME.BACK) == 'table' then
      can_continue = true
    end
  end

  e.config.colour = can_continue and G.C.RED or G.C.UI.BACKGROUND_INACTIVE

  if e.config.ref_table and e.config.ref_table.tab_definition_function then
    e.config.button = can_continue and 'change_tab' or nil
  else
    e.config.button = can_continue and 'continue' or nil
  end

  return can_continue or nil
end

G.FUNCS.can_load_profile = function(e)
  if G.SETTINGS.profile == G.focused_profile then
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
  else
    e.config.colour = G.C.BLUE
    e.config.button = 'load_profile'
  end
end

G.FUNCS.load_profile = function(delete_prof_data)
  G.SAVED_GAME = nil
  G.E_MANAGER:clear_queue()
  G.FUNCS.wipe_on()
  G.E_MANAGER:add_event(Event({
    no_delete = true,
    func = function()
      G:delete_run()
      local _name = nil
      if G.PROFILES[G.focused_profile].name and G.PROFILES[G.focused_profile].name ~= '' then
        _name = G.PROFILES[G.focused_profile].name
      end
      if delete_prof_data then G.PROFILES[G.focused_profile] = {} end
      G.DISCOVER_TALLIES = nil
      G.PROGRESS = nil
      G:load_profile(G.focused_profile)
      G.PROFILES[G.focused_profile].name = _name
      G:init_item_prototypes()
      return true
    end
  }))
  G.E_MANAGER:add_event(Event({
    no_delete = true,
    blockable = true, 
    blocking = false,
    func = function()
      G:main_menu()
      G.FILE_HANDLER.force = true
      return true
    end
  }))
  G.FUNCS.wipe_off()
end

G.FUNCS.can_delete_profile = function(e)
  G.CHECK_PROFILE_DATA = G.CHECK_PROFILE_DATA or love.filesystem.getInfo(G.focused_profile..'/'..'profile.jkr')
  if (not G.CHECK_PROFILE_DATA) or e.config.disable_button then
      G.CHECK_PROFILE_DATA = false
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
  else
    e.config.colour = G.C.RED
    e.config.button = 'delete_profile'
  end
end

G.FUNCS.delete_profile = function(e)
  local warning_text = e.UIBox:get_UIE_by_ID('warning_text')
  if warning_text.config.colour ~= G.C.WHITE then 
    warning_text:juice_up()
    warning_text.config.colour = G.C.WHITE
    warning_text.config.shadow = true
    e.config.disable_button = true
    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06, blockable = false, blocking = false, func = function()
      play_sound('tarot2', 0.76, 0.4);return true end}))

    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.35, blockable = false, blocking = false, func = function()
      e.config.disable_button = nil;return true end}))

    play_sound('tarot2', 1, 0.4)
  else
    love.filesystem.remove(G.focused_profile..'/'..'profile.jkr')
    love.filesystem.remove(G.focused_profile..'/'..'save.jkr')
    love.filesystem.remove(G.focused_profile..'/'..'meta.jkr')
    love.filesystem.remove(G.focused_profile..'/'..'unlock_notify.jkr')
    love.filesystem.remove(G.focused_profile..'')
    G.SAVED_GAME = nil
    G.DISCOVER_TALLIES = nil
    G.PROGRESS = nil
    G.PROFILES[G.focused_profile] = {}
    if G.focused_profile == G.SETTINGS.profile then
        G.FUNCS.load_profile(true)
    else
      local tab_but = G.OVERLAY_MENU:get_UIE_by_ID('tab_but_'..G.focused_profile)
      G.FUNCS.change_tab(tab_but)
    end
  end
end

G.FUNCS.can_unlock_all = function(e)
  if G.PROFILES[G.SETTINGS.profile].all_unlocked or e.config.disable_button then
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
  else
    e.config.colour = G.C.GREY
    e.config.button = 'unlock_all'
  end
end

G.FUNCS.unlock_all = function(e)
  local _infotip_object = G.OVERLAY_MENU:get_UIE_by_ID('overlay_menu_infotip')

  if (not _infotip_object.config.set) and (not G.F_NO_ACHIEVEMENTS) then 
    _infotip_object.config.object:remove() 
    _infotip_object.config.object = UIBox{
      definition = overlay_infotip(localize(G.F_TROPHIES and 'ml_unlock_all_trophies' or 'ml_unlock_all_explanation')),
      config = {offset = {x=0,y=0}, align = 'bm', parent = _infotip_object}
    }
    _infotip_object.config.object.UIRoot:juice_up()
    _infotip_object.config.set = true
    e.config.disable_button = true
    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06, blockable = false, blocking = false, func = function()
      play_sound('tarot2', 0.76, 0.4);return true end}))

    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.35, blockable = false, blocking = false, func = function()
      e.config.disable_button = nil;return true end}))

    play_sound('tarot2', 1, 0.4)
  else
    G.PROFILES[G.SETTINGS.profile].all_unlocked = true
    for k, v in pairs(G.P_CENTERS) do
      if not v.demo and not v.wip then 
        v.alerted = true
        v.discovered = true
        v.unlocked = true
      end
    end
    for k, v in pairs(G.P_BLINDS) do
      if not v.demo and not v.wip then 
        v.alerted = true
        v.discovered = true
        v.unlocked = true
      end
    end
    for k, v in pairs(G.P_TAGS) do
      if not v.demo and not v.wip then 
        v.alerted = true
        v.discovered = true
        v.unlocked = true
      end
    end
    set_profile_progress()
    set_discover_tallies()
    G:save_progress()
    G.FILE_HANDLER.force = true

    local tab_but = G.OVERLAY_MENU:get_UIE_by_ID('tab_but_'..G.focused_profile)
    G.FUNCS.change_tab(tab_but)
  end
end

--Creates an alert on this UIE if the round score for this id is a career high score
--
---@param e {}
--**e** Is the UIE that called this function
G.FUNCS.high_score_alert = function(e)
  if e.config.id and not e.children.alert then
    if G.GAME.round_scores[e.config.id] and G.GAME.round_scores[e.config.id].high_score then
      e.children.alert = UIBox{
        definition = create_UIBox_card_alert({no_bg = true,text = localize('k_high_score_ex'), scale = 0.3}),
        config = {
          instance_type = 'ALERT',
          align="tri",
          offset = {x = 0.3, y = -0.18},
          major = e, parent = e}
      }
      e.children.alert.states.collide.can = false
    end
  end
end

G.FUNCS.beta_lang_alert = function(e)
  if not e.children.alert then
    if e.config.ref_table and e.config.ref_table.beta then
      e.children.alert = UIBox{
        definition = create_UIBox_card_alert({no_bg = true, text = 'BETA', scale = 0.35}),
        config = {
          instance_type = 'ALERT',
          align="tri",
          offset = {x = 0.07, y = -0.07},
          major = e, parent = e}
      }
      e.children.alert.states.collide.can = false
    end
  end
end

--Creates a binding pip on this UIE if controller is being used
--
---@param e {}
--**e** Is the UIE that called this function
G.FUNCS.set_button_pip = function(e)
  if G.CONTROLLER.HID.controller and e.config.focus_args and not e.children.button_pip then
    e.children.button_pip = UIBox{
      definition = create_button_binding_pip{button = e.config.focus_args.button, scale = e.config.focus_args.scale},
      config = {
        align= e.config.focus_args.orientation or 'cr',
        offset = e.config.focus_args.offset or e.config.focus_args.orientation == 'bm' and {x = 0, y = 0.02} or {x = 0.1, y = 0.02},
        major = e, parent = e}
    }
    e.children.button_pip.states.collide.can = false
  end
  if not G.CONTROLLER.HID.controller and e.children.button_pip then
    e.children.button_pip:remove()
    e.children.button_pip = nil
  end
end

--Flashes text input cursor for the hooked text input, otherwise sets the width and alpha to 0
--
---@param e {}
--**e** Is the UIE cursor that called this function
G.FUNCS.flash = function(e)
  if G.CONTROLLER.text_input_hook then 
    if (math.floor(G.TIMERS.REAL*2))%2 == 1 then
        e.config.colour[4] = 0
    else
      e.config.colour[4] = 1
    end
    if e.config.w ~= 0.1 then e.config.w = 0.1; e.UIBox:recalculate(true) end
  else
    e.config.colour[4] = 0
    if e.config.w ~= 0 then e.config.w = 0; e.UIBox:recalculate(true) end
  end
end

--highlights/lowlights the pips for any dynatext with multiple values based on which one is displaying
--
---@param e {}
--**e** Is the dynatext that called this function
G.FUNCS.pip_dynatext = function(e)
  if 'pip_'..tostring(e.config.ref_table.focused_string) == e.config.id then
    if e.config.pip_state ~= 1 then
      e.config.colour = e.config.pipcol1
      e.config.pip_state = 1
    end
  elseif e.config.pip_state ~= 2 then
    e.config.colour = e.config.pipcol2
    e.config.pip_state = 2
  end
end

--for the toggle
--
---@param e {}
--**e** Is the slider UIE that called this function
function G.FUNCS.toggle_button(e)
  e.config.ref_table.ref_table[e.config.ref_table.ref_value] = not e.config.ref_table.ref_table[e.config.ref_table.ref_value]
  if e.config.toggle_callback then 
    e.config.toggle_callback(e.config.ref_table.ref_table[e.config.ref_table.ref_value])
  end
end

--for the toggle
--
---@param e {}
--**e** Is the slider UIE that called this function
function G.FUNCS.toggle(e)
  if not e.config.ref_table.ref_table[e.config.ref_table.ref_value] and e.config.toggle_active then
    e.config.toggle_active = nil
    e.config.colour = e.config.ref_table.inactive_colour
    e.children[1].states.visible = false
    e.children[1].config.object.states.visible = false
  elseif e.config.ref_table.ref_table[e.config.ref_table.ref_value] and not e.config.toggle_active then
    e.config.toggle_active = true
    e.config.colour = e.config.ref_table.active_colour
    e.children[1].states.visible = true
    e.children[1].config.object.states.visible = true
  end
  
end


--Modifies the slider value if it is being dragged. e contains the 'container' for the bar and
--c contains the 'child' for the bar. either can be dragged. The value is lerped between the size
--of the child bar and the parent bar depending on any min/max values. Also changes the display text for the slider.
--
---@param e {}
--**e** Is the slider UIE that called this function
function G.FUNCS.slider(e)
  local c = e.children[1]
  e.states.drag.can = true
  c.states.drag.can = true
  if G.CONTROLLER and G.CONTROLLER.dragging.target and
  (G.CONTROLLER.dragging.target == e or
  G.CONTROLLER.dragging.target == c) then
    local rt = c.config.ref_table
    rt.ref_table[rt.ref_value] = math.min(rt.max,math.max(rt.min, rt.min + (rt.max - rt.min)*(G.CURSOR.T.x - e.parent.T.x - G.ROOM.T.x)/e.T.w))
    rt.text = string.format("%."..tostring(rt.decimal_places).."f", rt.ref_table[rt.ref_value])
    c.T.w = (rt.ref_table[rt.ref_value] - rt.min)/(rt.max - rt.min)*rt.w
    c.config.w = c.T.w
    if rt.callback then G.FUNCS[rt.callback](rt) end
  end
end

--Modifies the slider value descreetly by percentage
--c contains the 'child' for the bar. either can be dragged. The value is lerped between the size
--of the child bar and the parent bar depending on any min/max values. Also changes the display text for the slider.
--
---@param e {}
--**e** Is the slider UIE that called this function
function G.FUNCS.slider_descreet(e, per)
  local c = e.children[1]
  e.states.drag.can = true
  c.states.drag.can = true
  if per then
    local rt = c.config.ref_table
    rt.ref_table[rt.ref_value] = math.min(rt.max,math.max(rt.min, rt.ref_table[rt.ref_value] + per*(rt.max - rt.min)))
    rt.text = string.format("%."..tostring(rt.decimal_places).."f", rt.ref_table[rt.ref_value])
    c.T.w = (rt.ref_table[rt.ref_value] - rt.min)/(rt.max - rt.min)*rt.w
    c.config.w = c.T.w
  end
end

--When clicked, changes the selected option from an option cycle. Wraps around.
--Modifies any pips to show the currently selected option and resets last pip.
--Calls any functions from opt_callback defined in the option cycle when the value changes.
--
---@param e {}
--**e** Is the UIE that called this function
G.FUNCS.option_cycle = function(e)
  local from_val = e.config.ref_table.options[e.config.ref_table.current_option]
  local from_key = e.config.ref_table.current_option
  local old_pip = e.UIBox:get_UIE_by_ID('pip_'..e.config.ref_table.current_option, e.parent.parent)
  local cycle_main = e.UIBox:get_UIE_by_ID('cycle_main', e.parent.parent)

  if cycle_main and cycle_main.config.h_popup then
    cycle_main:stop_hover()
    G.E_MANAGER:add_event(Event({
      func = function()
        cycle_main:hover()
      return true
    end
    }))
  end

  if e.config.ref_value == 'l' then
    --cycle left
    e.config.ref_table.current_option = e.config.ref_table.current_option - 1
    if e.config.ref_table.current_option <= 0 then e.config.ref_table.current_option = #e.config.ref_table.options end
  else
    --cycle right
    e.config.ref_table.current_option = e.config.ref_table.current_option + 1
    if e.config.ref_table.current_option > #e.config.ref_table.options then e.config.ref_table.current_option = 1 end
  end
  local to_val = e.config.ref_table.options[e.config.ref_table.current_option]
  local to_key = e.config.ref_table.current_option
  e.config.ref_table.current_option_val = e.config.ref_table.options[e.config.ref_table.current_option]

  local new_pip = e.UIBox:get_UIE_by_ID('pip_'..e.config.ref_table.current_option, e.parent.parent)

  if old_pip then old_pip.config.colour = G.C.BLACK end
  if new_pip then new_pip.config.colour = G.C.WHITE end

  if e.config.ref_table.opt_callback then
      G.FUNCS[e.config.ref_table.opt_callback]{
      from_val = from_val,
      to_val = to_val,
      from_key = from_key,
      to_key = to_key,
      cycle_config = e.config.ref_table
    }
  end
end

--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--                                         CYCLE CALLBACKS
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

--Generalized test framework callback for any testing option cycles
--
---@param args {cycle_config: table, to_val: value}
--**cycle_config** Is the config table from the original option cycle UIE\
--**to_val** is the value the option is changing to
G.FUNCS.test_framework_cycle_callback = function(args)
  args = args or {}
  if args.cycle_config and args.cycle_config.ref_table and args.cycle_config.ref_value then
    args.cycle_config.ref_table[args.cycle_config.ref_value] = args.to_val
  end
end

--Changing the current page being viewed for the Joker Collection
--
---@param args {cycle_config: table}
--**cycle_config** Is the config table from the original option cycle UIE
G.FUNCS.your_collection_joker_page = function(args)
  if not args or not args.cycle_config then return end
  for j = 1, #G.your_collection do
    for i = #G.your_collection[j].cards,1, -1 do
      local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
      c:remove()
      c = nil
    end
  end
  for i = 1, 5 do
    for j = 1, #G.your_collection do
      local center = G.P_CENTER_POOLS["Joker"][i+(j-1)*5 + (5*#G.your_collection*(args.cycle_config.current_option - 1))]
      if not center then break end
      local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
      card.sticker = get_joker_win_sticker(center)
      G.your_collection[j]:emplace(card)
    end
  end
  INIT_COLLECTION_CARD_ALERTS()
end

--Changing the current page being viewed for the tarot and planet card collection
--
---@param args {cycle_config: table}
--**cycle_config** Is the config table from the original option cycle UIE
G.FUNCS.your_collection_tarot_page = function(args)
  if not args or not args.cycle_config then return end
  for j = 1, #G.your_collection do
    for i = #G.your_collection[j].cards,1, -1 do
      local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
      c:remove()
      c = nil
    end
  end
  
  for j = 1, #G.your_collection do
    for i = 1, 4+j do
      local center = G.P_CENTER_POOLS["Tarot"][i+(j-1)*(5) + (11*(args.cycle_config.current_option - 1))]
      if not center then break end
      local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
      card:start_materialize(nil, i>1 or j>1)
      G.your_collection[j]:emplace(card)
    end
  end
  INIT_COLLECTION_CARD_ALERTS()
end

G.FUNCS.your_collection_spectral_page = function(args)
  if not args or not args.cycle_config then return end
  for j = 1, #G.your_collection do
    for i = #G.your_collection[j].cards,1, -1 do
      local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
      c:remove()
      c = nil
    end
  end
  
  for j = 1, #G.your_collection do
    for i = 1, 3+j do
      local center = G.P_CENTER_POOLS["Spectral"][i+(j-1)*(4) + (9*(args.cycle_config.current_option - 1))]
      if not center then break end
      local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
      card:start_materialize(nil, i>1 or j>1)
      G.your_collection[j]:emplace(card)
    end
  end
  INIT_COLLECTION_CARD_ALERTS()
end

--Changing the current page being viewed for the booster pack card collection
--
---@param args {cycle_config: table}
--**cycle_config** Is the config table from the original option cycle UIE
G.FUNCS.your_collection_booster_page = function(args)
  if not args or not args.cycle_config then return end
  for j = 1, #G.your_collection do
    for i = #G.your_collection[j].cards,1, -1 do
      local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
      c:remove()
      c = nil
    end
  end
  
  for j = 1, #G.your_collection do
    for i = 1, 4 do
      local center = G.P_CENTER_POOLS["Booster"][i+(j-1)*4 + (8*(args.cycle_config.current_option - 1))]
      if not center then break end
      local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W*1.27, G.CARD_H*1.27, nil, center)
      card:start_materialize(nil, i>1 or j>1)
      G.your_collection[j]:emplace(card)
    end
  end
  INIT_COLLECTION_CARD_ALERTS()
end

--Changing the current page being viewed for the voucher collection
--
---@param args {cycle_config: table}
--**cycle_config** Is the config table from the original option cycle UIE
G.FUNCS.your_collection_voucher_page = function(args)
  if not args or not args.cycle_config then return end
  for j = 1, #G.your_collection do
    for i = #G.your_collection[j].cards,1, -1 do
      local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
      c:remove()
      c = nil
    end
  end
  for i = 1, 4 do
    for j = 1, #G.your_collection do
      local center = G.P_CENTER_POOLS["Voucher"][i+(j-1)*4 + (8*(args.cycle_config.current_option - 1))]
      if not center then break end
      local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
      card:start_materialize(nil, i>1 or j>1)
      G.your_collection[j]:emplace(card)
    end
  end
  INIT_COLLECTION_CARD_ALERTS()
end

--Changing the selected card back
--
---@param args {to_val: value}
--**to_val** Deck back name being changed to
G.FUNCS.change_selected_back = function(args)
  local selected_center = G.P_CENTER_POOLS.Back[args.to_key] or G.P_CENTERS.b_red
  G.GAME.selected_back:change_to(selected_center)
end

--Changing the collection viewed card back
--
---@param args {to_val: value}
--**to_val** Deck back name being changed to
G.FUNCS.change_viewed_back = function(args)
  G.viewed_stake = G.viewed_stake or 1
  local deck_key = args and args.cycle_config and args.cycle_config.deck_keys and args.cycle_config.deck_keys[args.to_key]
  local viewed_center = (deck_key and G.P_CENTERS[deck_key]) or G.P_CENTER_POOLS.Back[args.to_key] or G.P_CENTERS.b_red
  G.GAME.viewed_back:change_to(viewed_center)
  if G.sticker_card then G.sticker_card.sticker = get_deck_win_sticker(G.GAME.viewed_back.effect.center) end
  local max_stake = get_deck_win_stake(G.GAME.viewed_back.effect.center.key) or 0
  G.viewed_stake = math.min(G.viewed_stake, max_stake + 1)
  G.PROFILES[G.SETTINGS.profile].MEMORY.deck = viewed_center.name or args.to_val
  G.PROFILES[G.SETTINGS.profile].MEMORY.deck_key = viewed_center.key or nil
end

G.FUNCS.change_stake = function(args)
  G.viewed_stake = args.to_key
  G.PROFILES[G.SETTINGS.profile].MEMORY.stake = args.to_key
end

--Switch VSync on or off - add the change to the settings change queue
--
---@param args {to_key: key}
--**to_key** new VSync key setting, 1 for On, 2 for Off
G.FUNCS.change_vsync = function(args)
  G.SETTINGS.QUEUED_CHANGE.vsync = (G.SETTINGS.WINDOW.vsync == 0 and args.to_key == 1 and 1) or (G.SETTINGS.WINDOW.vsync == 1 and args.to_key == 2 and 0) or nil
end

--Changes the screen resolution to the cycled resolution.\
--Note - an issue with windows scaling above 100% means that these resolutions may not match the actual monitor resolution,
--they are more like render resolutions adjusted to fit the screen with scaling
--
---@param args {cycle_config: table, to_key: key}
--**cycle_config** Is the config table from the original option cycle UIE\
--**to_key** The new resolution setting, refers to a resolution table generated with the option cycle
G.FUNCS.change_screen_resolution = function(args)
  local curr_disp = G.SETTINGS.WINDOW.selected_display
  local to_resolution = G.SETTINGS.WINDOW.DISPLAYS[curr_disp].screen_resolutions.values[args.to_key]
  G.SETTINGS.QUEUED_CHANGE.screenres = {w = to_resolution.w, h = to_resolution.h}

end

--Changes the screen mode\
--Options: Windowed, Fullscreen, Borderless
--
---@param args {cycle_config: table, to_val: value}
--**cycle_config** Is the config table from the original option cycle UIE\
--**to_val** The new screenmode setting value
G.FUNCS.change_screenmode = function(args)
  G.ARGS.screenmode_vals = G.ARGS.screenmode_vals or {"Windowed", "Fullscreen", "Borderless"}
  G.SETTINGS.QUEUED_CHANGE.screenmode = G.ARGS.screenmode_vals[args.to_key]
  G.FUNCS.change_window_cycle_UI()
end

--Changes the displaying monitors
--
---@param args {cycle_config: table, to_key: key}
--**cycle_config** Is the config table from the original option cycle UIE\
--**to_key** The new screenmode setting key
G.FUNCS.change_display = function(args)
  G.SETTINGS.QUEUED_CHANGE.selected_display = args.to_key
  G.FUNCS.change_window_cycle_UI()
end

--Helper function to re-add the resolution cycle UIE with updated data
G.FUNCS.change_window_cycle_UI = function()
  if G.OVERLAY_MENU then
    local swap_node = G.OVERLAY_MENU:get_UIE_by_ID('resolution_cycle')
    if swap_node then
      local focused_display, focused_screenmode = G.SETTINGS.QUEUED_CHANGE.selected_display or G.SETTINGS.WINDOW.selected_display, G.SETTINGS.QUEUED_CHANGE.screenmode or G.SETTINGS.WINDOW.screenmode

      --Refresh the display information
      local res_option = GET_DISPLAYINFO(focused_screenmode, focused_display)

      --Remove the old cycle, replace it with a new updated one reflecting any changes
      swap_node.children[1]:remove()
      swap_node.children[1] = nil
      swap_node.UIBox:add_child(
        create_option_cycle({w = 4,scale = 0.8, options = G.SETTINGS.WINDOW.DISPLAYS[focused_display].screen_resolutions.strings, opt_callback = 'change_screen_resolution',current_option = res_option or 1}),
        swap_node)
    end
  end
end

--Changes the speed that the game runs at, does not affect all timers, just G.TIMERS.TOTAL
--
---@param args {cycle_config: table, to_val: value}
--**cycle_config** Is the config table from the original option cycle UIE\
--**to_val** The new screenmode setting key
G.FUNCS.change_gamespeed = function(args)
  G.SETTINGS.GAMESPEED = args.to_val
end

--Changes the relative position of play and discard buttons
--
---@param args {cycle_config: table, to_key: value}
--**cycle_config** Is the config table from the original option cycle UIE\
--**to_val** The new screenmode setting key
G.FUNCS.change_play_discard_position = function(args)
  G.SETTINGS.play_button_pos = args.to_key
  if G.buttons then
    G.buttons:remove()
      G.buttons = UIBox{
          definition = create_UIBox_buttons(),
          config = {align="bm", offset = {x=0,y=0.3},major = G.hand, bond = 'Weak'}
      }
  end
end

--Changes the Shadow setting
--
---@param args {cycle_config: table, to_val: value}
--**cycle_config** Is the config table from the original option cycle UIE\
--**to_val** The new value for shadows, 'On' or 'Off'
G.FUNCS.change_shadows = function(args)
  G.SETTINGS.GRAPHICS.shadows = args.to_key == 1 and 'On' or 'Off'
  G:save_settings()
end

--Changes the Pixel smoothing, all sprites need to be realoaded when this changes\
--
---@param args {cycle_config: table, to_key: key}
--**cycle_config** Is the config table from the original option cycle UIE\
--**to_val** The new value for shadows, 'On' or 'Off'
G.FUNCS.change_pixel_smoothing = function(args)
  G.SETTINGS.GRAPHICS.texture_scaling = args.to_key--^2
  G:set_render_settings()
  G:save_settings()
end

--Changes the Bloom amount for the CRT effect, number of samples to take for bloom\
--
---@param args {cycle_config: table, to_key: key}
--**cycle_config** Is the config table from the original option cycle UIE\
--**to_val** The new value for shadows, 'On' or 'Off'
G.FUNCS.change_crt_bloom = function(args)
  G.SETTINGS.GRAPHICS.bloom = args.to_key
  G:save_settings()
end

G.FUNCS.change_collab = function(args)
  G.SETTINGS.CUSTOM_DECK.Collabs[args.cycle_config.curr_suit] = G.COLLABS.options[args.cycle_config.curr_suit][args.to_key] or 'default'
  for k, v in pairs(G.I.CARD) do
    if v.config and v.config.card and v.children.front and v.ability.effect ~= 'Stone Card' then 
      v:set_sprites(nil, v.config.card)
    end
  end
  G:save_settings()
end

--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--                                         TEXT ENTRY
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

--passes a keyboard input to the controller when a key UI button is pressed
--
---@param e table
--
--[e is the UI Element that calls this update function, contains ARGS in e.config.ref_table]
G.FUNCS.key_button = function(e)
  local args = e.config.ref_table
  if args.key then G.CONTROLLER:key_press_update(args.key) end
end

--Modifies the text input to show the current text value being modified. Shows the prompt text if\
--the text input area is not hooked. Also modifies the UIE colour to show the hooked/non hooked colour\
--If using a keyboard, pops it up here or removes it if using KBM
--
---@param e table
--
--[e is the UI Element that calls this update function, contains ARGS in e.config.ref_table]
G.FUNCS.text_input = function(e)
  local args =e.config.ref_table
  if G.CONTROLLER.text_input_hook == e then
    e.parent.parent.config.colour = args.hooked_colour
    args.current_prompt_text = ''
    args.current_position_text = args.position_text
  else
    e.parent.parent.config.colour = args.colour
    args.current_prompt_text = (args.text.ref_table[args.text.ref_value] == '' and args.prompt_text or '')
    args.current_position_text = ''
  end

  local OSkeyboard_e = e.parent.parent.parent
  if G.CONTROLLER.text_input_hook == e and G.CONTROLLER.HID.controller then
    if not OSkeyboard_e.children.controller_keyboard then 
      OSkeyboard_e.children.controller_keyboard = UIBox{
        definition = create_keyboard_input{backspace_key = true, return_key = true, space_key = false},
        config = {
          align= 'cm',
          offset = {x = 0, y = G.CONTROLLER.text_input_hook.config.ref_table.keyboard_offset or -4},
          major = e.UIBox, parent = OSkeyboard_e}
      }
      G.CONTROLLER.screen_keyboard = OSkeyboard_e.children.controller_keyboard
      G.CONTROLLER:mod_cursor_context_layer(1)
    end
  elseif OSkeyboard_e.children.controller_keyboard then
    OSkeyboard_e.children.controller_keyboard:remove()
    OSkeyboard_e.children.controller_keyboard = nil
    G.CONTROLLER.screen_keyboard = nil
    G.CONTROLLER:mod_cursor_context_layer(-1)
  end
end

G.FUNCS.paste_seed = function(e)
  G.CONTROLLER.text_input_hook = e.UIBox:get_UIE_by_ID('text_input').children[1].children[1]
  for i = 1, 8 do
    G.FUNCS.text_input_key({key = 'right'})
  end
  for i = 1, 8 do
      G.FUNCS.text_input_key({key = 'backspace'})
  end
  local clipboard = (G.F_LOCAL_CLIPBOARD and G.CLIPBOARD or love.system.getClipboardText()) or ''
  for i = 1, #clipboard do
    local c = clipboard:sub(i,i)
    G.FUNCS.text_input_key({key = c})
  end
  G.FUNCS.text_input_key({key = 'return'})
end

--When clicked, hooks the text input defined by e->1->1, which should be the text input UIE
--
---@param e table
--
--[e is the UI Element that calls this click function]
G.FUNCS.select_text_input = function(e)
  G.CONTROLLER.text_input_hook = e.children[1].children[1]

  --Start by setting the cursor position to the correct location
  TRANSPOSE_TEXT_INPUT(0)
  e.UIBox:recalculate(true)
end

--Handles all key inputs for the hooked text input.
--
---@param args {key: string, caps: boolean}
--**key** the key being pressed\
--**caps** if the key should be capitalized
G.FUNCS.text_input_key = function(args)
  args = args or {}

  if args.key == '[' or args.key == ']' then return end
  if args.key == '0' then args.key = 'o' end

  --shortcut to hook config
  local hook_config = G.CONTROLLER.text_input_hook.config.ref_table
  hook_config.orig_colour = hook_config.orig_colour or copy_table(hook_config.colour)

  args.key = args.key or '%'
  args.caps = args.caps or G.CONTROLLER.capslock or hook_config.all_caps --capitalize if caps lock or hook requires

  --Some special keys need to be mapped accordingly before passing through the corpus
  local keymap = {
    space = ' ',
    backspace = 'BACKSPACE',
    delete = 'DELETE',
    ['return'] = 'RETURN',
    right = 'RIGHT',
    left = 'LEFT'
  }
  local hook = G.CONTROLLER.text_input_hook
  local corpus = '123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'..(hook.config.ref_table.extended_corpus and " 0!$&()<>?:{}+-=,.[]_" or '')
  
  if hook.config.ref_table.extended_corpus then 
    local lower_ext = '1234567890-=;\',./'
    local upper_ext = '!@#$%^&*()_+:"<>?'
    if string.find(lower_ext, args.key) and args.caps then 
      args.key = string.sub(string.sub(upper_ext,string.find(lower_ext, args.key)), 0, 1)
    end
  end
  local text = hook_config.text

  --set key to mapped key or upper if caps is true
  args.key = keymap[args.key] or (args.caps and string.upper(args.key) or args.key)
  
  --Start by setting the cursor position to the correct location
  TRANSPOSE_TEXT_INPUT(0)

  if string.len(text.ref_table[text.ref_value]) > 0 and args.key == 'BACKSPACE' then --If not at start, remove preceding letter
    MODIFY_TEXT_INPUT{
      letter = '',
      text_table = text,
      pos = text.current_position,
      delete = true
    }
    TRANSPOSE_TEXT_INPUT(-1)
  elseif string.len(text.ref_table[text.ref_value]) > 0 and args.key == 'DELETE' then --if not at end, remove following letter
    MODIFY_TEXT_INPUT{
      letter = '',
      text_table = text,
      pos = text.current_position+1,
      delete = true
    }
    TRANSPOSE_TEXT_INPUT(0)
  elseif args.key == 'RETURN' then --Release the hook
    if hook.config.ref_table.callback then hook.config.ref_table.callback() end
    hook.parent.parent.config.colour = hook_config.colour
    local temp_colour = copy_table(hook_config.orig_colour)
    hook_config.colour[1] = G.C.WHITE[1]
    hook_config.colour[2] = G.C.WHITE[2]
    hook_config.colour[3] = G.C.WHITE[3]
    ease_colour(hook_config.colour, temp_colour)
    G.CONTROLLER.text_input_hook = nil
  elseif args.key == 'LEFT' then --Move cursor position to the left
    TRANSPOSE_TEXT_INPUT(-1)
  elseif args.key == 'RIGHT' then --Move cursor position to the right
    TRANSPOSE_TEXT_INPUT(1)
  elseif hook_config.max_length > string.len(text.ref_table[text.ref_value]) and
        (string.len(args.key) == 1) and
        string.find( corpus,  args.key , 1, true) then --check to make sure the key is in the valid corpus, add it to the string
    MODIFY_TEXT_INPUT{
      letter = args.key,
      text_table = text,
      pos = text.current_position+1
    }
    TRANSPOSE_TEXT_INPUT(1)
  end
end

--Helper function for G.FUNCS.text_input_key
function GET_TEXT_FROM_INPUT()
  local new_text = ''
  local hook = G.CONTROLLER.text_input_hook
  for i = 1, #hook.children do
    if hook.children[i].config and hook.children[i].config.id:sub(1, 7) == 'letter_' and hook.children[i].config.text ~= '' then
      new_text = new_text..hook.children[i].config.text
    end
  end
  return new_text
end

--Helper function for G.FUNCS.text_input_key
--
---@param args {letter: string, text_table: table, pos: number, delete: boolean}
--**letter** the letter being pressed\
--**text_table** the table full of letters from hook\
--**pos** the current position of the iterator\
--**delete** if the action is a deletion action
function MODIFY_TEXT_INPUT(args)
  args = args or {}

  if args.delete and args.pos > 0 then 
    if args.pos >= #args.text_table.letters then
      args.text_table.letters[args.pos] = ''
    else
      args.text_table.letters[args.pos] = args.text_table.letters[args.pos+1]
      MODIFY_TEXT_INPUT{
        letter = args.letter,
        text_table = args.text_table,
        pos = args.pos+1,
        delete = args.delete
      }
    end
    return
  end
  local swapped_letter = args.text_table.letters[args.pos]
  args.text_table.letters[args.pos] = args.letter
  if swapped_letter and swapped_letter ~= '' then
    MODIFY_TEXT_INPUT{
      letter = swapped_letter,
      text_table = args.text_table,
      pos = args.pos+1
    }
  end
end

--Helper function for G.FUNCS.text_input_key\
--Moves the cursor left or right. Typing a key, deleting or backspacing also counts\
--as a cursor move, since empty strings are used to fill the hook
--
---@param amount number
function TRANSPOSE_TEXT_INPUT(amount)
  local position_child = nil
  local hook = G.CONTROLLER.text_input_hook
  local text = G.CONTROLLER.text_input_hook.config.ref_table.text
  for i = 1, #hook.children do
    if hook.children[i].config then
     if hook.children[i].config.id == 'position' then
        position_child = i; break
      end
    end
  end

  local dir = (amount/math.abs(amount)) or 0
  
  while amount ~= 0 do
    if position_child + dir < 1 or position_child + dir >= #hook.children then break end
    local real_letter = hook.children[position_child+dir].config.id:sub(1, 7) == 'letter_' and hook.children[position_child+dir].config.text ~= ''
    SWAP(hook.children, position_child, position_child + dir)
    if real_letter then amount = amount - dir end
    position_child = position_child + dir
  end

  text.current_position = math.min(position_child-1, string.len(text.ref_table[text.ref_value]))
  hook.UIBox:recalculate(true)
  text.ref_table[text.ref_value] = GET_TEXT_FROM_INPUT()
end

--Determines if there are any graphical changes in the queue that require window re-initialization,
--changes the button accordingly
--
---@param e {}
--**e** Is the UIE that called this function
G.FUNCS.can_apply_window_changes = function(e)
  local can_apply = false
  if G.SETTINGS.QUEUED_CHANGE then 
    if G.SETTINGS.QUEUED_CHANGE.screenmode and
      G.SETTINGS.QUEUED_CHANGE.screenmode ~= G.SETTINGS.WINDOW.screenmode then
        can_apply = true
    elseif G.SETTINGS.QUEUED_CHANGE.screenres then
        can_apply = true
    elseif G.SETTINGS.QUEUED_CHANGE.vsync then
        can_apply = true
    elseif G.SETTINGS.QUEUED_CHANGE.selected_display and
           G.SETTINGS.QUEUED_CHANGE.selected_display ~= G.SETTINGS.WINDOW.selected_display then
        can_apply = true
    end
  end

  if can_apply then 
    e.config.button = 'apply_window_changes'
    e.config.colour = G.C.RED
  else
    e.config.button = nil
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
  end
end

--Applies all window changes, including updates to the screenmode, selected display, resolution and vsync.\
--These changes are all defined in the G.SETTINGS.QUEUED_CHANGE table. Any unchanged settings use the previous value
G.FUNCS.apply_window_changes = function(_initial)
  --Set the screenmode setting from Windowed, Fullscreen or Borderless
  G.SETTINGS.WINDOW.screenmode = (G.SETTINGS.QUEUED_CHANGE and G.SETTINGS.QUEUED_CHANGE.screenmode) or G.SETTINGS.WINDOW.screenmode or 'Windowed'

  --Set the monitor the window should be rendered to
  G.SETTINGS.WINDOW.selected_display = (G.SETTINGS.QUEUED_CHANGE and G.SETTINGS.QUEUED_CHANGE.selected_display) or G.SETTINGS.WINDOW.selected_display or 1

  --Set the screen resolution
  G.SETTINGS.WINDOW.DISPLAYS[G.SETTINGS.WINDOW.selected_display].screen_res = {
    w = (G.SETTINGS.QUEUED_CHANGE and G.SETTINGS.QUEUED_CHANGE.screenres and G.SETTINGS.QUEUED_CHANGE.screenres.w) or (G.SETTINGS.screen_res and G.SETTINGS.screen_res.w) or love.graphics.getWidth( ),
    h = (G.SETTINGS.QUEUED_CHANGE and G.SETTINGS.QUEUED_CHANGE.screenres and G.SETTINGS.QUEUED_CHANGE.screenres.h) or (G.SETTINGS.screen_res and G.SETTINGS.screen_res.h) or love.graphics.getHeight( )
  }

  --Set the vsync value, 0 is off 1 is on
  G.SETTINGS.WINDOW.vsync = (G.SETTINGS.QUEUED_CHANGE and G.SETTINGS.QUEUED_CHANGE.vsync) or G.SETTINGS.WINDOW.vsync or 1

  love.window.updateMode(
    (G.SETTINGS.QUEUED_CHANGE and G.SETTINGS.QUEUED_CHANGE.screenmode == 'Windowed') and love.graphics.getWidth()*0.8 or G.SETTINGS.WINDOW.DISPLAYS[G.SETTINGS.WINDOW.selected_display].screen_res.w,
    (G.SETTINGS.QUEUED_CHANGE and G.SETTINGS.QUEUED_CHANGE.screenmode == 'Windowed') and love.graphics.getHeight()*0.8 or G.SETTINGS.WINDOW.DISPLAYS[G.SETTINGS.WINDOW.selected_display].screen_res.h,
    {fullscreen = G.SETTINGS.WINDOW.screenmode ~= 'Windowed',
    fullscreentype = (G.SETTINGS.WINDOW.screenmode == 'Borderless' and 'desktop') or (G.SETTINGS.WINDOW.screenmode == 'Fullscreen' and 'exclusive') or nil,
    vsync = G.SETTINGS.WINDOW.vsync,
    resizable = true,
    display = G.SETTINGS.WINDOW.selected_display,
    highdpi = (love.system.getOS() == 'OS X')
    })
  G.SETTINGS.QUEUED_CHANGE = {}
  if _initial ~= true then
    love.resize(love.graphics.getWidth(),love.graphics.getHeight())
    G:save_settings()
  end
  if G.OVERLAY_MENU then
    local tab_but = G.OVERLAY_MENU:get_UIE_by_ID('tab_but_Video')
    G.FUNCS.change_tab(tab_but)
  end
end

--Iterates through any collection cardareas, applies the initial collection alert update.\
--This update_alert function for each card is also called by the card in its own update function
function INIT_COLLECTION_CARD_ALERTS()
  for j = 1, #G.your_collection do
    for _, v in ipairs(G.your_collection[j].cards) do
      v:update_alert()
    end
  end
end

--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--                                         RUN SETUP
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

--Monitors the run option deck to determine if a new 'back' has been chosen from the option cycle\
--if so, this function removes the old UI describing the ability of the back and replaces it with the new ability UI
--
---@param e {}
--**e** Is the UIE that called this function
G.FUNCS.RUN_SETUP_check_back = function(e)
  local viewed_key = G.GAME.viewed_back and G.GAME.viewed_back.effect and G.GAME.viewed_back.effect.center and G.GAME.viewed_back.effect.center.key
  if viewed_key ~= e.config.id then 
    --removes the UI from the previously selected back and adds the new one

    e.config.object:remove() 
    e.config.object = UIBox{
      definition = G.GAME.viewed_back:generate_UI(),
      config = {offset = {x=0,y=0}, align = 'cm', parent = e}
    }
    e.config.id = viewed_key
  end
end

G.FUNCS.RUN_SETUP_check_back_name = function(e)
  local viewed_key = G.GAME.viewed_back and G.GAME.viewed_back.effect and G.GAME.viewed_back.effect.center and G.GAME.viewed_back.effect.center.key
  if e.config.object and viewed_key ~= e.config.id then 
    --removes the UI from the previously selected back and adds the new one

    e.config.object:remove() 
    e.config.object = UIBox{
      definition = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
        {n=G.UIT.O, config={id = viewed_key, func = 'RUN_SETUP_check_back_name', object = DynaText({string = G.GAME.viewed_back:get_name(),maxw = 4, colours = {G.C.WHITE}, shadow = true, bump = true, scale = 0.5, pop_in = 0, silent = true})}},
      }},
      config = {offset = {x=0,y=0}, align = 'cm', parent = e}
    }
    e.config.id = viewed_key
  end
end

G.FUNCS.RUN_SETUP_check_stake = function(e)
  local viewed_key = G.GAME.viewed_back and G.GAME.viewed_back.effect and G.GAME.viewed_back.effect.center and G.GAME.viewed_back.effect.center.key
  if (viewed_key ~= e.config.id) then 
    e.config.object:remove() 
    e.config.object = UIBox{
      definition =  G.UIDEF.stake_option(G.SETTINGS.current_setup),
      config = {offset = {x=0,y=0}, align = 'tmi', parent = e}
    }
    e.config.id = viewed_key
  end
end

G.FUNCS.RUN_SETUP_check_stake2 = function(e)
  if (G.viewed_stake ~= e.config.id) then 
    e.config.object:remove() 
    e.config.object = UIBox{
      definition =  G.UIDEF.viewed_stake_option(),
      config = {offset = {x=0,y=0}, align = 'cm', parent = e}
    }
    e.config.id = G.viewed_stake
  end
end

G.FUNCS.change_viewed_collab = function(args)
  G.viewed_collab = args.to_val
end

G.FUNCS.CREDITS_check_collab = function(e)
  if (G.viewed_collab ~= e.config.id) then 
    e.config.object:remove() 
    e.config.object = UIBox{
      definition =  G.UIDEF.viewed_collab_option(),
      config = {offset = {x=0,y=0}, align = 'cm', parent = e}
    }
    e.config.id = G.viewed_collab
  end
end

G.FUNCS.RUN_SETUP_check_back_stake_column= function(e)
  local viewed_key = G.GAME.viewed_back and G.GAME.viewed_back.effect and G.GAME.viewed_back.effect.center and G.GAME.viewed_back.effect.center.key
  if viewed_key ~= e.config.id then 
    --removes the UI from the previously selected back and adds the new one
    e.config.object:remove() 
    e.config.object = UIBox{
      definition = G.UIDEF.deck_stake_column(G.GAME.viewed_back.effect.center.key),
      config = {offset = {x=0,y=0}, align = 'cm', parent = e}
    }
    e.config.id = viewed_key
  end
end

G.FUNCS.RUN_SETUP_check_back_stake_highlight= function(e)
  if G.viewed_stake == e.config.id and e.config.outline < 0.1 then 
    e.config.outline = 0.8
  elseif G.viewed_stake ~= e.config.id and e.config.outline > 0.1 then
    e.config.outline = 0
  end
end

G.FUNCS.change_tab = function(e)
  if not e then return end
  local _infotip_object = G.OVERLAY_MENU:get_UIE_by_ID('overlay_menu_infotip')
  if _infotip_object and _infotip_object.config.object then 
    _infotip_object.config.object:remove() 
    _infotip_object.config.object = Moveable()
  end

  local tab_contents = e.UIBox:get_UIE_by_ID('tab_contents')
  tab_contents.config.object:remove()
  tab_contents.config.object = UIBox{
      definition = e.config.ref_table.tab_definition_function(e.config.ref_table.tab_definition_function_args),
      config = {offset = {x=0,y=0}, parent = tab_contents, type = 'cm'}
    }
  tab_contents.UIBox:recalculate()
end

--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--                                         OVERLAY MENUS
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

--The overlay menu is a full screen menu interface, and is usually called from button presses. The base Overlay menu function here\
--creates a global G.OVERLAY_MENU that represents this full screen UIBox. The game may be paused at this time as well\
--The generated UIBox is created below the visible screen area and eased up to the center of the screen
--
---@param args {definition: table, config: table, pause: boolean}
--**definition** The definition table for the UIBox\
--**config** A configuration table for the UIBox\
--**pause** Whether the game should be paused on creation of the UIBox
G.FUNCS.overlay_menu  = function(args)
  if not args then return end
  --Remove any existing overlays if there is one
  if G.OVERLAY_MENU then G.OVERLAY_MENU:remove() end
  G.CONTROLLER.locks.frame_set = true
  G.CONTROLLER.locks.frame = true
  G.CONTROLLER.cursor_down.target = nil
  G.CONTROLLER:mod_cursor_context_layer(G.NO_MOD_CURSOR_STACK and 0 or 1)

  args.config = args.config or {}
  args.config = {
    align = args.config.align or "cm",
    offset = args.config.offset or {x=0,y=10},
    major = args.config.major or G.ROOM_ATTACH,
    bond = 'Weak',
    no_esc = args.config.no_esc
  }
  G.OVERLAY_MENU = true
  --Generate the UIBox
  G.OVERLAY_MENU = UIBox{
    definition = args.definition,
    config = args.config
  }

  --Set the offset and align. The menu overlay can be initially offset in the y direction and this will ensure it slides to middle
  G.OVERLAY_MENU.alignment.offset.y = 0
  G.ROOM.jiggle = G.ROOM.jiggle + 1
  G.OVERLAY_MENU:align_to_major()
end

--Removes the overlay menu if one exists, unpauses the game, and saves the settings to file
G.FUNCS.exit_overlay_menu = function()
  if not G.OVERLAY_MENU then return end
  G.CONTROLLER.locks.frame_set = true
  G.CONTROLLER.locks.frame = true
  G.CONTROLLER:mod_cursor_context_layer(-1000)
  G.OVERLAY_MENU:remove()
  G.OVERLAY_MENU = nil
  G.VIEWING_DECK = nil
  G.SETTINGS.paused = false

  --Save settings to file
  G:save_settings()
end

--Removes overlay menu and immediately generates the next unlock menu if there is one
G.FUNCS.continue_unlock = function()
  G.FUNCS.exit_overlay_menu()
  G.CONTROLLER:mod_cursor_context_layer(-2000)
  G.E_MANAGER:update(0, true)
end

G.FUNCS.test_framework = function(options)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_test_framework(options),
  }
end
  
G.FUNCS.options = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_options(),
  }
end

G.FUNCS.skip_tutorial = function(e)
  print("[DEBUG] Skip tutorial button clicked - completing tutorial and starting new run")
  G.SETTINGS.tutorial_complete = true
  G.SETTINGS.tutorial_progress = G.SETTINGS.tutorial_progress or {}
  G.SETTINGS.tutorial_progress.completed_parts = G.SETTINGS.tutorial_progress.completed_parts or {}
  G.SETTINGS.tutorial_progress.completed_parts['big_blind'] = true
  G:save_settings()
  
  -- Start a new run
  G.FUNCS.start_run(nil, {stake = 1})
end

G.FUNCS.current_hands = function(e, simple)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_current_hands(simple),
  }
end

G.FUNCS.run_info = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.run_info(),
  }
end

G.FUNCS.deck_info = function(e)
  G.SETTINGS.paused = true
  if G.deck_preview then 
    G.deck_preview:remove()
    G.deck_preview = nil
  end
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.deck_info(
      G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.HAND_PLAYED or G.STATE == G.STATES.DRAW_TO_HAND 
    ),
  }
end

G.FUNCS.settings = function(e, instant)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
  definition = create_UIBox_settings(),
  config = {offset = {x=0,y=instant and 0 or 10}}
}
end

G.FUNCS.show_credits = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.credits(),
  }
end

G.FUNCS.language_selection = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.language_selector(),
  }
end

G.FUNCS.your_collection = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_your_collection(),
  }
end

G.FUNCS.your_collection_blinds = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_your_collection_blinds(),
  }
end

G.FUNCS.your_collection_jokers = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_your_collection_jokers(),
  }
end

G.FUNCS.your_collection_tarots = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_your_collection_tarots(),
  }
end

G.FUNCS.your_collection_planets = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_your_collection_planets(),
  }
end

G.FUNCS.your_collection_spectrals = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_your_collection_spectrals(),
  }
end

G.FUNCS.your_collection_vouchers = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_your_collection_vouchers(),
  }
end

G.FUNCS.your_collection_enhancements_exit_overlay_menu = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_your_collection_enhancements('exit_overlay_menu'),
  }
end

G.FUNCS.your_collection_enhancements = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_your_collection_enhancements(),
  }
end

G.FUNCS.your_collection_decks = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_your_collection_decks(),
  }
end

G.FUNCS.your_collection_editions = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_your_collection_editions(),
  }
end

G.FUNCS.your_collection_tags = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_your_collection_tags(),
  }
end

G.FUNCS.your_collection_seals = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_your_collection_seals(),
  }
end

G.FUNCS.your_collection_boosters = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_your_collection_boosters(),
  }
end

G.FUNCS.challenge_list = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.challenge_list((e.config.id == 'from_game_over')),
  }
  if (e.config.id == 'from_game_over') then G.OVERLAY_MENU.config.no_esc =true end
end

G.FUNCS.high_scores = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_high_scores(),
  }
end

G.FUNCS.customize_deck = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_customize_deck(),
  }
end

G.FUNCS.usage = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.usage_tabs()
  }
end

G.FUNCS.setup_run = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.run_setup((e.config.id == 'from_game_over' or e.config.id == 'from_game_won' or e.config.id == 'challenge_list') and e.config.id),
  }
  if (e.config.id == 'from_game_over' or e.config.id == 'from_game_won') then G.OVERLAY_MENU.config.no_esc =true end
end

G.FUNCS.wait_for_high_scores = function(e)
  if G.ARGS.HIGH_SCORE_RESPONSE then 
    e.config.object:remove() 
    e.config.object = UIBox{
      definition =  create_UIBox_high_scores_filling(G.ARGS.HIGH_SCORE_RESPONSE),
      config = {offset = {x=0,y=0}, align = 'cm', parent = e}
    }
    G.ARGS.HIGH_SCORE_RESPONSE = nil
  end
end

G.FUNCS.notify_then_setup_run = function(e)
  G.OVERLAY_MENU:remove()
  G.OVERLAY_MENU = nil

  G.E_MANAGER:add_event(Event({
    blockable = false,
    func = (function()
      unlock_notify()
      return true
    end)
  }))

  G.E_MANAGER:add_event(Event({
    blockable = false,
    func = (function()
      if #G.E_MANAGER.queues.unlock <= 0 and not G.OVERLAY_MENU then
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
          definition = G.UIDEF.run_setup((e.config.id == 'from_game_over' or e.config.id == 'from_game_won') and e.config.id),
        }
        if (e.config.id == 'from_game_over' or e.config.id == 'from_game_won') then G.OVERLAY_MENU.config.no_esc =true end
        return true
      end
    end)
  }))
end

G.FUNCS.change_challenge_description = function(e)
  if G.OVERLAY_MENU then
    local desc_area = G.OVERLAY_MENU:get_UIE_by_ID('challenge_area')
    if desc_area and desc_area.config.oid ~= e.config.id then
      if desc_area.config.old_chosen then desc_area.config.old_chosen.config.chosen = nil end
      e.config.chosen = 'vert'
      if desc_area.config.object then 
        desc_area.config.object:remove() 
      end
      desc_area.config.object = UIBox{
        definition =  G.UIDEF.challenge_description(e.config.id),
        config = {offset = {x=0,y=0}, align = 'cm', parent = desc_area}
      }
      desc_area.config.oid = e.config.id 
      desc_area.config.old_chosen = e
    end
  end
end

G.FUNCS.change_challenge_list_page = function(args)
  if not args or not args.cycle_config then return end
  if G.OVERLAY_MENU then
    local ch_list = G.OVERLAY_MENU:get_UIE_by_ID('challenge_list')
    if ch_list then 
      if ch_list.config.object then 
        ch_list.config.object:remove() 
      end
      ch_list.config.object = UIBox{
        definition =  G.UIDEF.challenge_list_page(args.cycle_config.current_option-1),
        config = {offset = {x=0,y=0}, align = 'cm', parent = ch_list}
      }
      G.FUNCS.change_challenge_description{config = {id = 'nil'}}
    end
  end
end

G.FUNCS.deck_view_challenge = function(e)
  G.FUNCS.overlay_menu{
    definition = create_UIBox_generic_options({back_func = 'deck_info', contents ={
        G.UIDEF.challenge_description(get_challenge_int_from_id(e.config.id.id or ''), nil, true)
      }
    })
  }
end

G.FUNCS.profile_select = function(e)
  G.SETTINGS.paused = true
  G.focused_profile = G.SETTINGS.profile

  local function describe_name(name)
    if not name then
      return "<nil>"
    elseif name == "" then
      return "<empty>"
    end
    return name
  end
  local names_before = {}
  for i = 1, 3 do
    names_before[#names_before + 1] = describe_name(G.PROFILES[i] and G.PROFILES[i].name)
  end
  print("[PROFILE_UI] opening overlay: profile " .. tostring(G.SETTINGS.profile) .. ", names before: " .. table.concat(names_before, ", "))

  for i = 1, 3 do
    if i ~= G.focused_profile and love.filesystem.getInfo(i..'/'..'profile.jkr') then G:load_profile(i) end
  end
  G:load_profile(G.focused_profile)

  local names_after = {}
  for i = 1, 3 do
    names_after[#names_after + 1] = describe_name(G.PROFILES[i] and G.PROFILES[i].name)
  end
  print("[PROFILE_UI] after load: " .. table.concat(names_after, ", "))

  G.FUNCS.overlay_menu{
    definition = G.UIDEF.profile_select(),
  }
end

G.FUNCS.quit = function(e)
  love.event.quit()
end

G.FUNCS.quit_cta = function(e)
  G.SETTINGS.paused = true
  G.SETTINGS.DEMO.quit_CTA_shown = true

  G:save_progress()
  
  G.FUNCS.overlay_menu{
      definition = create_UIBox_exit_CTA(),
      config = {no_esc = true}
  }
  local Jimbo = nil

  if not G.jimboed then 
      G.jimboed  = true
      G.E_MANAGER:add_event(Event({
          trigger = 'after',
          blockable = false,
          delay = 2.5,
          func = (function()
              if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('jimbo_spot') then 
                  Jimbo = Card_Character({x = 0, y = 5})
                  local spot = G.OVERLAY_MENU:get_UIE_by_ID('jimbo_spot')
                  spot.config.object:remove()
                  spot.config.object = Jimbo
                  Jimbo.ui_object_updated = true
                  Jimbo:add_speech_bubble( {"Having fun?", {{text = "Wishlist Balatro!", type = 'GREEN'}}})
                  Jimbo:say_stuff(5)
                  end
              return true
          end)
      }))
  end
end

G.FUNCS.demo_survey = function(e)
  love.system.openURL( "https://forms.gle/WX26BHq1AwwV5xyH9")--"https://forms.gle/P8F4WzdCsccrm15T6" )
end

G.FUNCS.louisf_insta = function(e)
  love.system.openURL( "https://www.instagram.com/louisfsoundtracks/" )
end

G.FUNCS.wishlist_steam = function(e)
  love.system.openURL( "https://store.steampowered.com/app/2379780/Balatro/#game_area_purchase" )
end

G.FUNCS.go_to_playbalatro = function(e)
  love.system.openURL( "https://www.playbalatro.com" )
end

G.FUNCS.go_to_discord = function(e)
  love.system.openURL( "https://discord.gg/balatro" )
end

G.FUNCS.go_to_discord_loc = function(e)
  love.system.openURL( "https://discord.com/channels/1116389027176787968/1207803392978853898" )
end

G.FUNCS.loc_survey = function(e)
  love.system.openURL( "https://forms.gle/pL5tMh1oXLmv8czz9" )
end

G.FUNCS.go_to_twitter = function(e)
  love.system.openURL( "https://twitter.com/LocalThunk" )
end

G.FUNCS.unlock_this = function(e)
  unlock_achievement(e.config.id)
end

G.FUNCS.reset_achievements = function(e)
  G.ACHIEVEMENTS = nil
  G.SETTINGS.ACHIEVEMENTS_EARNED = {}
  G:save_progress()
  G.FUNCS.exit_overlay_menu()
end

G.FUNCS.refresh_contrast_mode = function()
  local new_colour_proto = G.C["SO_"..(G.SETTINGS.colourblind_option and 2 or 1)]
  G.C.SUITS.Hearts = new_colour_proto.Hearts
  G.C.SUITS.Diamonds = new_colour_proto.Diamonds
  G.C.SUITS.Spades = new_colour_proto.Spades
  G.C.SUITS.Clubs = new_colour_proto.Clubs
  for k, v in pairs(G.I.CARD) do
    if v.config and v.config.card and v.children.front and v.ability.effect ~= 'Stone Card' then 
      v:set_sprites(nil, v.config.card)
    end
  end
end

G.FUNCS.warn_lang = function(e)
  local _infotip_object = G.OVERLAY_MENU:get_UIE_by_ID('overlay_menu_infotip')
  if (_infotip_object.config.set ~= e.config.ref_table.label) and (not G.F_NO_ACHIEVEMENTS) then 
    _infotip_object.config.object:remove() 
    _infotip_object.config.object = UIBox{
      definition = overlay_infotip({e.config.ref_table.warning[1],e.config.ref_table.warning[2],e.config.ref_table.warning[3], lang = e.config.ref_table}),
      config = {offset = {x=0,y=0}, align = 'bm', parent = _infotip_object}
    }
    _infotip_object.config.object.UIRoot:juice_up()
    _infotip_object.config.set = e.config.ref_table.label
    e.config.disable_button = true
    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06, blockable = false, blocking = false, func = function()
      play_sound('tarot2', 0.76, 0.4);return true end}))

    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.35, blockable = false, blocking = false, func = function()
      e.config.disable_button = nil;return true end}))
      e.config.button = 'change_lang'
    play_sound('tarot2', 1, 0.4)
  end
end



G.FUNCS.change_lang = function(e)
  local lang = e.config.ref_table
  if not lang or lang == G.LANG then 
    G.FUNCS.exit_overlay_menu()
  else
    G.SETTINGS.language = lang.key
    G:set_language()
    G.E_MANAGER:clear_queue()
    G.FUNCS.wipe_on()
    G.E_MANAGER:add_event(Event({
      no_delete = true,
      blockable = true, 
      blocking = false,
      func = function()
        G:delete_run()
        G:init_item_prototypes()
        if G and G.save_progress then
          pcall(function()
            G:save_progress()
          end)
        end
        G:main_menu()
        return true
      end
    }))
    G.FUNCS.wipe_off()
  end
end

G.FUNCS.copy_seed = function(e)
  if G.F_LOCAL_CLIPBOARD then
    G.CLIPBOARD = G.GAME.pseudorandom.seed
  else
    love.system.setClipboardText(G.GAME.pseudorandom.seed)
  end 
end

G.FUNCS.start_setup_run = function(e)
  if G.OVERLAY_MENU then G.FUNCS.exit_overlay_menu() end
  if G.SETTINGS.current_setup == 'New Run' then 
    if not G.GAME or (not G.GAME.won and not G.GAME.seeded) then
      if G.SAVED_GAME ~= nil then
        if not G.SAVED_GAME.GAME.won then 
          G.PROFILES[G.SETTINGS.profile].high_scores.current_streak.amt = 0
        end
        G:save_settings()
      end
    end
    local _seed = G.run_setup_seed and G.setup_seed or G.forced_seed or nil
    local _challenge = G.challenge_tab or nil
    local _stake = G.forced_stake or G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
    G.FUNCS.start_run(e, {stake = _stake, seed = _seed, challenge = _challenge})

  elseif G.SETTINGS.current_setup == 'Continue' then
    if G.SAVED_GAME ~= nil then
      G.FUNCS.start_run(nil, {savetext = G.SAVED_GAME})
    end
  end
end

G.FUNCS.start_challenge_run = function(e)
  if G.OVERLAY_MENU then G.FUNCS.exit_overlay_menu() end
  G.FUNCS.start_run(e, {stake = 1, challenge = G.CHALLENGES[e.config.id]})
end

function G.FUNCS.toggle_seeded_run(e)
  if e.config.object and not G.run_setup_seed then
    e.config.object:remove()
    e.config.object = nil
  elseif not e.config.object and G.run_setup_seed then
    e.config.object = UIBox{
      definition = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
        {n=G.UIT.C, config={align = "cm", minw = 2.5, padding = 0.05}, nodes={
          simple_text_container('ml_disabled_seed',{colour = G.C.UI.TEXT_LIGHT, scale = 0.26, shadow = true}),
        }},
        {n=G.UIT.C, config={align = "cm", minw = 0.1}, nodes={
          create_text_input({max_length = 8, all_caps = true, ref_table = G, ref_value = 'setup_seed', prompt_text = localize('k_enter_seed')}),
          {n=G.UIT.C, config={align = "cm", minw = 0.1}, nodes={}},
          UIBox_button({label = localize('ml_paste_seed'),minw = 1, minh = 0.6, button = 'paste_seed', colour = G.C.BLUE, scale = 0.3, col = true})
        }},

        {n=G.UIT.C, config={align = "cm", minw = 2.5}, nodes={
        }},
      }},
      config = {offset = {x=0,y=0}, parent = e, type = 'cm'}
    }
    e.config.object:recalculate()
  end
end

G.FUNCS.start_tutorial = function(e)
  if G.OVERLAY_MENU then G.FUNCS.exit_overlay_menu() end
  G.SETTINGS.tutorial_progress = 
  {
      forced_shop = {'j_joker', 'c_empress'},
      forced_voucher = 'v_grabber',
      forced_tags = {'tag_handy', 'tag_garbage'},
      hold_parts = {},
      completed_parts = {},
  }
  G.SETTINGS.tutorial_complete = false
  G.FUNCS.start_run(e)
end

G.FUNCS.chip_UI_set = function(e)
  local new_chips_text = number_format(G.GAME.chips)
  if G.GAME.chips_text ~= new_chips_text then
    e.config.scale = math.min(0.8, scale_number(G.GAME.chips, 1.1))
    G.GAME.chips_text = new_chips_text
  end
end

G.FUNCS.blind_chip_UI_scale = function(e)
  if G.GAME.blind and G.GAME.blind.chips then
    e.config.scale = scale_number(G.GAME.blind.chips, 0.7, 100000)
  end
end

function scale_number(number, scale, max)
  G.E_SWITCH_POINT = G.E_SWITCH_POINT or 100000000000
  if not number or type(number) ~= 'number' then return scale end
  if not max then max = 10000 end
  if number >= G.E_SWITCH_POINT then
    scale = scale*math.floor(math.log(max*10, 10))/math.floor(math.log(1000000*10, 10))
  elseif number >= max then
    scale = scale*math.floor(math.log(max*10, 10))/math.floor(math.log(number*10, 10))
  end
  return scale
end

G.FUNCS.hand_mult_UI_set = function(e)
  local new_mult_text = number_format(G.GAME.current_round.current_hand.mult)
  if new_mult_text ~= G.GAME.current_round.current_hand.mult_text then 
    G.GAME.current_round.current_hand.mult_text = new_mult_text
    e.config.object.scale = scale_number(G.GAME.current_round.current_hand.mult, 0.9, 1000)
    e.config.object:update_text()
    if not G.TAROT_INTERRUPT_PULSE then G.FUNCS.text_super_juice(e, math.max(0,math.floor(math.log10(type(G.GAME.current_round.current_hand.mult) == 'number' and G.GAME.current_round.current_hand.mult or 1)))) end
  end
end

G.FUNCS.hand_chip_UI_set = function(e)
  local new_chip_text = number_format(G.GAME.current_round.current_hand.chips)
    if new_chip_text ~= G.GAME.current_round.current_hand.chip_text then 
      G.GAME.current_round.current_hand.chip_text = new_chip_text
      e.config.object.scale = scale_number(G.GAME.current_round.current_hand.chips, 0.9, 1000)
      e.config.object:update_text()
      if not G.TAROT_INTERRUPT_PULSE then G.FUNCS.text_super_juice(e, math.max(0,math.floor(math.log10(type(G.GAME.current_round.current_hand.chips) == 'number' and G.GAME.current_round.current_hand.chips or 1)))) end
    end
end

G.FUNCS.hand_chip_total_UI_set = function(e)
  if G.GAME.current_round.current_hand.chip_total < 1 then
    G.GAME.current_round.current_hand.chip_total_text = ''
  else
    local new_chip_total_text = number_format(G.GAME.current_round.current_hand.chip_total)
    if new_chip_total_text ~= G.GAME.current_round.current_hand.chip_total_text then 
      e.config.object.scale = scale_number(G.GAME.current_round.current_hand.chip_total, 0.95, 100000000)
      
      G.GAME.current_round.current_hand.chip_total_text = new_chip_total_text
      if not G.ARGS.hand_chip_total_UI_set or G.ARGS.hand_chip_total_UI_set <  G.GAME.current_round.current_hand.chip_total then 
         G.FUNCS.text_super_juice(e, math.floor(math.log10(G.GAME.current_round.current_hand.chip_total)))
      end
      G.ARGS.hand_chip_total_UI_set = G.GAME.current_round.current_hand.chip_total
      --e.UIBox:recalculate()
    end
  end
end

function G.FUNCS.text_super_juice(e, _amount)
  e.config.object:set_quiver(0.03*_amount)
  e.config.object:pulse(0.3 + 0.08*_amount)
  e.config.object:update_text()
  e.config.object:align_letters()
  e:update_object()
end

G.FUNCS.flame_handler = function(e)
  G.C.UI_CHIPLICK = G.C.UI_CHIPLICK or {1, 1, 1, 1}
  G.C.UI_MULTLICK = G.C.UI_MULTLICK or {1, 1, 1, 1}
  for i=1, 3 do
    G.C.UI_CHIPLICK[i] = math.min(math.max(((G.C.UI_CHIPS[i]*0.5+G.C.YELLOW[i]*0.5) + 0.1)^2, 0.1), 1)
    G.C.UI_MULTLICK[i] = math.min(math.max(((G.C.UI_MULT[i]*0.5+G.C.YELLOW[i]*0.5) + 0.1)^2, 0.1), 1)
  end

  G.ARGS.flame_handler = G.ARGS.flame_handler or {
    chips = {
      id = 'flame_chips', 
      arg_tab = 'chip_flames',
      colour = G.C.UI_CHIPS,
      accent = G.C.UI_CHIPLICK
    },
    mult = {
      id = 'flame_mult', 
      arg_tab = 'mult_flames',
      colour = G.C.UI_MULT,
      accent = G.C.UI_MULTLICK
    }
  }
  for k, v in pairs(G.ARGS.flame_handler) do
    if e.config.id == v.id then 
      if not e.config.object:is(Sprite) or e.config.object.ID ~= v.ID then 
        e.config.object:remove()
        e.config.object = Sprite(0, 0, 2.5, 2.5, G.ASSET_ATLAS["ui_1"], {x = 2, y = 0})
        v.ID = e.config.object.ID
        G.ARGS[v.arg_tab] = {
            intensity = 0,
            real_intensity = 0,
            intensity_vel = 0,
            colour_1 = v.colour,
            colour_2 = v.accent,
            timer = G.TIMERS.REAL
        }      
        e.config.object:set_alignment({
            major = e.parent,
            type = 'bmi',
            offset = {x=0,y=0},
            xy_bond = 'Weak'
        })
        e.config.object:define_draw_steps({{
          shader = 'flame',
          send = {
              {name = 'time', ref_table = G.ARGS[v.arg_tab], ref_value = 'timer'},
              {name = 'amount', ref_table = G.ARGS[v.arg_tab], ref_value = 'real_intensity'},
              {name = 'image_details', ref_table = e.config.object, ref_value = 'image_dims'},
              {name = 'texture_details', ref_table = e.config.object.RETS, ref_value = 'get_pos_pixel'},
              {name = 'colour_1', ref_table =  G.ARGS[v.arg_tab], ref_value = 'colour_1'},
              {name = 'colour_2', ref_table =  G.ARGS[v.arg_tab], ref_value = 'colour_2'},
              {name = 'id', val =  e.config.object.ID},
          }}})
          e.config.object:get_pos_pixel()
      end
      local _F = G.ARGS[v.arg_tab]
      local exptime = math.exp(-0.4*G.real_dt)
      
      if G.ARGS.score_intensity.earned_score >= G.ARGS.score_intensity.required_score and G.ARGS.score_intensity.required_score > 0 then
        _F.intensity = ((G.pack_cards and not G.pack_cards.REMOVED) or (G.TAROT_INTERRUPT)) and 0 or math.max(0., math.log(G.ARGS.score_intensity.earned_score, 5)-2)
      else
        _F.intensity = 0
      end

      _F.timer = _F.timer + G.real_dt*(1 + _F.intensity*0.2)
      if _F.intensity_vel < 0 then _F.intensity_vel = _F.intensity_vel*(1 - 10*G.real_dt) end
      _F.intensity_vel = (1-exptime)*(_F.intensity - _F.real_intensity)*G.real_dt*25 + exptime*_F.intensity_vel
      _F.real_intensity = math.max(0, _F.real_intensity + _F.intensity_vel)
      _F.change = (_F.change or 0)*(1 - 4.*G.real_dt) + ( 4.*G.real_dt)*(_F.real_intensity < _F.intensity - 0.0 and 1 or 0)*_F.real_intensity
    end
  end
end

G.FUNCS.hand_text_UI_set = function(e)
  if G.GAME.current_round.current_hand.handname ~= G.GAME.current_round.current_hand.handname_text then 
    G.GAME.current_round.current_hand.handname_text = G.GAME.current_round.current_hand.handname
    if G.GAME.current_round.current_hand.handname:len() >= 13 then
      e.config.object.scale = 12*0.56/G.GAME.current_round.current_hand.handname:len()
    else
      e.config.object.scale = 2.4/math.sqrt(G.GAME.current_round.current_hand.handname:len()+5)
    end
    e.config.object:update_text()
  end
end

  G.FUNCS.can_play = function(e)
    if #G.hand.highlighted <= 0 or G.GAME.blind.block_play or #G.hand.highlighted > 5 then 
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = G.C.BLUE
        e.config.button = 'play_cards_from_highlighted'
    end
  end

  G.FUNCS.can_start_run = function(e)
    if not G.GAME.viewed_back.effect.center.unlocked then 
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = G.C.BLUE
        e.config.button = 'start_setup_run'
    end
  end

  G.FUNCS.visible_blind = function(e)
    if next(G.GAME.blind.config.blind) then 
        e.states.visible = true
    else
        e.states.visible = false
    end
  end

  G.FUNCS.can_reroll = function(e)
    if ((G.GAME.dollars-G.GAME.bankrupt_at) - G.GAME.current_round.reroll_cost < 0) and G.GAME.current_round.reroll_cost ~= 0 then 
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
        --e.children[1].children[1].config.shadow = false
        --e.children[2].children[1].config.shadow = false
        --e.children[2].children[2].config.shadow = false
    else
        e.config.colour = G.C.GREEN
        e.config.button = 'reroll_shop'
        --e.children[1].children[1].config.shadow = true
        --e.children[2].children[1].config.shadow = true
        --e.children[2].children[2].config.shadow = true
    end
  end

  G.FUNCS.can_discard = function(e)
    if G.GAME.current_round.discards_left <= 0 or #G.hand.highlighted <= 0 then 
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = G.C.RED
        e.config.button = 'discard_cards_from_highlighted'
    end
  end
  
  G.FUNCS.can_use_consumeable = function(e)
    if e.config.ref_table:can_use_consumeable() then 
        e.config.colour = G.C.RED
        e.config.button = 'use_card'
    else
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
    end
  end

  G.FUNCS.can_select_card = function(e)
    if e.config.ref_table.ability.set ~= 'Joker' or (e.config.ref_table.edition and e.config.ref_table.edition.negative) or #G.jokers.cards < G.jokers.config.card_limit then 
        e.config.colour = G.C.GREEN
        e.config.button = 'use_card'
    else
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
    end
  end

  G.FUNCS.can_sell_card = function(e)
    if e.config.ref_table:can_sell_card() then 
        e.config.colour = G.C.GREEN
        e.config.button = 'sell_card'
    else
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
    end
  end

  G.FUNCS.can_skip_booster = function(e)
    if G.pack_cards and (G.pack_cards.cards[1]) and 
    (G.STATE == G.STATES.PLANET_PACK or G.STATE == G.STATES.STANDARD_PACK or G.STATE == G.STATES.BUFFOON_PACK or (G.hand and (G.hand.cards[1] or (G.hand.config.card_limit <= 0)))) then 
        e.config.colour = G.C.GREY
        e.config.button = 'skip_booster'
    else
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
    end
  end

  G.FUNCS.show_infotip = function(e)
    if e.config.ref_table then 
      e.children.info = UIBox{
        definition = {n=G.UIT.ROOT, config = {align = 'cm', colour = G.C.CLEAR, padding = 0.02}, nodes=e.config.ref_table},
        config = {offset = {x=-0.03,y=0}, align = 'cl', parent = e}
      }
      e.children.info:align_to_major()
      e.config.ref_table = nil
    end
  end
  

  G.FUNCS.use_card = function(e, mute, nosave)
    e.config.button = nil
    local card = e.config.ref_table
    local area = card.area
    local prev_state = G.STATE
    local dont_dissolve = nil
    local delay_fac = 1

    if card:check_use() then 
      G.E_MANAGER:add_event(Event({func = function()
        e.disable_button = nil
        e.config.button = 'use_card'
      return true end }))
      return
    end

    if card.ability.set == 'Booster' and not nosave and G.STATE == G.STATES.SHOP then
      save_with_action({
        type = 'use_card',
        card = card.sort_id,
      })
    end

    G.TAROT_INTERRUPT = G.STATE
    if card.ability.set == 'Booster' then G.GAME.PACK_INTERRUPT = G.STATE end 
    G.STATE = (G.STATE == G.STATES.TAROT_PACK and G.STATES.TAROT_PACK) or
      (G.STATE == G.STATES.PLANET_PACK and G.STATES.PLANET_PACK) or
      (G.STATE == G.STATES.SPECTRAL_PACK and G.STATES.SPECTRAL_PACK) or
      (G.STATE == G.STATES.STANDARD_PACK and G.STATES.STANDARD_PACK) or
      (G.STATE == G.STATES.BUFFOON_PACK and G.STATES.BUFFOON_PACK) or
      G.STATES.PLAY_TAROT
      
    G.CONTROLLER.locks.use = true
    if G.booster_pack and not G.booster_pack.alignment.offset.py and (card.ability.consumeable or not (G.GAME.pack_choices and G.GAME.pack_choices > 1)) then
      G.booster_pack.alignment.offset.py = G.booster_pack.alignment.offset.y
      G.booster_pack.alignment.offset.y = G.ROOM.T.y + 29
    end
    if G.shop and not G.shop.alignment.offset.py then
      G.shop.alignment.offset.py = G.shop.alignment.offset.y
      G.shop.alignment.offset.y = G.ROOM.T.y + 29
    end
    if G.blind_select and not G.blind_select.alignment.offset.py then
      G.blind_select.alignment.offset.py = G.blind_select.alignment.offset.y
      G.blind_select.alignment.offset.y = G.ROOM.T.y + 39
    end
    if G.round_eval and not G.round_eval.alignment.offset.py then
      G.round_eval.alignment.offset.py = G.round_eval.alignment.offset.y
      G.round_eval.alignment.offset.y = G.ROOM.T.y + 29
    end

    if card.children.use_button then card.children.use_button:remove(); card.children.use_button = nil end
    if card.children.sell_button then card.children.sell_button:remove(); card.children.sell_button = nil end
    if card.children.price then card.children.price:remove(); card.children.price = nil end

    if card.area then card.area:remove_card(card) end
    
    if card.ability.consumeable then
      if G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.PLANET_PACK or G.STATE == G.STATES.SPECTRAL_PACK then
        card.T.x = G.hand.T.x + G.hand.T.w/2 - card.T.w/2
        card.T.y = G.hand.T.y + G.hand.T.h/2 - card.T.h/2 - 0.5
        discover_card(card.config.center)
      else draw_card(G.hand, G.play, 1, 'up', true, card, nil, mute) end
      delay(0.2)
      e.config.ref_table:use_consumeable(area)
      for i = 1, #G.jokers.cards do
        G.jokers.cards[i]:calculate_joker({using_consumeable = true, consumeable = card})
      end
    elseif card.ability.set == 'Enhanced' or card.ability.set == 'Default' then 
      G.playing_card = (G.playing_card and G.playing_card + 1) or 1
      G.deck:emplace(card)
      play_sound('card1', 0.8, 0.6)
      play_sound('generic1')
      card.playing_card = G.playing_card
      playing_card_joker_effects({card})
      card:add_to_deck()
      table.insert(G.playing_cards, card)
      dont_dissolve = true
      delay_fac = 0.2
    elseif card.ability.set == 'Joker' then 
      card:add_to_deck()
      G.jokers:emplace(card)
      play_sound('card1', 0.8, 0.6)
      play_sound('generic1')
      dont_dissolve = true
      delay_fac = 0.2
    elseif card.ability.set == 'Booster' then 
      delay(0.1)
      if card.ability.booster_pos then G.GAME.current_round.used_packs[card.ability.booster_pos] = 'USED' end
      draw_card(G.hand, G.play, 1, 'up', true, card, nil, true) 
      if not card.from_tag then 
        G.GAME.round_scores.cards_purchased.amt = G.GAME.round_scores.cards_purchased.amt + 1
      end
      e.config.ref_table:open()
    elseif card.ability.set == 'Voucher' then 
      delay(0.1)
      draw_card(G.hand, G.play, 1, 'up', true, card, nil, true) 
      G.GAME.round_scores.cards_purchased.amt = G.GAME.round_scores.cards_purchased.amt + 1
      e.config.ref_table:redeem()
    end
    if card.ability.set == 'Booster' then
      G.CONTROLLER.locks.use = false
      G.TAROT_INTERRUPT = nil
    else
        G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.2,
        func = function()
            if not dont_dissolve then card:start_dissolve() end
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,
            func = function()
                G.STATE = prev_state
                G.TAROT_INTERRUPT=nil
                G.CONTROLLER.locks.use = false

                if (prev_state == G.STATES.TAROT_PACK or prev_state == G.STATES.PLANET_PACK or
                  prev_state == G.STATES.SPECTRAL_PACK or prev_state == G.STATES.STANDARD_PACK or
                  prev_state == G.STATES.BUFFOON_PACK) and G.booster_pack then
                  if area == G.consumeables then
                    G.booster_pack.alignment.offset.y = G.booster_pack.alignment.offset.py
                    G.booster_pack.alignment.offset.py = nil
                  elseif G.GAME.pack_choices and G.GAME.pack_choices > 1 then
                    if G.booster_pack.alignment.offset.py then 
                      G.booster_pack.alignment.offset.y = G.booster_pack.alignment.offset.py
                      G.booster_pack.alignment.offset.py = nil
                    end
                    G.GAME.pack_choices = G.GAME.pack_choices - 1
                  else
                      G.CONTROLLER.interrupt.focus = true
                      if prev_state == G.STATES.TAROT_PACK then inc_career_stat('c_tarot_reading_used', 1) end
                      if prev_state == G.STATES.PLANET_PACK then inc_career_stat('c_planetarium_used', 1) end
                      G.FUNCS.end_consumeable(nil, delay_fac)
                  end
                else
                  if G.shop then 
                    G.shop.alignment.offset.y = G.shop.alignment.offset.py
                    G.shop.alignment.offset.py = nil
                  end
                  if G.blind_select then
                    G.blind_select.alignment.offset.y = G.blind_select.alignment.offset.py
                    G.blind_select.alignment.offset.py = nil
                  end
                  if G.round_eval then
                    G.round_eval.alignment.offset.y = G.round_eval.alignment.offset.py
                    G.round_eval.alignment.offset.py = nil
                  end
                  if area and area.cards[1] then 
                    G.E_MANAGER:add_event(Event({func = function()
                      G.E_MANAGER:add_event(Event({func = function()
                        G.CONTROLLER.interrupt.focus = nil
                        if card.ability.set == 'Voucher' then 
                          G.CONTROLLER:snap_to({node = G.shop:get_UIE_by_ID('next_round_button')})
                        elseif area then
                          G.CONTROLLER:recall_cardarea_focus(area)
                        end
                      return true end }))
                    return true end }))
                  end
                end
            return true
          end}))
        return true
      end}))
    end
  end

  G.FUNCS.sell_card = function(e)
    local card = e.config.ref_table
    card:sell_card()
    for i = 1, #G.jokers.cards do
      if G.jokers.cards[i] ~= card then 
        G.jokers.cards[i]:calculate_joker({selling_card = true, card = card})
      end
    end
  end

  G.FUNCS.can_confirm_contest_name = function(e)
    if G.SETTINGS.COMP and G.SETTINGS.COMP.name ~= '' then 
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = G.C.PALE_GREEN
        e.config.button = 'confirm_contest_name'
    end
  end

  G.FUNCS.confirm_contest_name = function(e)
    G.SETTINGS.COMP.submission_name = true
    if G.MAIN_MENU_UI then G.MAIN_MENU_UI:remove() end
    if G.PROFILE_BUTTON then G.PROFILE_BUTTON:remove() end
    set_main_menu_UI()
    G:save_progress()
    G.FILE_HANDLER.force = true
  end

  G.FUNCS.change_contest_name = function(e)
    G.SETTINGS.COMP.name = ''
    if G.MAIN_MENU_UI then G.MAIN_MENU_UI:remove() end
    if G.PROFILE_BUTTON then G.PROFILE_BUTTON:remove() end
    set_main_menu_UI()
  end

  G.FUNCS.skip_tutorial_section = function(e)
    G.OVERLAY_TUTORIAL.skip_steps = true

    if G.OVERLAY_TUTORIAL.Jimbo then G.OVERLAY_TUTORIAL.Jimbo:remove() end
    if G.OVERLAY_TUTORIAL.content then G.OVERLAY_TUTORIAL.content:remove() end
    G.OVERLAY_TUTORIAL:remove()
    G.OVERLAY_TUTORIAL = nil
    G.E_MANAGER:clear_queue('tutorial')
    if G.SETTINGS.tutorial_progress.section == 'small_blind' then
      G.SETTINGS.tutorial_progress.completed_parts['small_blind']  = true
    elseif G.SETTINGS.tutorial_progress.section == 'big_blind' then
      G.SETTINGS.tutorial_progress.completed_parts['big_blind']  = true
      G.SETTINGS.tutorial_progress.forced_tags = nil
    elseif G.SETTINGS.tutorial_progress.section == 'second_hand' then
      G.SETTINGS.tutorial_progress.completed_parts['second_hand']  = true
      G.SETTINGS.tutorial_progress.hold_parts['second_hand'] = true
    elseif G.SETTINGS.tutorial_progress.section == 'first_hand' then
      G.SETTINGS.tutorial_progress.completed_parts['first_hand']  = true
      G.SETTINGS.tutorial_progress.completed_parts['first_hand_2']  = true
      G.SETTINGS.tutorial_progress.completed_parts['first_hand_3']  = true
      G.SETTINGS.tutorial_progress.completed_parts['first_hand_4']  = true
      G.SETTINGS.tutorial_progress.completed_parts['first_hand_section']  = true
    elseif G.SETTINGS.tutorial_progress.section == 'shop' then
      G.SETTINGS.tutorial_progress.completed_parts['shop_1']  = true
      G.SETTINGS.tutorial_progress.forced_voucher = nil
    end     
  end

G.FUNCS.shop_voucher_empty = function(e)
  if (G.shop_vouchers and G.shop_vouchers.cards and (G.shop_vouchers.cards[1] or G.GAME.current_round.voucher)) then
    e.states.visible = false
  elseif G.SETTINGS.language ~= 'en-us' then 
    e.states.visible = false
  else
    e.states.visible = true
  end
end

G.FUNCS.check_for_buy_space = function(card)
  if card.ability.set ~= 'Voucher' and
    card.ability.set ~= 'Enhanced' and
    card.ability.set ~= 'Default' and
    not (card.ability.set == 'Joker' and #G.jokers.cards < G.jokers.config.card_limit + ((card.edition and card.edition.negative) and 1 or 0)) and
    not (card.ability.consumeable and #G.consumeables.cards < G.consumeables.config.card_limit + ((card.edition and card.edition.negative) and 1 or 0)) then
      alert_no_space(card, card.ability.consumeable and G.consumeables or G.jokers)
    return false
  end
  return true
end

G.FUNCS.buy_from_shop = function(e)
    local c1 = e.config.ref_table
    if c1 and c1:is(Card) then
      if e.config.id ~= 'buy_and_use' then
        if not G.FUNCS.check_for_buy_space(c1) then
          e.disable_button = nil
          return false
        end
      end
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.1,
        func = function()
          c1.area:remove_card(c1)
          c1:add_to_deck()
          if c1.children.price then c1.children.price:remove() end
          c1.children.price = nil
          if c1.children.buy_button then c1.children.buy_button:remove() end
          c1.children.buy_button = nil
          remove_nils(c1.children)
          if c1.ability.set == 'Default' or c1.ability.set == 'Enhanced' then
            inc_career_stat('c_playing_cards_bought', 1)
            G.playing_card = (G.playing_card and G.playing_card + 1) or 1
            G.deck:emplace(c1)
            c1.playing_card = G.playing_card
            playing_card_joker_effects({c1})
            table.insert(G.playing_cards, c1)
          elseif e.config.id ~= 'buy_and_use' then
            if c1.ability.consumeable then
              G.consumeables:emplace(c1)
            else
              G.jokers:emplace(c1)
            end
            G.E_MANAGER:add_event(Event({func = function() c1:calculate_joker({buying_card = true, card = c1}) return true end}))
          end
          --Tallies for unlocks
          G.GAME.round_scores.cards_purchased.amt = G.GAME.round_scores.cards_purchased.amt + 1
          if c1.ability.consumeable then
            if c1.config.center.set == 'Planet' then
              inc_career_stat('c_planets_bought', 1)
            elseif c1.config.center.set == 'Tarot' then
              inc_career_stat('c_tarots_bought', 1)
            end
          elseif c1.ability.set == 'Joker' then
            G.GAME.current_round.jokers_purchased = G.GAME.current_round.jokers_purchased + 1
          end

          for i = 1, #G.jokers.cards do
            G.jokers.cards[i]:calculate_joker({buying_card = true, card = c1})
          end

          if G.GAME.modifiers.inflation then 
            G.GAME.inflation = G.GAME.inflation + 1
            G.E_MANAGER:add_event(Event({func = function()
              for k, v in pairs(G.I.CARD) do
                  if v.set_cost then v:set_cost() end
              end
              return true end }))
          end

          play_sound('card1')
          inc_career_stat('c_shop_dollars_spent', c1.cost)
          if c1.cost ~= 0 then
            ease_dollars(-c1.cost)
          end
          G.CONTROLLER:save_cardarea_focus('jokers')
          G.CONTROLLER:recall_cardarea_focus('jokers')

          if e.config.id == 'buy_and_use' then 
            G.FUNCS.use_card(e, true)
          end
          return true
        end
      }))
    end
end
  
  G.FUNCS.toggle_shop = function(e)
    stop_use()
    G.CONTROLLER.locks.toggle_shop = true
    if G.shop then 
      for i = 1, #G.jokers.cards do
        G.jokers.cards[i]:calculate_joker({ending_shop = true})
      end
      G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
          G.shop.alignment.offset.y = G.ROOM.T.y + 29
          G.SHOP_SIGN.alignment.offset.y = -15
          return true
        end
      })) 
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.5,
        func = function()
          G.shop:remove()
          G.shop = nil
          G.SHOP_SIGN:remove()
          G.SHOP_SIGN = nil
          G.STATE_COMPLETE = false
          G.STATE = G.STATES.BLIND_SELECT
          G.CONTROLLER.locks.toggle_shop = nil
          return true
        end
      }))
    end
  end

  G.FUNCS.select_blind = function(e)
    stop_use()
    if G.blind_select then 
        G.GAME.facing_blind = true
        G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext1').config.object.pop_delay = 0
        G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext1').config.object:pop_out(5)
        G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext2').config.object.pop_delay = 0
        G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext2').config.object:pop_out(5) 

        G.E_MANAGER:add_event(Event({
          trigger = 'before', delay = 0.2,
          func = function()
            G.blind_prompt_box.alignment.offset.y = -10
            G.blind_select.alignment.offset.y = 40
            G.blind_select.alignment.offset.x = 0
            return true
        end}))
        G.E_MANAGER:add_event(Event({
          trigger = 'immediate',
          func = function()
            ease_round(1)
            inc_career_stat('c_rounds', 1)
            if _DEMO then
              G.SETTINGS.DEMO_ROUNDS = (G.SETTINGS.DEMO_ROUNDS or 0) + 1
              inc_steam_stat('demo_rounds')
              G:save_settings()
            end
            G.GAME.round_resets.blind = e.config.ref_table
            G.GAME.round_resets.blind_states[G.GAME.blind_on_deck] = 'Current'
            G.blind_select:remove()
            G.blind_prompt_box:remove()
            G.blind_select = nil
            delay(0.2)
            return true
        end}))
        G.E_MANAGER:add_event(Event({
          trigger = 'immediate',
          func = function()
            new_round()
            return true
          end
        }))
    end
  end

  G.FUNCS.skip_booster = function(e)
    for i = 1, #G.jokers.cards do
      G.jokers.cards[i]:calculate_joker({skipping_booster = true})
    end
    G.FUNCS.end_consumeable(e)
  end

  G.FUNCS.end_consumeable = function(e, delayfac)
    delayfac = delayfac or 1
    stop_use()
    if G.booster_pack then
      if G.booster_pack_sparkles then G.booster_pack_sparkles:fade(1*delayfac) end
      if G.booster_pack_stars then G.booster_pack_stars:fade(1*delayfac) end
      if G.booster_pack_meteors then G.booster_pack_meteors:fade(1*delayfac) end
      G.booster_pack.alignment.offset.y = G.ROOM.T.y + 9

      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.2*delayfac,blocking = false, blockable = false,
      func = function()
          G.booster_pack:remove()
          G.booster_pack = nil
        return true
      end}))
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 1*delayfac,blocking = false, blockable = false,
      func = function()
        if G.booster_pack_sparkles then G.booster_pack_sparkles:remove(); G.booster_pack_sparkles = nil end
        if G.booster_pack_stars then G.booster_pack_stars:remove(); G.booster_pack_stars = nil end
        if G.booster_pack_meteors then G.booster_pack_meteors:remove(); G.booster_pack_meteors = nil end
        return true
      end}))
    end

    delay(0.2*delayfac)
    G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.2*delayfac,
    func = function()
      G.FUNCS.draw_from_hand_to_deck()
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.2*delayfac,
          func = function()
                if G.shop and G.shop.alignment.offset.py then 
                  G.shop.alignment.offset.y = G.shop.alignment.offset.py
                  G.shop.alignment.offset.py = nil
                end
                if G.blind_select and G.blind_select.alignment.offset.py then
                  G.blind_select.alignment.offset.y = G.blind_select.alignment.offset.py
                  G.blind_select.alignment.offset.py = nil
                end
                if G.round_eval and G.round_eval.alignment.offset.py then
                  G.round_eval.alignment.offset.y = G.round_eval.alignment.offset.py
                  G.round_eval.alignment.offset.py = nil
                end
                G.CONTROLLER.interrupt.focus = true
                
                G.E_MANAGER:add_event(Event({func = function()        
                    if G.shop then G.CONTROLLER:snap_to({node = G.shop:get_UIE_by_ID('next_round_button')}) end
                return true end }))
                G.STATE = G.GAME.PACK_INTERRUPT
                ease_background_colour_blind(G.GAME.PACK_INTERRUPT)
                G.GAME.PACK_INTERRUPT = nil
          return true
      end}))
      for i = 1, #G.GAME.tags do
        if G.GAME.tags[i]:apply_to_run({type = 'new_blind_choice'}) then break end
      end

      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.2*delayfac,
          func = function()
            save_run()
            return true
      end}))

      return true
    end}))
  end

  G.FUNCS.blind_choice_handler = function(e)
    if not e.config.ref_table.run_info and G.blind_select and G.blind_select.VT.y < 10 and e.config.id and G.blind_select_opts[string.lower(e.config.id)] then 
      if e.UIBox.role.xy_bond ~= 'Weak' then e.UIBox:set_role({xy_bond = 'Weak'}) end
      if (e.config.ref_table.deck ~= 'on' and e.config.id == G.GAME.blind_on_deck) or
         (e.config.ref_table.deck ~= 'off' and e.config.id ~= G.GAME.blind_on_deck) then

          local _blind_choice = G.blind_select_opts[string.lower(e.config.id)]
          local _top_button = e.UIBox:get_UIE_by_ID('select_blind_button')
          local _border = e.UIBox.UIRoot.children[1].children[1]
          local _tag = e.UIBox:get_UIE_by_ID('tag_'..e.config.id)
          local _tag_container = e.UIBox:get_UIE_by_ID('tag_container')
          if _tag_container and not G.SETTINGS.tutorial_complete and not G.SETTINGS.tutorial_progress.completed_parts['shop_1'] then _tag_container.states.visible = false
          elseif _tag_container then  _tag_container.states.visible = true end
          if e.config.id == G.GAME.blind_on_deck then
            e.config.ref_table.deck = 'on'
            e.config.draw_after = false
            e.config.colour = G.C.CLEAR
            _border.parent.config.outline = 2
            _border.parent.config.outline_colour = G.C.UI.TRANSPARENT_DARK
            _border.config.outline_colour = _border.config.outline and _border.config.outline_colour or get_blind_main_colour(e.config.id)
            _border.config.outline = 1.5
            _blind_choice.alignment.offset.y = -0.9
            if _tag and _tag_container then 
              _tag_container.children[2].config.draw_after = false
              _tag_container.children[2].config.colour = G.C.BLACK
              _tag.children[2].config.button = 'skip_blind'
              _tag.config.outline_colour = adjust_alpha(G.C.BLUE, 0.5)
              _tag.children[2].config.hover = true
              _tag.children[2].config.colour = G.C.RED
              _tag.children[2].children[1].config.colour = G.C.UI.TEXT_LIGHT
              local _sprite = _tag.config.ref_table
              _sprite.config.force_focus = nil
            end
            if _top_button then
              G.E_MANAGER:add_event(Event({func = function()
                G.CONTROLLER:snap_to({node = _top_button})
              return true end }))
              _top_button.config.button = 'select_blind'
              _top_button.config.colour = G.C.FILTER
              _top_button.config.hover = true
              _top_button.children[1].config.colour = G.C.WHITE
            end
          elseif e.config.id ~= G.GAME.blind_on_deck then 
            e.config.ref_table.deck = 'off'
            e.config.draw_after = true
            e.config.colour = adjust_alpha(G.GAME.round_resets.blind_states[e.config.id] == 'Skipped' and mix_colours(G.C.BLUE, G.C.L_BLACK, 0.1) or G.C.L_BLACK, 0.5)
            _border.parent.config.outline = nil
            _border.parent.config.outline_colour = nil
            _border.config.outline_colour = nil
            _border.config.outline = nil
            _blind_choice.alignment.offset.y = -0.2
            if _tag and _tag_container then 
              if G.GAME.round_resets.blind_states[e.config.id] == 'Skipped' or
                 G.GAME.round_resets.blind_states[e.config.id] == 'Defeated' then
                _tag_container.children[2]:set_role({xy_bond = 'Weak'})
                _tag_container.children[2]:align(0, 10)
                _tag_container.children[1]:set_role({xy_bond = 'Weak'})
                _tag_container.children[1]:align(0, 10)
              end
              if G.GAME.round_resets.blind_states[e.config.id] == 'Skipped' then
                _blind_choice.children.alert = UIBox{
                  definition = create_UIBox_card_alert({text_rot = -0.35, no_bg = true,text = localize('k_skipped_cap'), bump_amount = 1, scale = 0.9, maxw = 3.4}),
                  config = {
                    align="tmi",
                    offset = {x = 0, y = 2.2},
                    major = _blind_choice, parent = _blind_choice}
                }
              end
              _tag.children[2].config.button = nil
              _tag.config.outline_colour = G.C.UI.BACKGROUND_INACTIVE
              _tag.children[2].config.hover = false
              _tag.children[2].config.colour = G.C.UI.BACKGROUND_INACTIVE
              _tag.children[2].children[1].config.colour = G.C.UI.TEXT_INACTIVE
              local _sprite = _tag.config.ref_table
              _sprite.config.force_focus = true
            end
            if _top_button then 
              _top_button.config.colour = G.C.UI.BACKGROUND_INACTIVE
              _top_button.config.button = nil
              _top_button.config.hover = false
              _top_button.children[1].config.colour = G.C.UI.TEXT_INACTIVE
            end
          end
      end
    end
  end

  G.FUNCS.hover_tag_proxy = function(e)
    if not e.parent or not e.parent.states then return end
    if (e.states.hover.is or e.parent.states.hover.is) and (e.created_on_pause == G.SETTINGS.paused) and
      not e.parent.children.alert then
        local _sprite = e.config.ref_table:get_uibox_table()
        e.parent.children.alert = UIBox{
          definition = G.UIDEF.card_h_popup(_sprite),
          config = {align="tm", offset = {x = 0, y = -0.1},
          major = e.parent,
          instance_type = 'POPUP'},
      }
      _sprite:juice_up(0.05, 0.02)
      play_sound('paper1', math.random()*0.1 + 0.55, 0.42)
      play_sound('tarot2', math.random()*0.1 + 0.55, 0.09)
      e.parent.children.alert.states.collide.can = false
    elseif e.parent.children.alert and
    ((not e.states.collide.is and not e.parent.states.collide.is) or (e.created_on_pause ~= G.SETTINGS.paused)) then
      e.parent.children.alert:remove()
      e.parent.children.alert = nil
    end
  end

  G.FUNCS.skip_blind = function(e)
    stop_use()
    G.CONTROLLER.locks.skip_blind = true
    G.E_MANAGER:add_event(Event({
        no_delete = true,
        trigger = 'after',
        blocking = false,blockable = false,
        delay = 2.5,
        timer = 'TOTAL',
        func = function()
          G.CONTROLLER.locks.skip_blind = nil
          return true
        end
      }))
    local _tag = e.UIBox:get_UIE_by_ID('tag_container')
    G.GAME.skips = (G.GAME.skips or 0) + 1
    if _tag then 
      add_tag(_tag.config.ref_table)
      local skipped, skip_to = G.GAME.blind_on_deck or 'Small', 
      G.GAME.blind_on_deck == 'Small' and 'Big' or G.GAME.blind_on_deck == 'Big' and 'Boss' or 'Boss'
      G.GAME.round_resets.blind_states[skipped] = 'Skipped'
      G.GAME.round_resets.blind_states[skip_to] = 'Select'
      G.GAME.blind_on_deck = skip_to
      play_sound('generic1')
      G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
          delay(0.3)
          for i = 1, #G.jokers.cards do
            G.jokers.cards[i]:calculate_joker({skip_blind = true})
          end
          save_run()
          for i = 1, #G.GAME.tags do
            G.GAME.tags[i]:apply_to_run({type = 'immediate'})
          end
          for i = 1, #G.GAME.tags do
            if G.GAME.tags[i]:apply_to_run({type = 'new_blind_choice'}) then break end
          end
          return true
        end
      }))
    end
  end

  G.FUNCS.reroll_boss_button = function(e)
    if ((G.GAME.dollars-G.GAME.bankrupt_at) - 10 >= 0) and
      (G.GAME.used_vouchers["v_retcon"] or
      (G.GAME.used_vouchers["v_directors_cut"] and not G.GAME.round_resets.boss_rerolled)) then 
        e.config.colour = G.C.RED
        e.config.button = 'reroll_boss'
        e.children[1].children[1].config.shadow = true
        if e.children[2] then e.children[2].children[1].config.shadow = true end 
    else
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
      e.children[1].children[1].config.shadow = false
      if e.children[2] then e.children[2].children[1].config.shadow = false end 
    end
  end

  G.FUNCS.reroll_boss = function(e) 
    stop_use()
    G.GAME.round_resets.boss_rerolled = true
    if not G.from_boss_tag then ease_dollars(-10) end
    G.from_boss_tag = nil
    G.CONTROLLER.locks.boss_reroll = true
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
          play_sound('other1')
          G.blind_select_opts.boss:set_role({xy_bond = 'Weak'})
          G.blind_select_opts.boss.alignment.offset.y = 20
          return true
        end
      }))
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.3,
      func = (function()
        local par = G.blind_select_opts.boss.parent
        G.GAME.round_resets.blind_choices.Boss = get_new_boss()

        G.blind_select_opts.boss:remove()
        G.blind_select_opts.boss = UIBox{
          T = {par.T.x, 0, 0, 0, },
          definition =
            {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
              UIBox_dyn_container({create_UIBox_blind_choice('Boss')},false,get_blind_main_colour('Boss'), mix_colours(G.C.BLACK, get_blind_main_colour('Boss'), 0.8))
            }},
          config = {align="bmi",
                    offset = {x=0,y=G.ROOM.T.y + 9},
                    major = par,
                    xy_bond = 'Weak'
                  }
        }
        par.config.object = G.blind_select_opts.boss
        par.config.object:recalculate()
        G.blind_select_opts.boss.parent = par
        G.blind_select_opts.boss.alignment.offset.y = 0
        
        G.E_MANAGER:add_event(Event({blocking = false, trigger = 'after', delay = 0.5,func = function()
            G.CONTROLLER.locks.boss_reroll = nil
            return true
          end
        }))

        save_run()
        for i = 1, #G.GAME.tags do
          if G.GAME.tags[i]:apply_to_run({type = 'new_blind_choice'}) then break end
        end
          return true
      end)
    }))
  end

  G.FUNCS.reroll_shop = function(e) 
    stop_use()
    G.CONTROLLER.locks.shop_reroll = true
    if G.CONTROLLER:save_cardarea_focus('shop_jokers') then G.CONTROLLER.interrupt.focus = true end
    if G.GAME.current_round.reroll_cost > 0 then 
      inc_career_stat('c_shop_dollars_spent', G.GAME.current_round.reroll_cost)
      inc_career_stat('c_shop_rerolls', 1)
      ease_dollars(-G.GAME.current_round.reroll_cost)
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
          local final_free = G.GAME.current_round.free_rerolls > 0
          G.GAME.current_round.free_rerolls = math.max(G.GAME.current_round.free_rerolls - 1, 0)
          G.GAME.round_scores.times_rerolled.amt = G.GAME.round_scores.times_rerolled.amt + 1

          calculate_reroll_cost(final_free)
          for i = #G.shop_jokers.cards,1, -1 do
            local c = G.shop_jokers:remove_card(G.shop_jokers.cards[i])
            c:remove()
            c = nil
          end

          --save_run()

          play_sound('coin2')
          play_sound('other1')
          
          -- Create shop cards incrementally in small batches to avoid long frame stalls in the browser
          do
            local to_make = G.GAME.shop.joker_max - #G.shop_jokers.cards
            if to_make > 0 then
              local i = 0
              local batch = 4
              G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0,
                blockable = false,
                blocking = false,
                func = function()
                  local made = 0
                  while i < to_make and made < batch do
                    i = i + 1
                    local new_shop_card = create_card_for_shop(G.shop_jokers)
                    G.shop_jokers:emplace(new_shop_card)
                    new_shop_card:juice_up()
                    made = made + 1
                  end
                  if i >= to_make then return true end
                  return false
                end
              }))
            end
          end
          return true
        end
      }))
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.3,
        func = function()
        G.E_MANAGER:add_event(Event({
          func = function()
            G.CONTROLLER.interrupt.focus = false
            G.CONTROLLER.locks.shop_reroll = false
            G.CONTROLLER:recall_cardarea_focus('shop_jokers')
            for i = 1, #G.jokers.cards do
              G.jokers.cards[i]:calculate_joker({reroll_shop = true})
            end
            return true
          end
        }))
        return true
      end
    }))
    G.E_MANAGER:add_event(Event({ func = function() save_run(); return true end}))
  end

G.FUNCS.cash_out = function(e)
    stop_use()
      if G.round_eval then  
        e.config.button = nil
        G.round_eval.alignment.offset.y = G.ROOM.T.y + 15
        G.round_eval.alignment.offset.x = 0
        G.deck:shuffle('cashout'..G.GAME.round_resets.ante)
        G.deck:hard_set_T()
        delay(0.3)
        G.E_MANAGER:add_event(Event({
          trigger = 'immediate',
          func = function()
              if G.round_eval then 
                G.round_eval:remove()
                G.round_eval = nil
              end
              G.GAME.current_round.jokers_purchased = 0
              G.GAME.current_round.discards_left = math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards)
              G.GAME.current_round.hands_left = (math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands))
              G.STATE = G.STATES.SHOP
              G.GAME.shop_free = nil
              G.GAME.shop_d6ed = nil
              G.STATE_COMPLETE = false
            return true
          end
        }))
        ease_dollars(G.GAME.current_round.dollars)
        G.E_MANAGER:add_event(Event({
          func = function()
              G.GAME.previous_round.dollars = G.GAME.dollars
            return true
          end
        }))
        play_sound("coin7")
        G.VIBRATION = G.VIBRATION + 1
      end
      ease_chips(0)
      if G.GAME.round_resets.blind_states.Boss == 'Defeated' then 
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.ante
        local next_ante = G.GAME.round_resets.ante + 1
        local seed_suffix = G.GAME.pseudorandom and G.GAME.pseudorandom.seed and ('_seed_'..G.GAME.pseudorandom.seed) or ''
        G.GAME.round_resets.blind_tags.Small = get_next_tag_key('small_ante'..next_ante..seed_suffix)
        G.GAME.round_resets.blind_tags.Big = get_next_tag_key('big_ante'..next_ante..seed_suffix)
      end
      reset_blinds()
      delay(0.6)
end

G.FUNCS.start_run = function(e, args) 
  G.SETTINGS.paused = true
  if e and e.config.id == 'restart_button' then G.GAME.viewed_back = nil end
  G.E_MANAGER:clear_queue()
  G.FUNCS.wipe_on()
  G.E_MANAGER:add_event(Event({
    no_delete = true,
    func = function()
      G:delete_run()
      return true
    end
  }))
  G.E_MANAGER:add_event(Event({
    trigger = 'immediate',
    no_delete = true,
    func = function()
      G:start_run(args)
      return true
    end
  }))
  G.FUNCS.wipe_off()
end

G.FUNCS.go_to_menu = function(e)
  G.SETTINGS.paused = true
  G.E_MANAGER:clear_queue()
  G.FUNCS.wipe_on()
  G.E_MANAGER:add_event(Event({
    no_delete = true,
    func = function()
      if G and G.save_progress then
        pcall(function()
          G:save_progress()
        end)
      end
      save_run()
      if G.IS_WEB and process_save_request and G.ARGS and G.ARGS.save_run then
        pcall(function()
          process_save_request({
            type = 'save_run',
            save_table = G.ARGS.save_run,
            profile_num = G.SETTINGS.profile
          })
        end)
        G.FILE_HANDLER.run = nil
      end

      local profile_num = tostring(G.SETTINGS.profile or 1)
      local saved_blob = get_compressed(profile_num .. '/save.jkr')
      if saved_blob then
        print('[SAVE_DUMP_BEGIN]')
        print(saved_blob)
        print('[SAVE_DUMP_END]')

        local ok_unpack, unpacked = pcall(STR_UNPACK, saved_blob)
        if ok_unpack and unpacked then
          G.SAVED_GAME = unpacked
          local ok_pack, repacked = pcall(STR_PACK, unpacked)
          if ok_pack and repacked then
            print('[SAVE_DUMP_PARSED_BEGIN]')
            print(repacked)
            print('[SAVE_DUMP_PARSED_END]')
          end
        else
          print('[SAVE_DUMP_PARSE_ERROR]', tostring(unpacked))
        end
      else
        print('[SAVE_DUMP_MISSING]', profile_num .. '/save.jkr')
      end
      G:delete_run()
      return true
    end
  }))
  G.E_MANAGER:add_event(Event({
    no_delete = true,
    blockable = true, 
    blocking = false,
    func = function()
      G:main_menu('game')
      return true
    end
  }))
  G.FUNCS.wipe_off()
end

G.FUNCS.go_to_demo_cta = function(e)
  G.SETTINGS.paused = true
  G.E_MANAGER:clear_queue(nil, G.exception_queue)
  play_sound('explosion_buildup1', nil, 0.3)
  play_sound('whoosh1', 0.7, 0.8)
  play_sound('introPad1', 0.704, 0.8)
  G.video_organ = 0.6
  G.FUNCS.wipe_on(nil, true, nil, G.C.WHITE)
  G.E_MANAGER:add_event(Event({
    no_delete = true,
    func = function()
      G:delete_run()
      return true
    end
  }))
  G.E_MANAGER:add_event(Event({
    no_delete = true,
    blockable = true, 
    blocking = false,
    func = function()
      G:demo_cta()
      G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3,
      no_delete = true,
      blockable = false, 
      blocking = false,
        func = function()
          G.video_organ = nil
          G.normal_music_speed = nil
          return true
        end }))
      return true
    end
  }))
  G.FUNCS.wipe_off()
end

G.FUNCS.show_main_cta = function(e)
  if e then
    if e.config.id == 'lose_cta' and not G.SETTINGS.DEMO.lose_CTA_shown then
      G.SETTINGS.DEMO.lose_CTA_shown = true
    end
    if e.config.id == 'win_cta' and not G.SETTINGS.DEMO.win_CTA_shown then
      G.SETTINGS.DEMO.win_CTA_shown = true
    end
  end

  G:save_progress()

  G.SETTINGS.paused = true
  G.normal_music_speed = true
            
  G.FUNCS.overlay_menu{
      definition = create_UIBox_demo_video_CTA(),
      config = {no_esc = true}
  }
end

G.FUNCS.wipe_on = function(message, no_card, timefac, alt_colour)
  timefac = timefac or 1
  if G.screenwipe then return end
  G.CONTROLLER.locks.wipe = true
  G.STAGE_OBJECT_INTERRUPT = true
  local colours = {
    black = HEX("4f6367FF"),
    white = {1, 1, 1, 1}
  }
  if not no_card then 
    G.screenwipecard = Card(1, 1, G.CARD_W, G.CARD_H, pseudorandom_element(G.P_CARDS), G.P_CENTERS.c_base)
    G.screenwipecard.sprite_facing = 'back'
    G.screenwipecard.facing = 'back'
    G.screenwipecard.states.hover.can = false
    G.screenwipecard:juice_up(0.5, 1)
  end
  local message_t = nil
  if message then 
    message_t = {}
    for k, v in ipairs(message) do
      table.insert(message_t, {n=G.UIT.R, config={align = "cm"}, nodes={{n=G.UIT.O, config={object = DynaText({string = v or '', colours = {math.min(G.C.BACKGROUND.C[1], G.C.BACKGROUND.C[2]) > 0.5 and G.C.BLACK or G.C.WHITE},shadow = true, silent = k ~= 1, float = true, scale = 1.3, pop_in = 0, pop_in_rate = 2, rotate = 1})}}}})
    end
  end

  G.screenwipe = UIBox{
    definition = 
      {n=G.UIT.ROOT, config = {align = "cm", minw =0, minh =0 ,padding = 0.15, r = 0.1, colour = G.C.CLEAR}, nodes={
        {n=G.UIT.R, config={align = "cm"}, nodes={
          message and {n=G.UIT.R, config={id = 'text', align = "cm", padding = 0.7}, nodes=message_t} or nil,
          not no_card and {n=G.UIT.O, config={object = G.screenwipecard, role = {role_type = 'Major'}}} or nil
        }},
      }},
    config = {align="cm", offset = {x=0,y=0}, major = G.ROOM_ATTACH}
  }
  G.screenwipe.colours = colours
  G.screenwipe.children.particles = Particles(0, 0, 0,0, {
    timer = 0,
    max = 1,
    scale = 40,
    speed = 0,
    lifespan = 1.7*timefac,
    attach = G.screenwipe,
    colours = {alt_colour or G.C.BACKGROUND.C}
  })
  G.STAGE_OBJECT_INTERRUPT = nil
  G.screenwipe.alignment.offset.y = 0
  if message then 
    for k, v in ipairs(G.screenwipe:get_UIE_by_ID('text').children) do
      v.children[1].config.object:pulse()
    end
  end


    G.E_MANAGER:add_event(Event({
      trigger = 'before',
      delay = 0.7,
      no_delete = true,
      blockable = false,
      func = function()
        if not no_card then 
        G.screenwipecard:flip()
        play_sound('cardFan2')
        end
        return true
      end
    }))
end

G.FUNCS.wipe_off = function()
  G.E_MANAGER:add_event(Event({
    no_delete = true,
    func = function()
      delay(0.3)
      G.screenwipe.children.particles.max = 0
      G.E_MANAGER:add_event(Event({
          trigger = 'ease',
          no_delete = true,
          blockable = false,
          blocking = false,
          timer = 'REAL',
          ref_table = G.screenwipe.colours.black,
          ref_value = 4,
          ease_to = 0,
          delay =  0.3,
          func = (function(t) return t end)
      }))
      G.E_MANAGER:add_event(Event({
        trigger = 'ease',
        no_delete = true,
        blockable = false,
        blocking = false,
        timer = 'REAL',
        ref_table = G.screenwipe.colours.white,
        ref_value = 4,
        ease_to = 0,
        delay =  0.3,
        func = (function(t) return t end)
    }))
      return true
    end
  }))
  G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0.55,
    no_delete = true,
    blocking = false,
    timer = 'REAL',
    func = function()
      if G.screenwipecard then G.screenwipecard:start_dissolve({G.C.BLACK, G.C.ORANGE,G.C.GOLD, G.C.RED}) end
      if G.screenwipe:get_UIE_by_ID('text') then 
        for k, v in ipairs(G.screenwipe:get_UIE_by_ID('text').children) do
          v.children[1].config.object:pop_out(4)
        end
      end
      return true
    end
  }))
  G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 1.1,
    no_delete = true,
    blocking = false,
    timer = 'REAL',
    func = function()
      G.screenwipe.children.particles:remove()
      G.screenwipe:remove()
      G.screenwipe.children.particles = nil
      G.screenwipe = nil
      G.screenwipecard = nil
      return true
    end
  }))
  G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 1.2,
    no_delete = true,
    blocking = true,
    timer = 'REAL',
    func = function()
      return true
    end
  }))
end

local WEB_BRIDGE_DIR = 'webbridge'

local WEB_BRIDGE_FILES = {
  export_temp = WEB_BRIDGE_DIR .. '/export_temp.jkr',
  export_request = WEB_BRIDGE_DIR .. '/export_request.txt',
  export_result = WEB_BRIDGE_DIR .. '/export_result.txt',
  export_direct = WEB_BRIDGE_DIR .. '/export_direct.txt',
  import_temp = WEB_BRIDGE_DIR .. '/import_temp.jkr',
  import_request = WEB_BRIDGE_DIR .. '/import_request.txt',
  import_result = WEB_BRIDGE_DIR .. '/import_result.txt',
  import_direct = WEB_BRIDGE_DIR .. '/import_direct.txt',
  import_clipboard = WEB_BRIDGE_DIR .. '/import_clipboard.txt',
  import_mod_request = WEB_BRIDGE_DIR .. '/import_mod_request.txt',
  import_mod_result = WEB_BRIDGE_DIR .. '/import_mod_result.txt',
  mod_menu_request = WEB_BRIDGE_DIR .. '/mod_menu_request.txt',
  mod_menu_result = WEB_BRIDGE_DIR .. '/mod_menu_result.txt',
  mod_catalog_request = WEB_BRIDGE_DIR .. '/mod_catalog_request.txt',
  mod_catalog_result = WEB_BRIDGE_DIR .. '/mod_catalog_result.txt',
  mod_download_request = WEB_BRIDGE_DIR .. '/mod_download_request.txt',
  mod_download_result = WEB_BRIDGE_DIR .. '/mod_download_result.txt',
  hint = WEB_BRIDGE_DIR .. '/bridge_hint.txt'
}

local LOCAL_MOD_TOGGLE_FILE = WEB_BRIDGE_DIR .. '/local_mod_toggles.txt'
local LOCAL_MOD_CATALOG = {
  {id='more_speed', title='MoreSpeed', source='Thunderstore', implemented=true},
  {id='mikas_mod_collection', title='MikasModCollection', source='Thunderstore', implemented=true},
  {id='themed_jokers', title='ThemedJokers', source='Thunderstore', implemented=true},
  {id='jank_jonklers', title='JankJonklers', source='Thunderstore', implemented=true},
  {id='mor_jokers', title='Mor Jokers', source='Thunderstore', implemented=true},
  {id='jsutils', title='JSUtils', source='Thunderstore', implemented=false},
  {id='buffoon_deck', title='Buffoon Deck', source='Thunderstore', implemented=true},
  {id='mobile_like_dragging', title='MobileLikeDragging', source='Thunderstore', implemented=true},
  {id='subtle_additions', title='SubtleAdditions', source='Thunderstore', implemented=true},
  {id='pestrica_joker', title='PestricaJoker', source='Thunderstore', implemented=true},
  {id='chudjoker', title='Chudjoker', source='Thunderstore', implemented=true},
  {id='jevils_card', title='JevilsCard', source='Thunderstore', implemented=true},
  {id='lord_minimus', title='Lord Minimus', source='Thunderstore', implemented=true},
  {id='showdown', title='Showdown', source='Thunderstore', implemented=false},
  {id='joker_display', title='JokerDisplay', source='Thunderstore', implemented=true},
  {id='frost_utils', title='Frost Utils', source='Thunderstore', implemented=false},
  {id='baldatro', title='Baldatro', source='Thunderstore', implemented=true},
  {id='pokermon', title='Pokermon', source='Nexus', implemented=false},
  {id='balatro_plus', title='Balatro Plus', source='Nexus', implemented=false},
  {id='power_creep_joker', title='Power Creep Joker', source='Nexus', implemented=true},
}

local MOD_BROWSER_STATE = {
  source = 'local',
  status = 'Local mod manager ready',
  pending = false,
  items = {},
  local_mods = {},
  local_mode = true,
  preview_items = {},
  catalog_count = 0,
  page = 1,
  per_page = 6,
  needs_render = false,
  rebuild_disabled = false,
  stability_mode = true
}
local MOD_ICON_ATLAS_CACHE = {}
G.WEB_MOD_BROWSER_STATE = MOD_BROWSER_STATE

local function read_local_mod_toggles()
  local out = {}
  if not love.filesystem.getInfo(LOCAL_MOD_TOGGLE_FILE) then return out end
  local raw = love.filesystem.read(LOCAL_MOD_TOGGLE_FILE) or ''
  if raw == '' then return out end
  raw = raw:gsub('\r', '')
  for line in string.gmatch(raw, '([^\n]+)') do
    local id, state = line:match('^([^\t]+)\t([01])$')
    if id then out[id] = (state == '1') end
  end
  return out
end

local function write_local_mod_toggles(toggles)
  local lines = {}
  for _, mod in ipairs(LOCAL_MOD_CATALOG) do
    local enabled = toggles[mod.id] == true
    lines[#lines + 1] = tostring(mod.id) .. '\t' .. (enabled and '1' or '0')
  end
  love.filesystem.createDirectory(WEB_BRIDGE_DIR)
  love.filesystem.write(LOCAL_MOD_TOGGLE_FILE, table.concat(lines, '\n'))
  pcall(function()
    if love and love.filesystem and love.filesystem.flush then
      love.filesystem.flush()
    end
  end)
end

local function rebuild_local_mod_catalog()
  local prev_page = tonumber(MOD_BROWSER_STATE.page) or 1
  local per_page = tonumber(MOD_BROWSER_STATE.per_page) or 6
  local toggles = read_local_mod_toggles()
  local enabled_count = 0
  MOD_BROWSER_STATE.local_mods = {}
  for _, mod in ipairs(LOCAL_MOD_CATALOG) do
    local enabled = toggles[mod.id] == true
    local implemented = (mod.implemented ~= false)
    if not implemented then
      enabled = false
      toggles[mod.id] = false
    end
    if enabled then enabled_count = enabled_count + 1 end
    MOD_BROWSER_STATE.local_mods[#MOD_BROWSER_STATE.local_mods + 1] = {
      id = mod.id,
      title = mod.title,
      source = mod.source,
      implemented = implemented,
      enabled = enabled,
      description = (not implemented) and 'Not implemented' or (enabled and 'Enabled' or 'Disabled')
    }
  end
  MOD_BROWSER_STATE.items = {}
  MOD_BROWSER_STATE.catalog_count = #MOD_BROWSER_STATE.local_mods
  MOD_BROWSER_STATE.status = 'Local mods: ' .. tostring(enabled_count) .. '/' .. tostring(#MOD_BROWSER_STATE.local_mods) .. ' enabled'
  local max_page = math.max(1, math.ceil(MOD_BROWSER_STATE.catalog_count / per_page))
  MOD_BROWSER_STATE.page = math.min(max_page, math.max(1, prev_page))
end

local function get_native_mod_center_map()
  local mor_jokers_keys = {}
  local jank_jonklers_keys = {}
  local mikas_mod_collection_keys = {}

  if type(get_native_mod_center_keys) == 'function' then
    mor_jokers_keys = get_native_mod_center_keys('mor_jokers')
    jank_jonklers_keys = get_native_mod_center_keys('jank_jonklers')
  end
  if type(get_mikas_native_center_keys) == 'function' then
    mikas_mod_collection_keys = get_mikas_native_center_keys()
  end

  return {
    buffoon_deck = {'b_js_buffoon'},
    mikas_mod_collection = mikas_mod_collection_keys,
    mor_jokers = mor_jokers_keys,
    jank_jonklers = jank_jonklers_keys,
    chudjoker = {'j_chudjoker'},
    lord_minimus = {'j_minim_free_refill', 'j_minim_rna', 'j_minim_flyer', 'j_minim_number_one', 'j_minim_chocolate_coin'},
    pestrica_joker = {'j_pesj_pestrica'},
    jevils_card = {'j_jevi_jevil', 'j_jevi_devilsknife'},
    power_creep_joker = {'j_mod_power_creep'}
  }
end

local function pool_has_center(pool, center)
  if type(pool) ~= 'table' then return false end
  for i = 1, #pool do
    if pool[i] == center then return true end
  end
  return false
end

local function remove_center_from_pool(pool, center)
  if type(pool) ~= 'table' then return end
  for i = #pool, 1, -1 do
    if pool[i] == center then
      table.remove(pool, i)
    end
  end
end

local function apply_native_toggle_runtime(mod_id, enabled)
  if type(apply_qol_native_mod_toggles) == 'function' then
    pcall(function()
      apply_qol_native_mod_toggles({[mod_id] = enabled == true})
    end)
  end

  if not (G and G.P_CENTERS and G.P_CENTER_POOLS) then return end
  local center_keys = get_native_mod_center_map()[mod_id]
  if type(center_keys) ~= 'table' then return end

  for _, center_key in ipairs(center_keys) do
    local center = G.P_CENTERS[center_key]
    if center then
      center._toggle_default_omit = center._toggle_default_omit == nil and center.omit or center._toggle_default_omit
      center._toggle_default_unlocked = center._toggle_default_unlocked == nil and center.unlocked or center._toggle_default_unlocked
      center._toggle_default_discovered = center._toggle_default_discovered == nil and center.discovered or center._toggle_default_discovered

      if enabled then
        center.omit = center._toggle_default_omit
        center.unlocked = center._toggle_default_unlocked
        center.discovered = center._toggle_default_discovered

        if center.set == 'Joker' then
          if not pool_has_center(G.P_CENTER_POOLS.Joker, center) then
            table.insert(G.P_CENTER_POOLS.Joker, center)
          end
          if center.rarity and G.P_JOKER_RARITY_POOLS and G.P_JOKER_RARITY_POOLS[center.rarity] and not pool_has_center(G.P_JOKER_RARITY_POOLS[center.rarity], center) then
            table.insert(G.P_JOKER_RARITY_POOLS[center.rarity], center)
          end
        elseif center.set == 'Back' then
          if not pool_has_center(G.P_CENTER_POOLS.Back, center) then
            table.insert(G.P_CENTER_POOLS.Back, center)
          end
        elseif center.set and G.P_CENTER_POOLS[center.set] then
          if not pool_has_center(G.P_CENTER_POOLS[center.set], center) then
            table.insert(G.P_CENTER_POOLS[center.set], center)
          end
        end
      else
        center.omit = true
        center.unlocked = false
        center.discovered = false

        if center.set == 'Joker' then
          remove_center_from_pool(G.P_CENTER_POOLS.Joker, center)
          if center.rarity and G.P_JOKER_RARITY_POOLS and G.P_JOKER_RARITY_POOLS[center.rarity] then
            remove_center_from_pool(G.P_JOKER_RARITY_POOLS[center.rarity], center)
          end
        elseif center.set == 'Back' then
          remove_center_from_pool(G.P_CENTER_POOLS.Back, center)
          if G.GAME and G.GAME.viewed_back and G.GAME.viewed_back.effect and G.GAME.viewed_back.effect.center and G.GAME.viewed_back.effect.center.key == center_key then
            G.GAME.viewed_back:change_to(G.P_CENTERS.b_red)
          end
        elseif center.set and G.P_CENTER_POOLS[center.set] then
          remove_center_from_pool(G.P_CENTER_POOLS[center.set], center)
        end
      end
    end
  end

  table.sort(G.P_CENTER_POOLS.Joker, function(a, b) return a.order < b.order end)
  table.sort(G.P_CENTER_POOLS.Back, function(a, b) return (a.order - (a.unlocked and 100 or 0)) < (b.order - (b.unlocked and 100 or 0)) end)
  if G.P_JOKER_RARITY_POOLS then
    for i = 1, 4 do
      table.sort(G.P_JOKER_RARITY_POOLS[i], function(a, b) return a.order < b.order end)
    end
  end
end

local function sanitize_mod_icon_key(icon_rel_path)
  local key = tostring(icon_rel_path or '')
  key = key:gsub('\\', '_')
  key = key:gsub('/', '_')
  key = key:gsub('[^%w_%-%.]', '_')
  if #key > 80 then key = string.sub(key, #key - 79) end
  return 'web_mod_icon_' .. key
end

local function ensure_mod_icon_atlas(icon_rel_path)
  if not icon_rel_path or icon_rel_path == '' then return nil end

  local cached_key = MOD_ICON_ATLAS_CACHE[icon_rel_path]
  if cached_key and G and G.ASSET_ATLAS and G.ASSET_ATLAS[cached_key] then
    return cached_key
  end

  if not (love and love.filesystem and love.graphics and love.graphics.newImage) then return nil end
  if not love.filesystem.getInfo(icon_rel_path) then return nil end

  local atlas_key = sanitize_mod_icon_key(icon_rel_path)
  if G and G.ASSET_ATLAS and G.ASSET_ATLAS[atlas_key] then
    MOD_ICON_ATLAS_CACHE[icon_rel_path] = atlas_key
    return atlas_key
  end

  local ok_img, img = pcall(function()
    return love.graphics.newImage(icon_rel_path, {mipmaps = true, dpiscale = 1})
  end)
  if not ok_img or not img then return nil end

  local w, h = img:getDimensions()
  if not w or not h or w <= 0 or h <= 0 then return nil end

  G.ASSET_ATLAS = G.ASSET_ATLAS or {}
  G.ASSET_ATLAS[atlas_key] = {
    name = atlas_key,
    image = img,
    type = 0,
    px = w,
    py = h
  }
  MOD_ICON_ATLAS_CACHE[icon_rel_path] = atlas_key
  return atlas_key
end

local function bridge_log(...)
  if not G or not G.IS_WEB then return end
  if select('#', ...) == 0 then
    print('[WEB BRIDGE]')
  else
    print('[WEB BRIDGE]', ...)
  end
end

local function ensure_bridge_hint()
  if not love.filesystem.getInfo(WEB_BRIDGE_DIR) then
    love.filesystem.createDirectory(WEB_BRIDGE_DIR)
  end
  local identity = love.filesystem.getIdentity and love.filesystem.getIdentity() or ''
  local save_dir = love.filesystem.getSaveDirectory and love.filesystem.getSaveDirectory() or ''
  local hint_payload = (identity or '') .. '\n' .. (save_dir or '')
  pcall(function()
    love.filesystem.write(WEB_BRIDGE_FILES.hint, hint_payload)
  end)
  local real_dir = love.filesystem.getRealDirectory and love.filesystem.getRealDirectory(WEB_BRIDGE_DIR) or ''
  bridge_log('hint updated', WEB_BRIDGE_FILES.hint, 'identity=' .. tostring(identity), 'save_dir=' .. tostring(save_dir), 'real_dir=' .. tostring(real_dir))
end

local function flush_filesystem()
  if love and love.filesystem and love.filesystem.flush then
    local ok, err = pcall(love.filesystem.flush)
    if not ok then
      bridge_log('flush failed', tostring(err))
    end
  end
end

local function cleanup_bridge_file(path)
  pcall(function()
    if love.filesystem.getInfo(path) then
      love.filesystem.remove(path)
    end
  end)
end

local function parse_bridge_result(payload)
  if not payload or payload == '' then
    return nil, 'empty response'
  end

  payload = payload:gsub('\r', '')
  local first_line, rest = payload:match('^([^\n]*)\n?(.*)$')
  local status, detail = (first_line or ''):match('^(%u+)%s*(.*)$')
  detail = detail or ''
  if rest and rest ~= '' then
    detail = (detail ~= '') and (detail .. '\n' .. rest) or rest
  end
  detail = detail:gsub('^%s+', ''):gsub('%s+$', '')

  if status == 'OK' then
    return true, detail or ''
  elseif status == 'ERR' then
    if detail and detail ~= '' then
      return false, detail
    else
      return false, 'Unknown error'
    end
  end

  return nil, 'unrecognized response'
end

local function split_lines(text)
  local lines = {}
  if not text or text == '' then return lines end
  text = text:gsub('\r', '')
  for line in string.gmatch(text, '([^\n]+)') do
    lines[#lines + 1] = line
  end
  return lines
end

local function parse_mod_catalog_payload(detail)
  local function clip_field(value, max_len)
    local s = tostring(value or '')
    if #s <= max_len then return s end
    return string.sub(s, 1, max_len)
  end

  local out = {}
  local lines = split_lines(detail)
  for _, line in ipairs(lines) do
    if line and line ~= '' then
      if #line > 8192 then
        line = string.sub(line, 1, 8192)
      end
      local fields = {}
      local index = 1
      for field in string.gmatch(line .. '\t', '(.-)\t') do
        fields[index] = field
        index = index + 1
      end
      if fields[1] and fields[1] ~= '' then
        local icon_path = clip_field(fields[9] or '', 260)
        if icon_path ~= '' and not string.match(icon_path, '^webbridge/') then
          icon_path = 'webbridge/' .. icon_path
        end
        out[#out + 1] = {
          title = clip_field(fields[1] or 'Unnamed Mod', 180),
          author = clip_field(fields[2] or 'Unknown', 120),
          description = clip_field(fields[3] or '', 1200),
          url = clip_field(fields[4] or '', 700),
          source = clip_field(fields[5] or 'Web', 40),
          downloads = tonumber(fields[6]) or 0,
          icon = clip_field(fields[7] or '', 700),
          download_url = clip_field(fields[8] or '', 700),
          icon_path = icon_path,
          icon_atlas_key = nil
        }
      end
      if #out >= 500 then break end
    end
  end
  return out
end

local function warm_visible_mod_icons()
  return
end

local function refresh_mod_browser_overlay()
  if MOD_BROWSER_STATE.rebuild_disabled then return end
  if not G.OVERLAY_MENU then return end
  if MOD_BROWSER_STATE.refresh_queued then return end
  MOD_BROWSER_STATE.refresh_queued = true
  G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0,
    blockable = false,
    blocking = false,
    func = function()
      MOD_BROWSER_STATE.refresh_queued = false
      if not G.OVERLAY_MENU then return true end
      G.SETTINGS.paused = true
      G.FUNCS.overlay_menu({ definition = G.UIDEF.web_mod_browser() })
      return true
    end
  }))
end

local function request_mod_catalog(source)
  if MOD_BROWSER_STATE.local_mode then
    MOD_BROWSER_STATE.pending = false
    rebuild_local_mod_catalog()
    refresh_mod_browser_overlay()
    return
  end

  if not G.IS_WEB then
    MOD_BROWSER_STATE.status = 'Web-only feature'
    MOD_BROWSER_STATE.pending = false
    return
  end

  if MOD_BROWSER_STATE.pending then return end
  MOD_BROWSER_STATE.pending = true
  MOD_BROWSER_STATE.source = 'thunderstore_steamodded'
  MOD_BROWSER_STATE.status = 'Loading ' .. tostring(MOD_BROWSER_STATE.source) .. ' mods...'
  refresh_mod_browser_overlay()

  local stage_ok, stage_err = pcall(function()
    ensure_bridge_hint()
    cleanup_bridge_file(WEB_BRIDGE_FILES.mod_catalog_result)
    cleanup_bridge_file(WEB_BRIDGE_FILES.mod_catalog_request)

    local req_ok, req_err = love.filesystem.write(WEB_BRIDGE_FILES.mod_catalog_request, tostring(MOD_BROWSER_STATE.source))
    if not req_ok then error('Failed to stage mod catalog request: ' .. tostring(req_err)) end
    bridge_log('mod catalog request staged', tostring(MOD_BROWSER_STATE.source))
    flush_filesystem()

    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.2,
      blockable = false,
      blocking = false,
      func = (function()
        local wait_started_at = (love and love.timer and love.timer.getTime and love.timer.getTime()) or 0
        local timeout_seconds = 120
        return function()
          if love.filesystem.getInfo(WEB_BRIDGE_FILES.mod_catalog_result) then
            local res = love.filesystem.read(WEB_BRIDGE_FILES.mod_catalog_result) or ''
            bridge_log('mod catalog result observed')
            cleanup_bridge_file(WEB_BRIDGE_FILES.mod_catalog_result)
            cleanup_bridge_file(WEB_BRIDGE_FILES.mod_catalog_request)

            local ok_result, detail = parse_bridge_result(res)
            if ok_result == true then
              bridge_log('mod catalog parse begin')
              local parsed_items = parse_mod_catalog_payload(detail)
              local parsed_count = (type(parsed_items) == 'table') and #parsed_items or 0
              if MOD_BROWSER_STATE.stability_mode then
                MOD_BROWSER_STATE.items = {}
                MOD_BROWSER_STATE.catalog_count = parsed_count
                MOD_BROWSER_STATE.preview_items = {}
                local preview_limit = 10
                for idx = 1, math.min(preview_limit, parsed_count) do
                  local p = parsed_items[idx] or {}
                  MOD_BROWSER_STATE.preview_items[#MOD_BROWSER_STATE.preview_items + 1] = {
                    title = tostring(p.title or 'Unnamed Mod'),
                    author = tostring(p.author or 'Unknown'),
                    description = tostring(p.description or ''),
                    source = tostring(p.source or 'Web'),
                    downloads = tonumber(p.downloads) or 0,
                    url = tostring(p.url or ''),
                    download_url = tostring(p.download_url or ''),
                    icon = tostring(p.icon or ''),
                    icon_path = tostring(p.icon_path or '')
                  }
                end
              else
                MOD_BROWSER_STATE.items = parsed_items
                MOD_BROWSER_STATE.catalog_count = parsed_count
                MOD_BROWSER_STATE.preview_items = {}
              end
              bridge_log('mod catalog parse done', tostring(MOD_BROWSER_STATE.catalog_count or 0))
              MOD_BROWSER_STATE.page = 1
              warm_visible_mod_icons()
              MOD_BROWSER_STATE.status = 'Loaded ' .. tostring(MOD_BROWSER_STATE.catalog_count or 0) .. ' mods (' .. tostring(MOD_BROWSER_STATE.source) .. ')'
              if MOD_BROWSER_STATE.rebuild_disabled then
                MOD_BROWSER_STATE.status = MOD_BROWSER_STATE.status .. ' - ready'
              end
              attention_text({ text = 'Loaded ' .. tostring(MOD_BROWSER_STATE.catalog_count or 0) .. ' mods', scale = 0.45, hold = 1.4, align = 'cm', offset = {x = 0, y = -2.8}, major = G.ROOM_ATTACH })
            else
              MOD_BROWSER_STATE.items = {}
              MOD_BROWSER_STATE.preview_items = {}
              MOD_BROWSER_STATE.catalog_count = 0
              MOD_BROWSER_STATE.page = 1
              MOD_BROWSER_STATE.status = 'Load failed: ' .. tostring(detail or 'unknown error')
              attention_text({ text = 'Mod load failed', scale = 0.45, hold = 1.6, align = 'cm', offset = {x = 0, y = -2.8}, major = G.ROOM_ATTACH })
              print('[MOD MENU] ' .. tostring(detail))
            end
            MOD_BROWSER_STATE.pending = false
            bridge_log('mod catalog refresh begin')
            if MOD_BROWSER_STATE.rebuild_disabled then
              MOD_BROWSER_STATE.needs_render = false
              bridge_log('mod catalog refresh complete (rebuild disabled)')
            else
              MOD_BROWSER_STATE.needs_render = false
              refresh_mod_browser_overlay()
              bridge_log('mod catalog refresh complete (live rebuild)')
            end
            return true
          end

          local now_time = (love and love.timer and love.timer.getTime and love.timer.getTime()) or wait_started_at
          if (now_time - wait_started_at) > timeout_seconds then
            bridge_log('mod catalog result timeout')
            MOD_BROWSER_STATE.pending = false
            MOD_BROWSER_STATE.status = 'Mod list timed out (try refresh)'
            cleanup_bridge_file(WEB_BRIDGE_FILES.mod_catalog_request)
            if MOD_BROWSER_STATE.rebuild_disabled then
              MOD_BROWSER_STATE.needs_render = true
            else
              MOD_BROWSER_STATE.needs_render = false
              refresh_mod_browser_overlay()
            end
            attention_text({ text = 'Mod list timed out', scale = 0.45, hold = 1.6, align = 'cm', offset = {x = 0, y = -2.8}, major = G.ROOM_ATTACH })
            return true
          end

          return false
        end
      end)()
    }))
  end)

  if not stage_ok then
    MOD_BROWSER_STATE.pending = false
    MOD_BROWSER_STATE.items = {}
    MOD_BROWSER_STATE.page = 1
    MOD_BROWSER_STATE.status = 'Failed to stage request'
    bridge_log('mod catalog staging failed', tostring(stage_err))
    cleanup_bridge_file(WEB_BRIDGE_FILES.mod_catalog_request)
    cleanup_bridge_file(WEB_BRIDGE_FILES.mod_catalog_result)
    MOD_BROWSER_STATE.needs_render = true
    refresh_mod_browser_overlay()
  end
end

local function parse_import_bundle(raw_data)
  if not raw_data or raw_data == '' then return nil end
  local decoded = raw_data
  if string.sub(decoded, 1, 6) ~= 'return' then
    local ok_decomp, decomp = pcall(love.data.decompress, 'string', 'deflate', decoded)
    if not ok_decomp or not decomp then return nil end
    decoded = decomp
  end
  if string.sub(decoded, 1, 6) ~= 'return' then return nil end
  local ok_unpack, unpacked = pcall(STR_UNPACK, decoded)
  if not ok_unpack or type(unpacked) ~= 'table' then return nil end
  if unpacked.kind ~= 'profile_bundle_v1' then return nil end
  return unpacked
end

local function decode_save_blob(raw_data)
  if not raw_data or raw_data == '' then return nil end
  if string.sub(raw_data, 1, 6) == 'return' then return raw_data end
  local ok_decomp, decomp = pcall(love.data.decompress, 'string', 'deflate', raw_data)
  if not ok_decomp or not decomp then return nil end
  if string.sub(decomp, 1, 6) ~= 'return' then return nil end
  return decomp
end

local function unpack_blob_table(raw_data)
  local decoded = decode_save_blob(raw_data)
  if not decoded then return nil end
  local ok_unpack, unpacked = pcall(STR_UNPACK, decoded)
  if not ok_unpack or type(unpacked) ~= 'table' then return nil end
  return unpacked
end

local function json_escape(value)
  local s = tostring(value or '')
  s = s:gsub('\\', '\\\\')
       :gsub('"', '\\"')
       :gsub('\b', '\\b')
       :gsub('\f', '\\f')
       :gsub('\n', '\\n')
       :gsub('\r', '\\r')
       :gsub('\t', '\\t')
  return s
end

local function json_encode(value, seen)
  local value_type = type(value)
  if value_type == 'nil' then return 'null' end
  if value_type == 'boolean' then return value and 'true' or 'false' end
  if value_type == 'number' then
    if value ~= value or value == math.huge or value == -math.huge then return 'null' end
    return tostring(value)
  end
  if value_type == 'string' then
    return '"' .. json_escape(value) .. '"'
  end
  if value_type ~= 'table' then
    return '"' .. json_escape(tostring(value)) .. '"'
  end

  seen = seen or {}
  if seen[value] then return '"<cycle>"' end
  seen[value] = true

  local is_array = true
  local max_index = 0
  local count = 0
  for k, _ in pairs(value) do
    if type(k) ~= 'number' or k < 1 or k % 1 ~= 0 then
      is_array = false
      break
    end
    if k > max_index then max_index = k end
    count = count + 1
  end

  if is_array and max_index == count then
    local parts = {}
    for i = 1, max_index do
      parts[#parts+1] = json_encode(value[i], seen)
    end
    seen[value] = nil
    return '[' .. table.concat(parts, ',') .. ']'
  end

  local parts = {}
  for k, v in pairs(value) do
    parts[#parts+1] = '"' .. json_escape(tostring(k)) .. '":' .. json_encode(v, seen)
  end
  seen[value] = nil
  return '{' .. table.concat(parts, ',') .. '}'
end

local function dump_import_json(label, payload)
  print('[' .. label .. '_BEGIN]')
  local ok_json, encoded = pcall(function()
    return json_encode(payload)
  end)
  if ok_json and encoded then
    print(encoded)
  else
    print('{"error":"json_encode_failed"}')
  end
  print('[' .. label .. '_END]')
end

local function build_import_snapshot_from_bundle(bundle)
  return {
    kind = 'profile_bundle_v1',
    profile = unpack_blob_table(bundle and bundle.profile or nil),
    meta = unpack_blob_table(bundle and bundle.meta or nil),
    save = unpack_blob_table(bundle and bundle.save or nil)
  }
end

local function build_import_snapshot_single(raw_data, detail, target)
  local decoded_table = unpack_blob_table(raw_data)
  local snapshot = {
    kind = 'single',
    detail = detail or '',
    target = target or '',
    payload = decoded_table
  }
  if not decoded_table then
    snapshot.decoded = decode_save_blob(raw_data)
  end
  return snapshot
end

local function refresh_main_menu_ui_after_import()
  if not G or not G.STAGE or G.STAGE ~= G.STAGES.MAIN_MENU then return end
  pcall(function()
    if G.MAIN_MENU_UI then G.MAIN_MENU_UI:remove(); G.MAIN_MENU_UI = nil end
    if G.PROFILE_BUTTON then G.PROFILE_BUTTON:remove(); G.PROFILE_BUTTON = nil end
    if G.collection_alert then G.collection_alert:remove(); G.collection_alert = nil end
    if set_main_menu_UI then set_main_menu_UI() end
  end)
end

local function mark_tutorial_complete_after_import(profile_num)
  if not G or not G.SETTINGS then return end
  G.SETTINGS.tutorial_complete = true
  G.SETTINGS.tutorial_progress = G.SETTINGS.tutorial_progress or {}
  G.SETTINGS.tutorial_progress.completed_parts = G.SETTINGS.tutorial_progress.completed_parts or {}
  G.SETTINGS.tutorial_progress.completed_parts['big_blind'] = true
  pcall(function()
    if process_save_request then
      process_save_request({type = 'save_settings', save_settings = G.SETTINGS})
    else
      compress_and_save('settings.jkr', G.SETTINGS)
    end
  end)
  flush_filesystem()
  refresh_main_menu_ui_after_import()
end

local function is_valid_profile_blob(raw_data)
  local decoded = decode_save_blob(raw_data)
  if not decoded then return false end
  local ok_unpack, unpacked = pcall(STR_UNPACK, decoded)
  if not ok_unpack or type(unpacked) ~= 'table' then return false end
  if type(unpacked.high_scores) ~= 'table' then return false end
  if type(unpacked.progress) ~= 'table' then return false end
  return true
end

local function is_empty_meta_blob(raw_data)
  local decoded = decode_save_blob(raw_data)
  if not decoded then return true end
  local ok_unpack, unpacked = pcall(STR_UNPACK, decoded)
  if not ok_unpack or type(unpacked) ~= 'table' then return true end
  unpacked.unlocked = unpacked.unlocked or {}
  unpacked.discovered = unpacked.discovered or {}
  unpacked.alerted = unpacked.alerted or {}
  return (next(unpacked.unlocked) == nil) and (next(unpacked.discovered) == nil) and (next(unpacked.alerted) == nil)
end

local function build_meta_blob_from_runtime()
  local meta = { unlocked = {}, discovered = {}, alerted = {} }

  if G and G.P_CENTERS then
    for key, center in pairs(G.P_CENTERS) do
      if center then
        if center.unlocked then meta.unlocked[key] = true end
        if center.discovered then meta.discovered[key] = true end
        if center.alerted then meta.alerted[key] = true end
      end
    end
  end

  if G and G.P_BLINDS then
    for key, blind in pairs(G.P_BLINDS) do
      if blind then
        if blind.discovered then meta.discovered[key] = true end
        if blind.alerted then meta.alerted[key] = true end
      end
    end
  end

  if G and G.P_TAGS then
    for key, tag in pairs(G.P_TAGS) do
      if tag then
        if tag.discovered then meta.discovered[key] = true end
        if tag.alerted then meta.alerted[key] = true end
      end
    end
  end

  if G and G.P_SEALS then
    for key, seal in pairs(G.P_SEALS) do
      if seal then
        if seal.discovered then meta.discovered[key] = true end
        if seal.alerted then meta.alerted[key] = true end
      end
    end
  end

  return STR_PACK(meta)
end

local function apply_import_payload(prefix_profile, profile_num, data, detail)
  local bundle = parse_import_bundle(data)
  if bundle then
    dump_import_json('IMPORT_INCOMING_JSON', build_import_snapshot_from_bundle(bundle))
  else
    dump_import_json('IMPORT_INCOMING_JSON', build_import_snapshot_single(data, detail, ''))
  end

  if bundle then
    if bundle.profile and bundle.profile ~= '' and not is_valid_profile_blob(bundle.profile) then
      return false, 'invalid profile payload in bundle'
    end
    local wrote_any = false
    local wrote_profile_or_meta = false
    local wrote_save = false
    if bundle.profile and bundle.profile ~= '' then
      local ok_profile = love.filesystem.write(prefix_profile .. '/profile.jkr', bundle.profile)
      wrote_any = wrote_any or ok_profile
      wrote_profile_or_meta = wrote_profile_or_meta or ok_profile
    end
    if bundle.meta and bundle.meta ~= '' then
      local ok_meta = love.filesystem.write(prefix_profile .. '/meta.jkr', bundle.meta)
      wrote_any = wrote_any or ok_meta
      wrote_profile_or_meta = wrote_profile_or_meta or ok_meta
    end
    if bundle.save and bundle.save ~= '' then
      local ok_save = love.filesystem.write(prefix_profile .. '/save.jkr', bundle.save)
      wrote_any = wrote_any or ok_save
      wrote_save = wrote_save or ok_save
    end
    if not wrote_any then
      return false, 'bundle had no writable payload'
    end
    if wrote_profile_or_meta then
      local previous_profile = (G and G.SETTINGS and G.SETTINGS.profile) or profile_num
      local switched_profile = false
      if G and G.SETTINGS and previous_profile ~= profile_num then
        G.SETTINGS.profile = profile_num
        switched_profile = true
      end
      pcall(function() G:load_profile(profile_num) end)
      pcall(function() G:init_item_prototypes() end)
      pcall(function() set_discover_tallies() end)
      pcall(function()
        if G and G.save_progress then
          G:save_progress()
        end
      end)
      if switched_profile and G and G.SETTINGS then
        G.SETTINGS.profile = previous_profile
      end
    end
    if wrote_save then
      pcall(function()
        local raw = get_compressed(prefix_profile .. '/save.jkr')
        local ok_unpack, unpacked = pcall(STR_UNPACK, raw or '')
        G.SAVED_GAME = (ok_unpack and type(unpacked) == 'table') and unpacked or nil
      end)
      mark_tutorial_complete_after_import(profile_num)
    end
    local applied_bundle = {
      profile = get_compressed(prefix_profile .. '/profile.jkr') or '',
      meta = get_compressed(prefix_profile .. '/meta.jkr') or '',
      save = get_compressed(prefix_profile .. '/save.jkr') or ''
    }
    dump_import_json('IMPORT_APPLIED_JSON', build_import_snapshot_from_bundle(applied_bundle))
    flush_filesystem()
    return true, 'bundle'
  end

  local target_name = 'save.jkr'
  if detail and type(detail) == 'string' then
    local detail_lower = string.lower(detail)
    if string.find(detail_lower, 'profile', 1, true) then
      target_name = 'profile.jkr'
    end
  end
  if target_name == 'profile.jkr' and not is_valid_profile_blob(data) then
    return false, 'invalid profile payload'
  end
  local write_ok, write_err = love.filesystem.write(prefix_profile .. '/' .. target_name, data)
  if not write_ok then
    return false, write_err or 'write failed'
  end
  if target_name == 'profile.jkr' then
    local previous_profile = (G and G.SETTINGS and G.SETTINGS.profile) or profile_num
    local switched_profile = false
    if G and G.SETTINGS and previous_profile ~= profile_num then
      G.SETTINGS.profile = profile_num
      switched_profile = true
    end
    pcall(function() G:load_profile(profile_num) end)
    pcall(function() G:init_item_prototypes() end)
    pcall(function() set_discover_tallies() end)
    pcall(function()
      if G and G.save_progress then
        G:save_progress()
      end
    end)
    if switched_profile and G and G.SETTINGS then
      G.SETTINGS.profile = previous_profile
    end
  elseif target_name == 'save.jkr' then
    pcall(function()
      local raw = get_compressed(prefix_profile .. '/save.jkr')
      local ok_unpack, unpacked = pcall(STR_UNPACK, raw or '')
      G.SAVED_GAME = (ok_unpack and type(unpacked) == 'table') and unpacked or nil
    end)
    mark_tutorial_complete_after_import(profile_num)
  end
  local applied_raw = get_compressed(prefix_profile .. '/' .. target_name)
  if not applied_raw and love.filesystem.getInfo(prefix_profile .. '/' .. target_name) then
    applied_raw = love.filesystem.read(prefix_profile .. '/' .. target_name)
  end
  dump_import_json('IMPORT_APPLIED_JSON', build_import_snapshot_single(applied_raw or '', detail, target_name))
  flush_filesystem()
  return true, target_name
end

local JS_BRIDGE = {
  ready = false,
  available = false,
  ffi = nil
}

local function init_js_bridge()
  if JS_BRIDGE.ready then return JS_BRIDGE.available end
  JS_BRIDGE.ready = true
  if not G or not G.IS_WEB then return false end
  local ok, ffi = pcall(require, 'ffi')
  if not ok or not ffi or not ffi.C then return false end
  pcall(function()
    ffi.cdef[[void emscripten_run_script(const char*);]]
  end)
  JS_BRIDGE.ffi = ffi
  JS_BRIDGE.available = true
  return true
end

local function js_escape(value)
  local s = tostring(value or '')
  s = s:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\r', '\\r'):gsub('\n', '\\n')
  return s
end

local function run_js(script)
  if not init_js_bridge() then
    return false, 'ffi not available'
  end
  JS_BRIDGE.ffi.C.emscripten_run_script(script)
  return true
end

local function js_direct_export(temp_path, suggested_name)
  local script = string.format(
    'if (Module && Module.BalatroFS && Module.BalatroFS.directExport) { Module.BalatroFS.directExport("%s", "%s"); }',
    js_escape(temp_path),
    js_escape(suggested_name)
  )
  return run_js(script)
end

local function js_direct_import(temp_path)
  local script = string.format(
    'if (Module && Module.BalatroFS && Module.BalatroFS.directImport) { Module.BalatroFS.directImport("%s"); }',
    js_escape(temp_path)
  )
  return run_js(script)
end

-- Export save file (web version only)
G.FUNCS.export_save = function(e)
  if G and G.save_progress then
    pcall(function()
      G:save_progress()
    end)
  end

  -- Get the current profile save
  local profile_raw = G.focused_profile or G.SETTINGS.profile or 1
  local profile_num = tonumber(profile_raw) or 1
  local profile = tostring(profile_num)

  if G and G.PROFILES and G.PROFILES[profile_num] then
    if not love.filesystem.getInfo(profile) then love.filesystem.createDirectory(profile) end
    pcall(function()
      compress_and_save(profile..'/profile.jkr', G.PROFILES[profile_num])
    end)
    flush_filesystem()
  end

  local save_data = get_compressed(profile..'/'..'save.jkr')
  local export_source = 'save.jkr'
  if not save_data then
    save_data = get_compressed(profile..'/'..'profile.jkr')
    export_source = 'profile.jkr'
  end
  if not save_data then
    local save_info = love.filesystem.getInfo(profile..'/'..'save.jkr')
    if save_info then
      save_data = love.filesystem.read(profile..'/'..'save.jkr')
      export_source = 'save.jkr'
    end
  end
  if not save_data then
    local profile_info = love.filesystem.getInfo(profile..'/'..'profile.jkr')
    if profile_info then
      save_data = love.filesystem.read(profile..'/'..'profile.jkr')
      export_source = 'profile.jkr'
    end
  end
  if not save_data and G and G.PROFILES and G.PROFILES[profile_num] then
    local packed_profile = STR_PACK(G.PROFILES[profile_num])
    save_data = love.data.compress('string', 'deflate', packed_profile, 1)
    export_source = 'profile_mem.jkr'
  end

  local profile_blob = get_compressed(profile..'/profile.jkr') or ''
  if (not profile_blob or profile_blob == '') and G and G.PROFILES and G.PROFILES[profile_num] then
    profile_blob = love.data.compress('string', 'deflate', STR_PACK(G.PROFILES[profile_num]), 1)
    profile_blob = get_compressed(profile..'/profile.jkr') or profile_blob
  end

  local meta_blob = get_compressed(profile..'/meta.jkr') or ''
  if not meta_blob or meta_blob == '' or is_empty_meta_blob(meta_blob) then
    meta_blob = build_meta_blob_from_runtime()
    pcall(function()
      love.filesystem.write(profile..'/meta.jkr', meta_blob)
    end)
    flush_filesystem()
    bridge_log('meta snapshot generated from runtime for export bundle')
  end

  local save_blob = get_compressed(profile..'/save.jkr') or ''
  if (not save_blob or save_blob == '') and G and G.SAVED_GAME and G.SAVED_GAME ~= '' then
    save_blob = G.SAVED_GAME
  end

  if profile_blob ~= '' or meta_blob ~= '' or save_blob ~= '' then
    local bundle = {
      kind = 'profile_bundle_v1',
      profile = profile_blob or '',
      meta = meta_blob or '',
      save = save_blob or ''
    }
    local packed_bundle = STR_PACK(bundle)
    save_data = love.data.compress('string', 'deflate', packed_bundle, 1)
    export_source = 'profile_bundle.jkr'
  end

  bridge_log('export requested', 'profile=' .. tostring(profile), 'source=' .. tostring(export_source), 'has_data=' .. tostring(not not save_data), 'has_profile_mem=' .. tostring(not not (G and G.PROFILES and G.PROFILES[profile_num])))
  
  if not save_data then
    print('[WEB EXPORT] No save data found in save.jkr or profile.jkr for profile ' .. tostring(profile))
    G.E_MANAGER:add_event(Event({
      func = function()
        attention_text({
          text = "No save/profile data found!",
          scale = 0.6,
          hold = 2,
          align = 'cm',
          offset = {x = 0, y = -3},
          major = G.ROOM_ATTACH
        })
        return true
      end
    }))
    return
  end
  
  local stage_ok, stage_err
  if G.IS_WEB then
    stage_ok, stage_err = pcall(function()
      bridge_log('starting export staging')
      ensure_bridge_hint()
      cleanup_bridge_file(WEB_BRIDGE_FILES.export_result)
      cleanup_bridge_file(WEB_BRIDGE_FILES.export_request)
      cleanup_bridge_file(WEB_BRIDGE_FILES.export_direct)
      cleanup_bridge_file(WEB_BRIDGE_FILES.export_temp)

      bridge_log('writing temp save', WEB_BRIDGE_FILES.export_temp)
      local temp_ok, temp_err = love.filesystem.write(WEB_BRIDGE_FILES.export_temp, save_data)
      if not temp_ok then error('Failed to stage export data: ' .. tostring(temp_err)) end
  flush_filesystem()

      local day = tostring(tonumber(os.date("%d")))
      local month = tostring(tonumber(os.date("%m")))
      local year = os.date("%Y")
      local player = (profile_num == 1) and 'P1' or ((profile_num == 2) and 'P2' or ('P' .. tostring(profile_num)))
      local default_name = string.format("%s-%s-%s_%s%s.jkr", day, month, year, player, (export_source == 'profile.jkr' or export_source == 'profile_mem.jkr' or export_source == 'profile_bundle.jkr') and '_profile' or '')

    local js_ok, js_err = js_direct_export(WEB_BRIDGE_FILES.export_temp, default_name)
    if not js_ok then
      bridge_log('direct export unavailable, using export request', tostring(js_err))
      local req_ok, req_err = love.filesystem.write(WEB_BRIDGE_FILES.export_request, default_name)
      if not req_ok then error('Failed to stage export request: ' .. tostring(req_err)) end
      flush_filesystem()
    else
      bridge_log('direct export invoked', default_name)
    end

      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.2,
        blockable = false,
        blocking = false,
        func = (function()
          local tries = 0
          return function()
            tries = tries + 1

            if love.filesystem.getInfo(WEB_BRIDGE_FILES.export_result) then
              local res = love.filesystem.read(WEB_BRIDGE_FILES.export_result) or ''
              bridge_log('export result observed', res)
              cleanup_bridge_file(WEB_BRIDGE_FILES.export_result)
              cleanup_bridge_file(WEB_BRIDGE_FILES.export_request)

              local ok_result, detail = parse_bridge_result(res)
              if ok_result == true then
                attention_text({ text = 'Save exported!', scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
              elseif ok_result == false then
                print('[WEB EXPORT] Export failed: ' .. tostring(detail))
                attention_text({ text = 'Export failed', scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
              else
                print('[WEB EXPORT] Unexpected response: ' .. tostring(res))
                attention_text({ text = 'Export failed', scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
              end

              cleanup_bridge_file(WEB_BRIDGE_FILES.export_temp)
              return true
            end

            if tries > 150 then
              bridge_log('export timed out waiting for result')
              attention_text({ text = 'Export timed out', scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
              cleanup_bridge_file(WEB_BRIDGE_FILES.export_request)
              cleanup_bridge_file(WEB_BRIDGE_FILES.export_temp)
              return true
            end

            return false
          end
        end)()
      }))
    end)
  else
    stage_ok, stage_err = pcall(function()
      local day = tostring(tonumber(os.date("%d")))
      local month = tostring(tonumber(os.date("%m")))
      local year = os.date("%Y")
      local player = (profile == 1) and 'P1' or ((profile == 2) and 'P2' or ('P' .. tostring(profile)))
      local default_name = string.format("%s_%s.jkr", day .. '-' .. month .. '-' .. year, player)

      local ps_script = [[
Add-Type -AssemblyName System.Windows.Forms
$sfd = New-Object System.Windows.Forms.SaveFileDialog
$sfd.Filter = 'JKR Save (*.jkr)|*.jkr'
$sfd.FileName = '%s'
if ($sfd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { Write-Output $sfd.FileName }
]]
      ps_script = string.format(ps_script, default_name)

      local cmd = 'powershell -NoProfile -Command "' .. ps_script:gsub('"','\"'):gsub('\n',';') .. '"'
      local pipe = io.popen(cmd)
      if not pipe then error('Could not run powershell') end
      local selected = pipe:read('*a') or ''
      pipe:close()
      selected = selected:gsub('%s+$','')
      selected = selected:gsub('^%s+','')
      if selected == '' then
        error('Save cancelled')
      end

      local f, ferr = io.open(selected, 'wb')
      if not f then error('Could not open file for writing: ' .. tostring(ferr)) end
      f:write(save_data)
      f:close()
    end)
  end

  if not stage_ok then
    if stage_err then print('[EXPORT] Error staging export: ' .. tostring(stage_err)) end
    bridge_log('export staging failed', tostring(stage_err))
  cleanup_bridge_file(WEB_BRIDGE_FILES.export_request)
  cleanup_bridge_file(WEB_BRIDGE_FILES.export_result)
  cleanup_bridge_file(WEB_BRIDGE_FILES.export_temp)
    G.E_MANAGER:add_event(Event({
      func = function()
        attention_text({
          text = "Export failed - check console",
          scale = 0.6,
          hold = 2,
          align = 'cm',
          offset = {x = 0, y = -3},
          major = G.ROOM_ATTACH
        })
        return true
      end
    }))
  elseif not G.IS_WEB then
    G.E_MANAGER:add_event(Event({
      func = function()
        attention_text({
          text = "Save exported!",
          scale = 0.6,
          hold = 2,
          align = 'cm',
          offset = {x = 0, y = -3},
          major = G.ROOM_ATTACH
        })
        return true
      end
    }))
  end
end

G.FUNCS.import_save = function(e)
  local stage_ok, stage_err
  if G.IS_WEB then
    stage_ok, stage_err = pcall(function()
      bridge_log('starting import staging')
      ensure_bridge_hint()
      cleanup_bridge_file(WEB_BRIDGE_FILES.import_result)
      cleanup_bridge_file(WEB_BRIDGE_FILES.import_request)
      cleanup_bridge_file(WEB_BRIDGE_FILES.import_direct)
      cleanup_bridge_file(WEB_BRIDGE_FILES.import_temp)

      local req_ok, req_err = love.filesystem.write(WEB_BRIDGE_FILES.import_request, 'request')
      if not req_ok then error('Failed to stage import request: ' .. tostring(req_err)) end
      flush_filesystem()
      bridge_log('import request staged')

      local profile_raw = G.focused_profile or G.SETTINGS.profile or 1
      local profile_num = tonumber(profile_raw) or 1
      local prefix_profile = tostring(profile_num)
      if not love.filesystem.getInfo(prefix_profile) then love.filesystem.createDirectory(prefix_profile) end

      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.2,
        blockable = false,
        blocking = false,
        func = (function()
          local wait_started_at = (love and love.timer and love.timer.getTime and love.timer.getTime()) or 0
          local timeout_seconds = 600
          return function()
            if love.filesystem.getInfo(WEB_BRIDGE_FILES.import_result) then
              local res = love.filesystem.read(WEB_BRIDGE_FILES.import_result) or ''
              bridge_log('import result observed', res)
              cleanup_bridge_file(WEB_BRIDGE_FILES.import_result)
              cleanup_bridge_file(WEB_BRIDGE_FILES.import_request)

              local ok_result, detail = parse_bridge_result(res)
              if ok_result == true then
                local data = love.filesystem.read(WEB_BRIDGE_FILES.import_temp) or ''
                if data ~= '' then
                  bridge_log('writing imported save to profile', prefix_profile)
                  local apply_ok, apply_detail = apply_import_payload(prefix_profile, profile_num, data, detail)
                  if not apply_ok then
                    print('[WEB IMPORT] Failed to apply import: ' .. tostring(apply_detail))
                    cleanup_bridge_file(WEB_BRIDGE_FILES.import_temp)
                    attention_text({ text = "Import failed", scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
                  else
                    bridge_log('import applied', tostring(apply_detail))
                    cleanup_bridge_file(WEB_BRIDGE_FILES.import_temp)
                    attention_text({ text = "Save imported!", scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
                  end
                else
                  print('[WEB IMPORT] Missing import data after OK result')
                  cleanup_bridge_file(WEB_BRIDGE_FILES.import_temp)
                  attention_text({ text = "Import failed", scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
                end
              elseif ok_result == false then
                print('[WEB IMPORT] Import failed: ' .. tostring(detail))
                cleanup_bridge_file(WEB_BRIDGE_FILES.import_temp)
                attention_text({ text = "Import failed", scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
              else
                print('[WEB IMPORT] Unexpected response: ' .. tostring(res))
                cleanup_bridge_file(WEB_BRIDGE_FILES.import_temp)
                attention_text({ text = "Import failed", scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
              end
              return true
            end

            local now_time = (love and love.timer and love.timer.getTime and love.timer.getTime()) or wait_started_at
            if (now_time - wait_started_at) > timeout_seconds then
              bridge_log('import timed out waiting for result')
              attention_text({ text = "Import timed out or cancelled", scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
              cleanup_bridge_file(WEB_BRIDGE_FILES.import_request)
              cleanup_bridge_file(WEB_BRIDGE_FILES.import_temp)
              return true
            end

            return false
          end
        end)()
      }))
    end)
  else
    stage_ok, stage_err = pcall(function()
      local profile = G.SETTINGS.profile or 1
      local ps_script = [[
Add-Type -AssemblyName System.Windows.Forms
$ofd = New-Object System.Windows.Forms.OpenFileDialog
$ofd.Filter = 'JKR Save (*.jkr)|*.jkr'
$ofd.Multiselect = $false
if ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { Write-Output $ofd.FileName }
]]
      local cmd = 'powershell -NoProfile -Command "' .. ps_script:gsub('"','\"'):gsub('\n',';') .. '"'
      local pipe = io.popen(cmd)
      if not pipe then error('Could not run powershell') end
      local selected = pipe:read('*a') or ''
      pipe:close()
      selected = selected:gsub('%s+$','')
      selected = selected:gsub('^%s+','')
      if selected == '' then error('Import cancelled') end

      local f, ferr = io.open(selected, 'rb')
      if not f then error('Could not open file: ' .. tostring(ferr)) end
      local data = f:read('*a')
      f:close()

      local profile_num = tonumber(profile) or 1
      local prefix_profile = tostring(profile_num)
      if not love.filesystem.getInfo(prefix_profile) then love.filesystem.createDirectory(prefix_profile) end
      local apply_ok, apply_err = apply_import_payload(prefix_profile, profile_num, data, selected)
      if not apply_ok then error('Failed to apply import payload: ' .. tostring(apply_err)) end
    end)
  end

  if not stage_ok then
    if stage_err then print('[IMPORT] Error staging import: ' .. tostring(stage_err)) end
    bridge_log('import staging failed', tostring(stage_err))
  cleanup_bridge_file(WEB_BRIDGE_FILES.import_request)
  cleanup_bridge_file(WEB_BRIDGE_FILES.import_result)
  cleanup_bridge_file(WEB_BRIDGE_FILES.import_temp)
    G.E_MANAGER:add_event(Event({
      func = function()
        attention_text({
          text = "Import failed - check console",
          scale = 0.5,
          hold = 2,
          align = 'cm',
          offset = {x = 0, y = -3},
          major = G.ROOM_ATTACH
        })
        return true
      end
    }))
  elseif not G.IS_WEB then
    G.E_MANAGER:add_event(Event({
      func = function()
        attention_text({
          text = "Save imported!",
          scale = 0.5,
          hold = 2,
          align = 'cm',
          offset = {x = 0, y = -3},
          major = G.ROOM_ATTACH
        })
        return true
      end
    }))
  end
end

G.FUNCS.import_mod_web = function(e)
  if not G.IS_WEB then
    G.E_MANAGER:add_event(Event({
      func = function()
        attention_text({
          text = 'Web-only feature',
          scale = 0.5,
          hold = 2,
          align = 'cm',
          offset = {x = 0, y = -3},
          major = G.ROOM_ATTACH
        })
        return true
      end
    }))
    return
  end

  local stage_ok, stage_err = pcall(function()
    bridge_log('starting mod import staging', WEB_BRIDGE_FILES.import_mod_request)
    ensure_bridge_hint()
    cleanup_bridge_file(WEB_BRIDGE_FILES.import_mod_result)
    cleanup_bridge_file(WEB_BRIDGE_FILES.import_mod_request)

    local req_ok, req_err = love.filesystem.write(WEB_BRIDGE_FILES.import_mod_request, 'request')
    if not req_ok then error('Failed to stage mod import request: ' .. tostring(req_err)) end
    bridge_log('mod import request staged')
    flush_filesystem()

    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.2,
      blockable = false,
      blocking = false,
      func = (function()
        local wait_started_at = (love and love.timer and love.timer.getTime and love.timer.getTime()) or 0
        local timeout_seconds = 600
        return function()
          if love.filesystem.getInfo(WEB_BRIDGE_FILES.import_mod_result) then
            local res = love.filesystem.read(WEB_BRIDGE_FILES.import_mod_result) or ''
            bridge_log('mod import result observed', res)
            cleanup_bridge_file(WEB_BRIDGE_FILES.import_mod_result)
            cleanup_bridge_file(WEB_BRIDGE_FILES.import_mod_request)

            local ok_result, detail = parse_bridge_result(res)
            if ok_result == true then
              attention_text({ text = 'Mod imported: ' .. tostring(detail ~= '' and detail or 'ok'), scale = 0.5, hold = 2.2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
              attention_text({ text = 'Restart game to load mod', scale = 0.45, hold = 2.2, align = 'cm', offset = {x = 0, y = -2.2}, major = G.ROOM_ATTACH })
            else
              local lowered = string.lower(tostring(detail or ''))
              if lowered == 'cancelled' or lowered == 'canceled' then
                bridge_log('mod import cancelled (ignored)')
              else
                attention_text({ text = 'Mod import failed', scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
                if detail and detail ~= '' then print('[WEB MOD IMPORT] ' .. tostring(detail)) end
              end
            end
            return true
          end

          local now_time = (love and love.timer and love.timer.getTime and love.timer.getTime()) or wait_started_at
          if (now_time - wait_started_at) > timeout_seconds then
            bridge_log('mod import timed out waiting for result')
            cleanup_bridge_file(WEB_BRIDGE_FILES.import_mod_request)
            attention_text({ text = 'Mod import timed out', scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
            return true
          end

          return false
        end
      end)()
    }))
  end)

  if not stage_ok then
    if stage_err then print('[MOD IMPORT] Error staging mod import: ' .. tostring(stage_err)) end
    bridge_log('mod import staging failed', tostring(stage_err))
    cleanup_bridge_file(WEB_BRIDGE_FILES.import_mod_request)
    cleanup_bridge_file(WEB_BRIDGE_FILES.import_mod_result)
  end
end

G.FUNCS.open_mod_menu_web = function(e)
  if not G.IS_WEB then
    G.E_MANAGER:add_event(Event({
      func = function()
        attention_text({
          text = 'Web-only feature',
          scale = 0.5,
          hold = 2,
          align = 'cm',
          offset = {x = 0, y = -3},
          major = G.ROOM_ATTACH
        })
        return true
      end
    }))
    return
  end

  MOD_BROWSER_STATE.source = 'local'
  MOD_BROWSER_STATE.local_mode = true
  if type(MOD_BROWSER_STATE.items) ~= 'table' then
    MOD_BROWSER_STATE.items = {}
  end
  if type(MOD_BROWSER_STATE.preview_items) ~= 'table' then
    MOD_BROWSER_STATE.preview_items = {}
  end
  if MOD_BROWSER_STATE.catalog_count == nil then
    MOD_BROWSER_STATE.catalog_count = #MOD_BROWSER_STATE.items
  end
  rebuild_local_mod_catalog()

  cleanup_bridge_file(WEB_BRIDGE_FILES.import_mod_request)
  cleanup_bridge_file(WEB_BRIDGE_FILES.import_mod_result)

  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu({ definition = G.UIDEF.web_mod_browser() })
  refresh_mod_browser_overlay()
end

G.FUNCS.refresh_mod_catalog_web = function(e)
  if MOD_BROWSER_STATE.local_mode then
    rebuild_local_mod_catalog()
    refresh_mod_browser_overlay()
    return
  end

  if MOD_BROWSER_STATE.needs_render and not MOD_BROWSER_STATE.pending then
    bridge_log('mod catalog refresh button rendering cached result')
    MOD_BROWSER_STATE.needs_render = false
    refresh_mod_browser_overlay()
    return
  end

  local source = MOD_BROWSER_STATE.source or 'all'
  if e and e.config and e.config.ref_table and e.config.ref_table.source then
    source = tostring(e.config.ref_table.source)
  end
  bridge_log('mod catalog refresh button requesting source', source)
  request_mod_catalog(source)
end

G.FUNCS.set_mod_catalog_source_web = function(e)
  MOD_BROWSER_STATE.source = 'local'
  MOD_BROWSER_STATE.local_mode = true
  MOD_BROWSER_STATE.page = 1
  rebuild_local_mod_catalog()
  refresh_mod_browser_overlay()
end

G.FUNCS.toggle_local_mod_web = function(e)
  if not (e and e.config and e.config.ref_table and e.config.ref_table.mod_id) then return end
  local mod_id = tostring(e.config.ref_table.mod_id)
  for _, mod in ipairs(LOCAL_MOD_CATALOG) do
    if mod.id == mod_id and mod.implemented == false then
      MOD_BROWSER_STATE.status = 'Mod not implemented yet: ' .. tostring(mod.title or mod_id)
      rebuild_local_mod_catalog()
      refresh_mod_browser_overlay()
      return
    end
  end
  local toggles = read_local_mod_toggles()
  toggles[mod_id] = not (toggles[mod_id] == true)
  G.ACTIVE_MOD_TOGGLES = toggles
  write_local_mod_toggles(toggles)
  apply_native_toggle_runtime(mod_id, toggles[mod_id] == true)
  local requires_full_texture_reload = (
    mod_id == 'subtle_additions' or
    mod_id == 'themed_jokers' or
    mod_id == 'baldatro'
  )
  if requires_full_texture_reload and G and G.set_render_settings then
    pcall(function() G:set_render_settings() end)
  end
  if G and G.set_language then
    pcall(function() G:set_language() end)
  end
  if G and G.GAME and G.GAME.viewed_back and G.GAME.viewed_back.effect and G.GAME.viewed_back.effect.center then
    local viewed_key = G.GAME.viewed_back.effect.center.key
    if viewed_key and G.P_CENTERS and G.P_CENTERS[viewed_key] then
      pcall(function() G.GAME.viewed_back:change_to(G.P_CENTERS[viewed_key]) end)
    end
  end
  rebuild_local_mod_catalog()
  refresh_mod_browser_overlay()
end

G.FUNCS.mod_catalog_prev_page = function(e)
  local page = tonumber(MOD_BROWSER_STATE.page) or 1
  MOD_BROWSER_STATE.page = math.max(1, page - 1)
  warm_visible_mod_icons()
  refresh_mod_browser_overlay()
end

G.FUNCS.mod_catalog_next_page = function(e)
  local per_page = tonumber(MOD_BROWSER_STATE.per_page) or 6
  local use_local = MOD_BROWSER_STATE.local_mode == true
  local total_items = 0
  if use_local then
    total_items = (type(MOD_BROWSER_STATE.local_mods) == 'table') and #MOD_BROWSER_STATE.local_mods or 0
  else
    total_items = (type(MOD_BROWSER_STATE.items) == 'table') and #MOD_BROWSER_STATE.items or 0
  end
  local max_page = math.max(1, math.ceil(total_items / per_page))
  local page = tonumber(MOD_BROWSER_STATE.page) or 1
  MOD_BROWSER_STATE.page = math.min(max_page, page + 1)
  warm_visible_mod_icons()
  refresh_mod_browser_overlay()
end

G.FUNCS.open_mod_entry_url = function(e)
  local url = nil
  local download_url = nil
  local title = nil
  if e and e.config and e.config.ref_table then
    url = e.config.ref_table.mod_url or e.config.ref_table.url
    download_url = e.config.ref_table.download_url
    title = e.config.ref_table.title
  end

  if G.IS_WEB and download_url and download_url ~= '' then
    local stage_ok, stage_err = pcall(function()
      ensure_bridge_hint()
      cleanup_bridge_file(WEB_BRIDGE_FILES.mod_download_result)
      cleanup_bridge_file(WEB_BRIDGE_FILES.mod_download_request)

      local req_payload = tostring(download_url)
      if title and title ~= '' then
        req_payload = req_payload .. '\n' .. tostring(title)
      end

      local req_ok, req_err = love.filesystem.write(WEB_BRIDGE_FILES.mod_download_request, req_payload)
      if not req_ok then error('Failed to stage mod download request: ' .. tostring(req_err)) end
      flush_filesystem()

      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.2,
        blockable = false,
        blocking = false,
        func = (function()
          local wait_started_at = (love and love.timer and love.timer.getTime and love.timer.getTime()) or 0
          local timeout_seconds = 60
          return function()
            if love.filesystem.getInfo(WEB_BRIDGE_FILES.mod_download_result) then
              local res = love.filesystem.read(WEB_BRIDGE_FILES.mod_download_result) or ''
              cleanup_bridge_file(WEB_BRIDGE_FILES.mod_download_result)
              cleanup_bridge_file(WEB_BRIDGE_FILES.mod_download_request)
              local ok_result, detail = parse_bridge_result(res)
              if ok_result == true then
                attention_text({ text = 'Mod installed: ' .. tostring(detail ~= '' and detail or 'ok'), scale = 0.5, hold = 2.2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
                attention_text({ text = 'Restart game to load mod', scale = 0.45, hold = 2.2, align = 'cm', offset = {x = 0, y = -2.2}, major = G.ROOM_ATTACH })
              else
                attention_text({ text = 'Mod install failed', scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
              end
              return true
            end

            local now_time = (love and love.timer and love.timer.getTime and love.timer.getTime()) or wait_started_at
            if (now_time - wait_started_at) > timeout_seconds then
              cleanup_bridge_file(WEB_BRIDGE_FILES.mod_download_request)
              attention_text({ text = 'Mod install timeout', scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
              return true
            end

            return false
          end
        end)()
      }))
    end)

    if not stage_ok then
      bridge_log('mod download staging failed', tostring(stage_err))
      cleanup_bridge_file(WEB_BRIDGE_FILES.mod_download_request)
      cleanup_bridge_file(WEB_BRIDGE_FILES.mod_download_result)
      attention_text({ text = 'Mod install failed', scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
    end
    return
  end

  if url and url ~= '' then
    love.system.openURL(url)
  else
    attention_text({ text = 'No mod URL available', scale = 0.45, hold = 1.5, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
  end
end

G.FUNCS.import_save_clipboard = function(e)
  local warning_text = e.UIBox:get_UIE_by_ID('warning_text')
  if not e.config._confirm then
    warning_text:juice_up()
    warning_text.config.colour = G.C.WHITE
    warning_text.config.shadow = true
    e.config._confirm = true
    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, blockable = false, blocking = false, func = function()
      e.config._confirm = nil
      return true
    end}))
    play_sound('tarot2', 1, 0.4)
    return
  end

  e.config._confirm = nil
  local stage_ok, stage_err
  if G.IS_WEB then
    stage_ok, stage_err = pcall(function()
      bridge_log('starting clipboard import staging')
      ensure_bridge_hint()
      cleanup_bridge_file(WEB_BRIDGE_FILES.import_result)
      cleanup_bridge_file(WEB_BRIDGE_FILES.import_request)
      cleanup_bridge_file(WEB_BRIDGE_FILES.import_direct)
      cleanup_bridge_file(WEB_BRIDGE_FILES.import_clipboard)
      cleanup_bridge_file(WEB_BRIDGE_FILES.import_temp)

      local req_ok, req_err = love.filesystem.write(WEB_BRIDGE_FILES.import_clipboard, 'clipboard')
      if not req_ok then error('Failed to stage clipboard import: ' .. tostring(req_err)) end
      flush_filesystem()

      local profile_raw = G.focused_profile or G.SETTINGS.profile or 1
      local profile_num = tonumber(profile_raw) or 1
      local prefix_profile = tostring(profile_num)
      if not love.filesystem.getInfo(prefix_profile) then love.filesystem.createDirectory(prefix_profile) end

      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.2,
        blockable = false,
        blocking = false,
        func = (function()
          local wait_started_at = (love and love.timer and love.timer.getTime and love.timer.getTime()) or 0
          local timeout_seconds = 600
          return function()
            if love.filesystem.getInfo(WEB_BRIDGE_FILES.import_result) then
              local res = love.filesystem.read(WEB_BRIDGE_FILES.import_result) or ''
              bridge_log('clipboard import result observed', res)
              cleanup_bridge_file(WEB_BRIDGE_FILES.import_result)
              cleanup_bridge_file(WEB_BRIDGE_FILES.import_request)

              local ok_result, detail = parse_bridge_result(res)
              if ok_result == true then
                local data = love.filesystem.read(WEB_BRIDGE_FILES.import_temp) or ''
                if data ~= '' then
                  bridge_log('writing clipboard save to profile', prefix_profile)
                  local apply_ok, apply_detail = apply_import_payload(prefix_profile, profile_num, data, detail)
                  if not apply_ok then
                    print('[WEB IMPORT] Failed to apply import: ' .. tostring(apply_detail))
                    cleanup_bridge_file(WEB_BRIDGE_FILES.import_temp)
                    attention_text({ text = "Import failed", scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
                  else
                    bridge_log('clipboard import applied', tostring(apply_detail))
                    cleanup_bridge_file(WEB_BRIDGE_FILES.import_temp)
                    attention_text({ text = "Save imported!", scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
                  end
                else
                  print('[WEB IMPORT] Missing import data after OK result')
                  cleanup_bridge_file(WEB_BRIDGE_FILES.import_temp)
                  attention_text({ text = "Import failed", scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
                end
              elseif ok_result == false then
                print('[WEB IMPORT] Import failed: ' .. tostring(detail))
                cleanup_bridge_file(WEB_BRIDGE_FILES.import_temp)
                attention_text({ text = "Import failed", scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
              else
                print('[WEB IMPORT] Unexpected response: ' .. tostring(res))
                cleanup_bridge_file(WEB_BRIDGE_FILES.import_temp)
                attention_text({ text = "Import failed", scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
              end
              return true
            end

            local now_time = (love and love.timer and love.timer.getTime and love.timer.getTime()) or wait_started_at
            if (now_time - wait_started_at) > timeout_seconds then
              bridge_log('clipboard import timed out waiting for result')
              attention_text({ text = "Import timed out or cancelled", scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
              cleanup_bridge_file(WEB_BRIDGE_FILES.import_request)
              cleanup_bridge_file(WEB_BRIDGE_FILES.import_temp)
              return true
            end

            return false
          end
        end)()
      }))
    end)
  else
    stage_ok, stage_err = pcall(function()
      attention_text({ text = "Clipboard import is web-only", scale = 0.5, hold = 2, align = 'cm', offset = {x = 0, y = -3}, major = G.ROOM_ATTACH })
    end)
  end

  if not stage_ok then
    if stage_err then print('[IMPORT] Clipboard import error: ' .. tostring(stage_err)) end
    bridge_log('clipboard import staging failed', tostring(stage_err))
    cleanup_bridge_file(WEB_BRIDGE_FILES.import_request)
    cleanup_bridge_file(WEB_BRIDGE_FILES.import_result)
    cleanup_bridge_file(WEB_BRIDGE_FILES.import_temp)
    G.E_MANAGER:add_event(Event({
      func = function()
        attention_text({
          text = "Import failed - check console",
          scale = 0.5,
          hold = 2,
          align = 'cm',
          offset = {x = 0, y = -3},
          major = G.ROOM_ATTACH
        })
        return true
      end
    }))
  end
end

