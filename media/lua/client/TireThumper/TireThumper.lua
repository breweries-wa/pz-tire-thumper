-- TireThumper — minimal proof-of-life test
print("[TireThumper] FILE LOADED")

local tickCount = 0

local function onTick()
    tickCount = tickCount + 1
    if tickCount == 1 then
        print("[TireThumper] OnTick FIRED (tick 1)")
    end
    if tickCount == 300 then
        print("[TireThumper] OnTick FIRED (tick 300)")
        local player = getSpecificPlayer(0)
        print("[TireThumper] player=" .. tostring(player))
        if player then
            local veh = player:getVehicle()
            print("[TireThumper] vehicle=" .. tostring(veh))
        end
    end
end

Events.OnTick.Add(onTick)
print("[TireThumper] OnTick registered")
