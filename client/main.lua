local hasFocus, success = false, false
local sendData = nil
local Entities, Models, Zones, Bones = {}, {}, {}, {}, {}, {}

local ItemCount = function(item)
	if Config.LindenInventory then return exports['linden_inventory']:CountItems(item)[item]
	else
		for k, v in pairs(ESX.GetPlayerData().inventory) do
			if v.name == item then
				return v.count
			end
		end
	end
	return 0
end

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
	if hit == 0 then Citizen.Wait(20) end
	return hit, endCoords, entityHit
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

local CheckOptions = function(data)
	if (not data.owner or data.owner == NetworkGetNetworkIdFromEntity(ESX.PlayerData.ped))
	and (not data.job or data.job == ESX.PlayerData.job.name or (data.job[ESX.PlayerData.job.name] and data.job[ESX.PlayerData.job.name] <= ESX.PlayerData.job.grade))
	and (not data.required_item or data.required_item and ItemCount(data.required_item) > 0)
	and (data.canInteract == nil or data.canInteract()) then return true
	else return false end
end

local CheckEntity = function(entity, data, action)
	local send_options = {}
	for o, data in pairs(data.options) do
		if CheckOptions(data) then 
			local slot = #send_options + 1 
			send_options[slot] = data
			send_options[slot].entity = entity
		end
	end
	if #send_options > 0 then
		sendData = send_options
		success = true
		SendNUIMessage({response = "validTarget", data = send_options})
		action()
		success = false
		SendNUIMessage({response = "leftTarget"})
	else
		repeat
			Citizen.Wait(50)
			local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
			local hit, coords, entity2 = RaycastCamera(30)
		until entity ~= entity2 or #(playerCoords - coords) > data.distance
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
			local plyCoords = GetEntityCoords(ESX.PlayerData.ped)
			local hit, coords, entity = RaycastCamera(30)
			if hit then
				local entityType = GetEntityType(entity)
				if entityType > 0 then

					-- Owned entity targets
					if NetworkGetEntityIsNetworked(entity) then 
						local data = Entities[NetworkGetNetworkIdFromEntity(entity)]
						if data and #(plyCoords - coords) <= data.distance then
							CheckEntity(entity, data, function()
								while targetActive do
									local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
									local hit, coords, entity2 = RaycastCamera(30)
									if entity ~= entity2 or #(playerCoords - coords) > data.distance then 
										if hasFocus then DisableNUI() end
										break
									elseif not hasFocus and IsDisabledControlPressed(0, 24) then
										EnableNUI()
									end
								end
							end)
						end
					end
					
					if entityType == 1 then
						-- Player targets
						if IsPedAPlayer(entity) and next(Players) then
							if data and #(plyCoords - coords) <= data.distance then
								CheckEntity(entity, data, function()
									while targetActive do
										local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
										local hit, coords, entity2 = RaycastCamera(30)
										if entity ~= entity2 or #(playerCoords - coords) > data.distance then 
											if hasFocus then DisableNUI() end
											break
										elseif not hasFocus and IsDisabledControlPressed(0, 24) then
											EnableNUI()
										end
									end
								end)
							end
						else

							-- NPC targets
							local data = Models[GetEntityModel(entity)]
							if data and #(plyCoords - coords) <= data.distance then
								CheckEntity(entity, data, function()
									while targetActive do
										local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
										local hit, coords, entity2 = RaycastCamera(30)
										if entity ~= entity2 or #(playerCoords - coords) > data.distance then 
											if hasFocus then DisableNUI() end
											break
										elseif not hasFocus and IsDisabledControlPressed(0, 24) then
											EnableNUI()
										end
									end
								end)
							end
						end

					-- Vehicle bones
					elseif entityType == 2 then
						if #(plyCoords - coords) <= 1.8 then
							local min, max = GetModelDimensions(GetEntityModel(entity))
							local closestBone, closestPos, closestBoneName = CheckBones(coords, entity, min, max, Config.VehicleBones)
							if closestBone and #(coords - closestPos) <= 1.8 then
								local data = Bones[closestBoneName]
								local send_options = {}
								for o, data in pairs(data.options) do
									if CheckOptions(data) then 
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
										local hit, coords, entity2 = RaycastCamera(30)
										if hit and entity == entity2 then
											local closestBone2, closestPos2, closestBoneName2 = CheckBones(coords, entity, min, max, Config.VehicleBones)
										
											if closestBone ~= closestBone2 or #(coords - closestPos2) > 1.8 or #(playerCoords - closestPos2) > 1.8 then
												if hasFocus then DisableNUI() end
												break
											elseif not hasFocus and IsDisabledControlPressed(0, 24) then EnableNUI() end
										else
											if hasFocus then DisableNUI() end
											break
										end
									end
								end
							end
						end

						-- Vehicle targets
						local data = Models[GetEntityModel(entity)]
						if data and #(plyCoords - coords) <= data.distance then
							-- todo: setup vehicle stuff
						end

					-- Object targets
					else
						local data = Models[GetEntityModel(entity)]
						if data and #(plyCoords - coords) <= data.distance then
							CheckEntity(entity, data, function()
								while targetActive do
									local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
									local hit, coords, entity2 = RaycastCamera(30)
									if entity ~= entity2 or #(playerCoords - coords) > data.distance then 
										if hasFocus then DisableNUI() end
										break
									elseif not hasFocus and IsDisabledControlPressed(0, 24) then
										EnableNUI()
									end
								end
							end)
						end
					end
				end
				if not success then 
					local hit, coords, entity = RaycastCamera(-1)
					if hit then
						-- Zone targets
						for _,zone in pairs(Zones) do
							if zone:isPointInside(coords) and #(plyCoords - zone.center) <= zone.targetoptions.distance then 
								local options = zone.targetoptions.options
								local send_options = {}
								for o, data in pairs(data.options) do
									if CheckOptions(data) then
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
										local hit, coords, entity2 = RaycastCamera(-1)
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
										local hit, coords, entity2 = RaycastCamera(-1)
									until zone:isPointInside(coords) or #(playerCoords - zone.center) > zone.targetoptions.distance
									break
								end
							end 
						end
					end
				else success = false SendNUIMessage({response = "leftTarget"}) end
			end
			Citizen.Wait(0)
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

