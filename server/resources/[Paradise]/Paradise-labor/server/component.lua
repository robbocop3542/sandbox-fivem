AddEventHandler("Labor:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Database = exports["Paradise-base"]:FetchComponent("Database")
	Middleware = exports["Paradise-base"]:FetchComponent("Middleware")
	Callbacks = exports["Paradise-base"]:FetchComponent("Callbacks")
	Execute = exports["Paradise-base"]:FetchComponent("Execute")
	Logger = exports["Paradise-base"]:FetchComponent("Logger")
	Generator = exports["Paradise-base"]:FetchComponent("Generator")
	Utils = exports["Paradise-base"]:FetchComponent("Utils")
	Fetch = exports["Paradise-base"]:FetchComponent("Fetch")
	Config = exports["Paradise-base"]:FetchComponent("Config")
	Phone = exports["Paradise-base"]:FetchComponent("Phone")
	Wallet = exports["Paradise-base"]:FetchComponent("Wallet")
	Inventory = exports["Paradise-base"]:FetchComponent("Inventory")
	Loot = exports["Paradise-base"]:FetchComponent("Loot")
	Chat = exports["Paradise-base"]:FetchComponent("Chat")
	Labor = exports["Paradise-base"]:FetchComponent("Labor")
	Vehicles = exports["Paradise-base"]:FetchComponent("Vehicles")
	Reputation = exports["Paradise-base"]:FetchComponent("Reputation")
	WaitList = exports["Paradise-base"]:FetchComponent("WaitList")
	Properties = exports["Paradise-base"]:FetchComponent("Properties")
	Routing = exports["Paradise-base"]:FetchComponent("Routing")
	Status = exports["Paradise-base"]:FetchComponent("Status")
	Robbery = exports["Paradise-base"]:FetchComponent("Robbery")
	Crypto = exports["Paradise-base"]:FetchComponent("Crypto")
	Jail = exports["Paradise-base"]:FetchComponent("Jail")
	Banking = exports["Paradise-base"]:FetchComponent("Banking")
	Sequence = exports["Paradise-base"]:FetchComponent("Sequence")
	Pwnzor = exports["Paradise-base"]:FetchComponent("Pwnzor")
	Crafting = exports["Paradise-base"]:FetchComponent("Crafting")
	Vendor = exports["Paradise-base"]:FetchComponent("Vendor")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["Paradise-base"]:RequestDependencies("Labor", {
		"Database",
		"Middleware",
		"Callbacks",
		"Execute",
		"Logger",
		"Generator",
		"Utils",
		"Fetch",
		"Phone",
		"Wallet",
		"Inventory",
		"Loot",
		"Chat",
		"Labor",
		"Vehicles",
		"Reputation",
		"WaitList",
		"Properties",
		"Routing",
		"Status",
		"Robbery",
		"Crypto",
		"Jail",
		"Banking",
		"Sequence",
		"Pwnzor",
		"Crafting",
		"Vendor",
	}, function(error)
		if #error > 0 then
			Logger:Critical("Labor", "Failed To Load All Dependencies")
			return
		end
		RetrieveComponents()
		RegisterCallbacks()
		RegisterMiddleware()
		TriggerEvent("Labor:Server:Startup")
	end)
end)

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["Paradise-base"]:RegisterComponent("Labor", _LABOR)
end)

_Jobs = {}
_Groups = {}

