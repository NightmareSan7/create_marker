---@alias ActionHandler fun(source: number, actionData: table, markerId?: number)
---@type table<string, ActionHandler>
Config.ActionHandlers = {
	---@param source number
	---@param actionData { item: string, count: number }
	---@param markerId number
	giveItem = function(source, actionData, markerId)
		local xPlayer = ESX.GetPlayerFromId(source)
		if not xPlayer then return end

		local item = actionData.item
		if type(item) ~= "string" or item == "" then return end

		local itemLabel = ESX.GetItemLabel(item)
		if not itemLabel then
			return TriggerClientEvent("esx:showNotification", source,
				("~r~Item '%s' existiert nicht!"):format(item))
		end
		local count = math.floor(tonumber(actionData.count) or 1)

		if not xPlayer.canCarryItem(item, count) then
			return TriggerClientEvent("esx:showNotification", source,
				("Du hast nicht genug Platz für %dx ~g~%s~s~."):format(count, itemLabel))
		end

		xPlayer.addInventoryItem(item, count)
	end,
	---@param source number
	---@param actionData table
	---@param markerId number
	log = function(source, actionData, markerId)
		print(("[create_marker] Spieler %s (%s) hat mit NPC (%d) interagiert"):format(
			GetPlayerName(source), source, markerId))
	end,
}
