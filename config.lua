local Config, Players, Types, Entities, Models, Zones, Bones = {}, {}, {}, {}, {}, {}, {}
Types[1], Types[2], Types[3] = {}, {}, {}
Config.VehicleBones = {'chassis', 'windscreen', 'seat_pside_r', 'seat_dside_r', 'bodyshell', 'suspension_lm', 'suspension_lr', 'platelight', 'attach_female', 'attach_male', 'bonnet', 'boot', 'chassis_dummy', 'chassis_Control', 'door_dside_f', 'door_dside_r', 'door_pside_f', 'door_pside_r', 'Gun_GripR', 'windscreen_f', 'platelight', 'VFX_Emitter', 'window_lf', 'window_lr', 'window_rf', 'window_rr', 'engine', 'gun_ammo', 'ROPE_ATTATCH', 'wheel_lf', 'wheel_lr', 'wheel_rf', 'wheel_rr', 'exhaust', 'overheat', 'misc_e', 'seat_dside_f', 'seat_pside_f', 'Gun_Nuzzle', 'seat_r'}

--------------------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------------------
-- Support when using linden_inventory
Config.LindenInventory = true

--------------------------------------------------------------------------------------------

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

return Config, Players, Types, Entities, Models, Zones, Bones, ItemCount
