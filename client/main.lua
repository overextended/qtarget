local Config, Players, Types, Entities, Models, Zones, Bones, ItemCount = load(LoadResourceFile(GetCurrentResourceName(), 'config.lua'))()
local hasFocus, success, sendData = false, false

local RaycastCamera = function(flag)
	local cam = GetGameplayCamCoord()
	local direction = GetGameplayCamRot()
	direction = vector2(direction.x * math.pi / 180.0, direction.z * math.pi / 180.0)
	local num = math.abs(math.cos(direction.x))
	direction = vector3((-math.sin(direction.y) * num), (math.cos(direction.y) * num), math.sin(direction.x))
	local destination = vector3(cam.x + direction.x * 30, cam.y + direction.y * 30, cam.z + direction.z * 30)
	local rayHandle, result, hit, endCoords, surfaceNormal, entityHit = StartShapeTestLosProbe(cam, destination, flag or -1, ESX.PlayerData.ped, 0)
	repeat
		result, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
		Citizen.Wait(0)
	until result ~= 1
	local entityType = GetEntityType(entityHit)
	if hit == 0 or entityType == 0 then
		rayHandle = StartShapeTestLosProbe(cam, destination, 30, ESX.PlayerData.ped, 0)
		repeat
			result, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
			Citizen.Wait(0)
		until result ~= 1
		if hit == 0 then Citizen.Wait(20) else entityType = GetEntityType(entityHit) end
		return hit, endCoords, entityHit, entityType
	else
		return hit, endCoords, entityHit, entityType
	end
end
exports("raycast", RaycastCamera)

local DisableNUI = function()
	SetNuiFocus(false, false)
	SetNuiFocusKeepInput(false)
	hasFocus = false
end 

local EnableNUI = function()
	if targetActive and not hasFocus then 
		SetCursorLocation(0.5, 0.5)
		SetNuiFocus(true, true)
		SetNuiFocusKeepInput(true)
		hasFocus = true
	end
end

local CheckOptions = function(data, entity, distance)
	if (data.distance == nil or distance <= data.distance)
	and (data.owner == nil or data.owner == NetworkGetNetworkIdFromEntity(ESX.PlayerData.ped))
	and (data.job == nil or data.job == ESX.PlayerData.job.name or (data.job[ESX.PlayerData.job.name] and data.job[ESX.PlayerData.job.name] <= ESX.PlayerData.job.grade))
	and (data.required_item == nil or data.required_item and ItemCount(data.required_item) > 0)
	and (data.canInteract == nil or data.canInteract(entity)) then return true
	else return false end
end

local CheckRange = function(range, distance)
	for k, v in pairs(range) do
		if v == false and distance < k then return true
		elseif v == true and distance > k then return true end
	end
	return false
end

CheckEntity = function(data, entity, distance)
	local send_options = {}
	local send_distance = {}
	for o, data in pairs(data) do
		if CheckOptions(data, entity, distance) then
			local slot = #send_options + 1 
			send_options[slot] = data
			send_options[slot].entity = entity
			send_distance[data.distance] = true
		else send_distance[data.distance] = false end
	end
	if next(send_options) then
		sendData = send_options
		success = true
		SendNUIMessage({response = "validTarget", data = send_options})
		while targetActive do
			local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
			local hit, coords, entity2 = RaycastCamera()
			local distance = #(playerCoords - coords)
			if entity ~= entity2 then 
				if hasFocus then DisableNUI() end
				break
			elseif not hasFocus and IsDisabledControlPressed(0, 24) then
				EnableNUI()
			elseif CheckRange(send_distance, distance) then
				CheckEntity(data, entity, distance)
			end
			Citizen.Wait(5)
		end
		success = false
		SendNUIMessage({response = "leftTarget"})
	end
end

local CheckBones = function(coords, entity, min, max, bonelist)
	local closestBone, closestDistance, closestPos, closestBoneName = -1, 20
	for k, v in pairs(bonelist) do
		local coords = coords
		if Bones[v] then
			local boneId = GetEntityBoneIndexByName(entity, v)
			local bonePos = GetWorldPositionOfEntityBone(entity, boneId)
			if v:find('bonnet') then
				local offset = GetOffsetFromEntityInWorldCoords(entity, 0, (max.y-min.y), 0)
				local y = coords.y + (coords.y - offset.y) / 3
				coords = vector3(coords.x, y, coords.z+0.1)
			else
				local offset = GetOffsetFromEntityInWorldCoords(entity, 0, (max.y-min.y), 0)
				local y = coords.y - (coords.y - offset.y) / 10
				coords = vector3(coords.x, y, coords.z)
			end

			local distance = #(coords - bonePos)
			if closestBone == -1 or distance < closestDistance then
				closestBone, closestDistance, closestPos, closestBoneName = boneId, distance, bonePos, v
			end
		end
	end
	if closestBone ~= -1 then return closestBone, closestPos, closestBoneName
	else return false end
