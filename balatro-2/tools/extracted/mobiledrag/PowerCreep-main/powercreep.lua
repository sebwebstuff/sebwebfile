--- STEAMODDED HEADER
--- MOD_NAME: powercreep
--- MOD_ID: powercreep
--- MOD_AUTHOR: [dogwearingdurag]
--- MOD_DESCRIPTION: Slightly unbalanced mod
--- PREFIX: xmpl
----------------------------------------------
------------MOD CODE -------------------------
SMODS.Atlas{
    key = 'powercreep', -- atlas key
    path = 'Jokers.png', -- atlas' path in (yourMod)/assets/1x or (yourMod)/assets/2x
    px = 71, -- width of one card
    py = 95 -- height of one card
}
local event_added = false

SMODS.Joker{
    key = 'powercreep',
    loc_txt = {
        name = 'Power Creep',
        text = {
            "{X:mult,C:white} X#1# {} Mult",
            "Beating a {C:attention}Boss Blind{} by triple",
            "the required chips creates a",
            "{C:blue}Negative{} copy of Power Creep",
            "{C:red}One hand per round{}"
        }
    },
    atlas = 'powercreep', -- atlas' key
    rarity = 3,
    cost = 10,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pos = {x = 0, y = 0},
    config = {
        extra = {
            Xmult = 1.5
        }
    },
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.Xmult}}
    end,
    calculate = function(self, card, context)
  -- if card.edition and card.edition.negative then return end

  if context.setting_blind then
G.E_MANAGER:add_event(Event({func = function()
ease_hands_played(-G.GAME.current_round.discards_left, nil, true)
return true end }))
  end
  if context.joker_main then
return {
Xmult =1.5
}
  end
  if context.setting_blind then
event_added = false
  end

  -- count all powercreep jokers
  local counter = #SMODS.find_card('j_pow_powercreep')
 
  if not event_added and G.GAME.blind.boss and (G.GAME.chips / G.GAME.blind.chips >= 3) then
-- creates a new event for the joker generation,
-- this occurs once after the boss blind is beaten with more than 3x blind size to ensure no random joker creation.
G.E_MANAGER:add_event(Event({ func = function()
for i = 1, counter do
  -- original here was create 'powercreep' joker cards, I've changed it to 'j_pow_powercreep',
  -- no idea if this changes anything but it works so far
  local new_card = create_card('j_pow_powercreep', G.jokers, nil, nil, nil, nil, 'j_pow_powercreep')
  new_card:set_edition({ negative = true }, true)
  new_card:add_to_deck()
  G.jokers:emplace(new_card)
end
return true
end }))

event_added = true
  end
end,
    in_pool = function(self, wawa, wawa2)
        return true
    end,
}
