local activeMarkers = {} -- { [markerId] = { id, type, data } }
local activeNPCs    = {} -- { [markerId] = { netId, coords, label } }

RegisterNetEvent("create_marker:client:loadAll")
AddEventHandler("create_marker:client:loadAll", function(entries)
	activeMarkers = {}
	activeNPCs    = {}
	for _, entry in ipairs(entries) do
		if entry.type == "marker" then
			activeMarkers[entry.id] = entry
		elseif entry.type == "npc" then
			activeNPCs[entry.id] = { netId = entry.netId, coords = entry.coords, label = entry.label }
		end
	end
	StartDrawDefaultMarkers(activeMarkers)
	StartNpcHandler(activeNPCs)
end)

RegisterNetEvent("create_marker:client:add")
AddEventHandler("create_marker:client:add", function(entry)
	if entry.type == "marker" then
		activeMarkers[entry.id] = entry
	elseif entry.type == "npc" then
		activeNPCs[entry.id] = { netId = entry.netId, coords = entry.coords, label = entry.label }
	end
end)

RegisterNetEvent("create_marker:client:remove")
AddEventHandler("create_marker:client:remove", function(id)
	activeMarkers[id] = nil
	activeNPCs[id]    = nil
end)

RegisterNetEvent("create_marker:client:openMenu")
AddEventHandler("create_marker:client:openMenu", function()
	TriggerEvent("create_marker:openMenu")
end)
