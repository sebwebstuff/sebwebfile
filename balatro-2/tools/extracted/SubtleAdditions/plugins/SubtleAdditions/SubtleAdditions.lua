--- STEAMODDED HEADER
--- MOD_NAME: Subtle Additions
--- MOD_ID: SubtleAdditions
--- MOD_AUTHOR: [Booj]
--- MOD_DESCRIPTION: Additions you may not notice
--- PREFIX: sa
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0812d]

----------------------------------------------
------------MOD CODE -------------------------

sendDebugMessage("Launching Subtle Additions", "SubtleAdditions")

SubtleAdditions = SMODS.current_mod

SubtleAdditions.save_config = function(self)
	SMODS.save_mod_config(self)
	
	local config = self.config
	
	if config["Enable Subtle Deck"] == true then
		SMODS.Atlas{key = "cards_1", path = "8bitcards-subtle.png", px = 71, py = 95, prefix_config = { key = false } }
		SMODS.Atlas{key = "cards_2", path = "8bitcards-alt-subtle.png", px = 71, py = 95, prefix_config = { key = false } }
	else
		SMODS.Atlas{key = "cards_1", path = "8BitDeck.png", px = 71, py = 95, prefix_config = { key = false } }
		SMODS.Atlas{key = "cards_2", path = "8BitDeck_opt2.png", px = 71, py = 95, prefix_config = { key = false } }
	end
end

SubtleAdditions:save_config()

SMODS.Atlas{key = "Joker", path = "Jokers-subtle.png", px = 71, py = 95, prefix_config = { key = false } }
SMODS.Atlas{key = "shop_sign", path = "ShopSignAnimation-subtle.png", px = 113, py = 57, prefix_config = { key = false }, atlas_table = 'ANIMATION_ATLAS', frames = 4}
SMODS.Atlas{key = "blind_chips", path = "BlindChips-subtle.png", px = 34, py = 34, prefix_config = { key = false }, atlas_table = 'ANIMATION_ATLAS', frames = 21}
SMODS.Atlas{key = "Voucher", path = "Vouchers-subtle.png", px = 71, py = 95, prefix_config = { key = false } }
SMODS.Atlas{key = "Tarot", path = "Tarots-subtle.png", px = 71, py = 95, prefix_config = { key = false } }
SMODS.Atlas{key = "Planet", path = "Tarots-subtle.png", px = 71, py = 95, prefix_config = { key = false } }
SMODS.Atlas{key = "Spectral", path = "Tarots-subtle.png", px = 71, py = 95, prefix_config = { key = false } }
SMODS.Atlas{key = "Booster", path = "boosters-subtle.png", px = 71, py = 95, prefix_config = { key = false } }
SMODS.Atlas{key = "tags", path = "tags-subtle.png", px = 34, py = 34, prefix_config = { key = false } }

--SMODS.Atlas{key = "localthunk_logo", path = "localthunk-logo-subtle.png", px = 1390, py = 560, prefix_config = { key = false }, atlas_table = 'ASSET_IMAGES' }
Center = SMODS.Atlas:extend{
	inject = function(self)
		SMODS.Atlas.inject(self)
		G.shared_debuff = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["centers"], {x=4, y = 0})

		G.shared_soul = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["centers"], G.P_CENTERS.soul.pos)
		sendDebugMessage("Replaced Soul Texture", "SubtleAdditions")
		G.shared_undiscovered_joker = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["centers"], G.P_CENTERS.undiscovered_joker.pos)
		G.shared_undiscovered_tarot = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["centers"], G.P_CENTERS.undiscovered_tarot.pos)

		G.shared_sticker_eternal = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["stickers"], {x = 0,y = 0})
		G.shared_sticker_perishable = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["stickers"], {x = 0,y = 2})
		G.shared_sticker_rental = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["stickers"], {x = 1,y = 2})

		G.shared_stickers = {
			White = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["stickers"], {x = 1,y = 0}),
			Red = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["stickers"], {x = 2,y = 0}),
			Green = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["stickers"], {x = 3,y = 0}),
			Black = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["stickers"], {x = 0,y = 1}),
			Blue = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["stickers"], {x = 4,y = 0}),
			Purple = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["stickers"], {x = 1,y = 1}),
			Orange = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["stickers"], {x = 2,y = 1}),
			Gold = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["stickers"], {x = 3,y = 1})
		}
		G.shared_seals = {
			Gold = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["centers"], {x = 2,y = 0}),
			Purple = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["centers"], {x = 4,y = 4}),
			Red = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["centers"], {x = 5,y = 4}),
			Blue = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["centers"], {x = 6,y = 4}),
		}
		G.sticker_map = {
			'White','Red','Green','Black','Blue','Purple','Orange','Gold'
		}
	end,
}

Center{key = "centers", 
	path = "Enhancers-subtle.png", 
	px = 71, 
	py = 95, 
	prefix_config = { key = false },}
	
SMODS.Atlas{key = "icons", path = "icons-subtle.png", px = 66, py = 66, prefix_config = { key = false } }

SMODS.current_mod.config_tab = function()
 	return {n = G.UIT.ROOT, config = {r = 0.1, minw = 5, align = "cm", padding = 0.2, colour = G.C.CLEAR}, 
		nodes = {
			create_toggle({label = 'Enable Subtle Deck (Requires Restart)', ref_table = SubtleAdditions.config, ref_value = 'Enable Subtle Deck', callback = function() SubtleAdditions:save_config() end}),
		}
	}
 end

function replace_joker_text(joker_id, loc_text)
	G.localization.descriptions['Joker'][joker_id] = loc_text
