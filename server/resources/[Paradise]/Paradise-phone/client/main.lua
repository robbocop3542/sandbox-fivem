_openCd = false -- Prevents spamm open/close
_settings = {}
_loggedIn = false

local _payphones = {
	`p_phonebox_02_s`,
	`p_phonebox_01b_s`,
	`prop_phonebox_01a`,
	`prop_phonebox_01b`,
	`prop_phonebox_01c`,
	`prop_phonebox_02`,
	`prop_phonebox_03`,
	`prop_phonebox_04`,
	`ch_chint02_phonebox001`,
	`sf_prop_sf_phonebox_01b_s`,
	`sf_prop_sf_phonebox_01b_straight`,
}

local _ignoreEvents = {
	"Health",
	"HP",
	"Armor",
	"Status",
	"Damage",
	"Wardrobe",
	"Animations",
	"Ped",
	"PhoneSettings",
}

AddEventHandler("Phone:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Logger = exports["Paradise-base"]:FetchComponent("Logger")
	Phone = exports["Paradise-base"]:FetchComponent("Phone")
	Notification = exports["Paradise-base"]:FetchComponent("Notification")
	UISounds = exports["Paradise-base"]:FetchComponent("UISounds")
	Sounds = exports["Paradise-base"]:FetchComponent("Sounds")
	Hud = exports["Paradise-base"]:FetchComponent("Hud")
	Keybinds = exports["Paradise-base"]:FetchComponent("Keybinds")
	Interaction = exports["Paradise-base"]:FetchComponent("Interaction")
	Inventory = exports["Paradise-base"]:FetchComponent("Inventory")
	Hud = exports["Paradise-base"]:FetchComponent("Hud")
	Targeting = exports["Paradise-base"]:FetchComponent("Targeting")
	ListMenu = exports["Paradise-base"]:FetchComponent("ListMenu")
	Labor = exports["Paradise-base"]:FetchComponent("Labor")
	Jail = exports["Paradise-base"]:FetchComponent("Jail")
	Blips = exports["Paradise-base"]:FetchComponent("Blips")
	Reputation = exports["Paradise-base"]:FetchComponent("Reputation")
	Polyzone = exports["Paradise-base"]:FetchComponent("Polyzone")
	NetSync = exports["Paradise-base"]:FetchComponent("NetSync")
	Vehicles = exports["Paradise-base"]:FetchComponent("Vehicles")
	Progress = exports["Paradise-base"]:FetchComponent("Progress")
	Jobs = exports["Paradise-base"]:FetchComponent("Jobs")
	Properties = exports["Paradise-base"]:FetchComponent("Properties")
	InfoOverlay = exports["Paradise-base"]:FetchComponent("InfoOverlay")
	Input = exports["Paradise-base"]:FetchComponent("Input")
	Animations = exports["Paradise-base"]:FetchComponent("Animations")
	Notifications = exports["Paradise-base"]:FetchComponent("Notifications")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Phone", {
		"Callbacks",
		"Logger",
		"Phone",
		"Notification",
		"UISounds",
		"Sounds",
		"Hud",
		"Keybinds",
		"Interaction",
		"Inventory",
		"Hud",
		"Targeting",
		"ListMenu",
		"Labor",
		"Jail",
		"Blips",
		"Reputation",
		"Polyzone",
		"NetSync",
		"Vehicles",
		"Progress",
		"Jobs",
		"Properties",
		"InfoOverlay",
		"Input",
		"Animations",
		"Notifications",
	}, function(error)
		if #error > 0 then
			return
		end -- Do something to handle if not all dependencies loaded
		RetrieveComponents()
		Keybinds:Add("phone_toggle", "M", "keyboard", "Phone - Open/Close", function()
			if Phone == nil then
				return
			end

			TogglePhone()
		end)

		Keybinds:Add("phone_ansend", "", "keyboard", "Phone - Accept/End Call", function()
			if Phone == nil then
				return
			end

			if _call ~= nil then
				if _call.state == 1 then
					Phone.Call:Accept()
				else
					Phone.Call:End()
				end
			end
		end)

		Keybinds:Add("phone_answer", "", "keyboard", "Phone - Accept Call", function()
			if Phone == nil then
				return
			end

			if _call ~= nil then
				if _call.state == 1 then
					Phone.Call:Accept()
				end
			end
		end)

		Keybinds:Add("phone_end", "", "keyboard", "Phone - End Call", function()
			if Phone == nil then
				return
			end

			if _call ~= nil then
				Phone.Call:End()
			end
		end)

		Keybinds:Add("phone_mute", "", "keyboard", "Phone - Mute/Unmute Sound", function()
			if Phone == nil then
				return
			end

			if _settings.volume > 0 then
				_settings.volume = 0
				Sounds.Play:One("mute.ogg", 0.1)
			else
				_settings.volume = 100
				Sounds.Play:One("unmute.ogg", 0.1)
			end
			Callbacks:ServerCallback("Phone:Settings:Update", {
				type = "volume",
				val = _settings.volume,
			})

			-- Send this manually since we're blocking PhoneSettings
			-- updates bcuz react rerendering makes me want to cry
			SendNUIMessage({
				type = "UPDATE_DATA",
				data = {
					type = "player",
					id = "PhoneSettings",
					key = "volume",
					data = _settings.volume,
				},
			})
		end)

		for k, v in ipairs(_payphones) do
			Targeting:AddObject(v, "phone-rotary", {
				{
					icon = "phone-plus",
					text = "Use Payphone",
					event = "Phone:Client:Payphone",
					minDist = 2.0,
					isEnabled = function()
						return not Phone:IsOpen() and not Phone.Call:Status()
					end,
				},
			}, 3.0)
		end
	end)
