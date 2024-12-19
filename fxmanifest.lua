fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
author 'zykem'
game 'gta5'
lua54 'yes'
description 'A FiveM 1v1 Duels Open Source system.'

shared_scripts {
    '@es_extended/imports.lua',
    'shared/config.lua'
}

client_scripts {
    'client/interactions.lua',
    'client/match.lua',
    'client/main.lua'
}

server_scripts {
    'server/match.lua',
    'server/queue.lua',
    'server/main.lua',
    'server/anticheat-bypass.lua'
}

ui_page 'web/index.html'
files { 'web/**' }

dependency 'es_extended'