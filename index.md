---
title: Documentation
---

## Parameters

| Key | Data Type | Example |
| --- | --- | --- |
| label | string | 'Revive target' |
| event | string | 'qtarget:reviveTarget' | 
| action | function | function(entity) ReviveTarget(entity) end | 

##### Only define an event or an action. If action is defined it will always trigger instead of event.

## Optional Parameters

| Key | Data Type | Default | Example |
| --- | --- | --- | --- |
| canInteract | function | - | function(entity) return IsEntityDead(entity) end |
| icon | string | - | 'fas fa-leaf' |
| required_item | string | - | 'water' |
| job | string | - | 'police' |
| job | table | - | {['police'] = 0, ['ambulance'] = 0} |
| distance | float | 2.0 | 4.0 |

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
