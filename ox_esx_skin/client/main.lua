resName = GetCurrentResourceName()

if GetResourceState('es_extended'):find('start') then
	ESX = true

	AddEventHandler('skinchanger:loadDefaultModel', function(male, cb)
		exports[resName]:setPlayerModel(male and `mp_m_freemode_01` or `mp_f_freemode_01`)
		if cb then cb() end
	end)

	AddEventHandler('skinchanger:loadSkin', function(skin, cb)
		if not skin.model then skin.model = 'mp_m_freemode_01' end
		exports[resName]:setPlayerAppearance(skin)
		if cb then cb() end
	end)

	RegisterNetEvent('esx_skin:openSaveableMenu')
	AddEventHandler('esx_skin:openSaveableMenu', function(submitCb, cancelCb)
		exports[resName]:startPlayerCustomization(function (appearance)
			if (appearance) then
				TriggerServerEvent('esx_skin:save', appearance)
				if submitCb then submitCb() end
			else
				if cancelCb then cancelCb() end
			end
		end, {
			ped = true,
			headBlend = true,
			faceFeatures = true,
			headOverlays = true,
			components = true,
			props = true,
			tattoos = true
		})
	end)
end

local shops = {
	clothing = {
		vec(72.3, -1399.1, 28.4), -- tienda de ropa
		vec(-708.71, -152.13, 36.4), -- tienda de ropa
		vec(-165.15, -302.49, 38.6), -- tienda de ropa
		vec(428.7, -800.1, 28.5), -- tienda de ropa
		vec(-829.4, -1073.7, 10.3), -- tienda de ropa
		vec(-1449.16, -238.35, 48.8), -- tienda de ropa
		vec(11.6, 6514.2, 30.9), -- tienda de ropa
		vec(122.98, -222.27, 53.5), -- tienda de ropa
		vec(1696.3, 4829.3, 41.1), -- tienda de ropa
		vec(618.1, 2759.6, 41.1), -- tienda de ropa
		vec(1190.6, 2713.4, 37.2), -- tienda de ropa
		vec(-1193.4, -772.3, 16.3), -- tienda de ropa
		vec(-3172.5, 1048.1, 19.9), -- tienda de ropa
		vec(-1108.4, 2708.9, 18.1), -- tienda de ropa
		vec(193.96, -877.87, 29.77), -- tienda de ropa
		-- add 4th argument to create vector4 and disable blip
		vec(300.60, -597.76, 42.18, 0), -- Pillbox Hospital
		vec(461.47, -998.05, 30.20, 0), -- MRPD
		vec(-1622.64, -1034.01, 13.14, 0), -- Del Perro PD
		vec(-449.79, 6008.53, 31.84, 0), -- Paleto LSSO
		vec(1861.10, 3689.23, 34.27, 0), -- Sandy LSSO
		vec(1834.59, 3690.54, 34.27, 0), -- Sandy Medical
		vec(1742.14, 2481.58, 45.74, 0), -- Prisión estatal Bolingbroke
		vec(516.89, 4823.57, -66.19, 0), -- Interior submarino Kosatka
		vec(105.52, -1303.02, 28.79, 0), -- Vanilla Unicorn / Paraíso Canario
		vec(-175.07, 305.7842, 100.92, 0), -- Palacio Wei
		vec(-1832.05, -1189.56, 19.42, 0), -- Mesón de Servando
		vec(-132.50, -632.86, 168.82, 0), -- OneTravel sede
		vec(-2578.1, 1887.26, 163.72, 0), -- OneTravel Westons
		vec(-103.61, 984.23, 240.84, 0), -- OneTravel Vinewood Hills
		vec(-2268.12, 219.45, 108.37, 0), -- Canary Race
		vec(-452.53, 283.22, 83.04, 0), -- Nueva Vida
		vector3(-566.3472, 279.9956, 82.96338), -- tequilala
		vector3(317.2615, 212.4396, 104.3627), -- Dirty Angels
	},

	barber = {
		vec(-814.3, -183.8, 36.6),
		vec(136.8, -1708.4, 28.3),
		vec(-1282.6, -1116.8, 6.0),
		vec(1931.5, 3729.7, 31.8),
		vec(1212.8, -472.9, 65.2),
		vec(-34.31, -154.99, 55.8),
		vec(-278.1, 6228.5, 30.7),
	},

	tattoos = {
		vec(1322.6, -1651.9, 51.2),
		vec(-1153.6, -1425.6, 4.9),
		vec(322.1, 180.4, 103.5),
		vec(-3170.0, 1075.0, 20.8),
		vec(1864.6, 3747.7, 33.0),
		vec(-293.7, 6200.0, 31.4)
	}
}

local function createBlip(name, sprite, colour, scale, location)
	local blip = AddBlipForCoord(location.x, location.y)
	SetBlipSprite(blip, sprite)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, scale)
	SetBlipColour(blip, colour)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentString(name)
	EndTextCommandSetBlipName(blip)
end

for i = 1, #shops.clothing do
	if not shops.clothing[i].w then
		shops.clothing[i] = shops.clothing[i]+vector3(0, 0, 1)
		createBlip('Tienda de ropa', 73, 47, 0.7, shops.clothing[i])
	end
end

for i = 1, #shops.barber do
	createBlip('Peluquería', 71, 47, 0.7, shops.barber[i])
end

for i = 1, #shops.tattoos do
	createBlip('Tattoos studio', 75, 1, 0.7, shops.tattoos[i])
end

local shopType
local config = {
	clothing = {
		ped = false,
		headBlend = false,
		faceFeatures = false,
		headOverlays = false,
		components = true,
		props = true,
		tattoos = false
	},

	barber = {
		ped = false,
		headBlend = false,
		faceFeatures = false,
		headOverlays = true, 
		components = false,
		props = false,
		tattoos = false
	},

	tattoos = {
		ped = false,
		headBlend = false,
		faceFeatures = false,
		headOverlays = false,
		components = false,
		props = false,
		tattoos = true
	}
}

local function getClosestShop(currentShop, coords)
	local closestShop = #(currentShop.xyz - coords)

	if closestShop > 25 then
		for name, data in pairs(shops) do
			for i = 1, #data do
				Wait(100)
				local distance = #(data[i].xyz - coords)
				if distance < closestShop then
					closestShop = distance
					currentShop = data[i]
					shopType = name
				end
			end
		end
	end

	if closestShop > 25 then
		Wait(1000)
		canSaveOutfit = false
	else
		if open then
			Wait(250)
		else
			local activationDist = (currentShop.w and 1.2 or 4.0)
			for i = 1, 30, 1 do
				Wait(0)
				if closestShop < activationDist then
					canSaveOutfit = true
					DrawMarker(20, currentShop.xyz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 255, 0, 200, false, false, 2, true, nil, nil, false)
					if IsControlJustReleased(0, 38) then
						exports[resName]:startPlayerCustomization(function(appearance)
							if (appearance) then
								if ESX then
									TriggerServerEvent('esx_skin:save', appearance)
								else
									TriggerServerEvent('fivem-appearance:save', appearance)
								end
								SaveOutfitMenu()
							end
						end, config[shopType])
					end
				elseif closestShop < 6.0 then
					DrawMarker(20, currentShop.xyz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 155, 224, 219, 180, false, false, 2, true, nil, nil, false)
				else
					canSaveOutfit = false
				end
			end
		end
	end

	return currentShop
end

CreateThread(function()
	local currentShop = vec(0, 0, 0)
	while true do
		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed)
		currentShop = getClosestShop(currentShop, playerCoords)
	end
end)
