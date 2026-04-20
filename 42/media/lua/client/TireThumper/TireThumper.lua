-- TireThumper — Build 42
-- Plays rhythmic thumping sounds when driving on a flat tire.
-- Frequency and volume scale with speed and pressure severity.

local PRESSURE_THRESHOLD = 0.30  -- trigger below this pressure ratio (0–1)
local MIN_SPEED_KMH      = 21    -- no sound below this speed
local REF_SPEED_KMH      = 21    -- baseline speed for interval calculation
local FULL_VOL_SPEED_KMH = 81    -- speed at which volume reaches maximum
local MAX_SPEED_KMH      = 81    -- interval stops shortening above this speed
local BASE_INTERVAL      = 50    -- ticks between thumps at ref speed (~1.7 s)
local MIN_INTERVAL       = 6     -- minimum ticks between thumps (~0.2 s)
local BLOWOUT_PSI        = 5     -- PSI at or below which pressure is treated as maximum severity
local MASTER_VOLUME      = 0.50  -- global volume scalar (reduce if too loud)

local SOUND_NAMES = {
    "TireThumper_flat1", "TireThumper_flat2", "TireThumper_flat3",
    "TireThumper_flat4", "TireThumper_flat5", "TireThumper_flat6",
}

local TIRE_SLOTS = {
    "TireFrontLeft", "TireFrontRight",
    "TireRearLeft",  "TireRearRight",
}

local thumpTimer = 0
local active     = false

local function getWorstTire(vehicle)
    local worstRatio, worstPsi
    for _, slot in ipairs(TIRE_SLOTS) do
        local part = vehicle:getPartById(slot)
        if part then
            local cur = part:getContainerContentAmount()
            local cap = part:getContainerCapacity()
            if cur and cap and cap > 0 then
                local ratio = cur / cap
                if not worstRatio or ratio < worstRatio then
                    worstRatio = ratio
                    worstPsi   = cur
                end
            end
        end
    end
    return worstRatio, worstPsi
end

local function calcInterval(ratio, speedKmh)
    local t = ratio / PRESSURE_THRESHOLD
    if t < 0 then t = 0 elseif t > 1 then t = 1 end
    local pressureInterval = math.floor(MIN_INTERVAL + t * (BASE_INTERVAL - MIN_INTERVAL))

    local speedFactor = speedKmh / REF_SPEED_KMH
    if speedFactor > MAX_SPEED_KMH / REF_SPEED_KMH then speedFactor = MAX_SPEED_KMH / REF_SPEED_KMH end
    if speedFactor < 0.01 then speedFactor = 0.01 end

    local interval = math.floor(pressureInterval / speedFactor)
    if interval < MIN_INTERVAL  then interval = MIN_INTERVAL  end
    if interval > BASE_INTERVAL then interval = BASE_INTERVAL end
    return interval
end

local function calcVolume(ratio, psi, speedKmh)
    local pressureSeverity
    if psi and psi <= BLOWOUT_PSI then
        pressureSeverity = 1.0
    else
        pressureSeverity = (PRESSURE_THRESHOLD - ratio) / PRESSURE_THRESHOLD
        if pressureSeverity < 0    then pressureSeverity = 0    end
        if pressureSeverity > 0.75 then pressureSeverity = 0.75 end
    end

    local speedFraction = (speedKmh - MIN_SPEED_KMH) / (FULL_VOL_SPEED_KMH - MIN_SPEED_KMH)
    if speedFraction < 0 then speedFraction = 0 end
    if speedFraction > 1 then speedFraction = 1 end
    local speedSeverity = 0.25 + 0.75 * speedFraction

    local vol = pressureSeverity * speedSeverity * MASTER_VOLUME
    vol = vol * (1.0 + (ZombRand(11) - 5) / 100.0)  -- ±5% jitter
    if vol < 0 then vol = 0 end
    if vol > 1 then vol = 1 end
    return vol
end

local function playThump(player, vol)
    local name    = SOUND_NAMES[ZombRand(#SOUND_NAMES) + 1]
    local emitter = player:getEmitter()
    local soundRef = 0

    if emitter then
        soundRef = emitter:playSound(name)
        if soundRef ~= 0 and emitter.setVolume then
            emitter:setVolume(soundRef, vol)
        end
    end

    if soundRef == 0 then
        getSoundManager():playUISound(name)
    end
end

local function onTick()
    local player = getSpecificPlayer(0)
    if not player then return end

    local vehicle = player:getVehicle()
    if not vehicle or vehicle:getDriver() ~= player then
        thumpTimer = 0
        active = false
        return
    end

    local speed           = math.abs(vehicle:getCurrentSpeedKmHour())
    local ratio, worstPsi = getWorstTire(vehicle)

    if not ratio or ratio >= PRESSURE_THRESHOLD or speed < MIN_SPEED_KMH then
        thumpTimer = 0
        active = false
        return
    end

    local interval = calcInterval(ratio, speed)

    if not active then
        active     = true
        thumpTimer = interval  -- trigger immediately on first detection
    else
        thumpTimer = thumpTimer + 1
    end

    if thumpTimer >= interval then
        thumpTimer = 0
        playThump(player, calcVolume(ratio, worstPsi, speed))
    end
end

Events.OnTick.Add(onTick)
