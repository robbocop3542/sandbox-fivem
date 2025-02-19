_currentTree = {}
_treeLooted = {}
_currentDate = os.date("*t", os.time())
XMAS_MONTH = 12

AddEventHandler("Xmas:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Database = exports["Paradise-base"]:FetchComponent("Database")
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Middleware = exports["Paradise-base"]:FetchComponent("Middleware")
	Logger = exports["Paradise-base"]:FetchComponent("Logger")
	Utils = exports["Paradise-base"]:FetchComponent("Utils")
	Chat = exports["Paradise-base"]:FetchComponent("Chat")
	Fetch = exports["Paradise-base"]:FetchComponent("Fetch")
	Inventory = exports["Paradise-base"]:FetchComponent("Inventory")
	Loot = exports["Paradise-base"]:FetchComponent("Loot")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Xmas", {
		"Database",
		"Callbacks",
        "Middleware",
		"Logger",
		"Utils",
		"Chat",
		"Fetch",
		"Inventory",
		"Loot",
	}, function(error)
		if #error > 0 then
			return
		end -- Do something to handle if not all dependencies loaded
        
        RetrieveComponents()
        RegisterCommands()
        RegisterCallbacks()
		RegisterItems()
        Startup()
		StartThreading()
        
        Middleware:Add("Characters:Spawning", function(source)
			if _currentDate.month == XMAS_MONTH then
				local char = Fetch:CharacterSource(source)
				if char ~= nil then
					local sid = char:GetData("SID")
					TriggerClientEvent("Xmas:Client:Init", source, _currentDate.day, _currentTree, _treeLooted[sid] ~= nil)
				end
			end
        end, 2)
	end)
end)
