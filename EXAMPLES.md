# Examples

## AddBoxZone / Job Check
This is an example from our police resource. The resource defines a BoxZone around a clipboard in the `gabz_mrpd` MLO. 
It's a simple set-up, we provide a unique name, define its center point with the vector3, define a length and a width, and then we define some options; the unique name again, the heading of the box, a bool to display a debug poly, and the height of the zone. 

Then, in the actual options themselves,  we define 'police' as our required job.

```lua
exports['qtarget']:AddBoxZone("MissionRowDutyClipboard", vector3(441.7989, -982.0529, 30.67834), 0.45, 0.35, {
	name="MissionRowDutyClipboard",
	heading=11.0,
	debugPoly=false,
	minZ=30.77834,
	maxZ=30.87834,
	}, {
		options = {
			{
				event = "qrp_duty:goOnDuty",
				icon = "fas fa-sign-in-alt",
				label = "Sign In",
				job = "police",
			},
			{
				event = "qrp_duty:goOffDuty",
				icon = "fas fa-sign-out-alt",
				label = "Sign Out",
				job = "police",
			},
		},
		distance = 3.5
})
```

This is only one way you can define the job though, as you can also provide a `[key] = value` table instead:

```lua
job = {
	["police"] = 5,
	["ambulance"] = 0,
}
```
When defining multiple jobs, you **must** provide a minimum grade, even if you don't need one. This is due to how key/value tables work. Just set the minimum grade to 0. 

## AddTargetModel / required_item / canInteract()

This is another example from our police resource. It utilizes both the `required_item` parameter and `canInteract()` function.

`Config.Peds` in this example is a big list of playable ped hashes that players can play.

```lua
exports['qtarget']:AddTargetModel(Config.Peds, {
	options = {
		{
			event = "qrp_police:requestCuffPed",
			icon = "fas fa-hands",
			label = "Cuff / Uncuff",
			required_item = 'handcuffs',
			job = "police"
		},
		{
			event = "qrp_interaction:RobPlayer",
			icon = "fas fa-sack-dollar",
			label = "Rob",
			canInteract = function(entity)
				if IsPedAPlayer(entity) then 
					return Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.handsup
				end
			end, 
		},
	},
	distance = 2.5,
})
```

## Add Target Entity
This is an example from our postop resource. Players can rent delivery vehicles in order to make deliveries. When they rent a vehicle, we apply this qtarget to that entity only, which allows them to "get packages" from the vehicle.

```lua
exports['qtarget']:AddTargetEntity(NetworkGetNetworkIdFromEntity(vehicle), {
    options = {
        {
            event = "postop:getPackage",
            icon = "fas fa-box-circle-check",
            label = "Get Package",
            owner = NetworkGetNetworkIdFromEntity(PlayerPedId()),
            job = "postop",
        },
    },
    distance = 3.0
})
```

## Passing Item Data
In this example, we define the model of the coffee machines you see around the map, and allow players to purchase a coffee. You'll have to provide your own logic for the purchase, but this is how you would handle the qtarget, and how you would pass data through to an event for future use. 

```lua
local coffee = {
    690372739,
}
exports['qtarget']:AddTargetModel(coffee, {
    options = {
        {
            event = "coffee:buy",
            icon = "fas fa-coffee",
            label = "Coffee",
            item = "coffee",
            price = 5,
        },
    },
    distance = 2.5
})

RegisterNetEvent('coffee:buy')
AddEventHandler('coffee:buy',function(data)
    ESX.ShowNotification("You purchased a " .. data.item .. " for $" .. data.price .. ". Enjoy!")
    -- server event to buy the item here
end)
```

### EntityZone / Add a qtarget in an event
This is an example of how you can dynamically create a qtarget in an event, for example, planting a potato plant.

```lua
AddEventHandler('plantpotato',function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	model = `prop_plant_fern_02a`
	RequestModel(model)
	while not HasModelLoaded(model) do
		Citizen.Wait(50)
	end
	local plant = CreateObject(model, coords.x, coords.y, coords.z, true, true)
	Citizen.Wait(50)
	PlaceObjectOnGroundProperly(plant)
	SetEntityInvincible(plant, true)

	-- Logic to handle growth, create a thread and loop, or do something else. Up to you.

	exports['qtarget']:AddEntityZone("potato-growing-"..plant, plant, {
		name = "potato-growing-"..plant,
		heading=GetEntityHeading(plant),
		debugPoly=false,
	}, {
		options = {
		{
			event = "farming:harvestPlant",
			icon = "fa-solid fa-scythe",
			label = "Harvest potato",
			plant = plant,
			job = "farmer",
			canInteract = function(entity)
				if Entity(entity).state.growth >= 100 then 
					return true
				else 
					return false
				end 
			end,
		},
	},
		distance = 3.5
	})

end)
```
