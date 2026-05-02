-- TireThumper — Build 42
-- Plays rhythmic thumping sounds when driving on a flat tire.

local PRESSURE_THRESHOLD = 0.30  -- trigger below this pressure ratio (0–1)

-- Zoom thresholds (lower = more zoomed in, vanilla range ~0.5–2.5)
local ZOOM_SILENT = 2.0   -- at or above: no sound
local ZOOM_CLOSE  = 1.0   -- below: use close-zoom sound set

local SOUNDS = {
    slow         = { "TireThumper_flat1_slow",         "TireThumper_flat2_slow",         "TireThumper_flat3_slow",         "TireThumper_flat4_slow",         "TireThumper_flat5_slow",         "TireThumper_flat6_slow"         },
    fast         = { "TireThumper_flat1_fast",         "TireThumper_flat2_fast",         "TireThumper_flat3_fast",         "TireThumper_flat4_fast",         "TireThumper_flat5_fast",         "TireThumper_flat6_fast"         },
    faster       = { "TireThumper_flat1_faster",       "TireThumper_flat2_faster",       "TireThumper_flat3_faster",       "TireThumper_flat4_faster",       "TireThumper_flat5_faster",       "TireThumper_flat6_faster"       },
    slow_close   = { "TireThumper_flat1_slow_close",   "TireThumper_flat2_slow_close",   "TireThumper_flat3_slow_close",   "TireThumper_flat4_slow_close",   "TireThumper_flat5_slow_close",   "TireThumper_flat6_slow_close"   },
    fast_close   = { "TireThumper_flat1_fast_close",   "TireThumper_flat2_fast_close",   "TireThumper_flat3_fast_close",   "TireThumper_flat4_fast_close",   "TireThumper_flat5_fast_close",   "TireThumper_flat6_fast_close"   },
    faster_close = { "TireThumper_flat1_faster_close", "TireThumper_flat2_faster_close", "TireThumper_flat3_faster_close", "TireThumper_flat4_faster_close", "TireThumper_flat5_faster_close", "TireThumper_flat6_faster_close" },
}

-- Interval: linear from 2.0 s at MIN_SPEED to 0.2 s at MAX_SPEED
local MIN_SPEED    = 21
local MAX_SPEED    = 81
local INTERVAL_MAX = 2.0   -- seconds at min speed
local INTERVAL_MIN = 0.2   -- seconds at max speed

-- Speed tiers (sound pool selection only — interval is continuous)
local TIERS = {
    { min = 21, pool = SOUNDS.slow,   poolClose = SOUNDS.slow_close   },  -- SLOW
    { min = 51, pool = SOUNDS.fast,   poolClose = SOUNDS.fast_close   },  -- FAST
    { min = 81, pool = SOUNDS.faster, poolClose = SOUNDS.faster_close },  -- FASTER
}

local TIRE_SLOTS = { "TireFrontLeft", "TireFrontRight", "TireRearLeft", "TireRearRight" }

local thumpTimer = 0
local active     = false

local function getWorstTire(vehicle)
    local worstRatio
    for _, slot in ipairs(TIRE_SLOTS) do
        local part = vehicle:getPartById(slot)
        if part then
            local cur = part:getContainerContentAmount()
            local cap = part:getContainerCapacity()
            if cur and cap and cap > 0 then
                local ratio = cur / cap
                if not worstRatio or ratio < worstRatio then worstRatio = ratio end
            end
        end
    end
    return worstRatio
end

local function getTier(speedKmh)
    local tier
    for _, t in ipairs(TIERS) do
        if speedKmh >= t.min then tier = t end
    end
    return tier
end

local function calcInterval(speedKmh)
    local t = (speedKmh - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)
    if t < 0 then t = 0 elseif t > 1 then t = 1 end
    local secs = INTERVAL_MAX - t * (INTERVAL_MAX - INTERVAL_MIN)
    return math.max(1, math.floor(secs * 30))
end

local function playThump(player, pool)
    local name     = pool[ZombRand(#pool) + 1]
    local emitter  = player:getEmitter()
    local soundRef = 0
    if emitter then soundRef = emitter:playSound(name) end
    if soundRef == 0 then getSoundManager():playUISound(name) end
end

local function onTick()
    local player = getSpecificPlayer(0)
    if not player then return end

    local vehicle = player:getVehicle()
    if not vehicle or vehicle:getDriver() ~= player then
        thumpTimer = 0
        active     = false
        return
    end

    local zoom  = getCore():getZoom(0)
    local speed = math.abs(vehicle:getCurrentSpeedKmHour())
    local ratio = getWorstTire(vehicle)
    local tier  = getTier(speed)

    if not ratio or ratio >= PRESSURE_THRESHOLD or not tier or zoom >= ZOOM_SILENT then
        thumpTimer = 0
        active     = false
        return
    end

    local pool     = (zoom < ZOOM_CLOSE) and tier.poolClose or tier.pool
    local interval = calcInterval(speed)

    if not active then
        active     = true
        thumpTimer = interval  -- fire immediately on first detection
    else
        thumpTimer = thumpTimer + 1
    end

    if thumpTimer >= interval then
        thumpTimer = 0
        playThump(player, pool)
    end
end

Events.OnTick.Add(onTick)
