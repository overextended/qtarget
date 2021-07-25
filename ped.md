# NPC options
```lua
exports.qtarget:Ped(parameters)
exports.qtarget:RemovePed(events)
```
Registers the defined options to display on all non-player peds.

```lua
exports.qtarget:Ped({
	options = {
		{
			event = 'eventname',
			label = 'Perform action',
			icon = 'fas fa-leaf',
			job = 'police',
			canInteract = function(entity)
				return GetEntityHealth(entity) ~= 0
			end
		}
	},
	distance = 2.5
})
```

Options can be removed by calling the remove export, with all event names as entries in an array.
```lua
exports.qtarget:RemovePed({
	'eventname1', 'eventname2'
})
```
