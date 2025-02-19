AddEventHandler("Finance:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Fetch = exports["Paradise-base"]:FetchComponent("Fetch")
	Utils = exports["Paradise-base"]:FetchComponent("Utils")
	Execute = exports["Paradise-base"]:FetchComponent("Execute")
	Database = exports["Paradise-base"]:FetchComponent("Database")
	Middleware = exports["Paradise-base"]:FetchComponent("Middleware")
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Chat = exports["Paradise-base"]:FetchComponent("Chat")
	Logger = exports["Paradise-base"]:FetchComponent("Logger")
	Generator = exports["Paradise-base"]:FetchComponent("Generator")
	Phone = exports["Paradise-base"]:FetchComponent("Phone")
	Crypto = exports["Paradise-base"]:FetchComponent("Crypto")
	Banking = exports["Paradise-base"]:FetchComponent("Banking")
	Billing = exports["Paradise-base"]:FetchComponent("Billing")
	Loans = exports["Paradise-base"]:FetchComponent("Loans")
	Wallet = exports["Paradise-base"]:FetchComponent("Wallet")
	Tasks = exports["Paradise-base"]:FetchComponent("Tasks")
	Jobs = exports["Paradise-base"]:FetchComponent("Jobs")
	Vehicles = exports["Paradise-base"]:FetchComponent("Vehicles")
	Inventory = exports["Paradise-base"]:FetchComponent("Inventory")
	Properties = exports["Paradise-base"]:FetchComponent("Properties")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Finance", {
		"Fetch",
		"Utils",
		"Execute",
		"Chat",
		"Database",
		"Middleware",
		"Callbacks",
		"Logger",
		"Generator",
		"Phone",
		"Wallet",
		"Banking",
		"Billing",
		"Loans",
		"Crypto",
		"Jobs",
		"Tasks",
		"Vehicles",
		"Inventory",
		"Properties",
	}, function(error)
		if #error > 0 then
			exports["Paradise-base"]:FetchComponent("Logger"):Critical("Finance", "Failed To Load All Dependencies")
			return
		end
		RetrieveComponents()

		TriggerEvent("Finance:Server:Startup")
	end)
end)
