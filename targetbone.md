# Entity options
```lua
exports.qtarget:AddTargetBone(bones, parameters)
```
##### Registers the defined options to display on all vehicles with the selected target bone.
###### Bones can be found in qtarget/data/bones.lua

```lua
AddEventHandler('eventname', function(data)
	print(data.label, data.num, data.entity)
end)

exports.qtarget:AddTargetBone({'boot'},{
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

##### There isnt an export to delete targetbones yet.
