AddEventHandler("Buffs:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Buffs = exports["Paradise-base"]:FetchComponent("Buffs")
	Hud = exports["Paradise-base"]:FetchComponent("Hud")
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Progress = exports["Paradise-base"]:FetchComponent("Progress")
	Action = exports["Paradise-base"]:FetchComponent("Action")
	Keybinds = exports["Paradise-base"]:FetchComponent("Keybinds")
	ListMenu = exports["Paradise-base"]:FetchComponent("ListMenu")
	Notification = exports["Paradise-base"]:FetchComponent("Notification")
	Minigame = exports["Paradise-base"]:FetchComponent("Minigame")
	Interaction = exports["Paradise-base"]:FetchComponent("Interaction")
	Utils = exports["Paradise-base"]:FetchComponent("Utils")
	Phone = exports["Paradise-base"]:FetchComponent("Phone")
	Inventory = exports["Paradise-base"]:FetchComponent("Inventory")
	Weapons = exports["Paradise-base"]:FetchComponent("Weapons")
	Jail = exports["Paradise-base"]:FetchComponent("Jail")
	Animations = exports["Paradise-base"]:FetchComponent("Animations")
	Admin = exports["Paradise-base"]:FetchComponent("Admin")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Buffs", {
		"Buffs",
		"Hud",
		"Callbacks",
		"Action",
		"Progress",
		"Keybinds",
		"ListMenu",
		"Notification",
		"Minigame",
		"Interaction",
		"Utils",
		"Phone",
		"Inventory",
		"Weapons",
		"Jail",
		"Animations",
		"Admin",
	}, function(error)
		if #error > 0 then
			return
		end
		RetrieveComponents()
	end)
end)

local _runningIds = 1
local _buffDefs = {}

local _BUFFS = {
	RegisterBuff = function(self, id, icon, color, duration, type)
		_buffDefs[id] = {
			icon = icon,
			color = color,
			duration = duration,
			type = type,
		}
		SendNUIMessage({
			type = "REGISTER_BUFF",
			data = {
				id = id,
				data = {
					icon = icon,
					color = color,
					duration = duration,
					type = type,
				},
			},
		})
	end,
	ApplyBuff = function(self, buffId, val, override, options)
		SendNUIMessage({
			type = "BUFF_APPLIED",
			data = {
				instance = {
					buff = buffId,
					override = override,
					val = math.ceil(val or 0),
					options = options or {},
					startTime = GetCloudTimeAsInt(),
				},
			},
		})
	end,
	ApplyUniqueBuff = function(self, buffId, val, override, options)
		SendNUIMessage({
			type = "BUFF_APPLIED_UNIQUE",
			data = {
				instance = {
					buff = buffId,
					override = override,
					val = math.ceil(val or 0),
					options = options or {},
					startTime = GetCloudTimeAsInt(),
				},
			},
		})
	end,
	UpdateBuff = function(self, buffId, nVal)
		SendNUIMessage({
			type = "BUFF_UPDATED",
			data = {
				buff = buffId,
				val = nVal,
			},
		})
	end,
	IconOverride = function(self, buffId, override)
		SendNUIMessage({
			type = "BUFF_UPDATED",
			data = {
				buff = buffId,
				override = override,
			},
		})
	end,
	RemoveBuffType = function(self, buffId)
		SendNUIMessage({
			type = "REMOVE_BUFF_BY_TYPE",
			data = {
				type = buffId,
			},
		})
	end,
}

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["Paradise-base"]:RegisterComponent("Buffs", _BUFFS)
end)

RegisterNetEvent("Characters:Client:Spawned", function()
    _BUFFS:RegisterBuff("prog_mod", "mug-hot", "#D6451A", -1, "timed")
    _BUFFS:RegisterBuff("stress_ticks", "joint", "#de3333", -1, "timed")
    _BUFFS:RegisterBuff("heal_ticks", "suitcase-medical", "#52984a", -1, "timed")
    _BUFFS:RegisterBuff("armor_ticks", "dumbbell", "#4056b3", -1, "timed")
end)

RegisterNetEvent("Characters:Client:Logout", function()
    _BUFFS:RemoveBuffType("prog_mod")
    _BUFFS:RemoveBuffType("stress_ticks")
    _BUFFS:RemoveBuffType("heal_ticks")
    _BUFFS:RemoveBuffType("armor_ticks")
end)
