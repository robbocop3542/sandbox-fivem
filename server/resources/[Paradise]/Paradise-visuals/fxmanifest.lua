server_script "QS6.lua"
client_script "QS6.lua"
fx_version("cerulean")
lua54("yes")
game("gta5")
client_script("@Paradise-base/components/cl_error.lua")
client_script("@Paradise-pwnzor/client/check.lua")

files({
	"defaultsettings.dat",
	"visualsettings.dat",
})

client_scripts({
	"client/*.lua",
})

server_scripts({
	"server/*.lua",
})
