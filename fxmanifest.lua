fx_version 'adamant'

game 'gta5'
description 'ESX Skin'
version '1.10.5'
lua54 'yes'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'config.lua',
	'server/server.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'client/client.lua'
}

dependencies {
	'es_extended',
	'skinchanger'
}
