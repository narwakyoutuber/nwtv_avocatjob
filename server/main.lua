ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if Config.MaxInService ~= -1 then
	TriggerEvent('esx_service:activateService', 'avocat', Config.MaxInService)
end

TriggerEvent('esx_phone:registerNumber', 'avocat', 'message avocat', true, true)
TriggerEvent('esx_society:registerSociety', 'avocat', 'Avocat', 'society_avocat', 'society_avocat', 'society_avocat', {type = 'public'})

RegisterServerEvent('nwtv_avocatjob:getStockItem')
AddEventHandler('nwtv_avocatjob:getStockItem', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job2.name ~= 'avocat' then
		print(('nwtv_avocatjob: %s attempted to trigger getStockItem!'):format(xPlayer.identifier))
		return
	end
	
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_avocat', function(inventory)
		local item = inventory.getItem(itemName)
		local sourceItem = xPlayer.getInventoryItem(itemName)

		-- is there enough in the society?
		if count > 0 and item.count >= count then
		
			-- can the player carry the said amount of x item?
			if sourceItem.limit ~= -1 and (sourceItem.count + count) > sourceItem.limit then
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('player_cannot_hold'))
			else
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_withdrawn', count, item.label))
			end
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end
	end)
end)

ESX.RegisterServerCallback('nwtv_avocatjob:getStockItems', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_avocat', function(inventory)
		cb(inventory.items)
	end)
end)

RegisterServerEvent('nwtv_avocatjob:putStockItems')
AddEventHandler('nwtv_avocatjob:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job2.name ~= 'avocat' then
		print(('nwtv_avocatjob: %s attempted to trigger putStockItems!'):format(xPlayer.identifier))
		return
	end

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_avocat', function(inventory)
		local item = inventory.getItem(itemName)

		if item.count >= 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_deposited', count, item.label))
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end

	end)

end)

ESX.RegisterServerCallback('nwtv_avocatjob:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb( { items = items } )
end)


RegisterServerEvent('nwtv_avocatjob:dutyoff')
AddEventHandler('nwtv_avocatjob:dutyoff', function(job)

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local job = xPlayer.job2.name
    local grade = xPlayer.job2.grade
    
    if job == 'avocat' then
        xPlayer.setJob2('offavocat', grade)
    end

end)

RegisterServerEvent('nwtv_avocatjob:dutyon')
AddEventHandler('nwtv_avocatjob:dutyon', function(job)

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local job = xPlayer.job2.name
    local grade = xPlayer.job2.grade
    
    if job == 'offavocat' then
        xPlayer.setJob2('avocat', grade)
    end

end)