--- STEAMODDED HEADER
--- MOD_NAME: Jevil's card
--- MOD_ID: JEVILJOKER
--- MOD_AUTHOR: [Megathek]
--- MOD_DESCRIPTION: CHAOS CHAOS

SMODS.Atlas{
    key= 'Jokers',
    path = 'Jokers.png',
    px = 71;
    py = 95;
}
SMODS.Joker{
    key = 'Jevil',
    loc_txt = {
        name = 'Pirouette',
        text = {
            'When a hand is played,',
            'gives a {C:green}random{} effect.',
            '{s:0.7}{C:inactive}After {C:attention}4{} {C:inactive}rounds, sell this{}',
            "{s:0.7}{C:inactive} card to create {C:attention}Devil's knife{}"
        },
    },
    atlas = 'Jokers',
    pos = {x = 0, y = 0},
    config = {extra = { Xmin = 3, Xmax= 8, invis_rounds = 0, total_rounds = 4, random_eff1= 1, random_eff2= 5, repetitions = 3, half_chips = 0.5, half_mult = 0.5} },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    no_pool_flag = 'jevil_is_sold',
    
    calculate = function(self, card, context)
        
        if context.before then
            temp_random = pseudorandom('CHAOS effect', card.ability.extra.random_eff1, card.ability.extra.random_eff2)
            if temp_random ==3 and not context.blueprint then
                return {
                    message = 'ALL KINGS!',
                    colour = G.C.PURPLE
            }
            end
        end

        if context.destroy_card and context.destroy_card.should_destroy and not context.blueprint then
            return { remove = true}
        end

        if context.joker_main then
            if temp_random==1 then
                local temp_Xmult = pseudorandom('CHAOS mult', card.ability.extra.Xmin, card.ability.extra.Xmax)
                return {
                        Xmult = temp_Xmult,
                        message = 'X CHAOS MULT',
                        colour = G.C.PURPLE
                }
            end
            if temp_random ==4 and not context.blueprint then
                return {
                    message = "BYE-BYE!",
                    colour = G.C.PURPLE
            }
            end
            if temp_random ==5 then
                return {
                    xchips = card.ability.extra.half_chips,
                    extra = {
                        Xmult = card.ability.extra.half_mult,
                        message = "CUT IN HALF!",
                        colour = G.C.PURPLE
                    }
                
            }
            end             
        end

        if context.individual and context.cardarea == G.hand and not context.end_of_round and not context.blueprint then
            context.other_card.should_destroy = false

                if temp_random==3 then
                    assert(SMODS.change_base(context.other_card, "Spades", "King"))
                    play_sound('tarot2', 0.3, 0.3);
                end
                
                if temp_random==4 then
                    context.other_card.should_destroy = true
                end
        end
        if context.repetition and context.cardarea == G.play then
            if temp_random==2 then
                return {
                    repetitions = card.ability.extra.repetitions
                }
            end
        end

        if context.selling_self and (card.ability.extra.invis_rounds >= card.ability.extra.total_rounds) and not context.blueprint then
            G.GAME.pool_flags.jevil_is_sold = true
            local new_card = create_card('joker', G.jokers, nil, nil, nil, nil, 'j_jevi_Devilsknife')
            new_card:add_to_deck()
            G.jokers:emplace(new_card)
            return {
                message = "METAMORPHOSIS!",
                colour = G.C.PURPLE
            }
        end

        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            card.ability.extra.invis_rounds = card.ability.extra.invis_rounds + 1
            if card.ability.extra.invis_rounds == card.ability.extra.total_rounds then
                local eval = function(card) return not card.REMOVED end
                juice_card_until(card, eval, true)
            end
            return {
                message = (card.ability.extra.invis_rounds <= card.ability.extra.total_rounds) and
                    (card.ability.extra.invis_rounds .. '/' .. card.ability.extra.total_rounds),
                colour = G.C.FILTER
            }
        end
    end
}
SMODS.Joker {
    key = "Devilsknife",
    loc_txt = {
        name = "Devil's Knife",
        text = {
            'Each {C:attention}King {}of {C:spades}Spades{} in your',
            '{C:attention}full deck{} gives {X:red,C:white}X1{} Mult',
            '{s:0.7}{C:inactive}[Currently {X:red,C:white}X#1#{}{C:inactive}]{}',
        },
    },
    atlas = 'Jokers',
    pos = { x = 1, y = 0 },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    rarity = 4,
    soul_pos = { x = 2, y = 0},
    cost = 20,
    config = {extra = {suit = 'Spades', Xmult=0} },
    yes_pool_flag = 'jevil_is_sold',
    loc_vars = function(self, info_queue, card)
        spade_kings = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card:get_id() == 13 and playing_card:is_suit(card.ability.extra.suit) then spade_kings = spade_kings + 1 end
            end
        end
        return {vars = {spade_kings}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                Xmult = spade_kings,
                colour = G.C.MULT
            }
        end
    end
}
SMODS.Challenge{
    key = 'true_chaos',
    loc_txt = {
        name = 'THE TRUE AND NEO CHAOS!'
    },
    rules = {
        custom = {
        },
        modifiers = {
            {id = 'joker_slots', value = 2 },
            {id = 'hand_size', value = 10 }
        }
    },
    jokers = {
        {id = 'j_blueprint', eternal = true},
        {id = 'j_jevi_Jevil', eternal = true}
        
    },
    vouchers = {
        {id = 'v_blank'},
        {id = 'v_omen_globe'},
    }
}
SMODS.Atlas({
	key = "modicon",
	path = "jevilicon.png",
	px = 32,
	py = 32
})
