return {
  meta = {
    mod_name = "Buffoon Deck",
    source = "JoStro-Buffoon_Deck",
    started_utc = "2026-03-04T00:00:00Z",
  },

  deck = {
    id = "b_js_buffoon",
    name = "Buffoon Deck",
    set = "Back",
    pos = { x = 0, y = 0 },
    stake = 1,
    unlocked = true,
    discovered = true,
    atlas = "JS_Buffoon",
    config = {
      booster = "p_buffoon_jumbo_1",
    },
  },

  localization = {
    ["en-us"] = {
      Back = {
        b_js_buffoon = {
          name = "Buffoon Deck",
          text = {
            "Start by opening",
            "a {C:attention}Jumbo Buffoon Pack",
          },
        },
      },
    },
  },

  atlas = {
    name = "JS_Buffoon",
    path = "buffoon_deck.png",
    px = 71,
    py = 95,
  },

  behavior = {
    event = "blind_select",
    one_shot_flag = "booster_deck_triggered",
    action = "spawn_and_use_booster",
    booster_key = "p_buffoon_jumbo_1",
  },
}
