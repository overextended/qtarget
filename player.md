# Player options
```lua
exports.qtarget:Player(parameters)
exports.qtarget:RemovePlayer(events)
```
Registers the defined options to display on all players.

```lua
exports.qtarget:Player({
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
exports.qtarget:RemovePlayer({
	'eventname1', 'eventname2'
})
```
