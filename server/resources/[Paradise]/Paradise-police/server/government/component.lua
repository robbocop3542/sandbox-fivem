AddEventHandler("Handcuffs:Shared:DependencyUpdate", GovernmentComponents)
function GovernmentComponents()
	Fetch = exports["Paradise-base"]:FetchComponent("Fetch")
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Logger = exports["Paradise-base"]:FetchComponent("Logger")
	Execute = exports["Paradise-base"]:FetchComponent("Execute")
	Wallet = exports["Paradise-base"]:FetchComponent("Wallet")
	Inventory = exports["Paradise-base"]:FetchComponent("Inventory")
	Middleware = exports["Paradise-base"]:FetchComponent("Middleware")
end

_licenses = {
	drivers = { key = "Drivers", price = 1000 },
	weapons = { key = "Weapons", price = 2000 },
	hunting = { key = "Hunting", price = 800 },
	fishing = { key = "Fishing", price = 800 },
}

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Handcuffs", {
		"Callbacks",
		"Logger",
		"Fetch",
		"Execute",
		"Wallet",
		"Inventory",
		"Middleware",
	}, function(error)
		if #error > 0 then
			return
		end -- Do something to handle if not all dependencies loaded
		GovernmentComponents()

		Callbacks:RegisterServerCallback("Government:BuyID", function(source, data, cb)
			local char = Fetch:CharacterSource(source)
			if Wallet:Modify(source, -500) then
				Inventory:AddItem(char:GetData("SID"), "govid", 1, {}, 1)
			else
				Execute:Client(source, "Notification", "Error", "Not Enough Cash")
			end
		end)

		Callbacks:RegisterServerCallback("Government:BuyLicense", function(source, data, cb)
			if _licenses[data] ~= nil then
				local char = Fetch:CharacterSource(source)
				local licenses = char:GetData("Licenses")
				if Wallet:Modify(source, -_licenses[data].price) then
					if licenses[_licenses[data].key] ~= nil and not licenses[_licenses[data].key].Active then
						licenses[_licenses[data].key].Active = true
						char:SetData("Licenses", licenses)

						Middleware:TriggerEvent("Characters:ForceStore", source)
					else
						Execute:Client(source, "Notification", "Error", "Unable To Purchase License")
					end
				else
					Execute:Client(source, "Notification", "Error", "Not Enough Cash")
				end
			else
				Logger:Error(
					"Government",
					string.format("%s Tried To Buy Invalid License Type %s", char:GetData("SID"), data),
					{
						console = true,
						discord = true,
					}
				)
				Execute:Client(source, "Notification", "Error", "Unable To Purchase License")
			end
		end)

		Callbacks:RegisterServerCallback("Government:Client:DoWeaponsLicenseBuyPolice", function(source, data, cb)
			local char = Fetch:CharacterSource(source)
			if Jobs.Permissions:HasJob(source, "police") and char then
				local licenses = char:GetData("Licenses")
				if Wallet:Modify(source, -20) then
					licenses["Weapons"].Active = true
					char:SetData("Licenses", licenses)
					Middleware:TriggerEvent("Characters:ForceStore", source)
				else
					Execute:Client(source, "Notification", "Error", "Not Enough Cash")
				end
			else
				Execute:Client(source, "Notification", "Error", "You are Not PD")
			end
		end)

		-- Inventory.Poly:Create({
		-- 	id = "doj-chief-justice-safe",
		-- 	type = "box",
		-- 	coords = vector3(-586.32, -213.18, 42.84),
		-- 	width = 0.6,
		-- 	length = 1.0,
		-- 	options = {
		-- 		heading = 30,
		-- 		--debugPoly=true,
		-- 		minZ = 41.84,
		-- 		maxZ = 44.24,
		-- 	},
		-- 	data = {
		-- 		inventory = {
		-- 			invType = 46,
		-- 			owner = "doj-chief-justice-safe",
		-- 		},
		-- 	},
		-- })

		Inventory.Poly:Create({
			id = "doj-storage",
			type = "box",
			coords = vector3(-586.64, -203.5, 38.23),
			length = 0.8,
			width = 1.4,
			options = {
				heading = 30,
				--debugPoly=true,
				minZ = 37.23,
				maxZ = 39.43,
			},
			data = {
				inventory = {
					invType = 116,
					owner = "doj-storage",
				},
			},
		})
	end)
end)

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["Paradise-base"]:RegisterComponent("Government", _GOVT)
end)

_GOVT = {}

RegisterNetEvent("Government:Server:Gavel", function()
	TriggerClientEvent("Government:Client:Gavel", -1)
end)
