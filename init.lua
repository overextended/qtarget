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

-- Draw a Sprite on the center of a PolyZone to hint where it's located
Config.DrawSprite = false

-- The default distance to draw the Sprite
Config.DrawDistance = 10.0

-- The color of the sprite in rgb, the first value is red, the second value is green, the third value is blue and the last value is alpha (opacity). Here is a link to a color picker to get these values: https://htmlcolorcodes.com/color-picker/
Config.DrawColor = {255, 255, 255, 255}

-- The color of the sprite in rgb when the PolyZone is targeted, the first value is red, the second value is green, the third value is blue and the last value is alpha (opacity). Here is a link to a color picker to get these values: https://htmlcolorcodes.com/color-picker/
Config.SuccessDrawColor = {98, 135, 236, 255}

-- Enable outlines around the entity you're looking at
Config.EnableOutline = false

-- The color of the outline in rgb, the first value is red, the second value is green, the third value is blue and the last value is alpha (opacity). Here is a link to a color picker to get these values: https://htmlcolorcodes.com/color-picker/
Config.OutlineColor = {255, 255, 255, 255}

-- Control for key press detection on the context menu, it's the Left Mouse Button by default, controls are found here https://docs.fivem.net/docs/game-references/controls/
Config.MenuControlKey = 237

-- Key to open the target eye, here you can find all the names: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
Config.OpenKey = 'LMENU' -- Left Alt

-- Supported values: 'ESX', 'QB', false
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
			ItemCheck = function(items)
				if type(items) == 'table' then
					local finalcount = 0
					local count = 0
					local itemArray = {}
					local isArray = table.type(items) == 'array'
					for _ in pairs(items) do finalcount += 1 end
					if isArray then
						itemArray = items
					else
						for k in pairs(items) do
							itemArray[#itemArray + 1] = k
						end
					end

					local returnedItems = exports.ox_inventory:Search('count', itemArray)

					if returnedItems then
						for name, itemCount in pairs(returnedItems) do
							if isArray then -- Table expected in this format {'itemName1', 'itemName2', 'etc'}
								if itemCount >= 1 then
									count += 1
								end
							else -- Table expected in this format {['itemName'] = amount}
								if itemCount >= items[name] then
									count += 1
								end
							end
							if count == finalcount then -- This is to make sure it checks all items in the table instead of only one of the items
								return true
							end
						end
					end
					return false
				else
					return exports.ox_inventory:Search('count', items) >= 1
				end
			end
		else
			ItemCheck = function(items)
				local isTable = type(items) == 'table'
				local isArray = isTable and table.type(items) == 'array' or false
				local totalItems = #items
				local count = 0
				local kvIndex = 2
				if isTable and not isArray then
					totalItems = 0
					for _ in pairs(items) do totalItems += 1 end
					kvIndex = 1
				end
				for _, itemData in pairs(ESX.GetPlayerData().inventory) do
					if isTable then
						for k, v in pairs(items) do
							local itemKV = {k, v}
							if itemData.name == itemKV[kvIndex] and ((not isArray and itemData.count >= v) or (isArray and itemData.count > 0)) then
								count += 1
							end
						end
						if count == totalItems then
							return true
						end
					else -- Single item as string
						if itemData.name == items and itemData.count > 0 then
							return true
						end
					end
				end
				return false
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

		AddEventHandler('esx:setPlayerData', function(key, val)
			if GetInvokingResource() == 'es_extended' then
				ESX.PlayerData[key] = val
			end
		end)

	elseif Config.Framework == 'QB' then
		local QBCore = exports['qb-core']:GetCoreObject()
		local PlayerData = QBCore.Functions.GetPlayerData()

		ItemCheck = QBCore.Functions.HasItem

		JobCheck = function(job)
			if type(job) == 'table' then
				job = job[PlayerData.job.name]
				if job and PlayerData.job.grade.level >= job then
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
				if gang and PlayerData.gang.grade.level >= gang then
					return true
				end
			elseif gang == 'all' or gang == PlayerData.gang.name then
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
		if data.item and not ItemCheck(data.item) then return false end
		if data.citizenid and not CitizenCheck(data.citizenid) then return false end
		if data.canInteract and not data.canInteract(entity, distance, data) then return false end
		return true
	end
end)