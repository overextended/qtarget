local currentResourceName = GetCurrentResourceName()
local targeting = exports[currentResourceName]

AddEventHandler(currentResourceName..':debug', function(data)
	print('Entity: '..data.entity, 'Model: '..GetEntityModel(data.entity), 'Type: '..GetEntityType(data.entity))
	if data.remove then
		targeting:RemoveTargetEntity(data.entity, 'HelloWorld')
	else
		targeting:AddTargetEntity(data.entity, {
			options = {
				{
					event = currentResourceName..':debug',
					icon = 'fas fa-box-circle-check',
					label = 'HelloWorld',
					remove = true
				},
			},
			distance = 3.0
		})
	end

end)

targeting:Ped({
	options = {
		{
			event = currentResourceName..':debug',
			icon = 'fas fa-male',
			label = '(Debug) Ped',
		},
	},
	distance = Config.MaxDistance
})

targeting:Vehicle({
	options = {
		{
			event = currentResourceName..':debug',
			icon = 'fas fa-car',
			label = '(Debug) Vehicle',
		},
	},
	distance = Config.MaxDistance
})

targeting:Object({
	options = {
		{
			event = currentResourceName..':debug',
			icon = 'fas fa-cube',
			label = '(Debug) Object',
		},
	},
	distance = Config.MaxDistance
})

targeting:Player({
	options = {
		{
			event = currentResourceName..':debug',
			icon = 'fas fa-cube',
			label = '(Debug) Player',
		},
	},
	distance = Config.MaxDistance
})