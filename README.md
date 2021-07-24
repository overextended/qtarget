# Expermiental build
##### I am trying to keep compatibility with bt-target as much as possible. Current changes have only been tested with the dumpsters from linden_inventory.
###### This code allows for additive options to targets, rather than replacing all available options. You can also remove an option based on the model and event name.
```lua
exports['qtarget']:RemoveTargetModel(Config.Dumpsters}, {
	'linden_inventory:openDumpster'
})
```

## Overview
##### qTarget is a high performance targeting solution that allows interaction with any predefined entity, model, entity type, or polyzone. At the mere cost of 0.04~0.06 while activated you can easily and safely replace markers and distance checking, instead relying on intuitive design to improve player experiences.

### Features 
- Maintains compatibility with bt-target while providing improved utility and performance
- Optimised and improved raycasting function allows interaction with a wider range of entities
- Add generic options to apply for all players, peds, vehicles, or objects
- Trigger an event or function after clicking an option, with the ability to pass any data through
- Define distance on a per-option or overall basis when triggering qtarget function exports
- Ability to redefine or remove options, and add new options without replacing old ones
- Update option list when moving towards or away from a target with variable distances on their options
- Support for entity bones, with builtin tables for opening doors
- Support checking for job, items, or specific entities
- Utilise the `canInteract` function for advanced checks to show or hide an option based on any trigger
- Improved support when using `linden_inventory`


## [» Installation](https://github.com/QuantusRP/qtarget/wiki/Installation)
### Dependencies
#### [» ESX Legacy](https://github.com/esx-framework/esx-legacy)
#### [» PolyZone](https://github.com/mkafrin/PolyZone)
### Recommended
#### [» linden_inventory](https://github.com/thelindat/linden_inventory)
## [» Documentation](https://quantusrp.github.io/qtarget/)


## Preface
##### This resource is being actively developed and, as such, it is expected that there will be bugs, issues, and on occasion breaking commits. So long as you accept that this is a work in progress and not yet intended as a final product then we will provide support.

## Credits
- Primary development by [@thelindat](https://github.com/thelindat) and [@OfficialNoms](https://github.com/OfficialNoms)
- Inspired by, and based on, including using javascript from: [bt-target](https://github.com/brentN5/bt-target) by [@brentN5](https://github.com/brentN5)
- Motivation by the entire [Linden's discord](https://discord.gg/4V6VwvBEzQ) communtiy.
- Made for QuantusRP, our FiveM roleplaying server.

## Issues
Please use the GitHub issues system to report issues. 
