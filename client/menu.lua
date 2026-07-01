---create base data table
---@return { coords: { x: number, y: number, z: number }, heading: number }
local function getBaseData()
	local ped            = PlayerPedId()
	local coords         = GetEntityCoords(ped)
	local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
	return {
		coords = {
			x = coords.x,
			y = coords.y,
			z = found and groundZ or coords.z,
		},
		heading = GetEntityHeading(ped),
	}
end

---handle marker data prep for server
---@param base table
---@param data table
local function handleMarker(base, data)
	local color     = Config.Colors[data.colorIdx] or Config.Colors[1]
	base.color      = { r = color.r, g = color.g, b = color.b, a = Config.Marker.defaultAlpha }
	base.markerType = data.markerType
	TriggerServerEvent("create_marker:server:create", "marker", base)
end

---handle npc data prep for server
---@param base table
---@param data table
local function handleNpc(base, data)
	local model = data.model
	if model and not IsModelValid(GetHashKey(model)) then
		ESX.ShowNotification("~r~Ungültiges NPC-Model!")
		return
	end
	base.model  = model
	base.action = data.action
	TriggerServerEvent("create_marker:server:create", "npc", base)
end


local handlers = {
	npc    = handleNpc,
	marker = handleMarker,
}

RegisterNUICallback("submit", function(data, cb)
	cb("ok")
	SetNuiFocus(false, false)

	local base = getBaseData()
	base.label = data.label
	local handler = handlers[data.type]
	if handler then
		handler(base, data)
	else
		print("[create_marker] Unbekannter Typ: " .. tostring(data.type))
	end
end)

RegisterNUICallback("close", function(data, cb)
	cb("ok")
	SetNuiFocus(false, false)
end)

AddEventHandler("create_marker:openMenu", function()
	SetNuiFocus(true, true)
	SendNUIMessage({
		action      = "open",
		colors      = Config.Colors,
		actions     = Config.Actions,
		markerTypes = Config.Marker.markerTypes,
	})
end)