end

function replace_blind_text(blind_id, loc_text)
	G.localization.descriptions['Blind'][blind_id] = loc_text
end

function replace_tag_text(tag_id, loc_text)
	G.localization.descriptions['Tag'][tag_id] = loc_text
end

card_super = Card.set_ability

function Card:set_ability(center, initial, delay_sprites)
	card_super(self, center, initial, delay_sprites)
	local X, Y, W, H = self.T.x, self.T.y, self.T.w, self.T.h
	if center.name == "Wee Joker" and (center.discovered or self.bypass_discovery_center) then 
        H = H*0.3
        W = W*0.3
        self.T.h = H
        self.T.w = W
    end
	if center.name == "Ancient Joker" and (center.discovered or self.bypass_discovery_center) then 
        H = H*1.1
        W = W*1.1
        self.T.h = H
        self.T.w = W
    end
end

function SMODS.current_mod.process_loc_text()
	replace_joker_text('j_clever', {name = 'Pesky Joker', text = {"{C:chips}+#1#{} Chips if played", "hand contains", "a {C:attention}#2#"},})
	replace_joker_text('j_credit_card', {name = 'Dedit Carb', text = {"Go up to","{C:red}-$#1#{} in debt","{C:inactive} erm... crebit?",}})
	replace_joker_text('j_family', {name="The Family (Guy)", text={
                    "{X:mult,C:white} X#1# {} Mult if played",
                    "hand contains",
                    "a {C:attention}#2#",
                },
                unlock={
                    "Win a run",
                    "without playing",
                    "a {E:1,C:attention}#1#",
                },})
	
	replace_joker_text('j_faceless', {name="Sniffing Joker",
                text={
                    "Earn {C:money}$#1#{} if {C:attention}#2#{} or",
                    "more {C:attention}face cards{}",
                    "are sniffed",
                    "at the same time",
                },})
	replace_joker_text('j_green_joker', {name="The Green Grinner",
                text={
                    "{C:mult}+#1#{} Mult per hand played",
                    "{C:mult}-#2#{} Mult per discard",
                    "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult)",
                },})
	replace_joker_text('j_obelisk', {name="Obelisk",
                text={
                    "You don't care",
					"You know this card sucks",
                },})
	replace_joker_text('j_obelisk', {name="Obelisk",
                text={
                    "You don't care",
					"You know this card sucks",
                },})
	replace_joker_text('j_hanging_chad', {name="Hanging Chud",
                text={
                    "Retrigger {C:attention}first{} played",
                    "card used in scoring",
                    "{C:attention}#1#{} additional times",
                },
                unlock={
                    "Beat a Boss Blind",
                    "with a {E:1,C:attention}#1#",
                },})
				
	--Replace Blinds
	
	replace_blind_text('bl_eye', {name = 'The I', text={
                    "No repeat hand",
                    "types this round",
                },})
	replace_blind_text('bl_goad', {name = 'The Chode', text={
                    "All Spade cards",
                    "are debuffed",
                },})
	replace_blind_text('bl_mark', {name = 'The Mark(iplier)', text={
                    "All face cards are",
                    "drawn face down",
                },})
	
	--Replace Tags
	replace_tag_text('tag_economy', {name="Buzzfeed",
                text={
                    "Doubles your money",
                    "{C:inactive}(Max of {C:money}$#1#{C:inactive})",
                },})
	replace_tag_text('tag_juggle', {name="Ball Fondler",
                text={
                    "{C:attention}+#1#{} hand size",
                    "next round",
                },})
	
end

SMODS.Sound{
	key = "pingas",
	path = "pingas.ogg"
}

SMODS.Joker:take_ownership("ramen", {
	rarity = 2,
	calculate = function(self, card, context)
		local H, W = card.T.h, card.T.w
		local origh = 2.7512195121951
		local origw = 2.0487804878049
		
		card.T.h = origh * (card.ability.x_mult / 2)
		card.T.w = origw * (card.ability.x_mult / 2)
	end
}, true)

SMODS.Joker:take_ownership("bull", {
	loc_txt = {
		name="Robotnik",
		text={
			"{C:chips}+#1#{} Chips for",
			"each {C:money}$1{} you have",
			"{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)",
		},
	},
	calculate = function(self, card, context)
		if context.cardarea == G.jokers and card.ability.name == "Bull" then
			if context.joker_main then
				G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0, func = function()
					play_sound('sa_pingas')
					return true end }))
			end
		end
	end,
}, true)

--[[
SMODS.Challenge {
	key = 'sa_test_1',
	loc_txt = {name = 'Test Challenge',},
    rules = {
		custom = {
		},
		modifiers = {
			{id = 'dollars', value = 999},
			{id = 'discards', value = 999},
			{id = 'hands', value = 999},
			{id = 'reroll_cost', value = 0},
			{id = 'joker_slots', value = 10},
			{id = 'consumable_slots', value = 3},
			{id = 'hand_size', value = 8},
		}
	},
	jokers = {
		{id = 'j_ramen'},
		{id = 'j_bull'},
		{id = 'j_blueprint'},
	},
	consumeables = {
	},
	vouchers = {
	},
	deck = {
		type = 'Challenge Deck'
	},
	restrictions = {
	},
}
]]--

--G.P_TAGS.tag_economy = {name = 'Economy Tag',      set = 'Tag', discovered = false, min_ante = nil, order = 24, config = {type = 'immediate', max = 80}, pos = {x = 4,y = 3}}

----------------------------------------------
------------MOD CODE END----------------------