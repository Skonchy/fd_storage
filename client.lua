local plate = {}
local lastVehicle
local trunkOpen = false

function getTargetVehicle()
    local pos = GetEntityCoords(GetPlayerPed(-1))
    local entityWorld = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 4.0, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, GetPlayerPed(-1), 0)
    local a, b, c, d, result = GetRaycastResult(rayHandle)
    if IsEntityAVehicle(result) then
        return result
    else
        return nil
    end
end

Citizen.CreateThread(function()
    local sleep = 1000
    local player = GetPlayerPed(-1)
    while true do
        local playerPos = GetEntityCoords(player)
        local vehicle = getTargetVehicle()
        local trunkPos = GetOffsetFromEntityInWorldCoords(vehicle,0.0,-2.0,0.5)
        local distance = Vdist(playerPos.x,playerPos.y,playerPos.z,trunkPos.x,trunkPos.y,trunkPos.z)
        if (distance <= 1.5) and (GetVehicleClass(vehicle) ~= 8 or 13 or 15 or 16 or 19 or 20 or 21) and (GetVehiclePedIsIn(player,false) == 0) then
            local plate = GetVehicleNumberPlateText(vehicle)
            sleep = 5
            exports["drp_core"]:DrawText3Ds(trunkPos.x,trunkPos.y,trunkPos.z,tostring("Press ~b~E ~w~to open trunk or ~r~X ~w~ to close"))
            if IsControlJustPressed(1,86) then
                SetVehicleDoorOpen(vehicle,5,false,false)
                TriggerEvent("fd_storage:toggleTrunk",true)
                TriggerServerEvent("fd_storage:getStorage",plate)
            elseif IsControlJustPressed(1, 73) then
                SetVehicleDoorShut(vehicle,5,false,false)
                TriggerEvent("fd_storage:toggleTrunk",false)
            end
        end
        Citizen.Wait(sleep)
    end
end)

RegisterNetEvent("fd_storage:toggleTrunk")
AddEventHandler("fd_storage:toggleTrunk", function(bool)
    trunkOpen = bool
end)

RegisterCommand("put",function(src,args,raw)
    local amount = args[2]
    local item = args[1]
    local plate = GetVehicleNumberPlateText(getTargetVehicle())
    if trunkOpen then
        print(trunkOpen,"putting in inv")
        TriggerServerEvent("fd_storage:putInInv",item,amount,plate)
    end
end, false)

RegisterCommand("take", function(src,args,raw)
    local item = args[1]
    local amount = args[2]
    local plate = GetVehicleNumberPlateText(getTargetVehicle())
    if trunkOpen then
        TriggerServerEvent("fd_storage:takeFromInv",item,amount,plate)
    end
end, false)
