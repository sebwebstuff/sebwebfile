-- RandomLua v0.3.1 (adapted)
-- Pure Lua PRNG wrapper exposing a Mersenne Twister generator
local math_floor = math.floor

local function normalize(n)
    return n % 0x80000000
end

local function bit_and(a, b)
    local r = 0
    local m = 0
    for m = 0, 31 do
        if (a % 2 == 1) and (b % 2 == 1) then r = r + 2^m end
        if a % 2 ~= 0 then a = a - 1 end
        if b % 2 ~= 0 then b = b - 1 end
        a = a / 2
        b = b / 2
    end
    return normalize(r)
end

local function bit_or(a, b)
    local r = 0
    local m = 0
    for m = 0, 31 do
        if (a % 2 == 1) or (b % 2 == 1) then r = r + 2^m end
        if a % 2 ~= 0 then a = a - 1 end
        if b % 2 ~= 0 then b = b - 1 end
        a = a / 2
        b = b / 2
    end
    return normalize(r)
end

local function bit_xor(a, b)
    local r = 0
    local m = 0
    for m = 0, 31 do
        if a % 2 ~= b % 2 then r = r + 2^m end
        if a % 2 ~= 0 then a = a - 1 end
        if b % 2 ~= 0 then b = b - 1 end
        a = a / 2
        b = b / 2
    end
    return normalize(r)
end

local function seed_time()
    return normalize(os.time())
end

-- Mersenne Twister implementation (adapted from RandomLua)
local mersenne_twister = {}
mersenne_twister.__index = mersenne_twister

function mersenne_twister:randomseed(s)
    if not s then s = seed_time() end
    -- accept string seeds by converting to numeric if necessary
    if type(s) == 'string' then
        local t = ''
        for i = 1, #s do
            local byte = string.byte(s, i)
            if byte >= 48 and byte <= 57 then t = t .. tostring(byte - 48)
            elseif byte >= 65 and byte <= 90 then t = t .. tostring(byte - 64)
            elseif byte >= 97 and byte <= 122 then t = t .. tostring(byte - 96)
            end
        end
        s = tonumber(t) or seed_time()
    end
    self.mt[0] = normalize(s)
    for i = 1, 623 do
        self.mt[i] = normalize(0x6c078965 * bit_xor(self.mt[i-1], math_floor(self.mt[i-1] / 0x40000000)) + i)
    end
    self.index = 0
end

function mersenne_twister:random(a, b)
    local y
    if self.index == 0 then
        for i = 0, 623 do
            y = self.mt[(i + 1) % 624] % 0x80000000
            self.mt[i] = bit_xor(self.mt[(i + 397) % 624], math_floor(y / 2))
            if y % 2 ~= 0 then self.mt[i] = bit_xor(self.mt[i], 0x9908b0df) end
        end
    end
    y = self.mt[self.index]
    y = bit_xor(y, math_floor(y / 0x800))
    y = bit_xor(y, bit_and(normalize(y * 0x80), 0x9d2c5680))
    y = bit_xor(y, bit_and(normalize(y * 0x8000), 0xefc60000))
    y = bit_xor(y, math_floor(y / 0x40000))
    self.index = (self.index + 1) % 624
    if not a then return y / 0x80000000
    elseif not b then
        if a == 0 then return y
        else return 1 + (y % a)
        end
    else
        return a + (y % (b - a + 1))
    end
end

local function twister(s)
    local temp = {}
    setmetatable(temp, mersenne_twister)
    temp.mt = {}
    temp.index = 0
    temp:randomseed(s)
    return temp
end

-- Module table
local RandomLua = {}

-- default generator
local default_gen = twister(seed_time())

function RandomLua.randomseed(s)
    default_gen:randomseed(s)
end

function RandomLua.random(a, b)
    return default_gen:random(a, b)
end

-- alias for integer rand
function RandomLua.randint(a, b)
    return default_gen:random(a, b)
end

-- Replace Lua math.random and math.randomseed with RandomLua
function RandomLua.set_as_global()
    math.random = function(a, b) return RandomLua.random(a, b) end
    math.randomseed = function(s) return RandomLua.randomseed(s) end
end

return RandomLua