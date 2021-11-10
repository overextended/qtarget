function Load(name)
	local chunk = LoadResourceFile('qtarget', ('%s.lua'):format(name))
	if chunk then
		local err
		chunk, err = load(chunk, ('@@%s.lua'):format(name), 't')
		if err then
			error(('\n^1 %s'):format(err), 0)
		end
		return chunk()
	end
end

-------------------------------------------------------------------------------
-- Settings
-------------------------------------------------------------------------------

Config   = {}

-- It's possible to interact with entities through walls so this should be low
Config.MaxDistance = 7.0

-- Enable debug options and distance preview
Config.Debug = false

-- Supported values: ESX, QB, false
Config.Framework = false

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
local JobCheck

do
	local CountItems
	if Config.Framework == 'ESX' then
		local ESX = exports['es_extended']:getSharedObject()

		if GetResourceState('ox_inventory') ~= 'unknown' then
			ItemCount = function(item)
				return exports.ox_inventory:Search(2, item)
			end
		else
			ItemCount = function(item)
				for _, v in pairs(ESX.GetPlayerData().inventory) do
					if v.name == item then
						return v.count
					end
				end
				return 0
			end
		end

		JobCheck = function(job)
			if type(job) == 'table' then
				job = job[ESX.PlayerData.job.name]
				if ESX.PlayerData.job.grade >= job then
					return true
				end
			elseif job == ESX.PlayerData.job.name then
				return true
			end
			return false
		end

		RegisterNetEvent('esx:playerLoaded', function(xPlayer)
			ESX.PlayerData = xPlayer
		end)

		RegisterNetEvent('esx:setJob', function(job)
			ESX.PlayerData.job = job
		end)

	elseif Config.Compatibility == 'QB' then
		-- todo

	else
		JobCheck = function()
			return true
		end
	end
end

function CheckOptions(data, entity, distance)
	if data.distance and distance > data.distance then return nil end
	if data.required_item and ItemCount(data.required_item) < 1 then return nil end
	if data.canInteract and not data.canInteract(entity) then return nil end
	if data.job and not JobCheck(data.job) then return nil end
	return true
end

Load('client')
Load = nil