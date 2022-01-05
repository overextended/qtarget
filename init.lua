function Load(name)
	local resourceName = GetCurrentResourceName()
	local chunk = LoadResourceFile(resourceName, ('data/%s.lua'):format(name))
	if chunk then
		local err
		chunk, err = load(chunk, ('@@%s/data/%s.lua'):format(resourceName, name), 't')
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
local function ItemCheck() return true end
local function CitizenCheck() return true end

CreateThread(function()
	if not Config.Framework then
		local framework = 'es_extended'
		local state = GetResourceState(framework)

		if state == 'missing' then
			framework = 'qb-core'
			state = GetResourceState(framework)
		end

		if state ~= 'missing' then
			if state ~= ('started' or 'starting') then
				local timeout = 0
				repeat
					Wait(0)
					timeout += 1
				until (GetResourceState(framework) == 'started' or timeout > 100)
			end
			Config.Framework = (framework == 'es_extended') and 'ESX' or 'QB'
		end
	end

	if Config.Framework == 'ESX' then
		local ESX = exports['es_extended']:getSharedObject()

        local resState = GetResourceState('ox_inventory')
        if resState ~= 'missing' and resState ~= 'unknown' then
			ItemCheck = function(item)
				if type(item) == 'table' then 
					local inventory = exports.ox_inventory:Search(2, item)
					if inventory then
						for name, count in pairs(inventory) do
							for items, j in pairs(item) do
								if items == name then
									if count < j then 
										return false
									end
								end
							end
						end
						return true
					end
					return false
				else
					return exports.ox_inventory:Search(2, item) > 0
				end
			end
		else
			ItemCheck = function(item)
				if type(item) == 'table' then
					for items, j in pairs(item) do
						local itemQuantity = 0
						for _, v in pairs(ESX.GetPlayerData().inventory) do
							if v.name == items then
								itemQuantity = itemQuantity + v.count
							end
						end
						if itemQuantity < j then 
							return false
						end
					end
					return true
				else
					for _, v in pairs(ESX.GetPlayerData().inventory) do
						if v.name == item then
							return v.count > 0
						end
					end
					return false
				end
			end
		end

		JobCheck = function(job)
			if type(job) == 'table' then
				job = job[ESX.PlayerData.job.name]
				if job and ESX.PlayerData.job.grade >= job then
					return true
				end
			elseif job == ESX.PlayerData.job.name or job == 'all' then
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

		ItemCheck = function(item)
			if type(item) == 'table' then
				for items, j in pairs(item) do
					local itemQuantity = 0
					for _, v in pairs(PlayerData.items) do
						if v.name == items then
							itemQuantity = itemQuantity + v.amount
						end
					end
					if itemQuantity < j then 
						return false
					end
				end
				return true
			else
				for _, v in pairs(PlayerData.items) do
					if v.name == item then
						return v.amount > 0
					end
				end
				return false
			end
		end

		JobCheck = function(job)
			if type(job) == 'table' then
				job = job[PlayerData.job.name]
				if PlayerData.job.grade.level >= job then
					return true
				end
			elseif job == PlayerData.job.name or job == 'all' then
				return true
			end
			return false
		end

		GangCheck = function(gang)
			if type(gang) == 'table' then
				gang = gang[PlayerData.gang.name]
				if PlayerData.gang.grade.level >= gang then
					return true
				end
			elseif gang == PlayerData.gang.name or gang == 'all' then
				return true
			end
			return false
		end

		CitizenCheck = function(citizenid)
			return (citizenid == PlayerData.citizenid or citizenid[PlayerData.citizenid])
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

		RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
			PlayerData = val
		end)
	end

	function CheckOptions(data, entity, distance)
		if data.distance and distance > data.distance then return false end
		if data.job and not JobCheck(data.job) then return false end
		if data.gang and not GangCheck(data.gang) then return false end
		if data.item and not ItemCheck(data.item) then return false end
		if data.citizenid and not CitizenCheck(data.citizenid) then return false end
		if data.canInteract and not data.canInteract(entity, distance, data) then return false end
		return true
	end
end)