end)

AddEventHandler("Phone:Client:Payphone", function(entity, data)
	if entity.entity ~= nil then
		Phone:OpenPayphone()
	end
end)

AddEventHandler("Characters:Client:Updated", function(key)
	if hasValue(_ignoreEvents, key) then
		return
	end

	_settings = LocalPlayer.state.Character:GetData("PhoneSettings")
	Phone.Data:Set("player", LocalPlayer.state.Character:GetData())

	if
		key == "States"
		and LocalPlayer.state.phoneOpen
		and (not hasValue(LocalPlayer.state.Character:GetData("States"), "PHONE"))
	then
		Phone:Close(true)
	end
end)

RegisterNetEvent("Job:Client:DutyChanged", function(state)
	Phone.Data:Set("onDuty", state)
end)

RegisterNetEvent("UI:Client:Reset", function(manual)
	SetNuiFocus(false, false)
	SendNUIMessage({
		type = "UI_RESET",
		data = {},
	})

	if manual then
		TriggerServerEvent("Phone:Server:UIReset")
		if LocalPlayer.state.phoneOpen then
			Phone:Close()
		end
	end
end)

AddEventHandler("UI:Client:Close", function(context)
	if context ~= "phone" then
		Phone:Close()
	end
end)

AddEventHandler("Ped:Client:Died", function()
	if LocalPlayer.state.phoneOpen then
		Phone:Close()
	end
end)

RegisterNetEvent("Phone:Client:SetApps", function(apps)
	PHONE_APPS = apps
	SendNUIMessage({
		type = "SET_APPS",
		data = apps,
	})
end)

local shareTypes = {
	documents = "A document was shared with you",
	contacts = "Contact details were shared with you",
}

RegisterNetEvent("Phone:Client:ReceiveShare", function(share, time)
	Phone.Notification:Add("Received QuickShare", shareTypes[share.type], time, 7500, {
		color = "#18191e",
		label = "Share",
		icon = "share-nodes",
	}, {
		view = "USE_SHARE",
	}, nil)
	Phone:ReceiveShare(share)
end)

AddEventHandler("Characters:Client:Spawn", function()
	_loggedIn = true

	while Phone == nil do
		Citizen.Wait(1)
	end

	if LocalPlayer.state.Character then
		local settings = LocalPlayer.state.Character:GetData("PhoneSettings")
		if settings then
			Phone:SetExpanded(settings.Expanded)
		end
	end

	Citizen.CreateThread(function()
		while _loggedIn do
			SendNUIMessage({
				type = "SET_TIME",
				data = GlobalState["Sync:Time"],
			})
			Citizen.Wait(15000)
		end
	end)

	CreateBizPhones()
end)

