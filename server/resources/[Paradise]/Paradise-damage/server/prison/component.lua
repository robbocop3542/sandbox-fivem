AddEventHandler("Damage:Shared:DependencyUpdate", PrisonHospitalComponents)
function PrisonHospitalComponents()
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Middleware = exports["Paradise-base"]:FetchComponent("Middleware")
	Fetch = exports["Paradise-base"]:FetchComponent("Fetch")
	Damage = exports["Paradise-base"]:FetchComponent("Damage")
	Hospital = exports["Paradise-base"]:FetchComponent("Hospital")
	Crypto = exports["Paradise-base"]:FetchComponent("Crypto")
	Phone = exports["Paradise-base"]:FetchComponent("Phone")
	Execute = exports["Paradise-base"]:FetchComponent("Execute")
	Chat = exports["Paradise-base"]:FetchComponent("Chat")
	Billing = exports["Paradise-base"]:FetchComponent("Billing")
	Inventory = exports["Paradise-base"]:FetchComponent("Inventory")
	Labor = exports["Paradise-base"]:FetchComponent("Labor")
	Jobs = exports["Paradise-base"]:FetchComponent("Jobs")
	Handcuffs = exports["Paradise-base"]:FetchComponent("Handcuffs")
	Ped = exports["Paradise-base"]:FetchComponent("Ped")
	Routing = exports["Paradise-base"]:FetchComponent("Routing")
	Pwnzor = exports["Paradise-base"]:FetchComponent("Pwnzor")
	Banking = exports["Paradise-base"]:FetchComponent("Banking")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("PrisonHospital", {
		"Callbacks",
		"Middleware",
		"Fetch",
		"Damage",
		"Hospital",
		"Crypto",
		"Phone",
		"Execute",
		"Chat",
		"Billing",
		"Inventory",
		"Labor",
		"Jobs",
		"Handcuffs",
		"Ped",
		"Routing",
		"Pwnzor",
		"Banking",
	}, function(error)
		if #error > 0 then
			return
		end -- Do something to handle if not all dependencies loaded
		PrisonHospitalComponents()
		PrisonHospitalCallbacks()
	end)
end)
