fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
author "Fixitfy"
description 'Fixitfy Edit Anim Position'
version "1.0"

shared_scripts {
    "config.lua",
}

client_scripts {
    "c/*.lua",
}
server_scripts {
    "s/*.lua",
    "versionchecker.lua"
}

ui_page 'ui/index.html'

files {
    'ui/**/*',
}

lua54 'yes'

escrow_ignore {
    '**/*'
}