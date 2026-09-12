# Buffoon Deck Porting Status

## Status
- Started: 2026-03-04
- Source staged from: `tools/downloaded_mods/Buffoon_Deck.zip`
- Current phase: baseline extraction + behavior mapping

## Upstream summary
- Mod type: custom deck + startup booster effect
- Upstream deps: Lovely patches + JSUtils data files
- Deck id: `b_js_buffoon`
- Deck behavior: opens `p_buffoon_jumbo_1` at blind selection once per run

## Behavior mapping (upstream -> target)
1. `game.lua` patch hook after blind-select alignment setup
   - Target equivalent: run selected-back effect trigger when entering blind select
2. `back.lua` patch hook in back effect trigger
   - Target equivalent: if `args.context == 'blind_select'` and deck has booster config, spawn zero-cost booster card and consume once
3. JSUtils `centers.json`
   - Target equivalent: native deck center registration table
4. JSUtils `descriptions.json`
   - Target equivalent: localization entry in `localization/en-us.lua`
5. JSUtils `asset_atli.json` + textures
   - Target equivalent: atlas registration and texture placement in project resources

## Next implementation steps
- [ ] Add native deck center registration for `b_js_buffoon`
- [ ] Add one-shot blind-select booster effect in base deck trigger path
- [ ] Add EN localization text for Buffoon Deck
- [ ] Register/import atlas + texture data
- [ ] Add toggle-aware load gate for this local mod
- [ ] Smoke test: select deck, start run, verify jumbo buffoon appears once
