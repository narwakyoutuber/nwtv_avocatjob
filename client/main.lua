local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local OnJob                     = false
local CurrentCustomer           = nil
local CurrentCustomerBlip       = nil
local DestinationBlip           = nil
local IsNearCustomer            = false
local CustomerIsEnteringVehicle = false
local CustomerEnteredVehicle    = false
local TargetCoords              = nil
local IsDead                    = false

ESX                             = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	-- while ESX.GetPlayerData().job == nil do
		-- Citizen.Wait(10)
	-- end

	-- ESX.PlayerData = ESX.GetPlayerData()
end)

function OpenCloakroom()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'avocat_cloakroom',
	{
		title    = _U('cloakroom_menu'),
		align    = 'top-left',
		elements = {
			{ label = _U('wear_citizen'), value = 'wear_citizen' },
			{ label = _U('wear_work'),    value = 'wear_work'}
		}
	}, function(data, menu)
		if data.current.value == 'wear_citizen' then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			TriggerServerEvent('nwtv_avocatjob:dutyoff')
				TriggerEvent("pNotify:SendNotification", {
					text = "Fin de service",
					type = "info",
					timeout = 10000,
					layout = "centerRight"
	})
				TriggerEvent('skinchanger:loadSkin', skin)
			end)
		elseif data.current.value == 'wear_work' then
			TriggerServerEvent('nwtv_avocatjob:dutyon')
				TriggerEvent("pNotify:SendNotification", {
					text = "Prise de service",
					type = "info",
					timeout = 10000,
					layout = "centerRight"
	})
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin2', function(skin, job2Skin)
				if skin.sex == 0 then
					TriggerEvent('skinchanger:loadClothes', skin, job2Skin.skin_male)
				else
					TriggerEvent('skinchanger:loadClothes', skin, job2Skin.skin_female)
				end
			end)
		end
	end, function(data, menu)
		menu.close()

		CurrentAction     = 'cloakroom'
		CurrentActionMsg  = _U('cloakroom_prompt')
		CurrentActionData = {}
	end)
end

function OpenVehicleSpawnerMenu()
	ESX.UI.Menu.CloseAll()

	local elements = {}

	if Config.EnableSocietyOwnedVehicles then

		ESX.TriggerServerCallback('esx_society:getVehiclesInGarage', function(vehicles)

			for i=1, #vehicles, 1 do
				table.insert(elements, {
					label = GetDisplayNameFromVehicleModel(vehicles[i].model) .. ' [' .. vehicles[i].plate .. ']',
					value = vehicles[i]
				})
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawner',
			{
				title    = _U('spawn_veh'),
				align    = 'top-left',
				elements = elements
			}, function(data, menu)
				if not ESX.Game.IsSpawnPointClear(Config.Zones.VehicleSpawnPoint.Pos, 5.0) then
					ESX.ShowNotification(_U('spawnpoint_blocked'))
					return
				end

				menu.close()

				local vehicleProps = data.current.value
				ESX.Game.SpawnVehicle(vehicleProps.model, Config.Zones.VehicleSpawnPoint.Pos, Config.Zones.VehicleSpawnPoint.Heading, function(vehicle)
					ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
					local playerPed = PlayerPedId()
					TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
				end)

				TriggerServerEvent('esx_society:removeVehicleFromGarage', 'avocat', vehicleProps)

			end, function(data, menu)
				CurrentAction     = 'vehicle_spawner'
				CurrentActionMsg  = _U('spawner_prompt')
				CurrentActionData = {}

				menu.close()
			end)
		end, 'avocat')

	else -- not society vehicles

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawner',
		{
			title		= _U('spawn_veh'),
			align		= 'top-left',
			elements	= Config.AuthorizedVehicles
		}, function(data, menu)
			if not ESX.Game.IsSpawnPointClear(Config.Zones.VehicleSpawnPoint.Pos, 5.0) then
				ESX.ShowNotification(_U('spawnpoint_blocked'))
				return
			end

			menu.close()
			ESX.Game.SpawnVehicle(data.current.model, Config.Zones.VehicleSpawnPoint.Pos, Config.Zones.VehicleSpawnPoint.Heading, function(vehicle)
			local numberplate = math.random(1000, 9999)
			SetVehicleNumberPlateText(vehicle,"AVOCAT"..numberplate.."")
			SetVehicleColours(vehicle, 12, 12)
			SetVehicleExtraColours(vehicle, 0, 0)
			SetVehicleModKit(vehicle, 0)
			SetVehicleMod(vehicle, 1, 0)
			SetVehicleMod(vehicle, 2, 0)
			SetVehicleMod(vehicle, 3, 0)
			SetVehicleMod(vehicle, 4, 0)
			SetVehicleMod(vehicle, 11, 3)
			SetVehicleMod(vehicle, 12, 2)
			SetVehicleMod(vehicle, 13, 2)
			SetVehicleMod(vehicle, 15, 3)
			SetVehicleMod(vehicle, 16, 4)
			SetVehicleWindowTint(vehicle, 1)
			ToggleVehicleMod(vehicle, 18, 1)
		    ToggleVehicleMod(vehicle, 22, 1)
				local playerPed = PlayerPedId()
				TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
			end)
		end, function(data, menu)
			CurrentAction     = 'vehicle_spawner'
			CurrentActionMsg  = _U('spawner_prompt')
			CurrentActionData = {}

			menu.close()
		end)
	end
