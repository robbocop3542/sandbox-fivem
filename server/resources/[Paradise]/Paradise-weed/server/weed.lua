_plants = {}

AddEventHandler("Weed:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Database = exports["Paradise-base"]:FetchComponent("Database")
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Logger = exports["Paradise-base"]:FetchComponent("Logger")
	Middleware = exports["Paradise-base"]:FetchComponent("Middleware")
	Logger = exports["Paradise-base"]:FetchComponent("Logger")
	Utils = exports["Paradise-base"]:FetchComponent("Utils")
	Locations = exports["Paradise-base"]:FetchComponent("Locations")
	Game = exports["Paradise-base"]:FetchComponent("Game")
	Weed = exports["Paradise-base"]:FetchComponent("Weed")
	Routing = exports["Paradise-base"]:FetchComponent("Routing")
	Fetch = exports["Paradise-base"]:FetchComponent("Fetch")
	Inventory = exports["Paradise-base"]:FetchComponent("Inventory")
	Execute = exports["Paradise-base"]:FetchComponent("Execute")
	Routing = exports["Paradise-base"]:FetchComponent("Routing")
	Tasks = exports["Paradise-base"]:FetchComponent("Tasks")
	Wallet = exports["Paradise-base"]:FetchComponent("Wallet")
	Reputation = exports["Paradise-base"]:FetchComponent("Reputation")
	WaitList = exports["Paradise-base"]:FetchComponent("WaitList")
	Chat = exports["Paradise-base"]:FetchComponent("Chat")
	Status = exports["Paradise-base"]:FetchComponent("Status")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Weed", {
		"Database",
		"Callbacks",
		"Logger",
		"Middleware",
		"Logger",
		"Execute",
		"Utils",
		"Locations",
		"Game",
		"Routing",
		"Fetch",
		"Weed",
		"Inventory",
		"Routing",
		"Tasks",
		"Wallet",
		"Reputation",
		"WaitList",
		"Chat",
		"Status",
	}, function(error)
		if #error > 0 then
			return
		end -- Do something to handle if not all dependencies loaded
		RetrieveComponents()
		Startup()
		RegisterMiddleware()
		RegisterCallbacks()
		RegisterTasks()
		RegisterItems()
	end)
end)

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["Paradise-base"]:RegisterComponent("Weed", WEED)
end)

function getStageByPct(pct)
	local stagePct = 100 / (#Plants - 1)
	return math.floor((pct / stagePct) + 1.5)
end

function checkNearPlant(source, id)
	local coords = GetEntityCoords(GetPlayerPed(source))
	if _plants[id] ~= nil then
		return #(
				vector3(coords.x, coords.y, coords.z)
				- vector3(_plants[id].plant.location.x, _plants[id].plant.location.y, _plants[id].plant.location.z)
			) <= 5
	else
		return false
	end
end

WEED = {
	Planting = {
		Set = function(self, id, isUpdate, skipEvent)
			if _plants[id] ~= nil then
				local stage = getStageByPct(_plants[id].plant.growth)
				_plants[id].stage = stage

				if skipEvent then
					return { id = id, plant = _plants[id], update = isUpdate }
				else
					TriggerClientEvent("Weed:Client:Objects:Update", -1, id, _plants[id], isUpdate)
				end
			end
		end,
		Delete = function(self, id, skipRemove)
			if _plants[id] ~= nil then
				_plants[id] = nil
				TriggerClientEvent("Weed:Client:Objects:Delete", -1, id)
			end
		end,
		Create = function(self, isMale, location, material)
			local p = promise.new()
			local weed = {
				isMale = isMale,
				location = location,
				growth = 0,
				output = 1,
				material = material,
				planted = os.time(),
				water = 100.0,
			}
			Database.Game:insertOne({
				collection = "weed",
				document = weed,
			}, function(success, results, insertedIds)
				if not success then
					return p:resolve(nil)
				end
				weed._id = insertedIds[1]
				return p:resolve(weed)
			end)
			return Citizen.Await(p)
		end,
	},
}
