fx_version 'cerulean'
game 'gta5'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/app.js',
}

author 'NightmareSan'
description 'In-Game Marker & NPC Creator'
version '1.0.0'

dependencies {
    'es_extended',
    'oxmysql',
}

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua',
    'shared/helpers.lua',
}

client_scripts {
    'client/main.lua',
    'client/menu.lua',
    'client/marker.lua',
    'client/npc.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_config.lua',
    'server/marker_repository.lua',
    'server/marker_service.lua',
    'server/marker_events.lua',
}
