-- main.lua
-- Adventure game
-- Randy Knapp - 2014
--
-- The intention for this file is that the game can be run in two different ways: the first is in
-- the regular Lua interpreter on the command line. The second would be embedded in another game,
-- possibly a first-person shooter. If you are running Adventure embedded in another game,
-- implement your own main.lua in the game and set the global value IN_GAME to true in that file.
-- Also, you must create globals for a 'Color' library, 'game' instance, and 'io_write' function.
-- See this file for examples.
---------------------------------------------------------------------------------------------------

-- Library
LUA_PATH = "?;?.lua"
local Game = require "game"
Color = require 'util.color'

DEBUG = true

-- Aliases
io_write = io.write

-- Init (Global Game)
game = Game()
game:start()

-- Game loop
while not game.quit do
    io_write("> ")
    local input = io.read()

    -- Otherwise, pass input to the game
    local success = game:giveInput(input)

    if not success and input and #input > 0 then
        io_write("- " .. Color.noEffect("Sorry, I don't understand '" .. input .. "'.\n"))
    end

end
