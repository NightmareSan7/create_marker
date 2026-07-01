AddEventHandler("onResourceStart", function(resource)
	if resource ~= GetCurrentResourceName() then return end
	MarkerRepository.Initialize()
	MarkerService.LoadAll()
end)

AddEventHandler("onResourceStop", function(resource)
	if resource ~= GetCurrentResourceName() then return end
	MarkerService.DespawnAll()
end)

AddEventHandler("esx:playerLoaded", function(playerId)
	TriggerClientEvent("create_marker:client:loadAll", playerId, MarkerService.GetCache())
end)

AddEventHandler("playerDropped", function()
	MarkerService.ClearPlayer(source)
end)

RegisterNetEvent("create_marker:server:create", function(markerType, data)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end
	if not HasMarkerPermission(xPlayer.group) then return end
	MarkerService.HandleCreate(src, xPlayer, markerType, data)
end)

RegisterNetEvent("create_marker:server:interact", function(markerId)
	local src = source
	MarkerService.HandleInteract(src, markerId)
end)

ESX.RegisterCommand(Config.Commands.create, Config.AllowedGroups, function(xPlayer)
	TriggerClientEvent("create_marker:client:openMenu", xPlayer.source)
end, false, {})

ESX.RegisterCommand(Config.Commands.delete, Config.AllowedGroups, function(xPlayer)
	MarkerService.HandleDeleteNearest(xPlayer.source)
end, false, {})
