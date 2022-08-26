# Deprecated / unsupported

qtarget has been largely unmaintained, receiving some occasional fixes and tweaks .
There are issues with the ways many features were implemented, some from trying maintain compatibility with bt-target, but mostly janky patches on top of underlying flaws.

Development on a replacement is ongoing at [ox_target](https://github.com/overextended/ox_target), which will try to implement _some_ compatibility; however it cannot cover everything and will not attempt to patch poor-design decisions.

Some issues will be patched in qtarget if necessary, but it is dead (and should have been long ago).

<br><br>

<h2 align='center'><a href='https://overextended.github.io/qtarget/'>» Installation and Documentation «</a></h2>

## Overview
##### qTarget is a high performance targeting solution that allows interaction with any predefined entity, model, entity type, or polyzone. At the mere cost of ~0.04ms while activated you can easily and safely replace markers and distance checking, instead relying on intuitive design to improve player experiences.


## Features 
- Maintains compatibility with bt-target while providing improved utility and performance
- Optimised and improved raycasting function allows interaction with a wider range of entities
- Add generic options to apply for all players, peds, vehicles, or objects
- Trigger an event or function after clicking an option, with the ability to pass any data through
- Define distance on a per-option or overall basis when triggering qtarget function exports
- Ability to redefine or remove options and add new options without replacing old ones
- Update the option list when moving towards or away from a target with variable distances on their options
- Support for entity bones, with built-in tables for opening vehicle doors
- Support checking for job, items, or specific entities
- Utilise the `canInteract` function for advanced checks to show or hide an option based on any trigger
- Improved support when using `ox_inventory`

## Preface
##### This resource is being actively developed and, as such, it is expected that there will be bugs, issues, and on occasion breaking commits. So long as you accept that this is a work in progress and not yet intended as a final product then we will provide support.

## Credits
- Primary development by [@thelindat](https://github.com/thelindat) and [@OfficialNoms](https://github.com/OfficialNoms)
- Inspired by, and based on, including using javascript from: [bt-target](https://github.com/brentN5/bt-target) by [@brentN5](https://github.com/brentN5)
- Motivation by the entire [Linden's discord](https://discord.gg/mEM6eYdXPm) communtiy.

## Issues
Please use the GitHub issues system to report issues. 
