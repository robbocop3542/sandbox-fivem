local _timeout = false

AddEventHandler("Escort:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Utils = exports["Paradise-base"]:FetchComponent("Utils")
	Logger = exports["Paradise-base"]:FetchComponent("Logger")
	Game = exports["Paradise-base"]:FetchComponent("Game")
	Stream = exports["Paradise-base"]:FetchComponent("Stream")
	Keybinds = exports["Paradise-base"]:FetchComponent("Keybinds")
	Notification = exports["Paradise-base"]:FetchComponent("Notification")
	Targeting = exports["Paradise-base"]:FetchComponent("Targeting")
	Progress = exports["Paradise-base"]:FetchComponent("Progress")
	Hud = exports["Paradise-base"]:FetchComponent("Hud")
	Escort = exports["Paradise-base"]:FetchComponent("Escort")
	Vehicles = exports["Paradise-base"]:FetchComponent("Vehicles")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Escort", {
		"Callbacks",
		"Utils",
		"Logger",
		"Game",
		"Stream",
		"Keybinds",
		"Notification",
		"Targeting",
		"Progress",
		"Hud",
		"Escort",
		"Vehicles",
	}, function(error)
		if #error > 0 then
			return
		end
		RetrieveComponents()

		Keybinds:Add("escort", "k", "keyboard", "Escort", function()
			if _timeout then
				Notification:Error("Stop spamming you pepega.")
				return
			end
			_timeout = true
			DoEscort()
			Citizen.SetTimeout(1000, function()
				_timeout = false
			end)
		end)

		Callbacks:RegisterClientCallback("Escort:StopEscort", function(data, cb)
			DetachEntity(LocalPlayer.state.ped, true, true)
			cb(true)
		end)
	end)
end)

ESCORT = {
	DoEscort = function(self, target, tPlayer)
		if target ~= nil then
			if LocalPlayer.state.AllowEscorting == false then
				Notification:Error("Unable to escort in this location.")
				return
			end
			Callbacks:ServerCallback("Escort:DoEscort", {
				target = target,
				inVeh = IsPedInAnyVehicle(GetPlayerPed(tPlayer)),
				isSwimming = IsPedSwimming(LocalPlayer.state.ped),
			}, function(state)
				if state then
					StartEscortThread(tPlayer)
				end
			end)
		end
	end,
	StopEscort = function(self)
		Callbacks:ServerCallback("Escort:StopEscort", function() end)
	end,
}

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["Paradise-base"]:RegisterComponent("Escort", ESCORT)
end)

AddEventHandler("Interiors:Exit", function()
	if LocalPlayer.state.isEscorting ~= nil then
		Escort:StopEscort()
	end
end)

--[[ TODO 
Add Dragging When Dead 
Place In vehicle while Dead Slump Animation
Police Drag Maybe Cuff Also
Get In Trunk or Place in trunk???
]]
