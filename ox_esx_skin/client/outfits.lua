
local outfitNames
local outfits = {}

local function getOutfitNames()
	outfitNames = nil
	TriggerServerEvent('fivem-appearance:loadOutfitNames')
	repeat Wait(0) until outfitNames
end

local function getOutfit(slot)
	if not outfits[slot] then
		TriggerServerEvent('fivem-appearance:loadOutfit', slot)
		repeat Wait(0) until outfits[slot]
	end

	return outfits[slot]
end

if ESX then
	RegisterNetEvent('esx:playerLoaded', function()
		outfitNames = nil
		outfits = {}
	end)
end

RegisterNetEvent('fivem-appearance:outfitNames', function(data)
	outfitNames = data
end)

RegisterNetEvent('fivem-appearance:outfit', function(slot, data)
	outfits[slot] = data
end)

--[[
RegisterCommand('outfits', function(source, args, raw)
	if not outfitNames then
		getOutfitNames()
	end
	print(json.encode(outfitNames, {indent=true}))
end)

RegisterCommand('saveoutfit', function(source, args, raw)
	local slot = tonumber(args[1])

	if type(slot) == 'number' then
		if not outfitNames then
			getOutfitNames()
		end

		local appearance = exports[resName]:getAppearance()
		outfitNames[slot] = args[2]
		outfits[slot] = appearance

		TriggerServerEvent('fivem-appearance:saveOutfit', appearance, slot, outfitNames)
	end
end)

RegisterCommand('outfit', function(source, args, raw)
	local slot = tonumber(args[1])

	if type(slot) == 'number' then
		local appearance = getOutfit(slot)

		if not appearance.model then appearance.model = 'mp_m_freemode_01' end
		exports[resName]:setPlayerAppearance(appearance)
	end
end)]]

