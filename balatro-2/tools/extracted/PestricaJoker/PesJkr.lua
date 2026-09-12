--- STEAMODDED HEADER
--- MOD_NAME: Pestrica Joker
--- MOD_ID: PesJkr
--- MOD_AUTHOR: [MARINA]
--- MOD_DESCRIPTION: Adds the legendary juggler joker

----------------------------------------------
------------MOD CODE -------------------------
SMODS.Atlas {
    key = "Jokers-Pestrica",
    path = "Jokers-Pestrica.png",
    px = 71,
    py = 95
}
SMODS.Atlas({
key = "modicon",
path = "modicon.png", 
px = 32, 
py = 32
})

SMODS.Joker{
    key = "Pestrica",
    loc_txt = {
        name = "Pestrica",
        text = {
            "This Joker gains {X:mult,C:white}X0.5{} Mult",
            "every time that scoring hand",
            "contains exactly {C:attention}4{} cards",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)"
        }
    },
    atlas = "Jokers-Pestrica",
    pos = {x = 0, y = 0},
    rarity = 4,
    soul_pos = { x = 0, y = 1},
    cost = 20,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_comat = true,
    perishable_compat = true,
    config = { extra = {
        Xmult = 1,
        Xmult_gain = 0.5
    }
    },
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.Xmult}}
    end,
    calculate = function(self,card,context)
        
        if context.before and #context.scoring_hand == 4 then
            card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gain
            return { 
                message = localize('k_upgrade_ex') 
            }
        end
        if context.joker_main then
            return {
                   
                card = card,
                Xmult_mod = card.ability.extra.Xmult,
                message = "x" .. card.ability.extra.Xmult,
                colour = G.C.MULT,
            }
        end
        
    end,
    in_pool = function(self,wawa,wawa2)
        return true
    end
}

----------------------------------------------
------------MOD CODE END----------------------