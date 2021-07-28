# Model options
```lua
exports.qtarget:AddTargetModel(models, parameters)
exports.qtarget:RemoveTargetModel(models, events)
```
Registers the defined options to display on all entities with the provided model hash.

```lua
local atms = {`prop_atm_01`, `prop_atm_02`, `prop_atm_03`, `prop_fleeca_atm`}
exports.qtarget:AddTargetModel(atms, {
	options = {
		{
			event = "eventname",
			icon = "fas fa-credit-card",
			label = "Access ATM"
		},
	},
	distance = 1.5
})

```

Options can be removed by calling the remove export, with all models and event names as entries in arrays.
```lua
exports.qtarget:AddTargetModel(atms, {
	'eventname1', 'eventname2'
})
```
