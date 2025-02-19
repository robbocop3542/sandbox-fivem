EVIDENCE_CACHE = {}

RegisterNetEvent("Evidence:Server:RecieveEvidence", function(newEvidence)
	local _src = source

	local time = os.time()

	for k, v in ipairs(newEvidence) do
		v.id = string.format("%s-%s", os.date("%d%m%y-%H%M%S", time), 100000 + #EVIDENCE_CACHE)
		v.time = GetGameTimer()
		v.client = _src

		table.insert(EVIDENCE_CACHE, v)
	end
end)

AddEventHandler("Evidence:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Fetch = exports["Paradise-base"]:FetchComponent("Fetch")
	Utils = exports["Paradise-base"]:FetchComponent("Utils")
	Execute = exports["Paradise-base"]:FetchComponent("Execute")
	Database = exports["Paradise-base"]:FetchComponent("Database")
	Middleware = exports["Paradise-base"]:FetchComponent("Middleware")
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Chat = exports["Paradise-base"]:FetchComponent("Chat")
	Logger = exports["Paradise-base"]:FetchComponent("Logger")
	Generator = exports["Paradise-base"]:FetchComponent("Generator")
	Phone = exports["Paradise-base"]:FetchComponent("Phone")
	Jobs = exports["Paradise-base"]:FetchComponent("Jobs")
	Vehicles = exports["Paradise-base"]:FetchComponent("Vehicles")
	Inventory = exports["Paradise-base"]:FetchComponent("Inventory")
	Sequence = exports["Paradise-base"]:FetchComponent("Sequence")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Evidence", {
		"Fetch",
		"Utils",
		"Execute",
		"Chat",
		"Database",
		"Middleware",
		"Callbacks",
		"Logger",
		"Generator",
		"Phone",
		"Jobs",
		"Vehicles",
		"Inventory",
		"Sequence",
	}, function(error)
		if #error > 0 then
			exports["Paradise-base"]:FetchComponent("Logger"):Critical("Evidence", "Failed To Load All Dependencies")
			return
		end
		RetrieveComponents()

		StartDeletionThread()

		Callbacks:RegisterServerCallback("Evidence:Fetch", function(source, data, cb)
			cb(EVIDENCE_CACHE)
		end)

		RegisterBallisticsCallbacks()
		RegisterBallisticsItemUses()
	end)
end)

local _deletionThead = false

function StartDeletionThread()
	if not _deletionThead then
		_deletionThead = true

		Citizen.CreateThread(function()
			while true do
				Citizen.Wait((60 * 1000) * 30)

				if #EVIDENCE_CACHE > 0 then
					local removed = 0
					local currentTimer = GetGameTimer()
					for k, v in ipairs(EVIDENCE_CACHE) do
						if (currentTimer - v.time) >= ((60 * 1000) * 120) then
							table.remove(EVIDENCE_CACHE, k)
							removed = removed + 1
						end
					end

					if removed > 0 then
						TriggerClientEvent("Evidence:Client:ForceUpdateEvidence", -1)
						collectgarbage()
					end
				end
			end
		end)
	end
end

AddEventHandler("Sync:Server:WeatherChange", function(weather)
	if IsWeatherTypeRain(weather) then
		-- Wash away evidence after a bit
		if #EVIDENCE_CACHE > 0 then
			Citizen.SetTimeout(45000, function()
				local removed = 0
				for k, v in ipairs(EVIDENCE_CACHE) do
					if v.type == "blood" then
						table.remove(EVIDENCE_CACHE, k)
						removed = removed + 1
					end
				end

				if removed > 0 then
					TriggerClientEvent("Evidence:Client:ForceUpdateEvidence", -1)
					collectgarbage()
				end
			end)
		end
	end
end)

RegisterNetEvent("Evidence:Server:PickupEvidence", function(evidenceId)
	local _src = source
	local char = Fetch:CharacterSource(source)
	if char and Jobs.Permissions:HasJob(_src, "police") then
		for k, v in ipairs(EVIDENCE_CACHE) do
			if v.id == evidenceId then
				if v.type == "paint_fragment" then
					Inventory:AddItem(char:GetData("SID"), "evidence-paint", 1, {
						EvidenceType = v.type,
						EvidenceId = v.id,
						EvidenceCoords = { x = v.coords.x, y = v.coords.y, z = v.coords.z },
						EvidenceColor = v.data and v.data.color,
					}, 1)
				elseif v.type == "projectile" then
					Inventory:AddItem(char:GetData("SID"), "evidence-projectile", 1, {
						EvidenceType = v.type,
						EvidenceId = v.id,
						EvidenceCoords = { x = v.coords.x, y = v.coords.y, z = v.coords.z },
						EvidenceWeapon = v.data and v.data.weapon,
						EvidenceAmmoType = (v.data and v.data.weapon) and v.data.weapon.ammoTypeName,
						EvidenceDegraded = v.data and v.data.tooDegraded,
					}, 1)
				elseif v.type == "casing" then
					Inventory:AddItem(char:GetData("SID"), "evidence-casing", 1, {
						EvidenceType = v.type,
						EvidenceId = v.id,
						EvidenceCoords = { x = v.coords.x, y = v.coords.y, z = v.coords.z },
						EvidenceWeapon = v.data and v.data.weapon,
						EvidenceAmmoType = (v.data and v.data.weapon) and v.data.weapon.ammoTypeName,
					}, 1)
				elseif v.type == "blood" then
					Inventory:AddItem(char:GetData("SID"), "evidence-dna", 1, {
						EvidenceType = v.type,
						EvidenceId = v.id,
						EvidenceCoords = { x = v.coords.x, y = v.coords.y, z = v.coords.z },
						EvidenceDNA = v.data and v.data.DNA,
						EvidenceBloodPool = v.data and v.data.IsBloodPool,
						EvidenceDegraded = v.data and v.data.tooDegraded,
					}, 1)
				end

				table.remove(EVIDENCE_CACHE, k)
				TriggerClientEvent("Evidence:Client:ForceUpdateEvidence", -1)
			end
		end
	end
end)

local pendingSend = false

RegisterServerEvent("Camara:CapturePhoto", function()
	local src = source
	local char = Fetch:CharacterSource(src)

	if char then
		if pendingSend then
			Execute:Client(src, "Notification", "Warn", "Please wait while current photo is uploading", 2000)
			return
		end
		pendingSend = true
		Execute:Client(src, "Notification", "Info", "Prepping Photo Upload", 2000)

		local options = {
			encoding = "webp",
			quality = 0.8,
		}

		exports["discord-screenshot"]:requestCustomClientScreenshotUploadToDiscord(
			src,
			tostring(GetConvar("evidence_selfie_webhook", "")),
			options,
			{
				username = "ParadiseRP Evidence",
				avatar_url = "https://i.ibb.co/1Yg16pK/icon.png",
				content = "",
				embeds = {
					{
						color = 0xff9900,
						title = string.format(
							"New Evidence Posted by @%s_%s",
							char:GetData("First"),
							char:GetData("Last")
						),
						author = {
							name = "ParadiseRP Evidence",
							icon_url = "https://i.ibb.co/1Yg16pK/icon.png",
						},
						footer = {
							text = string.format("%s %s | %s", char:GetData("First"), char:GetData("Last"), src),
						},
					},
				},
			},
			5000,
			function(error)
				if error then
					pendingSend = false
					Execute:Client(src, "Notification", "Error", "Error uploading photo!", 2000)
					print("^1ERROR: " .. error .. "^7")
				end
				pendingSend = false
				Execute:Client(src, "Notification", "Success", "Photo uploaded successfully!", 2000)
			end
		)
	end
end)
