local QBCore = exports[Config.CoreName]:GetCoreObject()
local PlayerJob = {}
local Blips = {}
local Harvesting = false
local Rinsing = false

Citizen.CreateThread(function()
    local Player = QBCore.Functions.GetPlayerData()
    if Player ~= nil then
        PlayerJob = Player.job
        CheckBlips()
    end
    RequestModel(GetHashKey(Config.SellFood.Ped.Model))
    while not HasModelLoaded(GetHashKey(Config.SellFood.Ped.Model)) do
        Wait(1)
    end
    local ped = CreatePed(5, GetHashKey(Config.SellFood.Ped.Model), Config.SellFood.Ped.Coords, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    exports['qb-target']:AddBoxZone('sell-food', Config.SellFood.Target.Coords, 1.5, 1.6, {
        name = "sell-food",
        heading = Config.SellFood.Target.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                event = "rv_farming:client:SellFood",
                icon = "fas fa-money-bill",
                label = Config.SellFood.Target.Label
            }
        }
    })
    -- SUPPLIES
    RequestModel(GetHashKey(Config.SuppliesStore.Ped.Model))
    while not HasModelLoaded(GetHashKey(Config.SuppliesStore.Ped.Model)) do
        Wait(1)
    end
    local ped = CreatePed(5, GetHashKey(Config.SuppliesStore.Ped.Model), Config.SuppliesStore.Ped.Coords, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    exports['qb-target']:AddBoxZone('supplies-store', Config.SuppliesStore.Target.Coords, 1.5, 1.6, {
        name = "supplies-store",
        heading = Config.SuppliesStore.Target.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                event = "rv_farming:client:SuppliesStore",
                icon = "fas fa-wheat-awn",
                label = Config.SuppliesStore.Target.Label
            }
        }
    })
    -- RINSE FOOD
    exports[Config.TargetName]:AddBoxZone('rinse-food', Config.Rinsing.Target.Coords, 1.5, 1.6, {
        name = "rinse-food",
        heading = Config.Rinsing.Target.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                event = "rv_farming:client:RinseFood",
                icon = "fas fa-water",
                label = Locale.Info.rinse_food
            }
        }
    })
end)

RegisterNetEvent('rv_farming:client:SellFood', function()
    local options = {}
    for k,v in pairs(Config.SellFood.Items) do
        options[#options+1] = {
            title = v.MenuText,
            onSelect = function()
                local p = promise.new()
                local amount
                QBCore.Functions.TriggerCallback('rv_farming:server:GetItemAmount', function(result)
                    p:resolve(result)
                end, v.Item)
                amount = Citizen.Await(p)
                if amount <= 0 then
                    QBCore.Functions.Notify(Locale.Error.dont_have, 'error', 5000)
                    return
                end
                TriggerServerEvent('rv_farming:server:SellFood', v, amount)
            end
        }
    end
    lib.registerContext({
        id = 'sell',
        title = Locale.Info.sell_food,
        options = options,
        onExit = function()
        end
    })
    lib.showContext('sell')
end)

RegisterNetEvent('rv_farming:client:RinseFood', function()
    local options = {}
    for k,v in pairs(Config.Rinsing.Items) do
        options[#options+1] = {
            title = v.MenuText,
            onSelect = function()
                local p = promise.new()
                local amount
                QBCore.Functions.TriggerCallback('rv_farming:server:GetItemAmount', function(result)
                    p:resolve(result)
                end, v.Dirty)
                amount = Citizen.Await(p)
                if amount <= 0 then
                    QBCore.Functions.Notify(Locale.Error.dont_have, 'error', 5000)
                    return
                end
                if Rinsing then 
                    return
                end
                Rinsing = true
                LoadAnimDict("amb@prop_human_bum_bin@idle_b")
                TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
                QBCore.Functions.Progressbar("washing", Locale.Info.rinsing_food, amount * 1500, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true
                }, {
                }, {}, {}, function() -- Done
                    TriggerServerEvent('rv_farming:server:RinseFood', v, amount)
                    Rinsing = false
                    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
                end, function() -- Cancel
                    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
                end)
            end
        }
    end
    lib.registerContext({
        id = 'rinse',
        title = Locale.Info.rinse_food,
        options = options,
        onExit = function()
        end
    })
    lib.showContext('rinse')
