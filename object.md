# Object options
```lua
exports.qtarget:Object(parameters)
exports.qtarget:RemoveObject(events)
```
Registers the defined options to display on all objects.

```lua
exports.qtarget:Vehicle({
 	options = {
		event = 'eventname',
		label = 'Perform action'
		icon = 'fas fa-leaf',
		job = 'police',
		canInteract = function(entity)
			if IsEntityAMissionEntity(entity) then
				return true
			else return false end
		end
	},
	distance = 2.5
})
```

Options can be removed by calling the remove export, with all event names as entries in an array.
```lua
exports.qtarget:RemoveObject({
	'eventname1', 'eventname2'
})
```
