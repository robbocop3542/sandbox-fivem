AddEventHandler("Drugs:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Inventory = exports["Paradise-base"]:FetchComponent("Inventory")
	Targeting = exports["Paradise-base"]:FetchComponent("Targeting")
	Progress = exports["Paradise-base"]:FetchComponent("Progress")
	Hud = exports["Paradise-base"]:FetchComponent("Hud")
	Notification = exports["Paradise-base"]:FetchComponent("Notification")
	ObjectPlacer = exports["Paradise-base"]:FetchComponent("ObjectPlacer")
	Minigame = exports["Paradise-base"]:FetchComponent("Minigame")
	ListMenu = exports["Paradise-base"]:FetchComponent("ListMenu")
	PedInteraction = exports["Paradise-base"]:FetchComponent("PedInteraction")
	Polyzone = exports["Paradise-base"]:FetchComponent("Polyzone")
	Buffs = exports["Paradise-base"]:FetchComponent("Buffs")
	Minigame = exports["Paradise-base"]:FetchComponent("Minigame")
	Status = exports["Paradise-base"]:FetchComponent("Status")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Drugs", {
		"Callbacks",
		"Inventory",
		"Targeting",
		"Progress",
		"Hud",
		"Notification",
		"ObjectPlacer",
		"Minigame",
		"ListMenu",
		"PedInteraction",
		"Polyzone",
		"Buffs",
		"Minigame",
		"Status",
	}, function(error)
		if #error > 0 then
			exports["Paradise-base"]:FetchComponent("Logger"):Critical("Drugs", "Failed To Load All Dependencies")
			return
		end
		RetrieveComponents()

		TriggerEvent("Drugs:Client:Startup")
	end)
end)
