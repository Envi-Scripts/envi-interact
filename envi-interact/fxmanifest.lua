fx_version 'cerulean'

author 'Envi-Scripts'
description 'Interaction Menus'
version '1.0.0'

game 'gta5'
lua54 'yes'
 
client_scripts {
	'client/*.lua',
}
 
server_scripts {
	'server/*.lua',
}

shared_scripts {
	'config.lua',
	'@ox_lib/init.lua'
}

escrow_ignore {
    'config.lua',
}

files {
    'ui/**'
}

ui_page 'ui/index.html'