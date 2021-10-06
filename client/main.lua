local func, err = load(LoadResourceFile(GetCurrentResourceName(), 'config.lua'), 'config', 't')
assert(func, err == nil or '\n^1'..err..'^7')
local Config, Players, Types, Entities, Models, Zones, Bones, CheckOptions = func()
local playerPed, hasFocus, success, sendData = PlayerPedId(), false, false

local RaycastCamera = function(flag)
	local cam = GetGameplayCamCoord()
	local direction = GetGameplayCamRot()
	direction = vec2(math.rad(direction.x), math.rad(direction.z))
	local num = math.abs(math.cos(direction.x))
	direction = vec3((-math.sin(direction.y) * num), (math.cos(direction.y) * num), math.sin(direction.x))
	local rayHandle = StartShapeTestLosProbe(cam.x, cam.y, cam.z, cam.x + direction.x * 30, cam.y + direction.y * 30, cam.z + direction.z * 30, flag or -1, playerPed or PlayerPedId(), 0)
	while true do
		Wait(0)
		local result, _, endCoords, _, materialHash, entityHit = GetShapeTestResultIncludingMaterial(rayHandle)
		if result ~= 1 then
			return flag, endCoords, entityHit, entityHit and GetEntityType(entityHit) or 0
		end
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

CheckEntity = function(hit, data, entity, distance)
	local send_options = {}
	local send_distance = {}
	for _, data in pairs(data) do
		if CheckOptions(data, entity, distance) then
			local slot = #send_options + 1 
			send_options[slot] = data
			send_options[slot].entity = entity
			send_distance[data.distance] = true
		else send_distance[data.distance] = false end
	end
	sendData = send_options
	if next(send_options) then
		success = true
		SendNUIMessage({response = "validTarget", data = table.clone(sendData)})
		while targetActive do
			local playerCoords = GetEntityCoords(playerPed)
			local _, coords, entity2 = RaycastCamera(hit)
			local distance = #(playerCoords - coords)
			if entity ~= entity2 then 
				if hasFocus then DisableNUI() end
				break
			elseif not hasFocus and IsDisabledControlPressed(0, 24) then
				EnableNUI()
			else
				for k, v in pairs(send_distance) do
					if (v == false and distance < k) or (v == true and distance > k) then
						return CheckEntity(hit, data, entity, distance)
					end
				end
			end
			Wait(20)
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
			local distance = #(coords - bonePos)
			if closestBone == -1 or distance < closestDistance then
				closestBone, closestDistance, closestPos, closestBoneName = boneId, distance, bonePos, v
			end
		end
	end
	if closestBone ~= -1 then return closestBone, closestPos, closestBoneName
	else return false end
end

local curFlag = 30
local switch = function()
	if curFlag == 30 then curFlag = -1 else curFlag = 30 end
	return curFlag
end

function EnableTarget()
	if success or not IsControlEnabled(0, 24) then return end
	if not targetActive then 
		targetActive = true
		SendNUIMessage({response = "openTarget"})

		CreateThread(function()
			repeat
				if hasFocus then
					DisableControlAction(0, 1, true)
					DisableControlAction(0, 2, true)
				end
				DisablePlayerFiring(PlayerId(), true)
				DisableControlAction(0, 25, true)
				DisableControlAction(0, 37, true)
				Wait(0)
			until targetActive == false
		end)
		playerPed = PlayerPedId()

		while targetActive do
			local sleep = 0
			local playerCoords = GetEntityCoords(playerPed)
			local hit, coords, entity, entityType = RaycastCamera(switch())
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
					local min, max = GetModelDimensions(GetEntityModel(entity))
					local closestBone, closestPos, closestBoneName = CheckBones(coords, entity, min, max, Config.VehicleBones)
					local data = Bones[closestBoneName]
					if closestBone and #(coords - closestPos) <= data.distance then
						local send_options = {}
						for _, data in pairs(data.options) do
							if CheckOptions(data, entity) then 
								local slot = #send_options + 1 
								send_options[slot] = data
								send_options[slot].entity = entity
							end
						end
						sendData = send_options
						if next(send_options) then
							success = true
							SendNUIMessage({response = "validTarget", data = table.clone(sendData)})
							while targetActive do
								playerCoords = GetEntityCoords(playerPed)
								local _, coords, entity2 = RaycastCamera(hit)
								if hit and entity == entity2 then
									local closestBone2, closestPos2, closestBoneName2 = CheckBones(coords, entity, min, max, Config.VehicleBones)

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
			else sleep = sleep + 20 end
			if not success then
				-- Zone targets
				for _,zone in pairs(Zones) do
					local distance = #(playerCoords - zone.center)
					if zone:isPointInside(coords) and distance <= zone.targetoptions.distance then
						local send_options = {}
						for _, data in pairs(zone.targetoptions.options) do
							if CheckOptions(data, entity, distance) then
								local slot = #send_options + 1 
								send_options[slot] = data
								send_options[slot].entity = entity
							end
						end
						sendData = send_options
						if next(send_options) then
							success = true
							SendNUIMessage({response = "validTarget", data = table.clone(sendData)})
							while targetActive do
								playerCoords = GetEntityCoords(playerPed)
								_, coords = RaycastCamera(hit)
								if not zone:isPointInside(coords) or #(playerCoords - zone.center) > zone.targetoptions.distance then 
									if hasFocus then DisableNUI() end
									break
								elseif not hasFocus and IsDisabledControlPressed(0, 24) then
									EnableNUI()
								end
								Wait(20)
							end
							success = false
							SendNUIMessage({response = "leftTarget"})
						else
							repeat
								Wait(20)
								_, coords, entity2 = RaycastCamera(hit)
							until not targetActive or entity ~= entity2 or not zone:isPointInside(coords)
							break
						end
					end
				end
			else success = false SendNUIMessage({response = "leftTarget"}) end
			Wait(sleep)
		end
		hasFocus, success = false, false
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

