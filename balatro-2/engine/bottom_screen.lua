-- bottom_screen.lua
-- Draws a charcoal background on the bottom half and an optional 320x240 PNG
-- plus the custom cursor (scaled nearest to 16x16).

local M = {}

local cursor_image = nil
local bg_image = nil
local last_touch = {x = nil, y = nil}

-- Target screen sizes (3DS): top 800x240, bottom 320x240. Desktop testing will emulate
-- a stacked window of (800 x (240+240)) = 800x480 so the top and bottom areas are distinct.
local TOP_W, TOP_H = 800, 240
local BOTTOM_W, BOTTOM_H = 320, 240

-- Hotspot in source image (1-based pixel coordinates). The pixel at
-- (HOTSPOT_X, HOTSPOT_Y) will be placed at the logical cursor position.
local HOTSPOT_X, HOTSPOT_Y = 1, 3

-- Cursor scale relative to the original image (1.0 = original size).
-- Use 0.75 so the cursor is 1/4 smaller than the original image.
local CURSOR_SCALE = 0.75

-- Small font used for the tutorial hint on the bottom screen. Try to
-- load a bundled bitmap-ish font if present and fall back to a system
-- font size.
local tutorial_font = nil
pcall(function()
    if love.filesystem.getInfo("resources/fonts/m6x11plus.ttf") then
        tutorial_font = love.graphics.newFont("resources/fonts/m6x11plus.ttf", 14)
    else
        tutorial_font = love.graphics.newFont(14)
    end
end)

local candidate_cursor_paths = {
    'resources/textures/cursor.png',
    'resources/textures/1x/cursor.png',
    'cursor.png'
}
local candidate_bg_paths = {
    'resources/textures/bottom_bg.png',
    'resources/textures/1x/bottom_bg.png',
    'bottom_bg.png'
}

local function try_load(paths)
    for _, p in ipairs(paths) do
        if love.filesystem.getInfo(p) then
            local ok, img = pcall(love.graphics.newImage, p)
            if ok and img then return img end
        end
    end
    return nil
end

-- load images if available
pcall(function()
    cursor_image = try_load(candidate_cursor_paths)
    bg_image = try_load(candidate_bg_paths)
    if cursor_image then cursor_image:setFilter('nearest', 'nearest') end
    if bg_image then bg_image:setFilter('nearest', 'nearest') end
end)

local function touch_to_pixels(x, y)
    local w, h = love.graphics.getDimensions()
    if x <= 1 and y <= 1 then x = x * w; y = y * h end
    return x, y, w, h
end

function M.update(dt)
    -- Track most recent touch on bottom half for cursor display
    -- Prefer a project-level `touches` table (populated in love.touch callbacks),
    -- otherwise fall back to Love's touch API. The user's touch code may store
    -- normalized (0..1) coords or pixels; handle both.
    local found_touch = nil

    if touches and type(touches) == 'table' then
        -- `touches` is expected to be a map of id -> {x=..., y=...}
        for id, t in pairs(touches) do
            if t and t.x and t.y then
                local px, py = t.x, t.y
                local w, h = love.graphics.getDimensions()
                if px <= 1 and py <= 1 then px, py = px * w, py * h end
                if py > TOP_H then found_touch = {x = px, y = py}; break end
            end
        end
    end

    if not found_touch and love.touch and love.touch.getTouches then
        local touch_ids = love.touch.getTouches()
        if touch_ids and #touch_ids > 0 then
            for i = 1, #touch_ids do
                local id = touch_ids[i]
                local ok, x, y = pcall(love.touch.getPosition, id)
                if ok and x and y then
                    local px, py = x, y
                    local w,h = love.graphics.getDimensions()
                    if px <= 1 and py <= 1 then px, py = px*w, py*h end
                    if py > TOP_H then found_touch = {x = px, y = py}; break end
                end
            end
        end
    end

    if found_touch then
        last_touch.x = found_touch.x
        last_touch.y = found_touch.y
    end

    -- If the tutorial hint is visible and player taps the bottom screen, dismiss it
    if G and G.SETTINGS and G.SETTINGS.SHOW_TRACKPAD_HINT and love.touch and love.touch.getTouches then
        local touches = love.touch.getTouches()
        if touches and #touches > 0 then
            -- consider the first touch as a dismiss gesture if it's on bottom half
            local id = touches[1]
            local ok, x, y = pcall(love.touch.getPosition, id)
            if ok and x and y then
                local w,h = love.graphics.getDimensions()
                if x <= 1 and y <= 1 then x, y = x*w, y*h end
                if y > TOP_H then
                    -- Dismiss the hint so it doesn't reappear
                    G.SETTINGS.SHOW_TRACKPAD_HINT = false
                end
            end
        end
    end
end

