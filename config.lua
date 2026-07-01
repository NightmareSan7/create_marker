Config                = {}

Config.Commands       = {
	create = "createmarker",
	delete = "deletemarker",
}

Config.Types          = {
	npc    = true,
	marker = true,
}

Config.AllowedGroups  = { "admin", "superadmin" }

Config.deleteDist     = 5.0

Config.MaxLabelLength = 64

Config.Marker         = {
	defaultType    = 1,
	defaultScale   = 1.0,
	defaultAlpha   = 150,
	renderDist     = 30.0,
	renderTextdist = 10.0,
	markerTypes    = {
		{ label = "Zylinder",        value = 1 },
		{ label = "Pfeil nach Oben", value = 2 },
	},
}

Config.NPC            = {
	defaultModel = "a_m_m_business_01",
	interactDist = 2.0,
	cooldown     = 2,
	streamDist   = 400.0,
}

Config.Colors         = {
	{ label = "Rot",  r = 255, g = 0,   b = 0 },
	{ label = "Grün", r = 0,   g = 255, b = 0 },
	{ label = "Blau", r = 0,   g = 0,   b = 255 },
	{ label = "Gelb", r = 255, g = 255, b = 0 },
	{ label = "Weiß", r = 255, g = 255, b = 255 },
	{ label = "Lila", r = 128, g = 0,   b = 128 },
}

-- Nur Labels/Values für das UI
Config.Actions        = {
	{ label = "Item geben", value = "giveItem" },
	{ label = "Loggen",     value = "log" },
}