end

function DeleteJobVehicle()
	local playerPed = PlayerPedId()

	if Config.EnableSocietyOwnedVehicles then
		local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
		TriggerServerEvent('esx_society:putVehicleInGarage', 'avocat', vehicleProps)
		ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
	else
		if IsInAuthorizedVehicle() then
			ESX.Game.DeleteVehicle(CurrentActionData.vehicle)

			if Config.MaxInService ~= -1 then
				TriggerServerEvent('esx_service:disableService', 'avocat')
			end
		else
			ESX.ShowNotification(_U('only_avocat'))
		end
	end
end

function OpenAvocatActionsMenu()
	local elements = {
		{label = _U('deposit_stock'), value = 'put_stock'},
		{label = _U('take_stock'), value = 'get_stock'}
	}

	if Config.EnablePlayerManagement and ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' then
		table.insert(elements, {label = _U('boss_actions'), value = 'boss_actions'})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'avocat_actions',
	{
		title    = 'Avocat',
		align    = 'top-left',
		elements = elements
	}, function(data, menu)

		if data.current.value == 'put_stock' then
			OpenPutStocksMenu()
		elseif data.current.value == 'get_stock' then
			OpenGetStocksMenu()
		elseif data.current.value == 'boss_actions' then
			TriggerEvent('esx_society:openBossMenu', 'avocat', function(data, menu)
				menu.close()
			end)
		end

	end, function(data, menu)
		menu.close()

		CurrentAction     = 'avocat_actions_menu'
		CurrentActionMsg  = _U('press_to_open')
		CurrentActionData = {}
	end)
end

function OpenMobileAvocatActionsMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mobile_avocat_actions',
	{
		title    = 'Avocat',
		align    = 'top-left',
		elements = {
			{ label = _U('billing'),   value = 'billing' },
		}
	}, function(data, menu)
		if data.current.value == 'billing' then

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
				title = _U('invoice_amount')
			}, function(data, menu)

				local amount = tonumber(data.value)
				if amount == nil then
					ESX.ShowNotification(_U('amount_invalid'))
				else
					menu.close()
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('no_players_near'))
					else
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_avocat', 'Avocat', amount)
						ESX.ShowNotification(_U('billing_sent'))
					end

				end

			end, function(data, menu)
				menu.close()
			end)
		end
	end, function(data, menu)
		menu.close()
	end)
end

function IsInAuthorizedVehicle()
	local playerPed = PlayerPedId()
	local vehModel  = GetEntityModel(GetVehiclePedIsIn(playerPed, false))

	for i=1, #Config.AuthorizedVehicles, 1 do
		if vehModel == GetHashKey(Config.AuthorizedVehicles[i].model) then
			return true
		end
	end

	return false
end

