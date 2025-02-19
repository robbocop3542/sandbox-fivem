ONLINE_CHARACTERS = {}

AddEventHandler("Characters:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Middleware = exports["Paradise-base"]:FetchComponent("Middleware")
	Database = exports["Paradise-base"]:FetchComponent("Database")
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	DataStore = exports["Paradise-base"]:FetchComponent("DataStore")
	Logger = exports["Paradise-base"]:FetchComponent("Logger")
	Database = exports["Paradise-base"]:FetchComponent("Database")
	Fetch = exports["Paradise-base"]:FetchComponent("Fetch")
	Logger = exports["Paradise-base"]:FetchComponent("Logger")
	Chat = exports["Paradise-base"]:FetchComponent("Chat")
	GlobalConfig = exports["Paradise-base"]:FetchComponent("Config")
	Routing = exports["Paradise-base"]:FetchComponent("Routing")
	Sequence = exports["Paradise-base"]:FetchComponent("Sequence")
	Reputation = exports["Paradise-base"]:FetchComponent("Reputation")
	Apartment = exports["Paradise-base"]:FetchComponent("Apartment")
	Phone = exports["Paradise-base"]:FetchComponent("Phone")
	Damage = exports["Paradise-base"]:FetchComponent("Damage")
	Punishment = exports["Paradise-base"]:FetchComponent("Punishment")
	Execute = exports["Paradise-base"]:FetchComponent("Execute")
	RegisterCommands()
	_spawnFuncs = {}
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Characters", {
		"Callbacks",
		"Database",
		"Middleware",
		"DataStore",
		"Logger",
		"Database",
		"Fetch",
		"Logger",
		"Chat",
		"Config",
		"Routing",
		"Sequence",
		"Reputation",
		"Apartment",
		"Phone",
		"Damage",
		"Punishment",
		"Execute",
	}, function(error)
		if #error > 0 then
			return
		end -- Do something to handle if not all dependencies loaded
		RetrieveComponents()
		RegisterCallbacks()
		RegisterMiddleware()
		Startup()
	end)
end)

CHARACTERS = {
	GetLastLocation = function(self, source)
		return _tempLastLocation[source] or false
	end,
}

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["Paradise-base"]:RegisterComponent("Characters", CHARACTERS)
end)