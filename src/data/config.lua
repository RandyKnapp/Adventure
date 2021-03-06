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
            synonyms = { "b" },
            displayOrder = 1
        },
        stern = {
            article = "to the",
            synonyms = { "s" },
            displayOrder = 2
        },
        port = {
            article = "to",
            synonyms = { "p" },
            displayOrder = 3
        },
        starboard = {
            article = "to",
            synonyms = { "sb" },
            displayOrder = 4
        },
        up = {
            article = "",
            synonyms = { "u" },
            displayOrder = 5
        },
        down = {
            article = "",
            synonyms = { "d" },
            displayOrder = 6
        },
    },
    --=================================================================================================
    events = {
        -----------------------------------------------------------------------------------------------
        onStartGame = function ()
            io_write(Color.yellow .. "--------------------------------------------------------------------------------")
            game:writeCentered("Adventure")
            io_write("--------------------------------------------------------------------------------" .. Color.close)
        end,
        -----------------------------------------------------------------------------------------------
        onEnterHub = function (player)
            game:writeCentered("*** Adventure Hub ***")
            game:write(
                "Welcome to the Adventure Hub, Player. " .. 
                "I'm " .. Color.person("Ares") ..", the AI coordinating and directing Adventure. I'll be guiding you through each adventure you play.",
                "Type " .. Color.help("list") .. " to see the available adventures. " ..
                "Type " .. Color.help("start <adventure name>") .. " to go on an adventure." ..
                " At any time, type " .. Color.help("help") .. " and I'll try to give you some advice."
            )
        end,
        -----------------------------------------------------------------------------------------------
        onQuitGame = function (player)
            game:write("Until next time, Player. Farewell.")
        end
    }
}
