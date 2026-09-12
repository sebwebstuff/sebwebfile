local malverk = SMODS.Mods['malverk'] 
local malverk_can_load = false

if malverk then
    sendDebugMessage("Malverk found! Initializing Baldatro with malverk!")
    malverk_can_load = malverk.can_load
end

if malverk_can_load then
    AltTexture ({
        key = 'Baldatro_joker',
        set = 'Joker',
        path = 'baldJokers.png',
        original_sheet = true,
        loc_txt = {
            name = 'Bald jokers',
        },
        keys = {
            'j_joker',
            'j_greedy_joker',
            'j_lusty_joker',
            'j_wrathful_joker',
            'j_gluttenous_joker',
            'j_jolly',
            'j_zany',
            'j_mad',
            'j_crazy',
            'j_droll',
            'j_sly',
            'j_wily',
            'j_clever',
            'j_devious',
            'j_crafty',
            'j_half',
            'j_stencil',
            'j_four_fingers',
            'j_credit_card',
            'j_ceremonial',
            'j_marble',
            'j_misprint',
            'j_chaos',
            'j_steel_joker',
            'j_hack',
            'j_gros_michel',
            'j_even_steven',
            'j_odd_todd',
            'j_scholar',
            'j_space',
            'j_egg',
            'j_burglar',
            'j_blackboard',
            'j_runner',
            'j_blue_joker',
            'j_constellation',
            'j_hiker',
            'j_faceless',
            'j_green_joker',
            'j_cavendish',
            'j_card_sharp',
            'j_madness',
            'j_square',
            'j_riff_raff',
            'j_vampire',
            'j_hologram',
            'j_vagabond',
            'j_baron',
            'j_photograph',
            'j_gift',
            'j_hallucination',
            'j_fortune_teller',
            'j_juggler',
            'j_drunkard',
            'j_stone',
            'j_golden',
            'j_lucky_cat',
            'j_baseball',
            'j_bull',
            'j_trading',
            'j_flash',
            'j_selzer',
            'j_mr_bones',
            'j_swashbuckler',
            'j_troubadour',
            'j_smeared',
            'j_throwback',
            'j_glass',
            'j_ring_master',
            'j_blueprint',
            'j_wee',
            'j_merry_andy',
            'j_idol',
            'j_hit_the_road',
            'j_brainstorm',
            'j_shoot_the_moon',
            'j_drivers_license',
            'j_cartomancer',
            'j_astronomer',
            'j_burnt',
            'j_caino',
            'j_triboulet',
            'j_yorick',
            'j_chicot',
            'j_perkeo'
        },
    })

    AltTexture ({
        key = 'Baldatro_joker_diet_cola',
        set = 'Joker',
        path = 'baldJokers.png',
        original_sheet = true,
        keys = {
            'j_diet_cola',
        },
        loc_txt = {
            name = 'Minoxidil',
        },
    })
    TexturePack({
        key = 'Baldatro_pack',
        textures = {
            'Baldatro_joker',
            'Baldatro_joker_diet_cola',
        },
        dynamic_display = true,
        loc_txt = {
            name = 'Baldatro',
            text = {
                'Retextures Jokers card{}',
                'to be {E:1,C:legendary}"Bald"{}',
                'Art by {E:1,C:dark_edition,s:1.1}SirMaiquis',
                '{C:inactive,s:0.8}Code by SirMaiquis.{}'
            },
        },
    })
else
    sendDebugMessage("Launching Baldatro without malverk!")
    SMODS.Atlas { key = "Joker", path = "baldJokers.png", px = 71, py = 95, prefix_config = { key = false } }
end

