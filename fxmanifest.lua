fx_version 'cerulean'
game 'gta5'

author 'Linden, Noms'
description 'Optimised rewrite of bt-target'
repository 'https://github.com/QuantusRP/qtarget'
version '1.3.0'
lua54 'yes'

dependencies {
	"PolyZone"
}

ui_page 'html/index.html'

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
	'client/main.lua'
}

files {
	'config.lua',
	'html/index.html',
	'html/css/style.css',
	'html/js/script.js'
}
