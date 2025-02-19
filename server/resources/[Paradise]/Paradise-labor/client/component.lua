AddEventHandler("Labor:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Logger = exports["Paradise-base"]:FetchComponent("Logger")
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Game = exports["Paradise-base"]:FetchComponent("Game")
	Phone = exports["Paradise-base"]:FetchComponent("Phone")
	PedInteraction = exports["Paradise-base"]:FetchComponent("PedInteraction")
	Interaction = exports["Paradise-base"]:FetchComponent("Interaction")
	Progress = exports["Paradise-base"]:FetchComponent("Progress")
	Minigame = exports["Paradise-base"]:FetchComponent("Minigame")
	Notification = exports["Paradise-base"]:FetchComponent("Notification")
	ListMenu = exports["Paradise-base"]:FetchComponent("ListMenu")
	Blips = exports["Paradise-base"]:FetchComponent("Blips")
	Polyzone = exports["Paradise-base"]:FetchComponent("Polyzone")
	Targeting = exports["Paradise-base"]:FetchComponent("Targeting")
	Hud = exports["Paradise-base"]:FetchComponent("Hud")
	Inventory = exports["Paradise-base"]:FetchComponent("Inventory")
	EmergencyAlerts = exports["Paradise-base"]:FetchComponent("EmergencyAlerts")
	Status = exports["Paradise-base"]:FetchComponent("Status")
	Labor = exports["Paradise-base"]:FetchComponent("Labor")
	Sounds = exports["Paradise-base"]:FetchComponent("Sounds")
	Properties = exports["Paradise-base"]:FetchComponent("Properties")
	Action = exports["Paradise-base"]:FetchComponent("Action")
	Sync = exports["Paradise-base"]:FetchComponent("Sync")
	Confirm = exports["Paradise-base"]:FetchComponent("Confirm")
	Utils = exports["Paradise-base"]:FetchComponent("Utils")
	Keybinds = exports["Paradise-base"]:FetchComponent("Keybinds")
	Reputation = exports["Paradise-base"]:FetchComponent("Reputation")
	NetSync = exports["Paradise-base"]:FetchComponent("NetSync")
	Vehicles = exports["Paradise-base"]:FetchComponent("Vehicles")
	Animations = exports["Paradise-base"]:FetchComponent("Animations")
	Weapons = exports["Paradise-base"]:FetchComponent("Weapons")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Labor", {
		"Logger",
		"Callbacks",
		"Game",
		"Phone",
		"PedInteraction",
		"Interaction",
		"Progress",
		"Minigame",
		"Notification",
		"ListMenu",
		"Blips",
		"Polyzone",
		"Targeting",
		"Hud",
		"Inventory",
		"EmergencyAlerts",
		"Status",
		"Labor",
		"Sounds",
		"Properties",
		"Action",
		"Sync",
		"Confirm",
		"Utils",
		"Keybinds",
		"Reputation",
		"NetSync",
		"Vehicles",
		"Animations",
		"Weapons",
	}, function(error)
		if #error > 0 then
			return
		end
		RetrieveComponents()
		TriggerEvent("Labor:Client:Setup")
	end)
end)

function Draw3DText(x, y, z, text)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local px, py, pz = table.unpack(GetGameplayCamCoords())

	SetTextScale(0.25, 0.25)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 245)
	SetTextOutline(true)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x, _y)
end

function PedFaceCoord(pPed, pCoords)
	TaskTurnPedToFaceCoord(pPed, pCoords.x, pCoords.y, pCoords.z)

	Citizen.Wait(100)

	while GetScriptTaskStatus(pPed, 0x574bb8f5) == 1 do
		Citizen.Wait(0)
	end
end

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["Paradise-base"]:RegisterComponent("Labor", LABOR)
end)

AddEventHandler("Labor:Client:AcceptRequest", function(data)
	Callbacks:ServerCallback("Labor:AcceptRequest", data)
end)

AddEventHandler("Labor:Client:DeclineRequest", function(data)
	Callbacks:ServerCallback("Labor:DeclineRequest", data)
end)

LABOR = {
	Get = {
		Jobs = function(self)
			local p = promise.new()
			Callbacks:ServerCallback("Labor:GetJobs", {}, function(jobs)
				p:resolve(jobs)
			end)
			return Citizen.Await(p)
		end,
		Groups = function(self)
			local p = promise.new()
			Callbacks:ServerCallback("Labor:GetGroups", {}, function(groups)
				p:resolve(groups)
			end)
			return Citizen.Await(p)
		end,
		Reputations = function(self)
			local p = promise.new()
			Callbacks:ServerCallback("Labor:GetReputations", {}, function(jobs)
				p:resolve(jobs)
			end)
			return Citizen.Await(p)
		end,
	},
}
