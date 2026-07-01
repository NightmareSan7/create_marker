local running              = false
local markersCache         = {}
local nearbyMarkers        = {}
local NEARBY_SCAN_INTERVAL = 1000

---Draws the label above a marker.
---@param coords vector3
---@param text string
local function drawMarkerLabel(coords, text)
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextColour(255, 255, 255, 215)
	SetTextCentre(true)
	SetDrawOrigin(coords.x, coords.y, coords.z + 1.5)
	BeginTextCommandDisplayText("STRING")
	AddTextComponentString(text)
	EndTextCommandDisplayText(0.0, 0.0)
	ClearDrawOrigin()
end

---Starts the threads for drawing markers
---@param markers table<number, table> map markerId -> { type, data }
function StartDrawDefaultMarkers(markers)
	markersCache = markers
	if running then
		return
	end
	running = true
	CreateThread(function()
		while true do
			local playerCoords = GetEntityCoords(PlayerPedId())
			local nearby       = {}

			for _, entry in pairs(markersCache) do
				if entry.type == "marker" and #(playerCoords - entry.data.coords) < Config.Marker.renderDist then
					nearby[#nearby + 1] = entry
				end
			end

			nearbyMarkers = nearby
			Wait(NEARBY_SCAN_INTERVAL)
		end
	end)

	CreateThread(function()
		while true do
			if #nearbyMarkers == 0 then
				Wait(NEARBY_SCAN_INTERVAL)
			else
				local playerCoords = GetEntityCoords(PlayerPedId())

				for _, entry in ipairs(nearbyMarkers) do
					local mPos  = entry.data.coords
					local col   = entry.data.color or { r = 255, g = 0, b = 0, a = 150 }
					local scale = Config.Marker.defaultScale

					DrawMarker(
						entry.data.markerType or Config.Marker.defaultType,
						mPos.x, mPos.y, mPos.z,
						0.0, 0.0, 0.0,
						0.0, 0.0, 0.0,
						scale, scale, scale * 0.5,
						col.r, col.g, col.b, col.a,
						false, true, 2, false, nil, nil, false
					)

					if entry.data.label and #(playerCoords - mPos) < Config.Marker.renderTextdist then
						drawMarkerLabel(mPos, entry.data.label)
					end
				end

				Wait(0)
			end
		end
	end)
end
