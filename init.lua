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

-- Enable debug options
Config.Debug = false

-- Enable default options (Toggling vehicle doors)
Config.EnableDefaultOptions = true

-- Whether to have the target as a toggle or not
Config.Toggle = false

-- Enable outlines around the entity you're looking at
Config.EnableOutline = false

-- The color of the outline in rgb, the first value is red, the second value is green and the last value is blue. Here is a link to a color picker to get these values: https://htmlcolorcodes.com/color-picker/
Config.OutlineColor = {255, 255, 255}

-- Control for key press detection on the context menu, it's the Left Mouse Button by default, controls are found here https://docs.fivem.net/docs/game-references/controls/
Config.MenuControlKey = 237

-- Key to open the target eye, here you can find all the names: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
Config.OpenKey = 'LMENU' -- Left Alt

-- Supported values: ESX, QB, false
Config.Framework = false

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

local function JobCheck() return true end
local function GangCheck() return true end
local function ItemCount() return true end
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
			if state ~= 'started' then
				local timeout = 0
				repeat
					timeout += 1
					Wait(0)
				until GetResourceState(framework) == 'started' or timeout > 100
			end
			Config.Framework = framework == 'es_extended' and 'ESX' or 'QB'
		end
	end

	if Config.Framework == 'ESX' then
		local ESX = exports['es_extended']:getSharedObject()

        local resState = GetResourceState('ox_inventory')
        if resState ~= 'missing' and resState ~= 'unknown' then
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
			elseif job == 'all' or job == ESX.PlayerData.job.name then
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
				if PlayerData.job.grade.level >= job then
					return true
				end
			elseif job == 'all' or job == PlayerData.job.name then
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
			elseif job == 'all' or gang == PlayerData.gang.name then
				return true
			end
			return false
		end

		CitizenCheck = function(citizenid)
			return citizenid == PlayerData.citizenid or citizenid[PlayerData.citizenid]
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
		if data.item and ItemCount(data.item) < 1 then return false end
		if data.citizenid and not CitizenCheck(data.citizenid) then return false end
		if data.canInteract and not data.canInteract(entity, distance, data) then return false end
		return true
	end
end)