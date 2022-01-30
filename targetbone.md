# Entity options
```lua
exports.qtarget:AddTargetBone(bones, parameters)
```
##### Registers the defined options to display on all vehicles with the selected target bone.
###### Bones can be found in qtarget/data/bones.lua

```lua

exports.qtarget:AddTargetBone({'boot'},{
	options = {
		{
			event = "get:intrunk",
			icon = "fas fa-truck-loading",
			label = "Get in Trunk",
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

##### An export to delete target bones doesnt exist (yet maybe)
