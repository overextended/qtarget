# Vehicle options
```lua
exports.qtarget:Vehicle(parameters)
exports.qtarget:RemoveVehicle(events)
```
Registers the defined options to display on all vehicles.

```lua
exports.qtarget:Vehicle({
 	options = {
		event = 'eventname',
		label = 'Perform action'
		icon = 'fas fa-leaf',
		job = 'police',
		canInteract = function(entity)
			if IsVehicleStopped(entity) then
				return true
			else return false end
		end
	},
	distance = 2.5
})
```

Options can be removed by calling the remove export, with all event names as entries in an array.
```lua
exports.qtarget:RemoveVehicle({
	'eventname1', 'eventname2'
})
```