-- Optional helper to set up a desktop window that emulates separate top/bottom screens.
function M.setup()
    if love and love.window and love.window.setMode and love.system then
        local os = love.system.getOS()
        -- Only force a stacked window on desktop OSes to aid testing; do not change on actual 3DS builds
        if os == 'Windows' or os == 'OS X' or os == 'Linux' then
            pcall(function()
                -- Set window to (TOP_W) x (TOP_H + BOTTOM_H)
                love.window.setMode(TOP_W, TOP_H + BOTTOM_H, {resizable = true, minwidth = 640, minheight = 360})
            end)
        end
    end
end

function M.draw()
    local w, h = love.graphics.getDimensions()
    love.graphics.push()
    -- Charcoal background on bottom area (explicit bottom origin)
    love.graphics.setColor(0.14, 0.14, 0.14, 1)
    local bottom_origin_y = TOP_H
    love.graphics.rectangle('fill', 0, bottom_origin_y, w, BOTTOM_H)

    -- Draw background PNG centered in bottom half if present (assumes 320x240)
    if bg_image then
        local bw, bh = BOTTOM_W, BOTTOM_H
        local bx = math.floor((w - bw) / 2)
        local by = bottom_origin_y + math.floor((BOTTOM_H - bh) / 2)
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(bg_image, bx, by)
    end

    -- Draw cursor at last touch location (or nothing if none). Cursor scaled to 16x16
    if cursor_image and last_touch.x and last_touch.y then
        local cx, cy = last_touch.x, last_touch.y
        local sw = CURSOR_SCALE
        local sh = CURSOR_SCALE
        -- Place the image so that the source pixel (HOTSPOT_X, HOTSPOT_Y)
        -- maps to (cx, cy). Lua image pixels are 1-based, so the top-left
        -- pixel is (1,1) and its offset is 0.
        local draw_x = cx - (HOTSPOT_X - 1) * sw
        local draw_y = cy - (HOTSPOT_Y - 1) * sh
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(cursor_image, draw_x, draw_y, 0, sw, sh)
    end

    -- If the tutorial overlay is active, draw a short hint on the bottom
    -- screen explaining the drag controls.
    if G and G.OVERLAY_TUTORIAL and (not G.SETTINGS or G.SETTINGS.SHOW_TRACKPAD_HINT ~= false) then
        love.graphics.push()
        if tutorial_font then love.graphics.setFont(tutorial_font) end
        love.graphics.setColor(1,1,1,0.95)
        local hint = "Drag on the bottom screen to move the cursor.\nTap to click."
        -- Try to get a localized string if a localization helper exists.
        pcall(function()
            if G and type(G.L) == 'function' then
                local ok, localized = pcall(G.L, 'tutorial.drag_controls')
                if ok and localized then hint = localized end
            end
        end)
        local wrap_w = math.min(BOTTOM_W, w * 0.8)
        local tx = (w - wrap_w) / 2
        local ty = bottom_origin_y + 8
        love.graphics.printf(hint, tx, ty, wrap_w, 'center')
        love.graphics.pop()
    end

    love.graphics.pop()
    love.graphics.setColor(1,1,1,1)
end

    -- Optional debug overlay
    pcall(M.debug_draw)

-- Simple debug overlay to visualize last touch and adapter state when enabled.
function M.debug_draw()
    if not (G and G.SETTINGS and G.SETTINGS.DEBUG_TOUCH) then return end
    love.graphics.push()
    love.graphics.setColor(0,0,0,0.7)
    love.graphics.rectangle('fill', 8, 8, 220, 80)
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf(('last_touch: %s'):format(tostring(last_touch.x)..","..tostring(last_touch.y)), 12, 12, 200)
    if G and G.CONTROLLER then
        local mx,my = love.mouse.getPosition()
        love.graphics.printf(('mouse: %.1f, %.1f'):format(mx,my), 12, 32, 200)
    end
    love.graphics.pop()
end

-- Draw main cursor on top screen using the same cursor image (16x16 nearest)
-- This is done after the main game draw to ensure it overlays correctly.
function M.draw_main_cursor()
    if not cursor_image then return end
    if not G or not G.CONTROLLER or not G.CONTROLLER.cursor_position then return end
    local mx, my = G.CONTROLLER.cursor_position.x, G.CONTROLLER.cursor_position.y
    if not mx or not my then return end
    -- Only draw on top area (top screen)
    if my > TOP_H then return end
    local sw = CURSOR_SCALE
    local sh = CURSOR_SCALE
    love.graphics.push()
    love.graphics.setColor(1,1,1,1)
    -- Adjust draw so source hotspot maps to cursor (use HOTSPOT offsets)
    local draw_x = mx - (HOTSPOT_X - 1) * sw
    local draw_y = my - (HOTSPOT_Y - 1) * sh
    love.graphics.draw(cursor_image, draw_x, draw_y, 0, sw, sh)
    love.graphics.pop()
end

return M
