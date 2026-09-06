fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'tc_lib'
author 'tiny-core'
version '0.2.0'
description 'Biblioteca base dos recursos tc_ — zero dependencias externas'

-- tc_lib e distribuida aberta e gratuita, de proposito: os compradores precisam
-- dela instalada. Se fosse escrowed, cada produto exigia uma segunda entitlement.

shared_scripts {
    'init.lua',
}

ui_page 'web/dist/index.html'

files {
    'imports/**/*.lua',
    'locales/*.json',
    'web/dist/index.html',
    'web/dist/assets/*.js',
    'web/dist/assets/*.css',
}
