local identifiers = {}

local function saveAppearance(identifier, appearance)
	SetResourceKvp(('%s:appearance'):format(identifier), json.encode(appearance))
end
exports('save', saveAppearance)

local function loadAppearance(source, identifier)
	local appearance = GetResourceKvpString(('%s:appearance'):format(identifier))
	identifiers[source] = identifier

	return appearance and json.decode(appearance) or {}
end
exports('load', loadAppearance)

local function saveOutfit(identifier, appearance, slot, outfitNames)
	SetResourceKvp(('%s:outfit_%s'):format(identifier, slot), json.encode(appearance))
	SetResourceKvp(('%s:outfits'):format(identifier), json.encode(outfitNames))
end
exports('saveOutfit', saveOutfit)

local function loadOutfit(identifier, slot)
	local appearance = GetResourceKvpString(('%s:outfit_%s'):format(identifier, slot))

	return appearance and json.decode(appearance) or {}
end
exports('loadOutfit', loadOutfit)

local function loadOutfitNames(identifier)
	local data = GetResourceKvpString(('%s:outfits'):format(identifier))

	return data and json.decode(data) or {}
end
exports('outfitNames', loadOutfitNames)

if GetResourceState('es_extended'):find('start') then
	local ESX = exports.es_extended:getSharedObject()

	ESX = {
		GetExtendedPlayers = ESX.GetExtendedPlayers,
		RegisterServerCallback = ESX.RegisterServerCallback,
		GetPlayerFromId = ESX.GetPlayerFromId,
	}

	AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
		identifiers[playerId] = xPlayer.identifier		
		TriggerClientEvent('fivem-appearance:outfitNames', playerId, loadOutfitNames(xPlayer.identifier))
	end)

	RegisterNetEvent('esx_skin:save', function(appearance)
		local xPlayer = ESX.GetPlayerFromId(source)
		MySQL.update('UPDATE users SET skin = ? WHERE identifier = ?', { json.encode(appearance), xPlayer.identifier })
	end)

	ESX.RegisterServerCallback('esx_skin:getPlayerSkin', function(source, cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		local appearance = MySQL.scalar.await('SELECT skin FROM users WHERE identifier = ?', { xPlayer.identifier })

		cb(appearance and json.decode(appearance) or {})
	end)

	--[[do
		local xPlayers = ESX.GetExtendedPlayers()

		for i = 1, #xPlayers do
			local xPlayer = xPlayers[i]
			identifiers[xPlayer.source] = xPlayer.identifier
			TriggerClientEvent('fivem-appearance:outfitNames', xPlayer.source, loadOutfitNames(xPlayer.identifier))
		end
	end]]

	-- OUTFITS BY KARMAKARMELO & DK_DEN7E
	local cache = {}

	MySQL.Async.fetchAll('SELECT * FROM outfits', {}, function(result)
		if result[1] then
			for k, v in ipairs(result) do
				if cache[v.identifier] == nil then cache[v.identifier] = {} end
				
				table.insert(cache[v.identifier], { id = v.id, name = v.name, model = v.ped, components = json.decode(v.components), props = json.decode(v.props), hair = json.decode(v.hair), headOverlays = json.decode(v.headOverlays) })
				if k % 20 == 0 then
					Citizen.Wait(0)
				end
			end
		end
	end)
	
	ESX.RegisterServerCallback('guardarOutfitEnDB', function(source, cb, outfitName, skin)
		local xPlayer = ESX.GetPlayerFromId(source)
		local model, components, props, hair, headOverlays = skin.model, skin.components, skin.props, skin.hair, skin.headOverlays
		if cache[xPlayer.identifier] == nil then cache[xPlayer.identifier] = {} end

		MySQL.insert('INSERT INTO outfits (identifier, name, ped, components, props, hair, headOverlays) VALUES (?, ?, ?, ?, ?, ?, ?)', {xPlayer.identifier, outfitName, model, json.encode(components), json.encode(props), json.encode(hair), json.encode(headOverlays)},
		function(result)
			local id = result
			table.insert(cache[xPlayer.identifier], { id = id, name = outfitName, model = model, components = components, props = props, hair = hair, headOverlays = headOverlays })
			cb(id)
		end)
	end)
	
	RegisterServerEvent('deleteOutfit')
	AddEventHandler('deleteOutfit', function(id)
		local xPlayer = ESX.GetPlayerFromId(source)
		for k, v in ipairs(cache[xPlayer.identifier]) do -- May be more optimized to remove the loop and also add the identifier in the MySQL query?
			if tonumber(v.id) == tonumber(id) then
				table.remove(cache[xPlayer.identifier], k)
				MySQL.update('DELETE FROM `outfits` WHERE `id` = ?', {
					id
				})
				break
			end
		end
	end)
	
	ESX.RegisterServerCallback('getOutfitsFromDb', function(source, cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		cb(cache[xPlayer.identifier] and cache[xPlayer.identifier] or {})
	end)
end

RegisterNetEvent('fivem-appearance:save', function(appearance)
	local identifier = identifiers[source]

	if identifier then
		saveAppearance(identifier, appearance)
	end
end)

RegisterNetEvent('fivem-appearance:saveOutfit', function(appearance, slot, outfitNames)
	local identifier = identifiers[source]

	if identifier then
		saveOutfit(identifier, appearance, slot, outfitNames)
	end
end)

RegisterNetEvent('fivem-appearance:loadOutfitNames', function()
	local identifier = identifiers[source]
	TriggerClientEvent('fivem-appearance:outfitNames', source, identifier and loadOutfitNames(identifier) or {})
end)

RegisterNetEvent('fivem-appearance:loadOutfit', function(slot)
	local identifier = identifiers[source]
	TriggerClientEvent('fivem-appearance:outfit', source, slot, identifier and loadOutfit(identifier, slot) or {})
end)

AddEventHandler('playerDropped', function()
	identifiers[source] = nil
end)

RegisterCommand("skin", function(source, args, raw)
	local target = source
	if args[1] ~= nil then
		target = args[1] == "me" and source or (GetPlayerName(args[1]) and args[1] or nil)
	end
	if target ~= nil then
		TriggerClientEvent("esx_skin:openSaveableMenu", target)
	else
		print("Jugador no conectado")
	end
end, true)