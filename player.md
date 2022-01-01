# Player options
```lua
exports.qtarget:Player(parameters)
exports.qtarget:RemovePlayer(labels)
```
Registers the defined options to display on all players.

```lua
AddEventHandler('eventname', function(data)
	print(data.label, data.num, data.entity)
end)

exports.qtarget:Player({
	options = {
		{
			event = "eventname",
			icon = "fas fa-box-circle-check",
			label = "action 1",
			num = 1
		},
		{
			event = "eventname",
			icon = "fas fa-box-circle-check",
			label = "action 2",
			num = 2
		},
	},
	distance = 2
})
```

Options can be removed by calling the remove export, with all labels as entries in an array.
```lua
exports.qtarget:RemovePlayer({
	'action 1', 'action 2'
})
```
