fx_version "cerulean"
use_fxv2_oal 'yes'
lua54        'yes'
game { "gta5" }

author 'snakewiz'
description 'A flexible player customization script for FiveM.'
repository 'https://github.com/pedr0fontoura/fivem-appearance'
version '1.3.0'

client_script 'game/dist/index.js'

client_scripts {
	--'ox_esx_skin/client/constants.lua',
	--'ox_esx_skin/client/utils.lua',
	--'ox_esx_skin/client/customisation.lua',
	--'ox_esx_skin/client/nui.lua',
	'ox_esx_skin/client/main.lua',
	'ox_esx_skin/client/outfits.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'ox_esx_skin/server/main.lua'
}

files {
  'web/dist/index.html',
  'web/dist/assets/*.js',
  'locales/*.json',
  'peds.json',
  'tattoos.json'
}

ui_page 'web/dist/index.html'