function OpenGetStocksMenu()
	ESX.TriggerServerCallback('nwtv_avocatjob:getStockItems', function(items)
		local elements = {}

		for i=1, #items, 1 do
			table.insert(elements, {
				label = 'x' .. items[i].count .. ' ' .. items[i].label,
				value = items[i].name
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu',
		{
			title    = 'Avocat Stock',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)

				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()

					-- todo: refresh on callback
					TriggerServerEvent('nwtv_avocatjob:getStockItem', itemName, count)
					Citizen.Wait(1000)
					OpenGetStocksMenu()
				end

			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenPutStocksMenu()
	ESX.TriggerServerCallback('nwtv_avocatjob:getPlayerInventory', function(inventory)

		local elements = {}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard', -- not used
					value = item.name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu',
		{
			title    = _U('inventory'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)

				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()

					-- todo: refresh on callback
					TriggerServerEvent('nwtv_avocatjob:putStockItems', itemName, count)
					Citizen.Wait(1000)
					OpenPutStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
	ESX.PlayerData.job2 = job2
end)

AddEventHandler('nwtv_avocatjob:hasEnteredMarker', function(zone)
	if zone == 'VehicleSpawner' then
		CurrentAction     = 'vehicle_spawner'
		CurrentActionMsg  = _U('spawner_prompt')
		CurrentActionData = {}
	elseif zone == 'VehicleDeleter' then
		local playerPed = PlayerPedId()
		local vehicle   = GetVehiclePedIsIn(playerPed, false)

		if IsPedInAnyVehicle(playerPed, false) and GetPedInVehicleSeat(vehicle, -1) == playerPed then
			CurrentAction     = 'delete_vehicle'
			CurrentActionMsg  = _U('store_veh')
			CurrentActionData = { vehicle = vehicle }
		end
	elseif zone == 'AvocatActions' then
		CurrentAction     = 'avocat_actions_menu'
		CurrentActionMsg  = _U('press_to_open')
		CurrentActionData = {}

	elseif zone == 'Cloakroom' then
		CurrentAction     = 'cloakroom'
		CurrentActionMsg  = _U('cloakroom_prompt')
		CurrentActionData = {}
	end
end)

AddEventHandler('nwtv_avocatjob:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
	local specialContact = {
		name       = 'Avocat',
		number     = 'avocat',
		base64Icon = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAA3QAAAN0BcFOiBwAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAARoSURBVFiF7Zd/aFVlGMc/z3vPvfvldNPmnEbUyoUUQUVumJqDCaXYsrnb8ge2Zvnjj/4JzJxwJxJaUUQgDpoRFCZHmjpDxGg0HFjSHzENHa7wV/4cabft3uu955y3P+7uZXc7pzsHsX964IX3vO/zfL/f53nP+573iNaaiTQ1oeyAMe7INinFporTD1aSZ+/jw0tnxgMzvgq0yuvY/A4c4uL0dzlfeppND38+HigZ/Q6I4sKigGdE149zicU6AR8A385NIcEjtzbyxINfeMZeXBQnFHKGD42qwMm24G6tB6Lg0UoKu9Lkw00LJAr2YEnUremERPf3/7R7ZFiGgAPBoO/a5aL6qxeLrwC9ri1yd8Azw6hYXnG9t/xX+vr99cFgMEN8xkuoKqYucRymnfy+vH3FjtY6V5Jj8h7CVtc5iZ1iXeezblP7g7XfAC/PkfgS4Eiac7iTFr1uqLvs6+Y3Sl1JcviEnBxn9LgFUyJNbiHNK2tLBZYBiE5zZApob15fBrJ06NHvF2Otq4BVq0p44XlF2QxQCpSGskF4KwFbHp/tFhJIsFaDH0BgaXNdXdkoAY7QCPgQDgKI0q7ZYMtiJhfC4hpY2QAfObA1Dx7IgYTV6BaihaYh8oMafAEjkfZLChARkCYA7fNtBrq1pqJ924aFo+GkJt1VCgwZxmTNG+m9/ZXahUAF0A1sBtBamkRE0gIObNtQjVAO0lUf2t2nRfYmlWeuF1QboJ9zrQyAFZvOhercEemvS2av94bMw30CXUB5S/2y6rQAIUkkotsA8nyOCYQ1suLQ9saiNFh0ViVQ6CnAcYR8/2vp7JcvLwK9AggTwyRJ1pYhbMerL71dMm3SLjSJG/0D72jtJACmFResDPiNBdFofH9/ONqywzzcS2xNCE1LBumNc5kicgt/YEZnde38Zx69Lz+vJd8faEjY1ombA+F9AKKUf2bhlPcB//WBv7cYtq13XrsRNkieCZ+mcPr/HEx1GwzkCNCLpoZsZsWfAjBEP307Mthwm0GABSALALSj+eOvO0PFYKdC656soMrqgeAkoGoMAiYzWFOqHcmKq6FHgXRk8ev71ck/SySwiDF9vjUMssmY9dBZgb5/95UOBYFdgJdaS9CNpmnaiGQvfzrKftE0TVuLNAKWh1ePcSe2S4VMMx69y3w0rUAEQECDPiVKV4bMju6kWD12AXZ8DkD7iZ+7RUklok8Bqe9+BKTVJm++eeZMPOM+EAwGfY85sdnkWldDXx0Npycia8oQrrqSjdwFKSsofpKS47+kHpdUVU3OV9ZMdX/5edM07dS4y4XExWKrV6Ply3sSkFvUyozvNmaDHtuVzLmH9U+ZnVg8FjfPChz9+M0K29JTAebVxTuUosTN7+a5yx7IyunuLF4PYPi4tHbngeNubp7bStt8ICK1ACfbczwzOPub32tKQfgzgPzcnOtAmYfTxNr/AiZcgPfZ7rAH4Vg2gKJJBS63pkzzKZ/nb9vYDqL/0CZ8Cf4BrBmoU1KcpzcAAAAASUVORK5CYII='
	}

	TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
end)

-- Create Blips
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.AvocatActions.Pos.x, Config.Zones.AvocatActions.Pos.y, Config.Zones.AvocatActions.Pos.z)

	SetBlipSprite (blip, 79)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 1.0)
	SetBlipColour (blip, 4)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(_U('blip_avocat'))
	EndTextCommandSetBlipName(blip)
end)

-- Enter / Exit marker events, and draw markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'avocat' then
			local coords = GetEntityCoords(PlayerPedId())
			local isInMarker, currentZone = false

			for k,v in pairs(Config.Zones) do
				local distance = GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true)

				if v.Type ~= -1 and distance < Config.DrawDistance then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, false, 2, v.Rotate, nil, nil, false)
				end

				if distance < v.Size.x then
					isInMarker, currentZone = true, k
				end
			end

			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker, LastZone = true, currentZone
				TriggerEvent('nwtv_avocatjob:hasEnteredMarker', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('nwtv_avocatjob:hasExitedMarker', LastZone)
			end
    elseif ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'offavocat' then
			local coords = GetEntityCoords(PlayerPedId())
			local isInMarker, currentZone = false

			for k,v in pairs(Config.Zones) do
				local distance = GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true)

				if v.Duty == 1 and v.Type ~= -1 and distance < Config.DrawDistance then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, false, 2, v.Rotate, nil, nil, false)
				end

				if distance < v.Size.x then
					isInMarker, currentZone = true, k
				end
			end

			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker, LastZone = true, currentZone
				TriggerEvent('nwtv_avocatjob:hasEnteredMarker', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('nwtv_avocatjob:hasExitedMarker', LastZone)
			end
		else
			Citizen.Wait(1000)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction and not IsDead then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, Keys['E']) and ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'avocat' then
				if CurrentAction == 'avocat_actions_menu' then
					OpenAvocatActionsMenu()
				elseif CurrentAction == 'cloakroom' then
					OpenCloakroom()
				elseif CurrentAction == 'vehicle_spawner' then
					OpenVehicleSpawnerMenu()
				elseif CurrentAction == 'delete_vehicle' then
					DeleteJobVehicle()
				end
      elseif IsControlJustReleased(0, Keys['E']) and ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'offavocat' then
				if CurrentAction == 'cloakroom' then
					OpenCloakroom()
				end

				CurrentAction = nil
			end
		end

		if IsControlJustReleased(0, Keys['F3']) and IsInputDisabled(0) and not IsDead and Config.EnablePlayerManagement and ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'avocat' then
			OpenMobileAvocatActionsMenu()
		end
	end
end)