RegisterNetEvent("Characters:Client:Logout", function()
	_loggedIn = false

	CleanupBizPhones()
	fucksound()
end)

function hasValue(tbl, value)
	for k, v in ipairs(tbl or {}) do
		if v == value or (type(v) == "table" and hasValue(v, value)) then
			return true
		end
	end
	return false
end

function hasPhone(cb)
	cb(true)
end

function IsInCall()
	return false
end

function TogglePhone()
	if not _loggedIn then
		return
	end
	if not _openCd then
		if not Hud:IsDisabled() then
			if not Jail:IsJailed() and hasValue(LocalPlayer.state.Character:GetData("States"), "PHONE") then
				Phone:Open()
			else
				Notification:Error("You Don't Have a Phone", 2000)
				LocalPlayer.state.phoneOpen = false
			end
		else
			Phone:Close()
		end

		if not IsPedInAnyVehicle(PlayerPedId(), true) then
			DisplayRadar(LocalPlayer.state.phoneOpen or hasValue(LocalPlayer.state.Character:GetData("States"), "GPS"))
		end
	end
end

AddEventHandler("Phone:Client:OpenLimited", function()
	Phone:OpenLimited()
end)

AddEventHandler("Ped:Client:Died", function()
	Phone:Close(true)
end)

RegisterNUICallback("CDExpired", function(data, cb)
	cb("OK")
	_openCd = false
end)

RegisterNUICallback("Home", function(data, cb)
	cb("OK")
	Callbacks:ServerCallback("Phone:Apps:Home", data)
end)

RegisterNUICallback("Dock", function(data, cb)
	cb("OK")
	Callbacks:ServerCallback("Phone:Apps:Dock", data)
end)

RegisterNUICallback("Reorder", function(data, cb)
	cb("OK")
	Callbacks:ServerCallback("Phone:Apps:Reorder", data)
end)

RegisterNUICallback("UpdateAlias", function(data, cb)
	Callbacks:ServerCallback("Phone:UpdateAlias", data, cb)
end)

RegisterNUICallback("UpdateProfile", function(data, cb)
	Callbacks:ServerCallback("Phone:UpdateProfile", data, cb)
end)

RegisterNetEvent("Phone:Client:RestorePosition", function(data)
	SendNUIMessage({
		type = "SET_POSITION",
		data = data,
	})
end)

RegisterNUICallback("Phone:SavePosition", function(data, cb)
	cb("OK")
	Callbacks:ServerCallback("Phone:SavePosition", data)
end)

RegisterNUICallback("AcceptPopup", function(data, cb)
	cb("OK")
	if data.data ~= nil and data.data.server then
		TriggerServerEvent(data.event, data.data)
	else
		TriggerEvent(data.event, data.data)
	end
end)

RegisterNUICallback("CancelPopup", function(data, cb)
	cb("OK")
	if data.data ~= nil and data.data.server then
		TriggerServerEvent(data.event, data.data)
	else
		TriggerEvent(data.event, data.data)
	end
end)

RegisterNUICallback("SaveShare", function(data, cb)
	if data.type == "contacts" then
		Callbacks:ServerCallback("Phone:Contacts:Create", data.data, function(nId)
			cb(nId)
			if nId then
				Phone.Data:Add("contacts", {
					id = nId,
					name = data.data.name,
					number = data.data.number,
					color = data.data.color,
					favorite = false,
				})
			end
		end)
	elseif data.type == "documents" then
		Callbacks:ServerCallback("Phone:Documents:RecieveShare", data.data, function(success)
			cb(success)
			if success then
				if success.update then
					Phone.Data:Update("myDocuments", success.id, success)
				else
					Phone.Data:Add("myDocuments", success)
				end
			end
		end)
	else
		cb(false)
	end
end)

RegisterNUICallback("ShareMyContact", function(data, cb)
	cb(true)
	Callbacks:ServerCallback("Phone:ShareMyContact", {})
end)
