# Entity options
```lua
exports.qtarget:AddTargetEntity(entity, parameters)
```
##### Registers the defined options to display on a specific entity. Only works if the entity is networked.

```lua
AddEventHandler('eventname', function(data)
	print(data.label, data.num, data.entity)
end)

exports.qtarget:AddTargetEntity(entity, {
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

##### Options can be removed by calling the remove export, with all labels as entries in an array.
```lua
exports.qtarget:RemoveTargetEntity(entity, {
	'action 1', 'action 2'
})
```
