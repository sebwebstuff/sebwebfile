local function smods_copy_table(value)
    if type(value) ~= 'table' then return value end
    local out = {}
    for k, v in pairs(value) do
        out[k] = smods_copy_table(v)
    end
    return out
end

local function smods_count(tbl)
    local n = 0
    if type(tbl) ~= 'table' then return 0 end
    for _ in pairs(tbl) do n = n + 1 end
    return n
end

local function smods_next_center_order(set_name)
    local max_order = 0
    if G and G.P_CENTERS then
        for _, center in pairs(G.P_CENTERS) do
            if center and center.set == set_name and type(center.order) == 'number' and center.order > max_order then
                max_order = center.order
            end
        end
    end
    return max_order + 1
end

local function smods_ensure_mod_registry()
    _G.__SMODS_NATIVE_MOD_PATHS = _G.__SMODS_NATIVE_MOD_PATHS or {}
    _G.__NATIVE_MOD_CENTER_KEYS = _G.__NATIVE_MOD_CENTER_KEYS or {}
    _G.__SMODS_NATIVE_SPRITES = _G.__SMODS_NATIVE_SPRITES or {}
end

local function smods_register_center_key(mod_id, key)
    if not mod_id or not key then return end
    smods_ensure_mod_registry()
    _G.__NATIVE_MOD_CENTER_KEYS[mod_id] = _G.__NATIVE_MOD_CENTER_KEYS[mod_id] or {}
    local list = _G.__NATIVE_MOD_CENTER_KEYS[mod_id]
    for i = 1, #list do
        if list[i] == key then return end
    end
    list[#list + 1] = key
end

local function smods_queue_loc(set_name, key, loc)
    if type(set_name) ~= 'string' or type(key) ~= 'string' or type(loc) ~= 'table' then return end
    _G.__SMODS_NATIVE_PENDING_LOC = _G.__SMODS_NATIVE_PENDING_LOC or {}
    _G.__SMODS_NATIVE_PENDING_LOC[set_name] = _G.__SMODS_NATIVE_PENDING_LOC[set_name] or {}
    _G.__SMODS_NATIVE_PENDING_LOC[set_name][key] = smods_copy_table(loc)
end

local function smods_prepare_loc_entry(loc)
    if type(loc) ~= 'table' then return nil end
    local out = smods_copy_table(loc)

    if type(loc_parse_string) == 'function' then
        out.text_parsed = {}
        for _, line in ipairs(out.text or {}) do
            out.text_parsed[#out.text_parsed + 1] = loc_parse_string(line)
        end

        out.name_parsed = {}
        local name_lines = type(out.name) == 'table' and out.name or {out.name}
        for _, line in ipairs(name_lines) do
            out.name_parsed[#out.name_parsed + 1] = loc_parse_string(line)
        end

        if out.unlock then
            out.unlock_parsed = {}
            for _, line in ipairs(out.unlock) do
                out.unlock_parsed[#out.unlock_parsed + 1] = loc_parse_string(line)
            end
        end
    end

    return out
end

local function smods_apply_loc_if_ready(set_name, key, loc)
    if not (G and G.localization and G.localization.descriptions) then
        smods_queue_loc(set_name, key, loc)
        return false
    end
    G.localization.descriptions[set_name] = G.localization.descriptions[set_name] or {}
    G.localization.descriptions[set_name][key] = smods_prepare_loc_entry(loc)
    return true
end

local function smods_resolve_sprite_path(mod_path, file_name)
    if type(file_name) ~= 'string' or file_name == '' then return nil end
    local base = mod_path or ''
    local candidates = {
        base .. file_name,
        base .. 'assets/1x/' .. file_name,
        base .. 'assets/2x/' .. file_name,
    }
    for i = 1, #candidates do
        if love.filesystem.getInfo(candidates[i]) then
            return candidates[i]
        end
    end
    return candidates[1]
end

local function smods_ensure_atlas(name, path, px, py)
    if not (G and G.ASSET_ATLAS and name and path) then return end
    if not love.filesystem.getInfo(path) then return end
    if G.ASSET_ATLAS[name] then return end

    local atlas_px = px or 71
    local atlas_py = py or 95
    local is_hcm_single_sprite = type(name) == 'string' and (string.sub(name, 1, 6) == 'j_hcm_' or string.sub(name, 1, 6) == 'm_hcm_')
    local is_forced_single_sprite = (name == 'p_lowlight_normal' or name == 'b_xplaying')
    local is_single_sprite_atlas = is_hcm_single_sprite or is_forced_single_sprite

    if type(Atlas) == 'function' and not is_single_sprite_atlas then
        G.ASSET_ATLAS[name] = Atlas(path, atlas_px, atlas_py)
        return
    end

    local texture_scaling = (G.SETTINGS and G.SETTINGS.GRAPHICS and G.SETTINGS.GRAPHICS.texture_scaling) or 1
    local use_mipmaps = not (G.IS_WEB == true)
    local desired_dpiscale = is_single_sprite_atlas and 1 or texture_scaling
    local ok_img, image = pcall(love.graphics.newImage, path, {mipmaps = use_mipmaps, dpiscale = desired_dpiscale})
    if not ok_img or not image then
        ok_img, image = pcall(love.graphics.newImage, path)
    end
    if not ok_img or not image then return end

    local image_w, image_h = image:getDimensions()
    if is_single_sprite_atlas then
        atlas_px = image_w
        atlas_py = image_h
    end

    G.ASSET_ATLAS[name] = {
        name = name,
        image = image,
        type = 0,
        px = atlas_px,
        py = atlas_py,
    }
end

local function smods_register_sprite(sprite)
    if not sprite or not sprite.key then return end
    smods_ensure_mod_registry()
    local atlas_path = smods_resolve_sprite_path(sprite.mod_path, sprite.file_name)
    _G.__SMODS_NATIVE_SPRITES[sprite.key] = {
        name = sprite.key,
        path = atlas_path,
        px = sprite.px or 71,
        py = sprite.py or 95,
    }

    if G and G.P_CENTERS and type(sprite.key) == 'string' and string.sub(sprite.key, 1, 2) == 'j_' then
        local center = G.P_CENTERS[sprite.key]
        if center and center.set == 'Joker' and center._native_smods then
            center.atlas = sprite.key
        end
    end

    if G and G.ASSET_ATLAS then
        smods_ensure_atlas(sprite.key, atlas_path, sprite.px, sprite.py)
    end
end

local function smods_register_deck(deck)
    if not (G and G.P_CENTERS and deck and deck.slug) then return nil end
    local key = string.sub(deck.slug, 1, 2) == 'b_' and deck.slug or ('b_' .. tostring(deck.slug))

    local existing = G.P_CENTERS[key]
    local order = (existing and existing.order) or smods_next_center_order('Back')
    local center = existing or {}

    center.key = key
    center.name = deck.name or center.name or key
    center.set = 'Back'
    center.config = smods_copy_table(deck.config or center.config or {})
    center.pos = smods_copy_table(deck.pos or center.pos or {x = 0, y = 0})
    center.atlas = (deck.config and deck.config.atlas) or center.atlas or 'centers'
    center.order = order
    center.stake = center.stake or 1
    center.unlocked = deck.unlocked ~= false
    center.discovered = deck.discovered ~= false
    center.omit = center.omit or false

    G.P_CENTERS[key] = center

    if deck.loc then
        center.loc_txt = smods_copy_table(deck.loc)
        smods_apply_loc_if_ready('Back', key, deck.loc)
    end

    smods_register_center_key(deck.mod_id, key)
    return center
end

local function smods_register_joker(joker)
    if not (G and G.P_CENTERS and joker and joker.slug) then return nil end
    local key = string.sub(joker.slug, 1, 2) == 'j_' and joker.slug or ('j_' .. tostring(joker.slug))

    local existing = G.P_CENTERS[key]
    local order = (existing and existing.order) or smods_next_center_order('Joker')
    local center = existing or {}

    center.key = key
    center.name = joker.name or joker.ability_name or center.name or key
    center.set = 'Joker'
    center.rarity = joker.rarity or center.rarity or 1
    center.cost = joker.cost or center.cost or 0
    center.unlocked = joker.unlocked ~= false
    center.discovered = joker.discovered ~= false
    center.blueprint_compat = joker.blueprint_compat ~= false
    center.eternal_compat = joker.eternal_compat ~= false
    center.pos = smods_copy_table(joker.pos or center.pos or {x = 0, y = 0})
    local preferred_sprite_key = key
    if not joker.atlas and _G.__SMODS_NATIVE_SPRITES and _G.__SMODS_NATIVE_SPRITES[preferred_sprite_key] then
        center.atlas = preferred_sprite_key
    else
        center.atlas = joker.atlas or center.atlas or 'Joker'
    end
    center.order = order
    center.config = smods_copy_table(joker.ability or center.config or {})
    center.effect = joker.effect or center.effect
    center.soul_pos = joker.soul_pos or center.soul_pos
    center._native_smods = true

    G.P_CENTERS[key] = center

    if joker.loc then
        center.loc_txt = smods_copy_table(joker.loc)
        smods_apply_loc_if_ready('Joker', key, joker.loc)
    end

    SMODS.Jokers[key] = center
    SMODS.Jokers[joker.slug] = center
    smods_register_center_key(joker.mod_id, key)
    return center
end

local function smods_register_tarot(tarot)
    if not (G and G.P_CENTERS and tarot and tarot.slug) then return nil end
    local key = string.sub(tarot.slug, 1, 2) == 'c_' and tarot.slug or ('c_' .. tostring(tarot.slug))

    local existing = G.P_CENTERS[key]
    local order = (existing and existing.order) or smods_next_center_order('Tarot')
    local center = existing or {}

    center.key = key
    center.name = tarot.name or center.name or key
    center.set = 'Tarot'
    center.pos = smods_copy_table(tarot.pos or center.pos or {x = 0, y = 0})
    center.config = smods_copy_table(tarot.config or center.config or {})
    center.cost = tarot.cost or center.cost or 3
    center.cost_mult = tarot.cost_mult or center.cost_mult or 1
    center.effect = tarot.effect or center.effect
    center.consumeable = tarot.consumeable ~= false
    center.discovered = tarot.discovered ~= false
    center.unlocked = tarot.unlocked ~= false
    center.atlas = tarot.atlas or center.atlas or 'Tarot'
    center.order = order
    center._native_smods = true

    G.P_CENTERS[key] = center

    if tarot.loc then
        center.loc_txt = smods_copy_table(tarot.loc)
        smods_apply_loc_if_ready('Tarot', key, tarot.loc)
    end

    SMODS.Tarots[key] = center
    SMODS.Tarots[tarot.slug] = center
    smods_register_center_key(tarot.mod_id, key)
    return center
end

function register_native_smods_mod(mod_id, mod_path)
    if not mod_id then return end
    smods_ensure_mod_registry()
    _G.__SMODS_NATIVE_MOD_PATHS[mod_id] = mod_path or ''
    _G.__NATIVE_MOD_CENTER_KEYS[mod_id] = _G.__NATIVE_MOD_CENTER_KEYS[mod_id] or {}
end

function set_native_smods_active_mod(mod_id)
    _G.__SMODS_NATIVE_ACTIVE_MOD = mod_id
end

function get_native_mod_center_keys(mod_id)
    smods_ensure_mod_registry()
    local src = _G.__NATIVE_MOD_CENTER_KEYS[mod_id] or {}
    local out = {}
    for i = 1, #src do out[i] = src[i] end
    table.sort(out)
    return out
end

function get_native_mod_center_map()
    smods_ensure_mod_registry()
    local out = {}
    for mod_id, keys in pairs(_G.__NATIVE_MOD_CENTER_KEYS) do
        out[mod_id] = {}
        for i = 1, #keys do out[mod_id][i] = keys[i] end
        table.sort(out[mod_id])
    end
    return out
end

function apply_native_smods_localization()
    if not (G and G.localization and G.localization.descriptions) then return false end
    local pending = _G.__SMODS_NATIVE_PENDING_LOC
    if type(pending) ~= 'table' then return true end

    for set_name, entries in pairs(pending) do
        if type(entries) == 'table' then
            G.localization.descriptions[set_name] = G.localization.descriptions[set_name] or {}
            for key, loc in pairs(entries) do
                G.localization.descriptions[set_name][key] = smods_prepare_loc_entry(loc)
            end
        end
    end
    _G.__SMODS_NATIVE_PENDING_LOC = {}
    return true
end

function append_native_smods_asset_atlases(asset_atli)
    smods_ensure_mod_registry()
    if type(asset_atli) ~= 'table' then return end

    local existing = {}
    for i = 1, #asset_atli do
        local entry = asset_atli[i]
        if entry and entry.name then
            existing[entry.name] = true
        end
    end

    for name, data in pairs(_G.__SMODS_NATIVE_SPRITES) do
        if not existing[name] and data and type(data.path) == 'string' and data.path ~= '' and love.filesystem.getInfo(data.path) then
            asset_atli[#asset_atli + 1] = {
                name = name,
                path = data.path,
                px = data.px or 71,
                py = data.py or 95,
            }
            existing[name] = true
        end
    end
end

function ensure_native_smods_atlas(atlas_name)
    smods_ensure_mod_registry()
    if type(atlas_name) ~= 'string' or atlas_name == '' then return false end
    if G and G.ASSET_ATLAS and G.ASSET_ATLAS[atlas_name] then return true end

    local data = _G.__SMODS_NATIVE_SPRITES and _G.__SMODS_NATIVE_SPRITES[atlas_name]
    if not data then return false end

    smods_ensure_atlas(atlas_name, data.path, data.px, data.py)
    return not not (G and G.ASSET_ATLAS and G.ASSET_ATLAS[atlas_name])
end

function install_smods_native_compat()
    SMODS = SMODS or {}
    SMODS.INIT = SMODS.INIT or {}
    SMODS.Jokers = SMODS.Jokers or {}
    SMODS.Tarots = SMODS.Tarots or {}

    if SMODS.__native_compat_installed then
        return
    end

    SMODS.__native_compat_installed = true
    smods_ensure_mod_registry()

    function SMODS.findModByID(id)
        local path = (_G.__SMODS_NATIVE_MOD_PATHS and _G.__SMODS_NATIVE_MOD_PATHS[id]) or ''
        return { path = path }
    end

    function SMODS.end_calculate_context(context)
        return context and context.joker_main
    end

    SMODS.Card = SMODS.Card or {}
    SMODS.Card.SUIT_LIST = SMODS.Card.SUIT_LIST or {'Spades', 'Hearts', 'Clubs', 'Diamonds'}

    local sprite_mt = {}
    sprite_mt.__index = sprite_mt
    function sprite_mt:register()
        smods_register_sprite(self)
        return self
    end

    local deck_mt = {}
    deck_mt.__index = deck_mt
    function deck_mt:register()
        local center = smods_register_deck(self)
        self.key = center and center.key or self.key
        return self
    end

    local joker_mt = {}
    joker_mt.__index = joker_mt
    function joker_mt:register()
        local center = smods_register_joker(self)
        self.key = center and center.key or self.key
        return self
    end

    local tarot_mt = {}
    tarot_mt.__index = tarot_mt
    function tarot_mt:register()
        local center = smods_register_tarot(self)
        self.key = center and center.key or self.key
        return self
    end

    SMODS.Sprite = SMODS.Sprite or {}
    function SMODS.Sprite:new(key, mod_path, file_name, px, py)
        local sprite = {
            key = key,
            mod_path = mod_path,
            file_name = file_name,
            px = px,
            py = py,
            mod_id = _G.__SMODS_NATIVE_ACTIVE_MOD
        }
        return setmetatable(sprite, sprite_mt)
    end

    SMODS.Deck = SMODS.Deck or {}
    function SMODS.Deck:new(name, slug, config, pos, loc)
        local deck = {
            name = name,
            slug = slug,
            config = config,
            pos = pos,
            loc = loc,
            mod_id = _G.__SMODS_NATIVE_ACTIVE_MOD
        }
        return setmetatable(deck, deck_mt)
    end

    SMODS.Joker = SMODS.Joker or {}
    function SMODS.Joker:new(ability_name, slug, ability, pos, loc, rarity, cost, unlocked, discovered, blueprint_compat, eternal_compat, effect, atlas, soul_pos)
        local joker = {
            name = loc and loc.name,
            ability_name = ability_name,
            slug = slug,
            ability = ability,
            pos = pos,
            loc = loc,
            rarity = rarity,
            cost = cost,
            unlocked = unlocked,
            discovered = discovered,
            blueprint_compat = blueprint_compat,
            eternal_compat = eternal_compat,
            effect = effect,
            atlas = atlas,
            soul_pos = soul_pos,
            mod_id = _G.__SMODS_NATIVE_ACTIVE_MOD
        }
        return setmetatable(joker, joker_mt)
    end

    SMODS.Tarot = SMODS.Tarot or {}
    function SMODS.Tarot:new(name, slug, config, pos, loc, cost, cost_mult, effect, consumeable, discovered, atlas)
        local tarot = {
            name = name,
            slug = slug,
            config = config,
            pos = pos,
            loc = loc,
            cost = cost,
            cost_mult = cost_mult,
            effect = effect,
            consumeable = consumeable,
            discovered = discovered,
            atlas = atlas,
            mod_id = _G.__SMODS_NATIVE_ACTIVE_MOD
        }
        return setmetatable(tarot, tarot_mt)
    end
end

if not table_length then
    function table_length(tbl)
        return smods_count(tbl)
    end
end
