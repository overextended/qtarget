local Config, Players, Types, Entities, Models, Zones, Bones = {}, {}, {}, {}, {}, {}, {}
Types[1], Types[2], Types[3] = {}, {}, {}
Config.VehicleBones = {'chassis', 'windscreen', 'seat_pside_r', 'seat_dside_r', 'bodyshell', 'suspension_lm', 'suspension_lr', 'platelight', 'attach_female', 'attach_male', 'bonnet', 'boot', 'chassis_dummy', 'chassis_Control', 'door_dside_f', 'door_dside_r', 'door_pside_f', 'door_pside_r', 'Gun_GripR', 'windscreen_f', 'VFX_Emitter', 'window_lf', 'window_lr', 'window_rf', 'window_rr', 'engine', 'gun_ammo', 'ROPE_ATTATCH', 'wheel_lf', 'wheel_lr', 'wheel_rf', 'wheel_rr', 'exhaust', 'overheat', 'misc_e', 'seat_dside_f', 'seat_pside_f', 'Gun_Nuzzle'}

-------------------------------------------------------------------------------
-- Settings
-------------------------------------------------------------------------------
-- It's possible to interact with entities through walls so this should be low
Config.MaxDistance = 7.0

-- Enable debug options and distance preview
Config.Debug = false

-- Support when not using ESX Legacy
Config.Standalone = false

-- Support when using linden_inventory
Config.LindenInventory = false

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
local M = {}
if not Config.Standalone then
	M.ItemCount = function(item)
		if Config.LindenInventory then
			return exports['linden_inventory']:CountItems(item)[item]
		else
			for k, v in pairs(ESX.GetPlayerData().inventory) do
				if v.name == item then
					return v.count
				end
			end
		end
		return 0
	end

	M.CheckOptions = function(data, entity, distance)
		if (data.distance == nil or distance <= data.distance)
		and (data.job == nil or (data.job == ESX.PlayerData.job.name or data.job[ESX.PlayerData.job.name] and data.job[ESX.PlayerData.job.name] <= ESX.PlayerData.job.grade))
		and (data.required_item == nil or data.required_item and M.ItemCount(data.required_item) > 0)
		and (data.canInteract == nil or data.canInteract(entity)) then return true
		end
		return false
	end
else
	M.CheckOptions = function(data, entity, distance)
		if (data.distance == nil or distance <= data.distance)
		and (data.canInteract == nil or data.canInteract(entity)) then return true
		end
		return false
	end
end

M.CloneTable = function(table)
	local copy = {}
	for k,v in pairs(table) do
		if type(v) == 'table' then
			copy[k] = M.CloneTable(v)
		else
			if type(v) == 'function' then v = nil end
			copy[k] = v
		end
	end
	return copy
end

M.ToggleDoor = function(vehicle, door)
	if GetVehicleDoorLockStatus(vehicle) ~= 2 then 
		if GetVehicleDoorAngleRatio(vehicle, door) > 0.0 then
			SetVehicleDoorShut(vehicle, door, false)
		else
			SetVehicleDoorOpen(vehicle, door, false)
		end
	end
end

-------------------------------------------------------------------------------
-- Default options
-------------------------------------------------------------------------------
Bones['seat_dside_f'] = {
	options = {
		{
			icon = "fas fa-door-open",
			label = "Toggle front Door",
			canInteract = function(entity)
				return GetEntityBoneIndexByName(entity, 'door_dside_f') ~= -1
			end,
			action = function(entity)
				M.ToggleDoor(entity, 0)
			end
		},
	},
	distance = 1.2
}

Bones['seat_pside_f'] = {
	options = {
		{
			icon = "fas fa-door-open",
			label = "Toggle front Door",
			canInteract = function(entity)
				return GetEntityBoneIndexByName(entity, 'door_pside_f') ~= -1
			end,
			action = function(entity)
				M.ToggleDoor(entity, 1)
			end
		},
	},
	distance = 1.2
}

Bones['seat_dside_r'] = {
	options = {
		{
			icon = "fas fa-door-open",
			label = "Toggle rear Door",
			canInteract = function(entity)
				return GetEntityBoneIndexByName(entity, 'door_dside_r') ~= -1
			end,
			action = function(entity)
				M.ToggleDoor(entity, 2)
			end
		},
	},
	distance = 1.2
}

Bones['seat_pside_r'] = {
	options = {
		{
			icon = "fas fa-door-open",
			label = "Toggle rear Door",
			canInteract = function(entity)
				return GetEntityBoneIndexByName(entity, 'door_pside_r') ~= -1
			end,
			action = function(entity)
				M.ToggleDoor(entity, 3)
			end
		},
	},
	distance = 1.2
}

Bones['bonnet'] = {
	options = {
		{
			icon = "fa-duotone fa-engine",
			label = "Toggle Hood",
			action = function(entity)
				M.ToggleDoor(entity, 4)
			end
		},
	},
	distance = 0.9
}

-------------------------------------------------------------------------------
return Config, Players, Types, Entities, Models, Zones, Bones, M
-------------------------------------------------------------------------------
