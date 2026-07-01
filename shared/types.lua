---@alias MarkerType "npc"|"marker"

---@class MarkerColor
---@field r number 0–255
---@field g number 0–255
---@field b number 0–255
---@field a number 0–255

---@class NPCAction
---@field type   "giveItem"|"log"  Action handler key (see Config.ActionHandlers)
---@field item?  string            Item name
---@field count? number            Amount

---@class MarkerData
---@field coords      vector3
---@field label?      string       Displaytext for marker
---@field color?      MarkerColor  Defaults to red
---@field markerType? number       Marker ID, defaults to Config.Marker.defaultType
---@field heading?    number       defaults to 0.0
---@field createdBy?  string       player license identifier

---@class NPCData
---@field coords     vector3
---@field label?     string       Label for UI
---@field model?     string       Modelname, defaults to Config.NPC.defaultModel
---@field heading?   number       defaults to 0.0
---@field action?    NPCAction
---@field createdBy? string       player license identifier

---@class CacheEntryMarker
---@field id   number
---@field type "marker"
---@field data MarkerData

---@class CacheEntryNPC
---@field id     number
---@field type   "npc"
---@field netId  number
---@field coords vector3
---@field label? string

---@alias MarkerModel CacheEntryMarker|CacheEntryNPC
