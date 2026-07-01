---Checks if the usergroup has Permission to use the commands
---@param group string usergroup
---@return boolean hasPermission
function HasMarkerPermission(group)
	for _, allowed in ipairs(Config.AllowedGroups) do
		if allowed == group then return true end
	end
	return false
end