RegisterKeyMapping("+playerTarget", "Enable targeting~", "keyboard", "LMENU")
RegisterCommand('+playerTarget', EnableTarget, false)
RegisterCommand('-playerTarget', DisableTarget, false)
TriggerEvent("chat:removeSuggestion", "/+playerTarget")
TriggerEvent("chat:removeSuggestion", "/-playerTarget")

--Exports
function AddCircleZone(name, center, radius, options, targetoptions)
	Zones[name] = CircleZone:Create(center, radius, options)
	Zones[name].targetoptions = targetoptions
end

function AddBoxZone(name, center, length, width, options, targetoptions)
	Zones[name] = BoxZone:Create(center, length, width, options)
	Zones[name].targetoptions = targetoptions
end

function AddPolyzone(name, points, options, targetoptions)
	Zones[name] = PolyZone:Create(points, options)
	Zones[name].targetoptions = targetoptions
end

function AddTargetModel(models, parameters)
	for _, model in pairs(models) do
		Models[model] = parameters
	end
end

function AddTargetEntity(entity, parameters)
	Entities[entity] = parameters
end

function AddTargetBone(bones, parameters)
	for _, bone in pairs(bones) do
		Bones[bone] = parameters
	end
end

function AddEntityZone(name, entity, options, targetoptions)
	Zones[name] = EntityZone:Create(entity, options)
	Zones[name].targetoptions = targetoptions
end

function RemoveZone(name)
	if not Zones[name] then return end
	if Zones[name].destroy then
		Zones[name]:destroy()
	end

	Zones[name] = nil
end

exports("AddCircleZone", AddCircleZone)
exports("AddBoxZone", AddBoxZone)
exports("AddPolyzone", AddPolyzone)
exports("AddTargetModel", AddTargetModel)
exports("AddTargetEntity", AddTargetEntity)
exports("AddTargetBone", AddTargetBone)
exports("RemoveZone", RemoveZone)
exports("AddEntityZone", AddEntityZone)
