AddEventHandler("Hospital:Shared:DependencyUpdate", PrisonHospitalComponents)
function PrisonHospitalComponents()
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Notification = exports["Paradise-base"]:FetchComponent("Notification")
	Damage = exports["Paradise-base"]:FetchComponent("Damage")
	Notification = exports["Paradise-base"]:FetchComponent("Notification")
	Targeting = exports["Paradise-base"]:FetchComponent("Targeting")
	Hospital = exports["Paradise-base"]:FetchComponent("Hospital")
	Progress = exports["Paradise-base"]:FetchComponent("Progress")
	PedInteraction = exports["Paradise-base"]:FetchComponent("PedInteraction")
	Escort = exports["Paradise-base"]:FetchComponent("Escort")
	Action = exports["Paradise-base"]:FetchComponent("Action")
	Polyzone = exports["Paradise-base"]:FetchComponent("Polyzone")
	Animations = exports["Paradise-base"]:FetchComponent("Animations")
	Inventory = exports["Paradise-base"]:FetchComponent("Inventory")
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
		"Polyzone",
		"Action",
		"Animations",
		"Inventory",
	}, function(error)
		if #error > 0 then
			return
		end
		PrisonHospitalComponents()
		PrisonHospitalInit()
		PrisonVisitation()
	end)
end)
