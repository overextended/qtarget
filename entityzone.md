# Entityzone options
```lua
exports.qtarget:AddEntityZone(name, targetentity, options, targetoptions)
```
##### Creates a polyzonebox around the entity, registers the defined options to display when targetting the surface of the entity.
```lua
exports.qtarget:AddEntityZone("nancy", npc, {
    name="nancy",
    debugPoly=false,
    useZ = true
        }, {
        options = {
            {
            event = "hospital:checkInNancy",
            icon = "far fa-comment",
            label = "Check In",
            },
            {
            event = "Duty event",
            icon = "fas fa-sign-out-alt",
            label = "Sign in / Sign out",
            job = "ambulance",
            },
        },
        distance = 2.5
    })  
```
##### Remove the zone after usage.

```lua
exports.qtarget:RemoveZone('nancy')
```
