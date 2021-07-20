## Overview
qTarget is a FiveM interaction / targeting solution that allows you to hold a key to activate a mode that will let players target specific objects or zones to be able to interact with. 

### Features 
* Support for Objects, PolyZones, EntityZones, and Entities
  * Future support planned for: Players, Peds, Vehicles, VehicleBones
* Passes data through to the event that is executed
* Utilizes `canInteract()`, a function you can define for each individual option to determine whether or not that option should be visible. 
* Utilizes `required_item`, which hooks into linden_inventory to check if you have an item before showing the option. 
* Utilizes a multi-functional `job` check per option, which can be a string or a table defining minimum grade to see an option.
* Disables combat while the interactive mode is active.
* Optimised to  an inch of its life - 0.04ms max recorded during testing. 

## Dependencies
* [ESX Legacy](https://github.com/esx-framework/esx-legacy) by the ESX Team
* [PolyZone](https://github.com/mkafrin/PolyZone) by mkafrin
## Recommended
* [linden_inventory](https://github.com/thelindat/linden_inventory) by Linden

## [» Installation](https://github.com/QuantusRP/qtarget/wiki/Installation)
## [» Documentation](https://github.com/QuantusRP/qtarget/wiki)

## Preface 
This is an actively developed resource. As such, it is to be expected that there are bugs, issues and - heaven forbid - breaking commits, occasionally. We will provide support for this resource, so long as you accept that this is currently a work in progress and not yet intended as a final product. 

With that being said, we're happy to release this resource as it is functional to a point matching or exceeding functionality to our previous forked versions of bt-target, which this resource is heavily based on, and uses the javascript from. 

## Credits
* Primary development by [@thelindat](https://github.com/thelindat) and [@OfficialNoms](https://github.com/OfficialNoms)
* Inspired by, and based on, including using javascript from: [bt-target](https://github.com/brentN5/bt-target) by [@brentN5](https://github.com/brentN5)
* Motivation by the entire [Linden's discord](https://discord.gg/4V6VwvBEzQ) communtiy.
* Made for QuantusRP, our FiveM roleplaying server.

## Issues
Please use the GitHub issues system to report issues. 