local interactCooldown = false
local nearMarkerId     = nil
local running          = false
local label            = ""
local knownHandles     = {}
local npcCache         = {}
local SCAN_INTERVAL    = 1000

---Handle NPC input when in range
local function handleNPCInput()
	while true do
		if nearMarkerId then
			ESX.ShowHelpNotification(("[E] mit %s interagieren"):format(label), true)
			if IsControlJustReleased(0, 38) and not interactCooldown then
				interactCooldown = true
				TriggerServerEvent("create_marker:server:interact", nearMarkerId)
				Citizen.SetTimeout(Config.NPC.cooldown * 1000, function()
					interactCooldown = false
				end)
			end
			Wait(0)
		else
			Wait(500)
		end
	end
end

---Initialize ped state and behavior
---@param ped number
local function initializePed(ped)
	SetEntityInvincible(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
	TaskSetBlockingOfNonTemporaryEvents(ped, true)
	FreezeEntityPosition(ped, true)
end


---Handles NPC states if inside streaming range
---@param npcs table<number, { netId: number, coords: vector3, label: string }>
function StartNpcHandler(npcs)
	npcCache = npcs
	if running then
		return
	end
	running = true
	CreateThread(handleNPCInput)
	CreateThread(function()
		while true do
			local playerCoords = GetEntityCoords(PlayerPedId())
			local bestId       = nil
			local bestLabel    = ""
			local nearDist     = math.huge

			for markerId, npcData in pairs(npcCache) do
				local roughDist = #(playerCoords - npcData.coords)

				if roughDist < Config.NPC.streamDist then
					local netId = npcData.netId
					local ped   = NetworkGetEntityFromNetworkId(netId)
					if DoesEntityExist(ped) then
						if knownHandles[netId] ~= ped then
							initializePed(ped)
							knownHandles[netId] = ped
						end

						if roughDist < Config.NPC.interactDist and roughDist < nearDist then
							nearDist  = roughDist
							bestId    = markerId
							bestLabel = npcData.label or ""
						end
					else
						knownHandles[netId] = nil
					end
				else
					knownHandles[npcData.netId] = nil
				end
			end

			nearMarkerId = bestId
			label        = bestLabel
			Wait(SCAN_INTERVAL)
		end
	end)
end
