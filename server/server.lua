local QBCore = exports[Config.CoreName]:GetCoreObject()
local Harvested = {}

QBCore.Functions.CreateCallback('rv_farming:server:HasRequiredTools', function(source, cb, tools)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    for k,v in pairs(tools) do
        local item = Player.Functions.GetItemByName(v)
        if item == nil then
            TriggerClientEvent('QBCore:Notify', src, Locale.Error.missing_tools, 'error')
            cb(false)
            return
        end
    end
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_farming:server:IsPlantHarvested', function(source, cb, plant)
    for k,v in pairs(Harvested) do
        if v == plant then
            cb(true)
        end
    end
    cb(false)
end)

QBCore.Functions.CreateCallback('rv_farming:server:GetItemAmount', function(source, cb, name)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(name)
    if item == nil then
        cb(0)
        return
    end
    cb(item.amount)
end)

RegisterNetEvent('rv_farming:server:SetPlantHarvested', function(plant, harvest)
    if harvest then
        table.insert(Harvested, plant)
        return
    end
    for k,v in pairs(Harvested) do
        if v == plant then
            table.remove(Harvested, k)
        end
    end
end)

RegisterNetEvent('rv_farming:server:HarvestedPlant', function(farm)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(farm.Item.ItemName, math.random(farm.Item.AmountMin, farm.Item.AmountMax))
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[farm.Item.ItemName], 'add')
end)

RegisterNetEvent('rv_farming:server:RinseFood', function(info, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(info.Dirty)
    if item.amount < amount then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.dont_have, 'error')
        return
    end
    Player.Functions.RemoveItem(info.Dirty, amount)
    Player.Functions.AddItem(info.Clean, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[info.Clean], 'add')
end)

RegisterNetEvent('rv_farming:server:SellFood', function(info, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(info.Item)
    if item.amount < amount then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.dont_have, 'error')
        return
    end
    Player.Functions.RemoveItem(info.Item, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[info.Item], 'remove')
    Player.Functions.AddMoney('cash', amount * info.SellPrice)
end)