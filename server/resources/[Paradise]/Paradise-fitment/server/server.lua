AddEventHandler("Fitment:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Database = exports["Paradise-base"]:FetchComponent("Database")
	Utils = exports["Paradise-base"]:FetchComponent("Utils")
	Fetch = exports["Paradise-base"]:FetchComponent("Fetch")
	Logger = exports["Paradise-base"]:FetchComponent("Logger")
	Inventory = exports["Paradise-base"]:FetchComponent("Inventory")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Fitment", {
		"Fetch",
		"Logger",
		"Database",
		"Callbacks",
		"Utils",
		"Inventory",
	}, function(error)
		if #error > 0 then
			return
		end -- Do something to handle if not all dependencies loaded
		RetrieveComponents()

		Inventory.Items:RegisterUse("camber_controller", "Vehicles", function(source, item)
			Callbacks:ClientCallback(source, "Vehicles:UseCamberController", {}, function(veh)
				if not veh then
					return
				end
				veh = NetworkGetEntityFromNetworkId(veh)
				if veh and DoesEntityExist(veh) then
					local vehState = Entity(veh).state
					if not vehState.VIN then
						return
					end

					TriggerClientEvent("Fitment:Client:CamberController:UseItem", source)
				end
			end)
		end)
	end)
end)
