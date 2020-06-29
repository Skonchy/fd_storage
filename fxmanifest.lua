fx_version "adamant"

game "gta5"

client_scripts {
    "client.lua"
}

server_scripts {
    "server.lua",
    "@drp_inventory/server/inventoryItems.lua"
}

shared_scripts {
    "config.lua",
    "commands.lua"
}

dependencies {
    "drp_inventory"
}