local function getRgbColors()
	local colors = {
		hair = {},
		makeUp = {}
	}

	for i = 0, GetNumHairColors() do
		colors.hair[i+1] = {GetPedHairRgbColor(i)}
	end

	for i = 0, GetNumMakeupColors() do
		colors.makeUp[i+1] = {GetPedMakeupRgbColor(i)}
	end

	return colors
end

local playerAppearance

local function getAppearance()
	if not playerAppearance then
		playerAppearance = exports[resName]:getPedAppearance(PlayerPedId())
	end

	return playerAppearance
end
exports[resName]:getAppearance = getAppearance

local function getComponentSettings(ped, componentId)
	local drawableId = GetPedDrawableVariation(ped, componentId)
	return {
		component_id = componentId,
		drawable = {
			min = 0,
			max = GetNumberOfPedDrawableVariations(ped, componentId) - 1
		},
		texture = {
			min = 0,
			max = GetNumberOfPedTextureVariations(ped, componentId, drawableId) - 1
		}
	}
end
exports[resName]:getComponentSettings = getComponentSettings

local function getPropSettings(ped, propId)
	local drawableId = GetPedPropIndex(ped, propId)
	local settings = {
		prop_id = propId,
		drawable = {
			min = -1,
			max = GetNumberOfPedPropDrawableVariations(ped, propId) - 1
		},
		texture = {
			min = -1,
			max = GetNumberOfPedPropTextureVariations(ped, propId, drawableId) - 1
		}
	}
	return settings
end
exports[resName]:getPropSettings = getPropSettings

local function getAppearanceSettings()
	local playerPed = PlayerPedId()

	local ped = {
		model = {
			items = constants.PED_MODELS
		}
	}

	local components = {}
	for i = 1, #constants.PED_COMPONENTS_IDS do
		components[i] = getComponentSettings(playerPed, constants.PED_COMPONENTS_IDS[i])
	end

	local props = {}
	for i = 1, #constants.PED_PROPS_IDS do
		props[i] = getPropSettings(playerPed, constants.PED_PROPS_IDS[i])
	end

	local headBlend = {
		shapeFirst = {
			min = 0,
			max = 45
		},
		shapeSecond = {
			min = 0,
			max = 45
		},
		skinFirst = {
			min = 0,
			max = 45
		},
		skinSecond = {
			min = 0,
			max = 45
		},
		shapeMix = {
			min = 0,
			max = 0.99,
			factor = 0.01,
		},
		skinMix = {
			min = 0,
			max = 0.99,
			factor = 0.01,
		},
	}

	local size = #constants.FACE_FEATURES
	local faceFeatures = table.create(0, size)
	for i = 1, size do
		local feature = constants.FACE_FEATURES[i]
		faceFeatures[feature] = { min = -1, max = 0.99, factor = 0.01}
	end

	local colors = getRgbColors()

	local colorMap = {
		beard = colors.hair,
		eyebrows = colors.hair,
		chestHair = colors.hair,
		makeUp = colors.makeUp,
		blush = colors.makeUp,
		lipstick = colors.makeUp,
	}

	size = #constants.HEAD_OVERLAYS
	local headOverlays = table.create(0, size)

	for i = 1, size do
		local overlay = constants.HEAD_OVERLAYS[i]
		local settings = {
			style = {
				min = 0,
				max = GetPedHeadOverlayNum(i - 1) - 1
			},
			opacity = {
				min = 0,
				max = 0.99,
				factor = 0.01,
			}
		}

		if colorMap[overlay] then
			settings.color = {
				items = colorMap[overlay]
			}
		end

		headOverlays[overlay] = settings
	end

	local hair = {
		style = {
			min = 0,
			max = GetNumberOfPedDrawableVariations(playerPed, 2) - 1
		},
		color = {
			items = colors.hair,
		},
		highlight = {
			items = colors.hair
		}
	}

	local eyeColor = {
		min = 0,
		max = 32
	}

	return {
		ped = ped,
		components = components,
		props = props,
		headBlend = headBlend,
		faceFeatures = faceFeatures,
		headOverlays = headOverlays,
		hair = hair,
		eyeColor = eyeColor,
	}
end
exports[resName]:getAppearanceSettings = getAppearanceSettings

local config
function exports[resName]:getConfig() return config end

