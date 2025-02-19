AddEventHandler("Hospital:Shared:DependencyUpdate", SAFDComponents)
function SAFDComponents()
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Notification = exports["Paradise-base"]:FetchComponent("Notification")
	Damage = exports["Paradise-base"]:FetchComponent("Damage")
	Notification = exports["Paradise-base"]:FetchComponent("Notification")
	Targeting = exports["Paradise-base"]:FetchComponent("Targeting")
	Hospital = exports["Paradise-base"]:FetchComponent("Hospital")
	Progress = exports["Paradise-base"]:FetchComponent("Progress")
	Blips = exports["Paradise-base"]:FetchComponent("Blips")
	PedInteraction = exports["Paradise-base"]:FetchComponent("PedInteraction")
	Escort = exports["Paradise-base"]:FetchComponent("Escort")
	Action = exports["Paradise-base"]:FetchComponent("Action")
	Polyzone = exports["Paradise-base"]:FetchComponent("Polyzone")
	Animations = exports["Paradise-base"]:FetchComponent("Animations")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Hospital", {
		"Callbacks",
		"Notification",
		"Damage",
		"Targeting",
		"Hospital",
		"Progress",
		"PedInteraction",
		"Escort",
		"Blips",
		"Polyzone",
		"Action",
		"Animations",
	}, function(error)
		if #error > 0 then
			return
		end
		SAFDComponents()
		SAFDInit()
	end)
end)
