local hayBaleModel = 'prop_haybale_01'
local ESX = exports['es_extended']:getSharedObject()
local afkZoneCoords = vector3(2890.1797, 4652.1328, 48.5774)
local isInAfkZone = false
local isFarming = false
local hayBales = {}
local farmingEndTime = 0

-- Tạo cục rơm tại tọa độ chỉ định
function CreateHayBaleAtCoords(x, y, z)
    local modelHash = GetHashKey(hayBaleModel)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(1)
    end
    local hayBale = CreateObject(modelHash, x, y, z, false, false, true)
    PlaceObjectOnGroundProperly(hayBale)
    FreezeEntityPosition(hayBale, true)
    SetModelAsNoLongerNeeded(modelHash)
    return hayBale
end

-- Tạo cục rơm tại tất cả tọa độ được chỉ định trong Config.Rocks
Citizen.CreateThread(function()
    if Config.Rocks then
        for _, coords in ipairs(Config.Rocks) do
            local hayBale = CreateHayBaleAtCoords(coords.x, coords.y, coords.z)
            table.insert(hayBales, hayBale)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - afkZoneCoords)
        if distance < 10.0 then
            isInAfkZone = true
            local rotationAngle = 100.0
            DrawMarker(24, afkZoneCoords.x, afkZoneCoords.y, afkZoneCoords.z + 1.0, 0, 0, 0, 0, 0, rotationAngle, 3.0, 3.0, 1.0, 127, 255, 0, 100, false, false, 2, false, nil, nil, false)
            if distance < 1.0 then
                ESX.ShowHelpNotification("Nhấn ~INPUT_CONTEXT~ để bắt đầu tự động trồng trọt")
                if IsControlJustReleased(0, 38) then
                    ESX.TriggerServerCallback('qs-inventory:checkItem', function(hasItem)
                        if hasItem then
                            TriggerServerEvent('qs-inventory:removeItem', 'Banhmi', 1)
                            StartFarming(playerPed)
                        else
                            ESX.ShowNotification("Bạn thiếu cái gì đó!")
                        end
                    end, 'Banhmi', 1)
                end
            end
        else
            isInAfkZone = false
        end
    end
end)

-- Luồng để hiển thị thời gian đếm ngược
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isFarming then
            local currentTime = GetGameTimer()
            if currentTime < farmingEndTime then
                local remainingMinutes = math.floor((farmingEndTime - currentTime) / 60000)
                local remainingSeconds = math.floor((farmingEndTime - currentTime) % 60000 / 1000)
                DrawTimer(0.015, 0.5, remainingMinutes, remainingSeconds)
            else
                StopFarming(PlayerPedId())
            end
        end
    end
end)

function StartFarming(playerPed)
    isFarming = true
    farmingEndTime = GetGameTimer() + Config.FarmingTime

    Citizen.CreateThread(function()
        local items = Config.Item
        while GetGameTimer() < farmingEndTime do
            for i, coords in ipairs(Config.Rocks) do
                if GetGameTimer() >= farmingEndTime then
                    isFarming = false
                    break
                end
                local rockVec = vector3(coords.x, coords.y, coords.z)
                TaskGoStraightToCoord(playerPed, rockVec.x, rockVec.y, rockVec.z, 1.0, -1, heading, 0.0)
                local isMoving = true
                while isMoving do
                    Citizen.Wait(0)
                    local playerCoords = GetEntityCoords(playerPed)
                    if #(playerCoords - rockVec) < 1.0 then
                        isMoving = false
                        ClearPedTasksImmediately(playerPed)
                        TaskStartScenarioInPlace(playerPed, "world_human_gardener_plant", 0, true)
                        Citizen.Wait(5000)
                        ClearPedTasksImmediately(playerPed)
                        if hayBales[i] then
                            RemoveHayBale(hayBales[i])
                            hayBales[i] = nil
                            Citizen.SetTimeout(Config.HayBaleRespawnTime, function()
                                hayBales[i] = CreateHayBaleAtCoords(coords.x, coords.y, coords.z)
                            end)
                            local itemAwarded = items[math.random(#items)]
                            TriggerServerEvent('qs-inventory:addItem', itemAwarded, 1)
                            items = Config.Item -- Reset lại danh sách items sau mỗi lần farming
                        end
                    end
                end
            end
            if GetGameTimer() >= farmingEndTime then
                isFarming = false
                break
            end
        end
        StopFarming(playerPed)
    end)
end

function StopFarming(playerPed)
    isFarming = false
    ClearPedTasksImmediately(playerPed)
    TriggerServerEvent('esx_autofarm:rewardMoney', 100)
    ESX.ShowNotification("Hoàn thành tự động trồng trọt, bạn kiếm được $100")
    ReturnToStart(playerPed)
end

function ReturnToStart(playerPed)
    TaskGoStraightToCoord(playerPed, afkZoneCoords.x, afkZoneCoords.y, afkZoneCoords.z, 1.0, 20000, 0.0, 0.0)
    local isMoving = true
    while isMoving do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(playerPed)
        if #(playerCoords - afkZoneCoords) < 1.0 then
            isMoving = false
            ClearPedTasksImmediately(playerPed)
        end
    end
end


-- Xóa cục rơm
function RemoveHayBale(hayBale)
    if DoesEntityExist(hayBale) then
        DeleteObject(hayBale)
    end
end

-- Hiển thị thời gian đếm ngược
function DrawTimer(x, y, minutes, seconds)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.35, 0.35)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 205)
    SetTextEntry("STRING")
    local timeString = string.format("~b~Thời gian trồng trọt: ~w~%02d:%02d còn lại", minutes, seconds)
    AddTextComponentString(timeString)
    DrawText(x, y)
end