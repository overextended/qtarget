--[[ FX Information ]]--
fx_version   'cerulean'
-- use_fxv2_oal 'yes'	Pending fix for vector results (https://forum.cfx.re/t/use-fxv2-oal-lua54-break-raycast-vector-results/4772649)
lua54        'yes'
game         'gta5'

--[[ Resource Information ]]--
name         'qtarget'
author       'Linden, Noms'
version      '2.0.0'
repository   'https://github.com/overextended/qtarget'
description  'An optimised targetting solution, based on bt-target'

--[[ Manifest ]]--
dependencies {
	'PolyZone'
}

ui_page 'html/index.html'

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
	'init.lua',
	'client.lua',
}

files {
	'data/*.lua',
	'html/index.html',
	'html/css/style.css',
	'html/js/script.js'
}
