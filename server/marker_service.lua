MarkerService          = {}
local markerCache      = {}
local npcEntities      = {}
local interactCooldown = {}

---Spawns and syncs the NPC peds with their corresponding callback
---@param markerId number
---@param data NPCData
---@param onSpawned? fun(netId: number)
local function spawnNPCPed(markerId, data, onSpawned)
	local model   = data.model or Config.NPC.defaultModel
	local coords  = data.coords
	local heading = data.heading or 0.0

	ESX.OneSync.SpawnPed(model, coords, heading, function(netId)
		local ped   = NetworkGetEntityFromNetworkId(netId)
		local tries = 0

		while not DoesEntityExist(ped) and tries < 20 do
			Wait(100)
			ped   = NetworkGetEntityFromNetworkId(netId)
			tries = tries + 1
		end

		if not DoesEntityExist(ped) then
			print(("[create_marker] NPC #%d konnte nicht gespawnt werden"):format(markerId))
			return
		end

		FreezeEntityPosition(ped, true)
		SetEntityIgnoreRequestControlFilter(ped, true)

		npcEntities[markerId] = ped
		print(("[create_marker] NPC #%d gespawnt"):format(markerId))

		if onSpawned then onSpawned(netId) end
	end)
end

---loads all markers/npcs from DB and spawns those and syncs to client cache
function MarkerService.LoadAll()
	markerCache = MarkerRepository.GetAll()
	local count = 0
	for _, entries in pairs(markerCache) do
		for _ in pairs(entries) do count = count + 1 end
	end
	print(("[create_marker] %d Marker/NPCs aus DB geladen"):format(count))

	local npc = markerCache.npc
	CreateThread(function()
		if npc then
			for id, entry in pairs(npc) do
				spawnNPCPed(id, entry.data)
			end
		end
		SetTimeout(1000, function()
			TriggerClientEvent("create_marker:client:loadAll", -1, MarkerService.GetCache())
		end)
	end)
end

---Build a dto for client marker
---@param id number
---@param data MarkerData
---@return CacheEntryMarker
local function toClientMarker(id, data)
	return {
		id   = id,
		type = "marker",
		data = {
			coords     = data.coords,
			color      = data.color,
			markerType = data.markerType,
			label      = data.label,
		},
	}
end

