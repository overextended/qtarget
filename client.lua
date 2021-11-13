local screen   = {}

---------------------------------------
---Source: https://github.com/citizenfx/lua/blob/luaglm-dev/cfx/libs/scripts/examples/scripting_gta.lua
---Credits to gottfriedleibniz
local glm = require 'glm'

-- Cache common functions
local glm_rad = glm.rad
local glm_quatEuler = glm.quatEulerAngleZYX
local glm_rayPicking = glm.rayPicking

-- Cache direction vectors
local glm_up = glm.up()
local glm_forward = glm.forward()

local function ScreenPositionToCameraRay()
    local pos = GetFinalRenderedCamCoord()
    local rot = glm_rad(GetFinalRenderedCamRot(2))

    local q = glm_quatEuler(rot.z, rot.y, rot.x)
    return pos, glm_rayPicking(
        q * glm_forward,
        q * glm_up,
        glm_rad(screen.fov),
        screen.ratio,
        0.10000, -- GetFinalRenderedCamNearClip(),
        10000.0, -- GetFinalRenderedCamFarClip(),
        0, 0
    )
end
---------------------------------------

local playerPed

local function RaycastCamera(flag)
	local rayPos, rayDir = ScreenPositionToCameraRay()
	local destination = rayPos + 10000 * rayDir
	local rayHandle = StartShapeTestLosProbe(rayPos.x, rayPos.y, rayPos.z, destination.x, destination.y, destination.z, flag or -1, playerPed or PlayerPedId(), 0)
	while true do
		Wait(0)
		local result, hit, endCoords, _, entityHit = GetShapeTestResult(rayHandle)
		-- todo: add support for materialHash
		if result ~= 1 then
			return flag, endCoords, entityHit, entityHit and GetEntityType(entityHit) or 0
		end
	end
end
exports('raycast', RaycastCamera)

local hasFocus = false

local function DisableNUI()
	SetNuiFocus(false, false)
	SetNuiFocusKeepInput(false)
	hasFocus = false
end

local function EnableNUI()
	if targetActive and not hasFocus then
		SetCursorLocation(0.5, 0.5)
		SetNuiFocus(true, true)
		SetNuiFocusKeepInput(true)
		hasFocus = true
	end
end

local success  = false
local sendData = {}

local function LeaveTarget()
	table.wipe(sendData)
	success = false
	SendNUIMessage({response = 'leftTarget'})
end

local function CheckEntity(hit, data, entity, distance)
	local sendDistance = {}
	if next(data) then
		local nuiData
		local slot = 0
		for _, data in pairs(data) do
			if CheckOptions(data, entity, distance) then
				if not nuiData then nuiData = {} end
				slot += 1
				sendData[slot] = data
				sendData[slot].entity = entity
				nuiData[slot] = {
					icon = data.icon,
					label = data.label
				}
				sendDistance[data.distance] = true
			else sendDistance[data.distance] = false end
		end
		if nuiData then
			success = true
			SendNUIMessage({response = 'validTarget', data = nuiData})
			while targetActive do
				local playerCoords = GetEntityCoords(playerPed)
				local _, coords, entity2 = RaycastCamera(hit)
				distance = #(playerCoords - coords)
				if entity ~= entity2 then
					if hasFocus then DisableNUI() end
					break
				elseif not hasFocus and IsDisabledControlPressed(0, 24) then
					EnableNUI()
				else
					for k, v in pairs(sendDistance) do
						if (v == false and distance < k) or (v == true and distance > k) then
							return CheckEntity(hit, data, entity, distance)
						end
					end
				end
				Wait(20)
			end
		end
		LeaveTarget()
	end
end

