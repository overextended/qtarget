## Installation
- [ESX Legacy](https://github.com/esx-framework/esx-legacy) is required for receiving the ESX shared object and keeping PlayerData updated
- [PolyZone](https://github.com/mkafrin/PolyZone) is required for zone checks
- Replace `es_extended/imports.lua` with [this file](https://github.com/thelindat/es_extended/blob/linden/imports.lua) to add Interval support

## Parameters

| Key | Data Type | Example |
| --- | --- | --- |
| label | string | 'Revive target' |
| event | string | 'qtarget:reviveTarget' |
| action | function | function(entity) ReviveTarget(entity) end |  

##### Note: You should define event *OR* action for your option

## Optional Parameters

| Key | Data Type | Default | Example |
| --- | --- | --- | --- |
| distance | float | 2.0 | 4.0 |
| icon | string | - | 'fas fa-leaf' |
| required_item | string | - | 'water' |
| job | string | - | 'police' |
| job | table | - | {['police'] = 0, ['ambulance'] = 0} |
| canInteract | function | - | function(entity) return IsEntityDead(entity) end |  

## Custom Parameters
##### You can pass any information that you desire through the export. Once the event or function is triggered it will receive all parameters as data.
```lua
exports['qtarget']:AddTargetModel({690372739}, {
    options = {
        {
            event = "coffee:buy",
            icon = "fas fa-coffee",
            label = "Coffee",
            item = "coffee", -- custom parameter
            price = 5 -- custom parameter
        },
    },
    distance = 2.5
})

RegisterNetEvent('coffee:buy')
AddEventHandler('coffee:buy',function(data)
    ESX.ShowNotification("You purchased a " .. data.item .. " for $" .. data.price .. ". Enjoy!")
    -- server event to buy the item here
end)
```