end

function EnableTarget()
	if success or not IsControlEnabled(0, 24) then return end
	if not targetActive then 
		targetActive = true
		SendNUIMessage({response = "openTarget"})
		
		SetInterval(1, 5, function()
			if hasFocus then
				DisableControlAction(0, 1, true)
				DisableControlAction(0, 2, true)
			end
			DisablePlayerFiring(PlayerId(), true)
			DisableControlAction(0, 25, true)
			DisableControlAction(0, 47, true)
			DisableControlAction(0, 58, true)
			DisableControlAction(0, 140, true)
			DisableControlAction(0, 141, true)
			DisableControlAction(0, 142, true)
			DisableControlAction(0, 143, true)
			DisableControlAction(0, 263, true)
			DisableControlAction(0, 264, true)
			DisableControlAction(0, 257, true)
		end)

		while targetActive do
			local sleep = 10
			local plyCoords = GetEntityCoords(ESX.PlayerData.ped)
			local hit, coords, entity, entityType = RaycastCamera()
			if hit == 1 then
				if entityType > 0 then

					-- Owned entity targets
					if NetworkGetEntityIsNetworked(entity) then 
						local data = Entities[NetworkGetNetworkIdFromEntity(entity)]
						if data and #(plyCoords - coords) <= data.distance then
							CheckEntity(entity, data)
						end
					end
					

					-- Player targets
					if entityType == 1 and IsPedAPlayer(entity) then
						CheckEntity(Players, entity, #(plyCoords - coords))

					-- Vehicle bones
					elseif entityType == 2 and #(plyCoords - coords) <= 1.8 then
						local min, max = GetModelDimensions(GetEntityModel(entity))
						local closestBone, closestPos, closestBoneName = CheckBones(coords, entity, min, max, Config.VehicleBones)
						if closestBone and #(coords - closestPos) <= 1.8 then
							local data = Bones[closestBoneName]
							local send_options = {}
							for o, data in pairs(data.options) do
								if CheckOptions(data, entity) then 
									local slot = #send_options + 1 
									send_options[slot] = data
									send_options[slot].entity = entity
								end
							end
							if #send_options > 0 then
								sendData = send_options
								success = true
								SendNUIMessage({response = "validTarget", data = send_options})
								while targetActive do
									local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
									local hit, coords, entity2 = RaycastCamera()
									if hit and entity == entity2 then
										local closestBone2, closestPos2, closestBoneName2 = CheckBones(coords, entity, min, max, Config.VehicleBones)
									
										if closestBone ~= closestBone2 or #(coords - closestPos2) > 1.8 or #(playerCoords - coords) > 1.8 then
											if hasFocus then DisableNUI() end
											break
										elseif not hasFocus and IsDisabledControlPressed(0, 24) then EnableNUI() end
									else
										if hasFocus then DisableNUI() end
										break
									end
									Citizen.Wait(5)
								end
							end
						end

					-- Entity targets
					else
						local data = Models[GetEntityModel(entity)]
						if data then CheckEntity(data, entity, #(plyCoords - coords)) end
					end
				end
				if not success then
					-- Generic targets
					local data = Types[entityType]
					if data then CheckEntity(data, entity, #(plyCoords - coords)) end

					-- Zone targets
					for _,zone in pairs(Zones) do
						local distance = #(plyCoords - zone.center)
						if zone:isPointInside(coords) and distance <= zone.targetoptions.distance then
							local send_options = {}
							for o, data in pairs(zone.targetoptions.options) do
								if CheckOptions(data, entity, distance) then
									local slot = #send_options + 1 
									send_options[slot] = data
									send_options[slot].entity = entity
								end
							end
							if #send_options > 0 then
								sendData = send_options
								SendNUIMessage({response = "validTarget", data = send_options})
								while targetActive do
									local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
									local hit, coords, entity2 = RaycastCamera()
									if not zone:isPointInside(coords) or #(playerCoords - zone.center) > zone.targetoptions.distance then 
										if hasFocus then DisableNUI() end
										break
									elseif not hasFocus and IsDisabledControlPressed(0, 24) then
										EnableNUI()
									end
								end
								success = false
								SendNUIMessage({response = "leftTarget"})
							else
								repeat
									Citizen.Wait(50)
									local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
									local hit, coords, entity2 = RaycastCamera()
								until not targetActive or entity ~= entity2 or not zone:isPointInside(coords)
								break
							end
						end 
					end
				else success = false SendNUIMessage({response = "leftTarget"}) end
			else sleep = sleep + 10 end
			Citizen.Wait(sleep)
		end
		hasFocus, success = false, false
		ClearInterval(1)
		SendNUIMessage({response = "closeTarget"})
	end
end

function DisableTarget()
	if targetActive then
		SetNuiFocus(false, false)
		SetNuiFocusKeepInput(false)
		targetActive = false
	end
end

RegisterNUICallback('selectTarget', function(data, cb)
	hasFocus = false
	for k,v in pairs(sendData) do
		if data.event == v.event then
			Citizen.CreateThread(function()
				Citizen.Wait(50)
				TriggerEvent(data.event, data)
			end)
		end
	end
	sendData = nil
end)

RegisterNUICallback('closeTarget', function(data, cb)
	success = false
	hasFocus = false
end)

RegisterKeyMapping("+playerTarget", "[qtarget] Enable targeting~", "keyboard", "LMENU")
RegisterCommand('+playerTarget', EnableTarget, false)
RegisterCommand('-playerTarget', DisableTarget, false)
TriggerEvent("chat:removeSuggestion", "/+playerTarget")
TriggerEvent("chat:removeSuggestion", "/-playerTarget")

--Exports
local AddCircleZone = function(name, center, radius, options, targetoptions)
	Zones[name] = CircleZone:Create(center, radius, options)
	Zones[name].targetoptions = targetoptions
end

local AddBoxZone = function(name, center, length, width, options, targetoptions)
	Zones[name] = BoxZone:Create(center, length, width, options)
	Zones[name].targetoptions = targetoptions
end

local AddPolyzone = function(name, points, options, targetoptions)
	Zones[name] = PolyZone:Create(points, options)
	Zones[name].targetoptions = targetoptions
end

local AddTargetEntity = function(entity, parameters)
	Entities[entity] = parameters
end

local AddTargetBone = function(bones, parameters)
	for _, bone in pairs(bones) do
		Bones[bone] = parameters
	end
end

local AddEntityZone = function(name, entity, options, targetoptions)
	Zones[name] = EntityZone:Create(entity, options)
	Zones[name].targetoptions = targetoptions
end

local AddTargetModel = function(models, parameters)
	local distance, options = parameters.distance or 2, parameters.options
	for _, model in pairs(models) do
		if type(model) == 'string' then model = GetHashKey(model) end
		if not Models[model] then Models[model] = {} end
		for k, v in pairs(options) do
			if not v.distance then v.distance = distance end
			Models[model][v.event] = v
		end
	end
end

exports("AddCircleZone", AddCircleZone)
exports("AddBoxZone", AddBoxZone)
exports("AddPolyzone", AddPolyzone)
exports("AddTargetModel", AddTargetModel)
exports("AddTargetEntity", AddTargetEntity)
exports("AddTargetBone", AddTargetBone)
exports("AddEntityZone", AddEntityZone)
exports("AddTargetModel", AddTargetModel)

local RemoveZone = function(name)
	if not Zones[name] then return end
	if Zones[name].destroy then
		Zones[name]:destroy()
	end
	Zones[name] = nil
end

local RemoveTargetModel = function(models, events)
	for _, model in pairs(models) do
		if type(model) == 'string' then model = GetHashKey(model) end
		for k, v in pairs(events) do
			if Models[model] then
				Models[model][v] = nil
			end
		end
	end
end

exports("RemoveTargetModel", RemoveTargetModel)
exports("RemoveZone", RemoveZone)

local AddType = function(type, parameters)
	local distance, options = parameters.distance or 2, parameters.options
	for k, v in pairs(options) do
		if not v.distance then v.distance = distance end
		Types[type][v.event] = v
	end
end

local RemoveType = function(type, events)
	for k, v in pairs(events) do
		Types[type][v] = nil
	end
end

local RemovePlayer = function(type, events)
	for k, v in pairs(events) do
		Players[v.event] = nil
	end
end

local AddPlayer = function(parameters)
	local distance, options = parameters.distance or 2, parameters.options
	for k, v in pairs(options) do
		if not v.distance then v.distance = distance end
		Players[v.event] = v
	end
end

local AddPed = function(parameters) AddType(1, parameters) end
local AddVehicle = function(parameters) AddType(2, parameters) end
local AddObject = function(parameters) AddType(3, parameters) end
local AddPlayer = function(parameters) AddPlayer(parameters) end
exports("Ped", AddPed)
exports("Vehicle", AddVehicle)
exports("Object", AddObject)
exports("Player", AddPlayer)

local RemovePed = function(events) RemoveType(1, events) end
local RemoveVehicle = function(events) RemoveType(2, events) end
local RemoveObject = function(events) RemoveType(3, events) end
local RemovePlayer = function(events) RemoveType(1, events) end
exports("RemovePed", RemovePed)
exports("RemoveVehicle", RemoveVehicle)
exports("RemoveObject", RemoveObject)
exports("RemovePlayer", RemovePlayer)
