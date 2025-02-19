AddEventHandler("Jobs:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Logger = exports["Paradise-base"]:FetchComponent("Logger")
	Utils = exports["Paradise-base"]:FetchComponent("Utils")
	Notification = exports["Paradise-base"]:FetchComponent("Notification")
	Jobs = exports["Paradise-base"]:FetchComponent("Jobs")
	Polyzone = exports["Paradise-base"]:FetchComponent("Polyzone")
	Inventory = exports["Paradise-base"]:FetchComponent("Inventory")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Jobs", {
		"Callbacks",
		"Logger",
		"Utils",
		"Notification",
		"Jobs",
		"Polyzone",
		"Inventory",
	}, function(error)
		if #error > 0 then
			return
		end
		RetrieveComponents()
		RegisterMetalDetectors()
	end)
end)
