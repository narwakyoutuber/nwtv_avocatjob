fx_version 'adamant'

game 'gta5'

description 'nwtv_avocatjob'

version '1.0.2'

client_scripts {
	'@es_extended/locale.lua',
	'locales/fr.lua',
	'config.lua',
	'client/main.lua'
}

server_scripts {
	'@es_extended/locale.lua',
	'locales/fr.lua',
	'config.lua',
	'server/main.lua'
}

dependency 'es_extended'