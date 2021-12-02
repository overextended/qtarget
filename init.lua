function Load(name)
	local resourceName = GetCurrentResourceName()
	local chunk = LoadResourceFile(resourceName, ('%s.lua'):format(name))
	if chunk then
		local err
		chunk, err = load(chunk, ('@@%s/%s.lua'):format(resourceName, name), 't')
		if err then
			error(('\n^1 %s'):format(err), 0)
		end
		return chunk()
	end
end

-------------------------------------------------------------------------------
-- Settings
-------------------------------------------------------------------------------

Config = {}

-- It's possible to interact with entities through walls so this should be low
Config.MaxDistance = 7.0

-- Enable debug options and distance preview
Config.Debug = false

-- Supported values: ESX, QB, false
Config.Framework = false

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
local function JobCheck() return true end
local function GangCheck() return true end
local function ItemCount() return true end
local function CitizenCheck() return true end

do
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
				if job and ESX.PlayerData.job.grade >= job then
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

		RegisterNetEvent('esx:onPlayerLogout', function()
			table.wipe(ESX.PlayerData)
		end)

	elseif Config.Framework == 'QB' then
		local QBCore = exports['qb-core']:GetCoreObject()
		local PlayerData = QBCore.Functions.GetPlayerData()

		ItemCount = function(item)
			for _, v in pairs(PlayerData.items) do
				if v.name == item then
					return v.amount
				end
			end
			return 0
		end

		JobCheck = function(job)
			if type(job) == 'table' then
				job = job[PlayerData.job.name]
				if PlayerData.job.grade >= job then
					return true
				end
			elseif job == PlayerData.job.name then
				return true
			end
			return false
		end

		GangCheck = function(job)
			if type(job) == 'table' then
				job = job[PlayerData.job.name]
				if PlayerData.job.grade >= job then
					return true
				end
			elseif job == PlayerData.job.name then
				return true
			end
			return false
		end

		RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
			PlayerData = QBCore.Functions.GetPlayerData()
		end)

		RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
			table.wipe(PlayerData)
		end)

		RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
			PlayerData.job = JobInfo
		end)

		RegisterNetEvent('QBCore:Client:OnGangUpdate', function(GangInfo)
			PlayerData.gang = GangInfo
		end)

		RegisterNetEvent('QBCore:Client:SetPlayerData', function(val)
			PlayerData = val
		end)
	end
end

function CheckOptions(data, entity, distance)
	if data.distance and distance > data.distance then return false end
	if data.job and not JobCheck(data.job) then return false end
	if data.gang and not JobCheck(data.job) then return false end
	if data.item and ItemCount(data.item) < 1 then return false end
	if data.canInteract and not data.canInteract(entity, distance, data) then return false end
	return true
end

Load('client')
Load = nil
