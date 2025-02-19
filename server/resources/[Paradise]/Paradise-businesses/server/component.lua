_pickups = {}

AddEventHandler("Businesses:Shared:DependencyUpdate", RetrieveComponents)
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
	Jobs = exports["Paradise-base"]:FetchComponent("Jobs")
	Vehicles = exports["Paradise-base"]:FetchComponent("Vehicles")
	Inventory = exports["Paradise-base"]:FetchComponent("Inventory")
	Wallet = exports["Paradise-base"]:FetchComponent("Wallet")
	Crafting = exports["Paradise-base"]:FetchComponent("Crafting")
	Banking = exports["Paradise-base"]:FetchComponent("Banking")
	MDT = exports["Paradise-base"]:FetchComponent("MDT")
	Laptop = exports["Paradise-base"]:FetchComponent("Laptop")
	StorageUnits = exports["Paradise-base"]:FetchComponent("StorageUnits")
	Reputation = exports["Paradise-base"]:FetchComponent("Reputation")
	Status = exports["Paradise-base"]:FetchComponent("Status")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Businesses", {
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
		"Jobs",
		"Vehicles",
		"Inventory",
		"Wallet",
		"Crafting",
		"Banking",
		"MDT",
		"Laptop",
		"StorageUnits",
		"Reputation",
		"Status",
	}, function(error)
		if #error > 0 then
			exports["Paradise-base"]:FetchComponent("Logger"):Critical("Businesses", "Failed To Load All Dependencies")
			return
		end
		RetrieveComponents()

		TriggerEvent("Businesses:Server:Startup")

		Middleware:Add("Characters:Spawning", function(source)
			TriggerClientEvent(
				"Taco:SetQueue",
				source,
				{ counter = GlobalState["TacoShop:Counter"], item = GlobalState["TacoShop:CurrentItem"] }
			)
		end, 2)

		Middleware:Add("Characters:Spawning", function(source)
			TriggerLatentClientEvent("Businesses:Client:CreatePoly", source, 50000, _pickups)
		end, 2)

		Startup()
	end)
end)

function Startup()
	for k, v in ipairs(Config.Businesses) do
		Logger:Trace("Businesses", string.format("Registering Business ^3%s^7", v.Name))
		if v.Benches then
			for benchId, bench in pairs(v.Benches) do
				-- Logger:Trace(
				-- 	"Businesses",
				-- 	string.format("Registering Crafting Bench ^2%s^7 For ^3%s^7", bench.label, v.Name)
				-- )

				if bench.targeting.manual then
					Crafting:RegisterBench(string.format("%s-%s", v.Job, benchId), bench.label, bench.targeting, {}, {
						job = {
							id = v.Job,
							onDuty = true,
						},
					}, bench.recipes)
				else
					Crafting:RegisterBench(string.format("%s-%s", k, benchId), bench.label, bench.targeting, {
						x = 0,
						y = 0,
						z = bench.targeting.poly.coords.z,
						h = bench.targeting.poly.options.heading,
					}, {
						job = {
							id = v.Job,
							onDuty = true,
						},
					}, bench.recipes)
				end
			end
		end

		if v.Storage then
			for _, storage in pairs(v.Storage) do
				-- Logger:Trace(
				-- 	"Businesses",
				-- 	string.format("Registering Poly Inventory ^2%s^7 For ^3%s^7", storage.id, v.Name)
				-- )
				Inventory.Poly:Create(storage)
			end
		end

		if v.Pickups then
			for num, pickup in pairs(v.Pickups) do
				table.insert(_pickups, pickup.id)
				pickup.num = num
				pickup.job = v.Job
				pickup.jobName = v.Name
				GlobalState[string.format("Businesses:Pickup:%s", pickup.id)] = pickup
			end
		end
	end
end
