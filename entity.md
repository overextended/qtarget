# Entity options
```lua
exports.qtarget:AddTargetEntity(entity, parameters)
```
Registers the defined options to display on a specific entity. Only works if the entity is networked.

```lua
exports.qtarget:AddTargetEntity(entity), {
	options = {
		{
			event = "eventname",
			icon = "fas fa-box-circle-check",
			label = "Access ATM"
		},
	},
	distance = 1.5
})
```
