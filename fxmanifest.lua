fx_version 'cerulean'

author 'Envi-Scripts'
description 'Interaction Menus'
version '1.2.0'

game 'gta5'
lua54 'yes'
 
client_scripts {
	'client/pedPersonality.lua',
	'client/*.lua',
}
 
shared_scripts {
	'config.lua',
	'@ox_lib/init.lua'
}

files {
    'ui/**'
}

ui_page 'ui/index.html'