local isCameraInterpolating
local currentCamera
local cameraHandle
local function setCamera(key)
	if not isCameraInterpolating then
		if key ~= 'current' then
			currentCamera = key
		end

		local coords, point = table.unpack(constants.CAMERAS[currentCamera])
		local reverseFactor = reverseCamera and -1 or 1
		local playerPed = PlayerPedId()

		if cameraHandle then
			local camCoords = GetOffsetFromEntityInWorldCoords(playerPed, coords.x * reverseFactor, coords.y * reverseFactor, coords.z * reverseFactor)
			local camPoint = GetOffsetFromEntityInWorldCoords(playerPed, point.x, point.y, point.z)
			local tmpCamera = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', camCoords.x, camCoords.y, camCoords.z, 0.0, 0.0, 0.0, 50.0, false, 0)

			PointCamAtCoord(tmpCamera, camPoint.x, camPoint.y, camPoint.z)
			SetCamActiveWithInterp(tmpCamera, cameraHandle, 1000, 1, 1)

			isCameraInterpolating = true

			CreateThread(function()
				repeat Wait(500)
				until not IsCamInterpolating(cameraHandle) and IsCamActive(tmpCamera)
				DestroyCam(cameraHandle, false)
				cameraHandle = tmpCamera
				isCameraInterpolating = false
			end)
		else
			local camCoords = GetOffsetFromEntityInWorldCoords(playerPed, coords.x, coords.y, coords.z)
			local camPoint = GetOffsetFromEntityInWorldCoords(playerPed, point.x, point.y, point.z)
			cameraHandle = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', camCoords.x, camCoords.y, camCoords.z, 0.0, 0.0, 0.0, 50.0, false, 0)

			PointCamAtCoord(cameraHandle, camPoint.x, camPoint.y, camPoint.z)
			SetCamActive(cameraHandle, true)
		end
	end
end
exports[resName]:setCamera = setCamera

local reverseCamera
function exports[resName]:rotateCamera(direction)
	if not isCameraInterpolating then
		local coords, point = table.unpack(constants.CAMERAS[currentCamera])
		local offset = constants.OFFSETS[currentCamera]
		local sideFactor = direction == 'left' and 1 or -1
		local reverseFactor = reverseCamera and -1 or 1
		local playerPed = PlayerPedId()

		local camCoords = GetOffsetFromEntityInWorldCoords(
			playerPed,
			(coords.x + offset.x) * sideFactor * reverseFactor,
			(coords.y + offset.y) * reverseFactor,
			coords.z
		)

		local camPoint = GetOffsetFromEntityInWorldCoords(playerPed, point.x, point.y, point.z)
		local tmpCamera = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', camCoords.x, camCoords.y, camCoords.z, 0.0, 0.0, 0.0, 50.0, false, 0)

		PointCamAtCoord(tmpCamera, camPoint.x, camPoint.y, camPoint.z)
		SetCamActiveWithInterp(tmpCamera, cameraHandle, 1000, 1, 1)

		isCameraInterpolating = true

		CreateThread(function()
			repeat Wait(500)
			until not IsCamInterpolating(cameraHandle) and IsCamActive(tmpCamera)
			DestroyCam(cameraHandle, false)
			cameraHandle = tmpCamera
			isCameraInterpolating = false
		end)
	end
end

local playerCoords
local function pedTurnAround(ped)
	reverseCamera = not reverseCamera
	local sequenceTaskId = OpenSequenceTask()
	TaskGoStraightToCoord(0, playerCoords.x, playerCoords.y, playerCoords.z, 8.0, -1, GetEntityHeading(ped) - 180.0, 0.1)
	TaskStandStill(0, -1)
	CloseSequenceTask(sequenceTaskId)
	ClearPedTasks(ped)
	TaskPerformSequence(ped, sequenceTaskId)
	ClearSequenceTask(sequenceTaskId)
end
exports[resName]:pedTurnAround = pedTurnAround

local playerHeading
function exports[resName]:getHeading() return playerHeading end

local toggleRadar = GetConvarInt('fivem-appearance:radar', 1) == 1
local callback
function exports[resName]:startPlayerCustomization(cb, _config)
	local playerPed = PlayerPedId()
	playerAppearance = exports[resName]:getPedAppearance(playerPed)
	playerCoords = GetEntityCoords(playerPed, true)
	playerHeading = GetEntityHeading(playerPed)
	open = true

	callback = cb
	config = _config
	reverseCamera = false
	isCameraInterpolating = false

	setCamera('default')
	SetNuiFocus(true, true)
	SetNuiFocusKeepInput(false)
	RenderScriptCams(true, false, 0, true, true)
	SetEntityInvincible(playerPed, true)
	TaskStandStill(playerPed, -1)

	if toggleRadar then DisplayRadar(false) end

	SendNuiMessage(json.encode({
		type = 'appearance_display',
		payload = {}
	}))
end

function exports[resName]:exitPlayerCustomization(appearance)
	RenderScriptCams(false, false, 0, true, true)
	DestroyCam(cameraHandle, false)
	SetNuiFocus(false, false)

	if toggleRadar then DisplayRadar(true) end

	local playerPed = PlayerPedId()

	ClearPedTasksImmediately(playerPed)
	SetEntityInvincible(playerPed, false)

	SendNuiMessage(json.encode({
		type = 'appearance_hide',
		payload = {}
	}))

	if not appearance then
		exports[resName]:setPlayerAppearance(getAppearance())
	end

	if callback then
		callback(appearance)
	end

	callback = nil
	config = nil
	playerAppearance = nil
	playerCoords = nil
	cameraHandle = nil
	currentCamera = nil
	reverseCamera = nil
	isCameraInterpolating = nil
	open = false

end

AddEventHandler('onResourceStop', function(resource)
	if resource == resName then
		SetNuiFocus(false, false)
		SetNuiFocusKeepInput(false)
	end
end)

exports('startPlayerCustomization', exports[resName]:startPlayerCustomization)
