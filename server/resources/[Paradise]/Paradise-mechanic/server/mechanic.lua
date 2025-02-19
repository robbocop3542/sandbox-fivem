AddEventHandler("Apartments:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Database = exports["Paradise-base"]:FetchComponent("Database")
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Logger = exports["Paradise-base"]:FetchComponent("Logger")
	Utils = exports["Paradise-base"]:FetchComponent("Utils")
	Fetch = exports["Paradise-base"]:FetchComponent("Fetch")
	Mechanic = exports["Paradise-base"]:FetchComponent("Mechanic")
	Jobs = exports["Paradise-base"]:FetchComponent("Jobs")
	Inventory = exports["Paradise-base"]:FetchComponent("Inventory")
	Crafting = exports["Paradise-base"]:FetchComponent("Crafting")
	Vehicles = exports["Paradise-base"]:FetchComponent("Vehicles")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Mechanic", {
		"Database",
		"Callbacks",
		"Logger",
		"Utils",
		"Fetch",
		"Mechanic",
		"Jobs",
		"Inventory",
		"Crafting",
		"Vehicles",
	}, function(error)
		if #error > 0 then
			return
		end
		RetrieveComponents()
		RegisterCallbacks()

		RegisterMechanicItems()

		for k, v in ipairs(_mechanicShopStorageCrafting) do
			if v.partCrafting then
				for benchId, bench in ipairs(v.partCrafting) do
					Crafting:RegisterBench(string.format("mech-%s-%s", v.job, benchId), bench.label, bench.targeting, {
						x = bench.targeting.poly.coords.x,
						y = bench.targeting.poly.coords.y,
						z = bench.targeting.poly.coords.z,
						h = bench.targeting.poly.options.heading,
					}, {
						job = {
							id = v.job,
							onDuty = true,
						},
					}, bench.recipes, bench.canUseSchematics)
				end
			end

			if v.partStorage then
				for storageId, storage in ipairs(v.partStorage) do
					Inventory.Poly:Create(storage)
				end
			end
		end
	end)
end)

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["Paradise-base"]:RegisterComponent("Mechanic", MECHANIC)
end)

MECHANIC = {}
