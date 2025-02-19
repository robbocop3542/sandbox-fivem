AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["Paradise-base"]:RegisterComponent("Pwnzor", PWNZOR)
end)

PWNZOR = PWNZOR or {}