RegisterNUICallback('selectTarget', function(option)
	hasFocus = false
	local data = sendData[tonumber(option)]
	CreateThread(function()
		Wait(0)
		if data.action ~= nil then
			data.action(data.entity)
		else
			TriggerEvent(data.event, data)
		end
	end)

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
AddCircleZone = function(name, center, radius, options, targetoptions)
	Zones[name] = CircleZone:Create(center, radius, options)
	Zones[name].targetoptions = targetoptions
end
exports("AddCircleZone", AddCircleZone)

AddBoxZone = function(name, center, length, width, options, targetoptions)
	Zones[name] = BoxZone:Create(center, length, width, options)
	Zones[name].targetoptions = targetoptions
end
exports("AddBoxZone", AddBoxZone)

AddPolyzone = function(name, points, options, targetoptions)
	Zones[name] = PolyZone:Create(points, options)
	Zones[name].targetoptions = targetoptions
end
exports("AddPolyzone", AddPolyzone)

AddTargetBone = function(bones, parameters)
	for _, bone in pairs(bones) do
		Bones[bone] = parameters
	end
end
exports("AddTargetBone", AddTargetBone)

AddTargetEntity = function(entity, parameters)
	local entity = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity) or false
	if entity then
		local distance, options = parameters.distance or Config.MaxDistance, parameters.options
		if not Entities[entity] then Entities[entity] = {} end
		for k, v in pairs(options) do
			if not v.distance or v.distance > distance then v.distance = distance end
			Entities[entity][v.label] = v
		end
	end
end
exports("AddTargetEntity", AddTargetEntity)

AddEntityZone = function(name, entity, options, targetoptions)
	Zones[name] = EntityZone:Create(entity, options)
	Zones[name].targetoptions = targetoptions
end
exports("AddEntityZone", AddEntityZone)

AddTargetModel = function(models, parameters)
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
exports("AddTargetModel", AddTargetModel)

RemoveZone = function(name)
	if not Zones[name] then return end
	if Zones[name].destroy then
		Zones[name]:destroy()
	end
	Zones[name] = nil
end
exports("RemoveZone", RemoveZone)

RemoveTargetModel = function(models, labels)
	for _, model in pairs(models) do
		if type(model) == 'string' then model = GetHashKey(model) end
		for k, v in pairs(labels) do
			if Models[model] then
				Models[model][v] = nil
			end
		end
	end
end
exports("RemoveTargetModel", RemoveTargetModel)

RemoveTargetEntity = function(entity, labels)
	local entity = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity) or false
	if entity then
		for k, v in pairs(labels) do
			if Entities[entity] then
				Entities[entity][v] = nil
			end
		end
	end
end
exports("RemoveTargetEntity", RemoveTargetEntity)

local AddType = function(type, parameters)
	local distance, options = parameters.distance or Config.MaxDistance, parameters.options
	for k, v in pairs(options) do
		if not v.distance or v.distance > distance then v.distance = distance end
		Types[type][v.label] = v
	end
end

AddPed = function(parameters) AddType(1, parameters) end
exports("Ped", AddPed)
AddVehicle = function(parameters) AddType(2, parameters) end
exports("Vehicle", AddVehicle)
AddObject = function(parameters) AddType(3, parameters) end
exports("Object", AddObject)

AddPlayer = function(parameters)
	local distance, options = parameters.distance or Config.MaxDistance, parameters.options
	for k, v in pairs(options) do
		if not v.distance or v.distance > distance then v.distance = distance end
		Players[v.label] = v
	end
end
exports("Player", AddPlayer)

local RemoveType = function(type, labels)
	for k, v in pairs(labels) do
		Types[type][v] = nil
	end
end

RemovePed = function(labels) RemoveType(1, labels) end
exports("RemovePed", RemovePed)
RemoveVehicle = function(labels) RemoveType(2, labels) end
exports("RemoveVehicle", RemoveVehicle)
RemoveObject = function(labels) RemoveType(3, labels) end
exports("RemoveObject", RemoveObject)

RemovePlayer = function(labels)
	for k, v in pairs(labels) do
		Players[v] = nil
	end
end
exports("RemovePlayer", RemovePlayer)

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
						event = "qtarget:debug",
						icon = "fas fa-box-circle-check",
						label = "HelloWorld",
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
				event = "qtarget:debug",
				icon = "fas fa-male",
				label = "(Debug) Ped",
			},
		},
		distance = Config.MaxDistance
	})

	AddVehicle({
		options = {
			{
				event = "qtarget:debug",
				icon = "fas fa-car",
				label = "(Debug) Vehicle",
			},
		},
		distance = Config.MaxDistance
	})

	AddObject({
		options = {
			{
				event = "qtarget:debug",
				icon = "fas fa-cube",
				label = "(Debug) Object",
			},
		},
		distance = Config.MaxDistance
	})

	AddPlayer({
		options = {
			{
				event = "qtarget:debug",
				icon = "fas fa-cube",
				label = "(Debug) Player",
			},
		},
		distance = Config.MaxDistance
	})

end