Citizen.CreateThread(function()
	local ESX, cache, ready = nil, {}, false

    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(100)
    end

	function SaveOutfitMenu()
		ESX.UI.Menu.Open('default', resName, 'dk_saveoutfit', {
			title    = '¿Quieres guardar tu ropa actual como atuendo?',
			align    = 'center',
			elements = { { label = "Sí", value = "yes" }, { label = "No", value = "no" } }
		}, function(data, menu)
			menu.close()
			if data.current.value == "yes" then
				if not ready then
					ESX.TriggerServerCallback('getOutfitsFromDb', function(outfits)
						cache = outfits
						ready = true
					end)
					while not ready do
						Citizen.Wait(100)
					end
				end
				local _skin, outfitName = exports['fivem-appearance']:getPedAppearance(PlayerPedId()), ""
				local skin = { model = _skin.model, components = _skin.components, props = _skin.props, hair = _skin.hair, headOverlays = _skin.headOverlays }
				while IsDisabledControlPressed(0, 18) or IsControlPressed(0, 18) do
					Citizen.Wait(5)
				end
				local keyboard, outfitName = exports["nh-keyboard"]:Keyboard({
					header = "Guardando nuevo atuendo",
					rows = {
						"Nombre del atuendo"
					}
				})
				--DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP9N", "quantity", "", "", "", "", 30)
				--while (UpdateOnscreenKeyboard() == 0) do
				--	DisableAllControlActions(0);
				--	Wait(0);
				--end
			
				--if (GetOnscreenKeyboardResult()) then
				if outfitName then
					--outfitName = GetOnscreenKeyboardResult()
					if outfitName ~= "" then
						ESX.TriggerServerCallback('guardarOutfitEnDB', function(id)
							if id then
								table.insert(cache, { id = id, name = outfitName, components = skin.components, props = skin.props, hair = skin.hair, headOverlays = skin.headOverlays })
								TriggerEvent("chat:addMessage", { args = { "^1SISTEMA^3", 'atuendo "^3' .. outfitName .. '^0" guardado ^2con éxito^0. ^1Puedes usar ^3/atuendos ^1para ver los que tienes, usarlos, eliminarlos, y si estás cerca de un punto como este, guardar lo que lleves puesto como atuendo.' } })
							else
								TriggerEvent("chat:addMessage", { args = { "^1SISTEMA^3", 'error, el atuendo "^3' .. outfitName .. '^0" no se pudo guardar.' } })
							end
						end, outfitName, skin)
					end
				end
			end
		end, function(data, menu)
			menu.close()
		end)
	end

	RegisterCommand('atuendos', function()
		TriggerEvent("fivem_appearance:atuendos", false)
	end)

	RegisterNetEvent("fivem_appearance:atuendos")
	AddEventHandler("fivem_appearance:atuendos", function(save)
		if not ready then
			ESX.TriggerServerCallback('getOutfitsFromDb', function(outfits)
				cache = outfits
				ready = true
			end)
			while not ready do
				Citizen.Wait(100)
			end
		end
		local elements = {}
		for k, v in pairs(cache) do
			table.insert(elements, {label = v.name, value = v})
		end
	
		if save or canSaveOutfit then
			table.insert(elements, {label = "Guardar atuendo", value = "save_outfit"})
		end
	
		ESX.UI.Menu.CloseAll()
	
		ESX.UI.Menu.Open('default', resName, 'karma_outfits', {
			title    = 'Tus atuendos',
			align    = 'bottom-left',
			elements = elements
		}, function(data, menu)
			if data.current.value == "save_outfit" then
				SaveOutfitMenu()
			else
				local elements = {	{ label = "Usar", value = "use_outfit" }, { label = "Eliminar", value = "del_outfit" } }
				ESX.UI.Menu.Open('default', resName, 'karma_outfits2', {
					title    = '¿Qué quieres hacer?',
					align    = 'bottom-left',
					elements = elements
				}, function(data2, menu2)
					if data2.current.value == "use_outfit" then
						--if GetHashKey(data.current.value.model) == GetEntityModel(PlayerPedId()) then
							exports['fivem-appearance']:setPedComponents(PlayerPedId(), data.current.value.components)
							exports['fivem-appearance']:setPedProps(PlayerPedId(), data.current.value.props)
							--exports['fivem-appearance']:setPedHairAndDecorations(PlayerPedId(), data.current.value.hair, nil)
							--exports['fivem-appearance']:setPedHeadOverlays(PlayerPedId(), data.current.value.headOverlays)
							TriggerServerEvent('esx_skin:save', exports['fivem-appearance']:getPedAppearance(PlayerPedId()))
							ExecuteCommand("atuendos")
						--else
						--	TriggerEvent("chat:addMessage", { args = { "^1SISTEMA^3", 'el atuendo "^3' .. data.current.value.name .. '^0" no es para el modelo de PJ que tienes cargado.' } })
						--end
					else
						local elements, id, name = { { label = "Confirmar (¡IRREVERSIBLE!)", value = "del_confirm" }, { label = "Cancelar", value = "del_cancel" } }, data.current.value.id, data.current.value.name
						ESX.UI.Menu.Open('default', resName, 'karma_outfits3', {
							title    = '¿Seguro que quieres borrar el atuendo "' .. name .. '"?',
							align    = 'bottom-left',
							elements = elements
						}, function(data3, menu3)
							if data3.current.value == "del_confirm" then
								for k, v in ipairs(cache) do
									if v.id == id then
										table.remove(cache, k)
										TriggerServerEvent('deleteOutfit', id)
										TriggerEvent("chat:addMessage", { args = { "^1SISTEMA^3", 'el atuendo "^3' .. name .. '^0" fue ^1borrado ^2con éxito^0.' } })
										ExecuteCommand("atuendos")
										break
									end
								end
							else
								TriggerEvent("chat:addMessage", { args = { "^1SISTEMA^3", 'el atuendo "^3' .. name .. '^0" no se borró.' } })
							end
							ESX.UI.Menu.CloseAll()
						end, function(data, menu)
							menu.close()
						end)
					end
				end,
				function(data, menu)
					menu.close()
				end)
			end
		end,
		function(data, menu)
			menu.close()
		end)
	end)

end)