---Retrieves the server-side marker cache as a flat list with minimum values to send to clients.
---@return MarkerModel[]
function MarkerService.GetCache()
	local list = {}

	if markerCache.marker then
		for id, entry in pairs(markerCache.marker) do
			list[#list + 1] = toClientMarker(id, entry.data)
		end
	end

	if markerCache.npc then
		for id, entry in pairs(markerCache.npc) do
			local ped = npcEntities[id]
			if ped and DoesEntityExist(ped) then
				list[#list + 1] = {
					id = id,
					type = "npc",
					netId = NetworkGetNetworkIdFromEntity(ped),
					coords = entry.data.coords,
					label = entry.data.label
				}
			end
		end
	end

	return list
end

local function commitToCache(type, id, d)
	markerCache[type]     = markerCache[type] or {}
	markerCache[type][id] = { data = d }
end


---@param source number Player source ID
---@param xPlayer table
---@param markerType MarkerType
---@param data MarkerData|NPCData
function MarkerService.HandleCreate(source, xPlayer, markerType, data)
	if not xPlayer then return end

	if not Config.Types[markerType] then return end
	if type(data) ~= "table" or type(data.coords) ~= "table" then return end

	local coords = data.coords
	if type(coords.x) ~= "number" or type(coords.y) ~= "number" or type(coords.z) ~= "number" then return end

	local playerCoords = GetEntityCoords(GetPlayerPed(source))
	if #(playerCoords - vector3(coords.x, coords.y, coords.z)) > 10.0 then
		TriggerClientEvent("esx:showNotification", source, "~r~Zu weit von der Position entfernt!")
		return
	end

	if data.label ~= nil and (type(data.label) ~= "string" or #data.label > Config.MaxLabelLength) then
		TriggerClientEvent("esx:showNotification", source, "~r~Ungültiges Label!")
		return
	end

	if markerType == "npc" then
		local model = data.model or Config.NPC.defaultModel
		if type(model) ~= "string" then
			TriggerClientEvent("esx:showNotification", source, "~r~NPC-Model ungültig!")
			return
		end
		data.model = model

		if data.action ~= nil then
			if type(data.action) ~= "table" or type(data.action.type) ~= "string"
				or not Config.ActionHandlers[data.action.type] then
				TriggerClientEvent("esx:showNotification", source, "~r~Ungültige Aktion!")
				return
			end

			if data.action.type == "giveItem" then
				if type(data.action.item) ~= "string" or not ESX.GetItemLabel(data.action.item) then
					TriggerClientEvent("esx:showNotification", source, "~r~Item existiert nicht!")
					return
				end
			end
		end
	end

	data.createdBy = xPlayer.license

	local id = MarkerRepository.Insert(markerType, data)
	if not id then
		TriggerClientEvent("esx:showNotification", source, "~r~Fehler beim Speichern!")
		return
	end

	data.coords = vector3(coords.x, coords.y, coords.z)

	if markerType == "npc" then
		---@cast data NPCData
		spawnNPCPed(id, data, function(netId)
			TriggerClientEvent("create_marker:client:add", -1, { id = id, type = "npc", netId = netId, coords = data.coords, label = data.label })
			commitToCache(markerType, id, data)
		end)
	elseif markerType == "marker" then
		---@cast data MarkerData
		TriggerClientEvent("create_marker:client:add", -1, toClientMarker(id, data))
		commitToCache(markerType, id, data)
	else
		print(source, "hat versucht, einen Marker mit unbekanntem Typ zu erstellen:", markerType)
		return
	end

	print(("[create_marker] %s erstellt Marker #%d (type: %s)"):format(GetPlayerName(source), id, markerType))
end

---Handles the delete for nearest Marker close to player
---@param source number Player source ID
function MarkerService.HandleDeleteNearest(source)
	local playerCoords   = GetEntityCoords(GetPlayerPed(source))
	local nearestId      = nil
	local nearestType    = nil
	local nearestDist    = math.huge
	local deleteDistance = Config.deleteDist

	for markerType, entries in pairs(markerCache) do
		for id, entry in pairs(entries) do
			local entryCoords = entry.data.coords
			local dist        = #(playerCoords - entryCoords)
			if dist < nearestDist then
				nearestDist = dist
				nearestId   = id
				nearestType = markerType
			end
		end
	end

	if not nearestId or nearestDist > deleteDistance then
		TriggerClientEvent("esx:showNotification", source,
			("~r~Kein Marker in der Nähe (max. %.0fm)!"):format(deleteDistance))
		return
	end

	local deleted = MarkerRepository.Delete(nearestId)
	if not deleted then return TriggerClientEvent("esx:showNotification", source, "~r~Fehler beim löschen!") end
	markerCache[nearestType][nearestId] = nil
	print(("[create_marker] %s löscht Marker #%d (%s)"):format(GetPlayerName(source), nearestId, nearestType))

	if nearestType == "npc" then
		local ped = npcEntities[nearestId]
		if ped and DoesEntityExist(ped) then DeleteEntity(ped) end
		npcEntities[nearestId] = nil
	end
	TriggerClientEvent("create_marker:client:remove", -1, nearestId)
end

---Handles interactions with the NPC
---@param source number Player source ID
---@param markerId number NPC ID
function MarkerService.HandleInteract(source, markerId)
	if type(markerId) ~= "number" then return end
	if not npcEntities[markerId] then return end

	if interactCooldown[source] and interactCooldown[source] > os.time() then return end
	interactCooldown[source] = os.time() + Config.NPC.cooldown

	local entry = markerCache.npc and markerCache.npc[markerId]
	if not entry then return end

	local playerPos = GetEntityCoords(GetPlayerPed(source))
	if #(playerPos - entry.data.coords) > Config.NPC.interactDist then return end


	local action = entry.data.action
	if not action or not action.type then return end

	local handler = Config.ActionHandlers[action.type]
	if handler then handler(source, action, markerId) end
end

---Clears cooldown for player
---@param source number Player source ID
function MarkerService.ClearPlayer(source)
	interactCooldown[source] = nil
end

---Despawns all spawned NPC Marker Entities
function MarkerService.DespawnAll()
	for _, ped in pairs(npcEntities) do
		if DoesEntityExist(ped) then DeleteEntity(ped) end
	end
	npcEntities = {}
end
