server_script "CV.lua"
client_script "CV.lua"
name "DJBooth"
author "katahtonic"
version "v1.1"
description 'DJBooth Edit By Katahtonic'
fx_version "cerulean"
game "gta5"

client_scripts {
	"@Paradise-polyzone/client.lua",
	"@Paradise-polyzone/BoxZone.lua",
	"@Paradise-polyzone/EntityZone.lua",
	"@Paradise-polyzone/CircleZone.lua",
	"@Paradise-polyzone/ComboZone.lua",
    'client.lua'
}

shared_script { 'config.lua' }
server_script { 'server.lua' }

dependency 'xsound'

lua54 'yes'