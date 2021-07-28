---
title: Installation
---

## Requirements
- [ESX Legacy](https://github.com/esx-framework/esx-legacy) is required for receiving the ESX shared object and keeping PlayerData updated
- [PolyZone](https://github.com/mkafrin/PolyZone) is required for zone checks
- [Intervals](https://github.com/thelindat/es_extended/blob/linden/imports.lua) are required for simple creation and deletion of threads

## Intervals
- **Recommended:** Replace 'es_extended/imports.lua' with the file linked above
- **Not recommended:** Paste the following snippet into 'qtarget/client/main.lua', at the very top

```lua
local CreateThread = CreateThread
local Wait = Wait

local Intervals = {}
local CreateInterval = function(name, interval, action, clear)
	local self = {interval = interval}
	CreateThread(function()
		local name, action, clear = name, action, clear
		repeat
			action()
			Wait(self.interval)
		until self.interval == -1
		if clear then clear() end
		Intervals[name] = nil
	end)
	return self
end

SetInterval = function(name, interval, action, clear)
	if Intervals[name] and interval then Intervals[name].interval = interval
	else
		Intervals[name] = CreateInterval(name, interval, action, clear)
	end
end

ClearInterval = function(name)
	if Intervals[name] then Intervals[name].interval = -1 end
end
```