end)

RegisterNetEvent('rv_farming:client:SuppliesStore', function()
    local items = {
        label = Config.SuppliesStore.Label,
        slots = Config.SuppliesStore.Slots,
        items = Config.SuppliesStore.Items
    }
    TriggerServerEvent('inventory:server:OpenInventory', 'shop', Config.SuppliesStore.Label, items)
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    local Player = QBCore.Functions.GetPlayerData()
    PlayerJob = Player.job
    CheckBlips()
    LoadModel(GetHashKey(Config.Rinsing.Sink.ObjectName ))
    local Sink = CreateObject(GetHashKey(Config.Rinsing.Sink.ObjectName), Config.Rinsing.Sink.Coords, 1, 1, 0)
    FreezeEntityPosition(Sink, true)
    SetEntityHeading(Sink, Config.Rinsing.Sink.Coords.w)
    for k,v in pairs(Config.Farms) do
        exports[Config.TargetName]:AddTargetModel(v.Plants.ObjectName, {
            options = {
                {
                    type = "client",
                    action = function()
                        if not IsFarmer() then
                            QBCore.Functions.Notify(Locale.Error.must_be_farmer, 'error', 5000)
                            return
                        end
                        if Harvesting then
                            QBCore.Functions.Notify(Locale.Error.already_harvesting, 'error', 5000)
                            return
                        end
                        local p = promise.new()
                        local HasTools
                        QBCore.Functions.TriggerCallback('rv_farming:server:HasRequiredTools', function(result)
                            p:resolve(result)
                        end, v.RequiredTools)
                        HasTools = Citizen.Await(p)
                        if not HasTools then
                            return
                        end
                        local p = promise.new()
                        local Harvested
                        local Ped = PlayerPedId()
                        local Entity = GetClosestObjectOfType(GetEntityCoords(Ped), 2.3, GetHashKey(v.Plants.ObjectName))
                        local Coords = GetEntityCoords(Entity)
                        QBCore.Functions.TriggerCallback('rv_farming:server:IsPlantHarvested', function(result)
                            p:resolve(result)
                        end, tostring(Coords.x .. Coords.y .. Coords.z))
                        Harvested = Citizen.Await(p)
                        if Harvested then
                            QBCore.Functions.Notify(Locale.Error.already_harvested, 'error', 5000)
                            return
                        end
                        TriggerServerEvent('rv_farming:server:SetPlantHarvested', tostring(Coords.x .. Coords.y .. Coords.z), true)
                        Harvesting = true
                        local time = math.random(7500, 15000)
                        
                        if v.Plants.Tree then
                            TaskStartScenarioInPlace(Ped, "WORLD_HUMAN_GARDENER_LEAF_BLOWER", 0, true)
                        else
                            TaskStartScenarioInPlace(Ped, "WORLD_HUMAN_GARDENER_PLANT", 0, true)
                        end
                        QBCore.Functions.Progressbar("harvesting_plant", v.Plants.ProgressBar, time, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true
                        }, {
                        }, {}, {}, function() -- Done
                            Harvesting = false
                            ClearPedTasks(Ped)
                            TriggerServerEvent('rv_farming:server:HarvestedPlant', v)
                            if v.Plants.RemoveObjectWhenFarmed then
                                SetEntityAsMissionEntity(Entity, true, true)
                                DeleteEntity(Entity)
                            end
                            Wait(100)
                            local LeafBlower = GetClosestObjectOfType(GetEntityCoords(Ped), 5.0, GetHashKey('prop_leaf_blower_01'))
                            if LeafBlower ~= nil then
                                SetEntityAsMissionEntity(LeafBlower, true, true)
                                DeleteEntity(LeafBlower)
                            end
                            Wait(math.random(45000, 90000))
                            if v.Plants.RemoveObjectWhenFarmed then
                                local Plant = CreateObject(GetHashKey(v.Plants.ObjectName), Coords, 1, 1, 0)
                                FreezeEntityPosition(Plant, true)
                            end
                            TriggerServerEvent('rv_farming:server:SetPlantHarvested', tostring(Coords.x .. Coords.y .. Coords.z), false)
                        end, function() -- Cancel
                            ClearPedTasks(ped)
                        end)
                    end,
                    icon = "fas fa-" .. v.Plants.TargetIcon,
                    label = v.Plants.TargetLabel
                }
            }
        })
        if v.Plants.SpawnObject then
            LoadModel(GetHashKey(v.Plants.ObjectName))
            for k2,v2 in pairs(v.Plants.Locations) do
                local Entity = GetClosestObjectOfType(v2, 0.3, GetHashKey(v.Plants.ObjectName))
                if Entity ~= nil then
                    SetEntityAsMissionEntity(Entity, true, true)
                    DeleteEntity(Entity)
                end
                local Plant = CreateObject(GetHashKey(v.Plants.ObjectName), vector3(v2.x, v2.y, v2.z - v.Plants.Offset), 1, 1, 0)
                FreezeEntityPosition(Plant, true)
            end
        end
    end
