MarkerRepository = {}

---@class MarkerCacheEntry
---@field data MarkerData

---@class NPCCacheEntry
---@field data NPCData

---@class MarkerCache
---@field marker? table<number, MarkerCacheEntry>
---@field npc?    table<number, NPCCacheEntry>

---Creates the markers table if it does not exist
function MarkerRepository.Initialize()
	MySQL.query.await([[
		CREATE TABLE IF NOT EXISTS `markers` (
			`id`         INT          NOT NULL AUTO_INCREMENT,
			`type`       VARCHAR(10)  NOT NULL,
			`data`       JSON         NOT NULL,
			`created_at` DATETIME     NOT NULL DEFAULT (UTC_TIMESTAMP()),
			PRIMARY KEY (`id`)
		) ENGINE=InnoDB;
	]])
end

---Fetches all Markers and return rows with decoded .json data
---@return MarkerCache
function MarkerRepository.GetAll()
	local rows = MySQL.query.await("SELECT id, type, data FROM markers", {}) or {}
	local result = {}
	for _, row in ipairs(rows) do
		local data = json.decode(row.data)
		data.coords = vector3(data.coords.x, data.coords.y, data.coords.z)
		result[row.type] = result[row.type] or {}
		result[row.type][row.id] = { data = data }
	end
	return result
end

---Inserts marker into DB
---@param markerType MarkerType
---@param data MarkerData|NPCData
---@return number|nil
function MarkerRepository.Insert(markerType, data)
	return MySQL.insert.await(
		"INSERT INTO markers (type, data) VALUES (?, ?)",
		{ markerType, json.encode(data) }
	)
end

---Delete marker from DB by Id
---@param id number Unique Marker ID
---@return boolean deleteSuccess
function MarkerRepository.Delete(id)
	local affected = MySQL.update.await("DELETE FROM markers WHERE id = ?", { id })
	return affected ~= nil and affected > 0
end