_active = {}
_pendingInvites = {}
_offers = {}
_LABOR = {
	Get = {
		Jobs = function(self)
			return _Jobs
		end,
		Groups = function(self)
			return _Groups
		end,
	},
	Jobs = {
		Register = function(self, id, name, limit, salary, repAward, restrictions, customRep, hiddenRep, timeout)
			_Jobs[id] = {
				Id = id,
				Name = name,
				Limit = limit,
				Salary = salary or 0,
				RepAward = repAward or 0,
				OnDuty = {},
				Restricted = restrictions,
				Timeout = timeout,
			}

			Reputation:Create(id, name, customRep or {
				{ label = "Rank 1", value = 1500 },
				{ label = "Rank 2", value = 3000 },
				{ label = "Rank 3", value = 6000 },
				{ label = "Rank 4", value = 9000 },
				{ label = "Rank 5", value = 12000 },
			}, hiddenRep)
		end,
	},
	Offers = {
		Task = function(self, joiner, job, text, appOverride)
			local title = "Job Activity"
			local app = "labor"
			if appOverride then
				title = appOverride.title or "Job Activity"
				app = appOverride or "labor"
			end

			for k, v in pairs(_Jobs[job].OnDuty) do
				if v.Joiner == joiner then
					if _Jobs[job].Timeout then
						if _offers[joiner] == nil then
							_offers[joiner] = { job = job }
						end
						_offers[joiner].expires = os.time() + _Jobs[job].Timeout.Duration
					end

					if v.Group then
						for k2, v2 in pairs(_Groups) do
							if v2.Creator.ID == joiner then
								for k3, v3 in ipairs(v2.Members) do
									Phone.Notification:AddWithId(
										v3.ID,
										"LABOR_OBJ",
										title,
										text,
										os.time(),
										-1,
										app,
										{}
									)
								end
							end
						end
					end

					Phone.Notification:AddWithId(joiner, "LABOR_OBJ", title, text, os.time(), -1, app, {})
				end
			end
		end,
		Start = function(self, joiner, job, text, max, appOverride)
			local title = "Job Activity"
			local app = "labor"
			if appOverride then
				title = appOverride.title or "Job Activity"
				app = appOverride or "labor"
			end

			if _Jobs[job] ~= nil then
				_offers[joiner] = {
					job = job,
					text = text,
					current = 0,
					max = max,
				}

				if _Jobs[job].Timeout then
					_offers[joiner].expires = os.time() + _Jobs[job].Timeout.Duration
				end

				for k, v in pairs(_Jobs[job].OnDuty) do
					if v.Joiner == joiner then
						if v.Group then
							for k2, v2 in pairs(_Groups) do
								if v2.Creator.ID == joiner then
									for k3, v3 in ipairs(v2.Members) do
										Phone.Notification:AddWithId(
											v3.ID,
											"LABOR_OBJ",
											title,
											string.format(
												"%s - %s/%s",
												_offers[joiner].text,
												_offers[joiner].current,
												_offers[joiner].max
											),
											os.time(),
											-1,
											app,
											{}
										)
									end
								end
							end
						end

						Phone.Notification:AddWithId(
							joiner,
							"LABOR_OBJ",
							title,
							string.format(
								"%s - %s/%s",
								_offers[joiner].text,
								_offers[joiner].current,
								_offers[joiner].max
							),
							os.time(),
							-1,
							app,
							{}
						)
					end
				end
			end
		end,
		Update = function(self, joiner, job, change, skipFinish, appOverride)
			local title = "Job Activity"
			if appOverride then
				title = appOverride.title or "Job Activity"
			end

			if _offers[joiner] ~= nil then
				_offers[joiner].current = _offers[joiner].current + change

				if _Jobs[job].Timeout then
					_offers[joiner].expires = os.time() + _Jobs[job].Timeout.Duration
				end

				if _offers[joiner].current >= _offers[joiner].max and not skipFinish then
					local paidOut = {}

					for k, v in pairs(_Jobs[job].OnDuty) do
						if v.Joiner == joiner then
							if v.Group then
								for k2, v2 in pairs(_Groups) do
									if v2.Creator.ID == joiner then
										for k3, v3 in ipairs(v2.Members) do
											Phone.Notification:RemoveById(v3.ID, "LABOR_OBJ")
											if not paidOut[v3.ID] then
												paidOut[v3.ID] = true
												Labor.Offers:Complete(v3.ID, job)
											end
										end
									end
								end
							end
							Phone.Notification:RemoveById(joiner, "LABOR_OBJ")
							if not paidOut[joiner] then
								paidOut[joiner] = true
								Labor.Offers:Complete(joiner, job)
							end
							Labor.Duty:Off(job, joiner, true)
							TriggerEvent(string.format("%s:Server:FinishJob", job), joiner)
						end
					end

					_offers[joiner] = nil
					return true
				else
					for k, v in pairs(_Jobs[job].OnDuty) do
						if v.Joiner == joiner then
							if v.Group then
								for k2, v2 in pairs(_Groups) do
									if v2.Creator.ID == joiner then
										for k3, v3 in ipairs(v2.Members) do
											Phone.Notification:Update(
												v3.ID,
												"LABOR_OBJ",
												title,
												string.format(
													"%s - %s/%s",
													_offers[joiner].text,
													_offers[joiner].current,
													_offers[joiner].max
												)
											)
										end
									end
								end
							end
							Phone.Notification:Update(
								joiner,
								"LABOR_OBJ",
								title,
								string.format(
									"%s - %s/%s",
									_offers[joiner].text,
									_offers[joiner].current,
									_offers[joiner].max
								)
							)
						end
					end

					if _offers[joiner].current >= _offers[joiner].max and skipFinish then
						return true
					else
						return false
					end
				end
			else
				return false
			end
		end,
		Complete = function(self, source, job)
			local char = Fetch:CharacterSource(source)
			if char then
				Logger:Info(
					"Labor",
					string.format(
						"%s %s (%s) Completed Manual Round (%s) - Got $%s",
						char:GetData("First"),
						char:GetData("Last"),
						char:GetData("SID"),
						job,
						_Jobs[job].Salary
					)
				)
				if _Jobs[job].Salary > 0 then
					Banking.Balance:Deposit(Banking.Accounts:GetPersonal(char:GetData("SID")).Account, _Jobs[job].Salary, {
						type = "paycheck",
						title = "Paycheck",
						description = string.format("Paycheck For Labor Worked: %s - $%s", job, _Jobs[job].Salary),
						data = _Jobs[job].Salary,
					})
				end

				Reputation.Modify:Add(source, job, _Jobs[job].RepAward)
			end
		end,
		ManualFinish = function(self, joiner, job, appOverride)
			local paidOut = {}
			for k, v in pairs(_Jobs[job].OnDuty) do
				if v.Joiner == joiner then
					if v.Group then
						for k2, v2 in pairs(_Groups) do
							if v2.Creator.ID == v.Joiner then
								for k3, v3 in ipairs(v2.Members) do
									Phone.Notification:RemoveById(v3.ID, "LABOR_OBJ")
									if not paidOut[v3.ID] then
										paidOut[v3.ID] = true
										Labor.Offers:Complete(v3.ID, job)
									end
								end
							end
						end
					end

					Phone.Notification:RemoveById(v.Joiner, "LABOR_OBJ")
					if not paidOut[v.Joiner] then
						paidOut[v.Joiner] = true
						Labor.Offers:Complete(v.Joiner, job)
					end
					TriggerEvent(string.format("%s:Server:FinishJob", job), v.Joiner)
					Labor.Duty:Off(job, v.Joiner, true)
				end
			end

			_offers[joiner] = nil
		end,
		Fail = function(self, joiner, job, timeout)
			local paidOut = {}
			for k, v in pairs(_Jobs[job].OnDuty) do
				if v.Joiner == joiner then
					if v.Group then
						for k2, v2 in pairs(_Groups) do
							if v2.Creator.ID == joiner then
								for k3, v3 in ipairs(v2.Members) do
									Phone.Notification:RemoveById(v3.ID, "LABOR_OBJ")
									if timeout ~= nil then
										Phone.Notification:Add(
											v3.ID,
											"Job Failed",
											timeout.Message,
											os.time(),
											6000,
											"labor",
											{}
										)
									end
									if not paidOut[v3.ID] then
										paidOut[v3.ID] = true
										if not _Jobs[job]?.Timeout?.KeepRep then
											Reputation.Modify:Remove(v3.ID, job, _Jobs[job].RepAward)
										end
									end
								end
							end
						end
					end
					Phone.Notification:RemoveById(joiner, "LABOR_OBJ")
					if timeout ~= nil then
						Phone.Notification:Add(
							joiner,
							"Job Failed",
							timeout.Message,
							os.time(),
							6000,
							"labor",
							{}
						)
					end
					if not paidOut[v.Joiner] then
						paidOut[v.Joiner] = true
						if not _Jobs[job]?.Timeout?.KeepRep then
							Reputation.Modify:Remove(joiner, job, _Jobs[job].RepAward)
						end
					end
					TriggerEvent(string.format("%s:Server:CancelJob", job), joiner)
					Labor.Duty:Off(job, joiner, false, true)
				end
			end

			_offers[joiner] = nil
		end,
		Cancel = function(self, joiner, job)
			for k, v in pairs(_Jobs[job].OnDuty) do
				if v.Joiner == joiner then
					if v.Group then
						for k2, v2 in pairs(_Groups) do
							if v2.Creator.ID == joiner then
								for k3, v3 in ipairs(v2.Members) do
									Phone.Notification:RemoveById(v3.ID, "LABOR_OBJ")
								end
							end
						end
					end

					Phone.Notification:RemoveById(joiner, "LABOR_OBJ")
					TriggerEvent(string.format("%s:Server:CancelJob", job), joiner)
					Labor.Duty:Off(job, joiner, false, true)
				end
			end
		end,
	},
	Workgroups = {
		Create = function(self, source)
			local char = Fetch:CharacterSource(source)
			if char ~= nil then
				if char:GetData("ICU") ~= nil and not char:GetData("ICU").Released then
					return false
				end

				local myId = char:GetData("SID")
				for k, v in ipairs(_Groups) do
					if v.Creator.ID == source then
						return false
					end

					for k2, v2 in ipairs(v.Members) do
						if v2.ID == source then
							return false
						end
					end
				end

				local name = { First = char:GetData("First"), Last = char:GetData("Last") }
				if hasValue(char:GetData("States") or {}, "PHONE_VPN") then
					local vpn = Inventory.Items:GetFirst(char:GetData("SID"), "vpn", 1)
					name = vpn.MetaData.VpnName
				end

				table.insert(_Groups, {
					ID = source,
					Creator = {
						ID = source,
						SID = char:GetData("SID"),
						CharID = char:GetData("ID"),
						First = name.First,
						Last = name.Last,
					},
					Members = {},
				})

				return true
			else
				return false
			end
		end,
		Disband = function(self, source, force)
			for k, v in ipairs(_Groups) do
				if v.Creator.ID == source and (not _Groups[k].Working or force) then
					if _Groups[k].Working then
						Labor.Duty:Off(_Groups[k].Job, v.Creator.ID, false, true)
					end
					for k2, v2 in ipairs(v.Members) do
						TriggerClientEvent("Labor:Client:WorkgroupDisbanded", v2.ID)
						Phone.Notification:Add(
							v2.ID,
							"Job Activity",
							string.format(
								"%s %s Disbanded Your Workgroup",
								v.Creator.First,
								v.Creator.Last
							),
							os.time(),
							6000,
							"labor",
							{}
						)
					end

					table.remove(_Groups, k)
					return true
				end
			end
			return false
		end,
		Join = function(self, creator, source)
			local char = Fetch:CharacterSource(source)
			if char ~= nil and char:GetData("TempJob") == nil then
				if char:GetData("ICU") ~= nil and not char:GetData("ICU").Released then
					return false
				end

				local myId = char:GetData("SID")
				for k, v in ipairs(_Groups) do
					if v.Creator.ID == source then
						return false
					end

					for k2, v2 in ipairs(v.Members) do
						if v2.ID == source then
							return false
						end
					end
				end

				for k, v in ipairs(_Groups) do
					if v.Creator.ID == creator then
						if #_Groups[k].Members < 4 and not _Groups[k].Working then
							for k2, v2 in ipairs(_Groups[k].Members) do
								if v2.ID == source then
									return
								end
							end

							local name = { First = char:GetData("First"), Last = char:GetData("Last") }
							if hasValue(char:GetData("States") or {}, "PHONE_VPN") then
								local vpn = Inventory.Items:GetFirst(char:GetData("SID"), "vpn", 1)
								name = vpn.MetaData.VpnName
							end

							local d = {
								ID = source,
								SID = char:GetData("SID"),
								CharID = char:GetData("ID"),
								First = name.First,
								Last = name.Last,
							}
							table.insert(_Groups[k].Members, d)

							Phone.Notification:Add(
								v.Creator.ID,
								"Job Activity",
								string.format("%s %s Joined Your Workgroup", name.First, name.Last),
								os.time(),
								6000,
								"labor",
								{}
							)

							return true
						end
					end
				end
				return false
			else
				return false
			end
		end,
		Request = function(self, group, source)
			if _pendingInvites[source] == nil then
				local char = Fetch:CharacterSource(source)
				if char ~= nil and char:GetData("TempJob") == nil then
					if char:GetData("ICU") ~= nil and not char:GetData("ICU").Released then
						return false
					end

					local myId = char:GetData("SID")
					for k, v in ipairs(_Groups) do
						if v.Creator.ID == source then
							return false
						end

						for k2, v2 in ipairs(v.Members) do
							if v2.ID == source then
								return false
							end
						end
					end

					for k, v in ipairs(_Groups) do
						if v.Creator.ID == group.Creator.ID then
							if #_Groups[k].Members < 4 and not _Groups[k].Working then
								for k2, v2 in ipairs(_Groups[k].Members) do
									if v2.ID == source then
										return
									end
								end

								_pendingInvites[source] = group.Creator.ID

								local name = { First = char:GetData("First"), Last = char:GetData("Last") }
								if hasValue(char:GetData("States") or {}, "PHONE_VPN") then
									local vpn = Inventory.Items:GetFirst(char:GetData("SID"), "vpn", 1)
									name = vpn.MetaData.VpnName
								end

								Phone.Notification:Add(
									v.Creator.ID,
									"Job Activity",
									string.format("%s %s Request To Join Your Group", name.First, name.Last),
									os.time(),
									20000,
									"labor",
									{
										accept = "Labor:Client:AcceptRequest",
										cancel = "Labor:Client:DeclineRequest",
									},
									{
										source = source,
									}
								)

								Citizen.SetTimeout(30 * 1000, function()
									if _pendingInvites[source] ~= nil then
										_pendingInvites[source] = nil

										Phone.Notification:Add(
											source,
											"Job Activity",
											"Your Group Request Was Ignored",
											os.time(),
											4000,
											"labor",
											{}
										)
									end
								end)

								return true
							end
						end
					end
					return false
				else
					return false
				end
			end
		end,
		Leave = function(self, group, source)
			local char = Fetch:CharacterSource(source)
			if char ~= nil then
				local myId = char:GetData("SID")
				for k, v in ipairs(_Groups) do
					if v.Creator.ID == group.Creator.ID then
						for k2, v2 in ipairs(v.Members) do
							if v2.ID == source then
								table.remove(_Groups[k].Members, k2)

								Phone.Notification:Add(
									v.Creator.ID,
									"Job Activity",
									string.format("%s %s Left Your Workgroup", v2.First, v2.Last),
									os.time(),
									6000,
									"labor",
									{}
								)

								return true
							end
						end
					end
				end
				return false
			else
				return false
			end
		end,
		SendEvent = function(self, joiner, event, ...)
			for k, v in ipairs(_Groups) do
				if v.Creator.ID == joiner then
					for k2, v2 in ipairs(v.Members) do
						TriggerClientEvent(event, v2.ID, ...)
					end

					TriggerClientEvent(event, v.Creator.ID, ...)
					return
				end
			end

			
			TriggerClientEvent(event, joiner, ...)
		end,
	},
	Duty = {
		On = function(self, job, joiner, isWorkgroup, data)
			if _Jobs[job] ~= nil then
				if (_Jobs[job].Limit == 0) or #_Jobs[job].OnDuty < _Jobs[job].Limit then
					table.insert(_Jobs[job].OnDuty, {
						Joiner = joiner,
						Group = isWorkgroup,
						Data = data or {},
					})

					if isWorkgroup then
						for k, v in ipairs(_Groups) do
							if v.Creator.ID == joiner then
								TriggerEvent(string.format("%s:Server:OnDuty", job), joiner, v.Members, isWorkgroup, data or {})
								_Groups[k].Job = job
								_Groups[k].Working = true
								return true
							end
						end

						TriggerEvent(string.format("%s:Server:OnDuty", job), joiner, {}, false, data or {})
					else
						TriggerEvent(string.format("%s:Server:OnDuty", job), joiner, {}, isWorkgroup, data or {})
					end
					return true
				else
					return false
				end
			else
				return false
			end
		end,
		Off = function(self, job, joiner, wasFinished, noAlert)
			if _Jobs[job] ~= nil then
				for k, v in ipairs(_Jobs[job].OnDuty) do
					if v.Joiner == joiner then
						if v.Group then
							for k, v in ipairs(_Groups) do
								if v.Creator.ID == joiner then
									for k2, v2 in ipairs(v.Members) do
										local c = Fetch:CharacterSource(v2.ID)
										if c ~= nil then
											c:SetData("TempJob", nil)
											Phone.Notification:RemoveById(v2.ID, "LABOR_OBJ")
											TriggerEvent(string.format("%s:Server:OffDuty", job), v2.ID, joiner)

											if not noAlert then
												if wasFinished then
													Phone.Notification:Add(
														v2.ID,
														"Job Activity",
														"You finished a job",
														os.time(),
														6000,
														"labor",
														{}
													)
												else
													Phone.Notification:Add(
														v2.ID,
														"Job Activity",
														"You quit a job",
														os.time(),
														6000,
														"labor",
														{}
													)
												end
											end
										end
									end
									_Groups[k].Working = false
								end
							end
						end
						table.remove(_Jobs[job].OnDuty, k)

						_offers[joiner] = nil

						local char = Fetch:CharacterSource(joiner)
						if char then
							char:SetData("TempJob", nil)
							Phone.Notification:RemoveById(joiner, "LABOR_OBJ")
							TriggerEvent(string.format("%s:Server:OffDuty", job), joiner, joiner)
							if not noAlert then
								if wasFinished then
									Phone.Notification:Add(
										joiner,
										"Job Activity",
										"You finished a job",
										os.time(),
										6000,
										"labor",
										{}
									)
								else
									Phone.Notification:Add(
										joiner,
										"Job Activity",
										"You quit a job",
										os.time(),
										6000,
										"labor",
										{}
									)
									TriggerEvent(string.format("%s:Server:CancelJob", job), joiner)
								end
							end
							return true
						end
					end
				end
				return false
			else
				return false
			end
		end,
	},
	Jail = {
		Sentenced = function(self, source)
			for k, v in pairs(_Jobs) do
				if not v.Restricted or not v.Restricted.state or v.Restricted.state ~= "SCRIPT_PRISON_JOB" then
					if v.Restricted then
						Labor.Offers:Fail(source, k)
					else
						Labor.Duty:Off(k, source, false, true)
					end
				end
			end
		end,
		Released = function(self, source)
			for k, v in pairs(_Jobs) do
				if v.Restricted and v.Restricted.state and v.Restricted.state == "SCRIPT_PRISON_JOB" then
					Labor.Duty:Off(k, source, false, true)
				end
			end
		end,
	},
}
