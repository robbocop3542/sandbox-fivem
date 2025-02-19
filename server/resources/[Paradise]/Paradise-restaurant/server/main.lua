AddEventHandler("Restaurant:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Database = exports["Paradise-base"]:FetchComponent("Database")
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Middleware = exports["Paradise-base"]:FetchComponent("Middleware")
	Logger = exports["Paradise-base"]:FetchComponent("Logger")
	Fetch = exports["Paradise-base"]:FetchComponent("Fetch")
	Inventory = exports["Paradise-base"]:FetchComponent("Inventory")
	Crafting = exports["Paradise-base"]:FetchComponent("Crafting")
	Jobs = exports["Paradise-base"]:FetchComponent("Jobs")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Restaurant", {
		"Database",
		"Callbacks",
		"Middleware",
		"Logger",
		"Fetch",
		"Inventory",
		"Crafting",
		"Jobs",
	}, function(error)
		if error then
		end

		RetrieveComponents()
		Startup()

		Middleware:Add("Characters:Spawning", function(source)
			RunRestaurantJobUpdate(source, true)
		end, 2)
	end)
end)

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["Paradise-base"]:RegisterComponent("Restaurant", _RESTAURANT)
end)

_RESTAURANT = {}

function RunRestaurantJobUpdate(source, onSpawn)
	local charJobs = Jobs.Permissions:GetJobs(source)
	local warmersList = {}
	for k, v in ipairs(charJobs) do
		local jobWarmers = _warmers[v.Id]
		if jobWarmers then
			table.insert(warmersList, jobWarmers)
		end
	end
	TriggerClientEvent("Restaurant:Client:CreatePoly", source, _pickups, warmersList, onSpawn)
end

AddEventHandler("Jobs:Server:JobUpdate", function(source)
	RunRestaurantJobUpdate(source)
end)
