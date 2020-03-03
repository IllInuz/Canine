fx_version 'adamant'

game 'gta5'

description 'Kowalski Canine'

ui_page("html/index.html")

files {
    "html/index.html",
    "html/libraries/axios.min.js",
    "html/libraries/vue.min.js",
    "html/libraries/vuetify.js",
    "html/libraries/vuetify.css",
    "html/style.css",
    "html/script.js",
    "html/images/dog_left.png",
    "html/images/dog_right.png",
    "html/images/husky.png",
    "html/images/rottweiler.png",
    "html/images/shepherd.png",
    "html/images/retriever.png"
}

server_scripts {
	'config/main.lua',
	'server/main.lua'
}

client_scripts {
	'config/main.lua',
	'client/main.lua'
}