end)

RegisterNetEvent("QBCore:Client:SetDuty", function(newDuty)
    PlayerJob.onduty = newDuty
    CheckBlips()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    CheckBlips()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    for k,v in pairs(Config.Farms) do
        for k2,v2 in pairs(v.Plants.Locations) do
            local Entity = GetClosestObjectOfType(v2, 3.3, GetHashKey(v.Plants.ObjectName))
            if Entity ~= nil then
                SetEntityAsMissionEntity(Entity, true, true)
                DeleteEntity(Entity)
            end
        end
    end
end)
  

function IsFarmer()
    return PlayerJob.name == Config.JobName
end

function CheckBlips() 
    for k,v in pairs(Blips) do
        RemoveBlip(v)
    end
    Blips = {}
    local Blip = AddBlipForCoord(Config.SellFood.Blip.Coords)
    SetBlipSprite(Blip, Config.SellFood.Blip.Sprite)
    SetBlipDisplay(Blip, 4)
    SetBlipScale(Blip, Config.SellFood.Blip.Scale)
    SetBlipColour(Blip, Config.SellFood.Blip.Color)
    SetBlipAsShortRange(Blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.SellFood.Blip.Name)
    EndTextCommandSetBlipName(Blip)
    table.insert(Blips, Blip)
    local Blip = AddBlipForCoord(Config.Rinsing.Blip.Coords)
    SetBlipSprite(Blip, Config.Rinsing.Blip.Sprite)
    SetBlipDisplay(Blip, 4)
    SetBlipScale(Blip, Config.Rinsing.Blip.Scale)
    SetBlipColour(Blip, Config.Rinsing.Blip.Color)
    SetBlipAsShortRange(Blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Rinsing.Blip.Name)
    EndTextCommandSetBlipName(Blip)
    table.insert(Blips, Blip)
    local Blip = AddBlipForCoord(Config.SuppliesStore.Blip.Coords)
    SetBlipSprite(Blip, Config.SuppliesStore.Blip.Sprite)
    SetBlipDisplay(Blip, 4)
    SetBlipScale(Blip, Config.SuppliesStore.Blip.Scale)
    SetBlipColour(Blip, Config.SuppliesStore.Blip.Color)
    SetBlipAsShortRange(Blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.SuppliesStore.Blip.Name)
    EndTextCommandSetBlipName(Blip)
    table.insert(Blips, Blip)
    for k,v in pairs(Config.Farms) do
        local Blip = AddBlipForCoord(v.Blip.Coords)
        SetBlipSprite(Blip, v.Blip.Sprite)
        SetBlipDisplay(Blip, 4)
        SetBlipScale(Blip, v.Blip.Scale)
        SetBlipColour(Blip, v.Blip.Color)
        SetBlipAsShortRange(Blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(v.Blip.Name)
        EndTextCommandSetBlipName(Blip)
        table.insert(Blips, Blip)
    end
end

function LoadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(1)
    end
end

function LoadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return end
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end