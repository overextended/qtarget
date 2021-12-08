local exports = exports.qtarget

AddEventHandler('qtarget:debug', function(data)
	print( 'Entity: '..data.entity..'', 'Type: '..GetEntityType(data.entity)..'' )
	if data.remove then
		exports:RemoveTargetEntity(data.entity, {
			'HelloWorld'
		})
	else
		exports:AddTargetEntity(data.entity, {
			options = {
				{
					event = 'qtarget:debug',
					icon = 'fas fa-box-circle-check',
					label = 'HelloWorld',
					remove = true
				},
			},
			distance = 3.0
		})
	end

end)

exports:Ped({
	options = {
		{
			event = 'qtarget:debug',
			icon = 'fas fa-male',
			label = '(Debug) Ped',
		},
	},
	distance = Config.MaxDistance
})

exports:Vehicle({
	options = {
		{
			event = 'qtarget:debug',
			icon = 'fas fa-car',
			label = '(Debug) Vehicle',
		},
	},
	distance = Config.MaxDistance
})

exports:Object({
	options = {
		{
			event = 'qtarget:debug',
			icon = 'fas fa-cube',
			label = '(Debug) Object',
		},
	},
	distance = Config.MaxDistance
})

exports:Player({
	options = {
		{
			event = 'qtarget:debug',
			icon = 'fas fa-cube',
			label = '(Debug) Player',
		},
	},
	distance = Config.MaxDistance
})