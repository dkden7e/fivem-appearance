local client = client

RegisterNUICallback('appearance_get_locales', function(_, cb)
	local locales = LoadResourceFile(resName, ('locales/%s.json'):format(GetConvar('fivem-appearance:locale', 'en')))
	cb(locales)
end)

RegisterNUICallback('appearance_get_settings_and_data', function(_, cb)
	cb({ exports[resName]:getConfig(), exports[resName]:getAppearance(), exports[resName]:getAppearanceSettings() })
end)

RegisterNUICallback('appearance_set_camera', function(camera, cb)
	cb(1)
	exports[resName]:setCamera(camera)
end)

RegisterNUICallback('appearance_turn_around', function(_, cb)
	cb(1)
	exports[resName]:pedTurnAround(PlayerPedId())
end)

RegisterNUICallback('appearance_rotate_camera', function(direction, cb)
	cb(1)
	exports[resName]:rotateCamera(direction)
end)

RegisterNUICallback('appearance_change_model', function(model, cb)
	local playerPed = exports[resName]:setPlayerModel(model)

	SetEntityHeading(PlayerPedId(), exports[resName]:getHeading())
	SetEntityInvincible(playerPed, true)
	TaskStandStill(playerPed, -1)

	cb({ exports[resName]:getAppearanceSettings(), exports[resName]:getPedAppearance(playerPed) })
end)

RegisterNUICallback('appearance_change_component', function(component, cb)
	local playerPed = PlayerPedId()
	exports[resName]:setPedComponent(playerPed, component)
	cb(exports[resName]:getComponentSettings(playerPed, component.component_id))
end)

RegisterNUICallback('appearance_change_prop', function(prop, cb)
	local playerPed = PlayerPedId()
	exports[resName]:setPedProp(playerPed, prop)
	cb(exports[resName]:getPropSettings(playerPed, prop.prop_id))
end)

RegisterNUICallback('appearance_change_head_blend', function(headBlend, cb)
	cb(1)
	exports[resName]:setPedHeadBlend(PlayerPedId(), headBlend)
end)

RegisterNUICallback('appearance_change_face_feature', function(faceFeatures, cb)
	cb(1)
	exports[resName]:setPedFaceFeatures(PlayerPedId(), faceFeatures)
end)

RegisterNUICallback('appearance_change_head_overlay', function(headOverlays, cb)
	cb(1)
	exports[resName]:setPedHeadOverlays(PlayerPedId(), headOverlays)
end)

RegisterNUICallback('appearance_change_hair', function(hair, cb)
	cb(1)
	exports[resName]:setPedHairAndDecorations(PlayerPedId(), hair, nil)
end)

RegisterNUICallback('appearance_change_eye_color', function(eyeColor, cb)
	cb(1)
	exports[resName]:setPedEyeColor(PlayerPedId(), eyeColor)
end)

RegisterNUICallback('appearance_save', function(appearance, cb)
	cb(1)
	exports[resName]:exitPlayerCustomization(appearance)
end)

RegisterNUICallback('appearance_exit', function(_, cb)
	cb(1)
	exports[resName]:exitPlayerCustomization()
end)
