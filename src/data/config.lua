-- config.lua
-- Adventure game TEST GAME
-- Randy Knapp - 2014
---------------------------------------------------------------------------------------------------

local Color = require 'util.color'

return {
    --=================================================================================================
    game = {
        name = "Adventure",
        version = "0.1",
        authors = { "Randy Knapp" },
        initialState = "hub"
    },
    --=================================================================================================
    adventures = {
        require 'data.viceroy'
    },
    --=================================================================================================
    defaultExits = {
        bow = {
            article = "to the",
            synonyms = { "b" }
        },
        stern = {
            article = "to the",
            synonyms = { "s" }
        },
        port = {
            article = "to",
            synonyms = { "p" }
        },
        starboard = {
            article = "to",
            synonyms = { "sb" }
        },
        up = {
            article = "",
            synonyms = { "u" }
        },
        down = {
            article = "",
            synonyms = { "d" }
        },
    },
    --=================================================================================================
    events = {
        onStartGame = function ()
            io_write(Color.yellow .. "--------------------------------------------------------------------------------")
            game:writeCentered("Adventure")
            io_write("--------------------------------------------------------------------------------" .. Color.close)
        end,
        onEnterHub = function (player)
        end
    }
}
