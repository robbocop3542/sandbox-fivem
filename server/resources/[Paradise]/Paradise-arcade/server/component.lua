AddEventHandler("Arcade:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Fetch = exports["Paradise-base"]:FetchComponent("Fetch")
	Database = exports["Paradise-base"]:FetchComponent("Database")
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Logger = exports["Paradise-base"]:FetchComponent("Logger")
	Chat = exports["Paradise-base"]:FetchComponent("Chat")
	Middleware = exports["Paradise-base"]:FetchComponent("Middleware")
	Execute = exports["Paradise-base"]:FetchComponent("Execute")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Arcade", {
		"Fetch",
		"Database",
		"Callbacks",
		"Logger",
		"Chat",
		"Middleware",
		"Execute",
	}, function(error)
		if #error > 0 then
			return
		end -- Do something to handle if not all dependencies loaded
		RetrieveComponents()

		Callbacks:RegisterServerCallback("Arcade:Open", function(source, data, cb)
			local char = Fetch:CharacterSource(source)
			if char ~= nil then
				if Player(source).state.onDuty == "avast_arcade" then
					GlobalState["Arcade:Open"] = true
				end
			end
		end)

		Callbacks:RegisterServerCallback("Arcade:Close", function(source, data, cb)
			local char = Fetch:CharacterSource(source)
			if char ~= nil then
				if Player(source).state.onDuty == "avast_arcade" then
					GlobalState["Arcade:Open"] = false
				end
			end
		end)
	end)
end)
