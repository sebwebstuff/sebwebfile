--- STEAMODDED HEADER
--- MOD_NAME: Pestrica Challenge
--- MOD_ID: PesChl
--- MOD_AUTHOR: [MARINA]
--- MOD_DESCRIPTION: Challenge revolving playing 4 cards to try pestrica
--- BADGE_COLOR: 000000
--- DEPENDENCIES: Pestrica Joker
--- VERSION: 1.0

----------------------------------------------
------------MOD CODE -------------------------
local challenges = G.CHALLENGES
table.insert(G.CHALLENGES,1,{
    name = "Juggling hands",
    id = "c_mod_peschl",
    rules = {
        custom = {
            {id = "double_ante"},
            {id = "fast_scaling"},
        },
    },
    jokers = {
        {id = "j_four_fingers", eternal = true},
        {id = "j_square", eternal = true},
        {id = "j_trousers", eternal = true},
        {id = "j_family", eternal = true},
        {id = "j_pesj_Pestrica", eternal = true},
    },
    consumeables = {},
    vouchers = {
    },
    deck = {
        type = 'Challenge Deck',
    },
    restrictions = {
        banned_cards = {
        },
        banned_tags = {
        },
        banned_other = {
        }
    }
})
function SMODS.current_mod.process_loc_text()
    G.localization.misc.challenge_names.c_mod_peschl = "Juggling hands"
    G.localization.misc.v_text.ch_c_double_ante = {"{X:mult,C:white}X4{} base blind size"}
    G.localization.misc.v_text.ch_c_fast_scaling = {"Required score scales faster for each Ante"}
end


Game.start_run_ref = Game.start_run
    function Game:start_run(args)
        self:start_run_ref(args)
        if G.GAME.challenge == "c_mod_peschl" then
            G.GAME.starting_params.ante_scaling = 4
            G.GAME.modifiers.scaling = 2
        end
    end

G.localization.misc.challenge_names.c_mod_peschl = "Time to juggle"

----------------------------------------------
------------MOD CODE END----------------------