local Bones = Load('client/bones')
local function CheckBones(coords, entity, bonelist)
	local closestBone = -1
	local closestDistance = 20
	local closestPos, closestBoneName
	for _, v in pairs(bonelist) do
		local coords = coords
		if Bones[v] then
			local boneId = GetEntityBoneIndexByName(entity, v)
			local bonePos = GetWorldPositionOfEntityBone(entity, boneId)
			local distance = #(coords - bonePos)
			if closestBone == -1 or distance < closestDistance then
				closestBone, closestDistance, closestPos, closestBoneName = boneId, distance, bonePos, v
			end
		end
	end
	if closestBone ~= -1 then return closestBone, closestPos, closestBoneName
	else return false end
end

local Types    = {{}, {}, {}}
local Players  = {}
local Entities = {}
local Models   = {}
local Zones    = {}

local function EnableTarget()
	if success or not IsControlEnabled(0, 24) then return end
	if not targetActive then
		targetActive = true
		SendNUIMessage({response = 'openTarget'})

		CreateThread(function()
			local playerId = PlayerId()
			repeat
				if hasFocus then
					DisableControlAction(0, 1, true)
					DisableControlAction(0, 2, true)
				end
				DisablePlayerFiring(playerId, true)
				DisableControlAction(0, 25, true)
				DisableControlAction(0, 37, true)
				Wait(0)
			until targetActive == false
		end)

		playerPed = PlayerPedId()
		screen.ratio = GetAspectRatio(true)
		screen.fov = GetFinalRenderedCamFov()
		local curFlag = 30

		while targetActive do
			local sleep = 0
			local playerCoords = GetEntityCoords(playerPed)
			local hit, coords, entity, entityType = RaycastCamera(curFlag)
			if curFlag == 30 then curFlag = -1 else curFlag = 30 end

			if entityType > 0 then

				-- Owned entity targets
				if NetworkGetEntityIsNetworked(entity) then
					local data = Entities[NetworkGetNetworkIdFromEntity(entity)]
					if data then
						CheckEntity(hit, data, entity, #(playerCoords - coords))
					end
				end

				-- Player targets
				if entityType == 1 and IsPedAPlayer(entity) then
					CheckEntity(hit, Players, entity, #(playerCoords - coords))

				-- Vehicle bones
				elseif entityType == 2 and #(playerCoords - coords) <= 1.1 then
					local closestBone, closestPos, closestBoneName = CheckBones(coords, entity, Bones.Vehicle)
					local data = Bones[closestBoneName]
					if next(data) then
						if closestBone and #(coords - closestPos) <= data.distance then
							local nuiData
							local slot = 0
							for _, data in pairs(data.options) do
								if CheckOptions(data, entity) then
									if not nuiData then nuiData = {} end
									slot += 1
									sendData[slot] = data
									sendData[slot].entity = entity
									nuiData[slot] = {
										icon = data.icon,
										label = data.label
									}
								end
							end
							if nuiData then
								success = true
								SendNUIMessage({response = 'validTarget', data = nuiData})

								while targetActive do
									playerCoords = GetEntityCoords(playerPed)
									local _, coords, entity2 = RaycastCamera(hit)
									if hit and entity == entity2 then
										local closestBone2, closestPos2 = CheckBones(coords, entity, Bones.Vehicle)

										if closestBone ~= closestBone2 or #(coords - closestPos2) > data.distance or #(playerCoords - coords) > 1.1 then
											if hasFocus then DisableNUI() end
											break
										elseif not hasFocus and IsDisabledControlPressed(0, 24) then EnableNUI() end
									else
										if hasFocus then DisableNUI() end
										break
									end
									Wait(20)
								end
							end
						end
					end

				-- Entity targets
				else
					local data = Models[GetEntityModel(entity)]
					if data then CheckEntity(hit, data, entity, #(playerCoords - coords)) end
				end

				-- Generic targets
				if not success then
					local data = Types[entityType]
					if data then CheckEntity(hit, data, entity, #(playerCoords - coords)) end
				end
			else sleep += 20 end
			if not success then
				-- Zone targets
				for _,zone in pairs(Zones) do
					local distance = #(playerCoords - coords)
					if zone:isPointInside(coords) and distance <= zone.targetoptions.distance then
						local nuiData
						local slot = 0
						for _, data in pairs(zone.targetoptions.options) do
							if CheckOptions(data, entity, distance) then
								if not nuiData then nuiData = {} end
								slot += 1
								sendData[slot] = data
								sendData[slot].entity = entity
								nuiData[slot] = {
									icon = data.icon,
									label = data.label
								}
							end
						end
						if nuiData then
							success = true
							SendNUIMessage({response = 'validTarget', data = nuiData})
							while targetActive do
								playerCoords = GetEntityCoords(playerPed)
								_, coords = RaycastCamera(hit)
								if not zone:isPointInside(coords) or #(playerCoords - coords) > zone.targetoptions.distance then
									if hasFocus then DisableNUI() end
									break
								elseif not hasFocus and IsDisabledControlPressed(0, 24) then
									EnableNUI()
								end
								Wait(20)
							end
							LeaveTarget()
						else
							repeat
								Wait(20)
								_, coords, entity2 = RaycastCamera(hit)
							until not targetActive or entity ~= entity2 or not zone:isPointInside(coords)
							break
						end
					end
				end
			else LeaveTarget() end
			Wait(sleep)
		end
		hasFocus = false
		SendNUIMessage({response = 'closeTarget'})
	end
end

local function DisableTarget()
	if targetActive then
		SetNuiFocus(false, false)
		SetNuiFocusKeepInput(false)
		targetActive = false
	end
end

RegisterNUICallback('selectTarget', function(option)
	hasFocus = false
	local data = sendData[option]
	CreateThread(function()
		Wait(0)
		if data.action ~= nil then
			data.action(data.entity)
		else
			TriggerEvent(data.event, data)
		end
	end)

end)

RegisterNUICallback('closeTarget', function(data, cb)
	hasFocus = false
end)

RegisterKeyMapping('+playerTarget', 'Enable targeting~', 'keyboard', 'LMENU')
RegisterCommand('+playerTarget', EnableTarget, false)
RegisterCommand('-playerTarget', DisableTarget, false)
TriggerEvent('chat:removeSuggestion', '/+playerTarget')
TriggerEvent('chat:removeSuggestion', '/-playerTarget')

--Exports
local function AddCircleZone(name, center, radius, options, targetoptions)
	Zones[name] = CircleZone:Create(center, radius, options)
	Zones[name].targetoptions = targetoptions
end
exports('AddCircleZone', AddCircleZone)

local function AddBoxZone(name, center, length, width, options, targetoptions)
	Zones[name] = BoxZone:Create(center, length, width, options)
	Zones[name].targetoptions = targetoptions
end
exports('AddBoxZone', AddBoxZone)

local function AddPolyzone(name, points, options, targetoptions)
	Zones[name] = PolyZone:Create(points, options)
	Zones[name].targetoptions = targetoptions
end
exports('AddPolyzone', AddPolyzone)

local function AddTargetBone(bones, parameters)
	for _, bone in pairs(bones) do
		Bones[bone] = parameters
	end
end
exports('AddTargetBone', AddTargetBone)

local function AddTargetEntity(entity, parameters)
	entity = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity) or false
	if entity then
		local distance, options = parameters.distance or Config.MaxDistance, parameters.options
		if not Entities[entity] then Entities[entity] = {} end
		for k, v in pairs(options) do
			if not v.distance or v.distance > distance then v.distance = distance end
			Entities[entity][v.label] = v
		end
	end
end
exports('AddTargetEntity', AddTargetEntity)

local function AddEntityZone(name, entity, options, targetoptions)
	Zones[name] = EntityZone:Create(entity, options)
	Zones[name].targetoptions = targetoptions
end
exports('AddEntityZone', AddEntityZone)

local function AddTargetModel(models, parameters)
	local distance, options = parameters.distance or Config.MaxDistance, parameters.options
	for _, model in pairs(models) do
		if type(model) == 'string' then model = GetHashKey(model) end
		if not Models[model] then Models[model] = {} end
		for k, v in pairs(options) do
			if not v.distance or v.distance > distance then v.distance = distance end
			Models[model][v.label] = v
		end
	end
end
exports('AddTargetModel', AddTargetModel)

local function RemoveZone(name)
	if not Zones[name] then return end
	if Zones[name].destroy then
		Zones[name]:destroy()
	end
	Zones[name] = nil
end
exports('RemoveZone', RemoveZone)

local function RemoveTargetModel(models, labels)
	for _, model in pairs(models) do
		if type(model) == 'string' then model = GetHashKey(model) end
		for k, v in pairs(labels) do
			if Models[model] then
				Models[model][v] = nil
			end
		end
	end
end
exports('RemoveTargetModel', RemoveTargetModel)

local function RemoveTargetEntity(entity, labels)
	entity = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity) or false
	if entity then
		for _, v in pairs(labels) do
			if Entities[entity] then
				Entities[entity][v] = nil
			end
		end
	end
end
exports('RemoveTargetEntity', RemoveTargetEntity)

local function AddType(type, parameters)
	local distance, options = parameters.distance or Config.MaxDistance, parameters.options
	for _, v in pairs(options) do
		if not v.distance or v.distance > distance then v.distance = distance end
		Types[type][v.label] = v
	end
end

local function AddPed(parameters) AddType(1, parameters) end
exports('Ped', AddPed)

local function AddVehicle(parameters) AddType(2, parameters) end
exports('Vehicle', AddVehicle)

local function AddObject(parameters) AddType(3, parameters) end
exports('Object', AddObject)

local function AddPlayer(parameters)
	local distance, options = parameters.distance or Config.MaxDistance, parameters.options
	for _, v in pairs(options) do
		if not v.distance or v.distance > distance then v.distance = distance end
		Players[v.label] = v
	end
end
exports('Player', AddPlayer)

local function RemoveType(type, labels)
	for _, v in pairs(labels) do
		Types[type][v] = nil
	end
end

local function RemovePed(labels) RemoveType(1, labels) end
exports('RemovePed', RemovePed)

local function RemoveVehicle(labels) RemoveType(2, labels) end
exports('RemoveVehicle', RemoveVehicle)

local function RemoveObject(labels) RemoveType(3, labels) end
exports('RemoveObject', RemoveObject)

local function RemovePlayer(labels)
	for k, v in pairs(labels) do
		Players[v] = nil
	end
end
exports('RemovePlayer', RemovePlayer)

if Config.Debug then
	AddEventHandler('qtarget:debug', function(data)
		print( 'Entity: '..data.entity..'', 'Type: '..GetEntityType(data.entity)..'' )
		if data.remove then
			RemoveTargetEntity(data.entity, {
				'HelloWorld'
			})
		else
			AddTargetEntity(data.entity, {
				options = {
					{
						event = 'qtarget:debug',
						icon = 'fas fa-box-circle-check',
						label = 'HelloWorld',
						remove = true
					},
				},
				distance = 3.0
			})
		end

	end)

	AddPed({
		options = {
			{
				event = 'qtarget:debug',
				icon = 'fas fa-male',
				label = '(Debug) Ped',
			},
		},
		distance = Config.MaxDistance
	})

	AddVehicle({
		options = {
			{
				event = 'qtarget:debug',
				icon = 'fas fa-car',
				label = '(Debug) Vehicle',
			},
		},
		distance = Config.MaxDistance
	})

	AddObject({
		options = {
			{
				event = 'qtarget:debug',
				icon = 'fas fa-cube',
				label = '(Debug) Object',
			},
		},
		distance = Config.MaxDistance
	})

	AddPlayer({
		options = {
			{
				event = 'qtarget:debug',
				icon = 'fas fa-cube',
				label = '(Debug) Player',
			},
		},
		distance = Config.MaxDistance
	})

end