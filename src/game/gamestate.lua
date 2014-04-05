-- gamestate.lua
-- Adventure game
-- Randy Knapp - 2014
---------------------------------------------------------------------------------------------------

local class = require 'util.class'
local CommandModule = require 'modules.command'

--=================================================================================================
local GameState = class.define({
    name = "<unnamed>",
    commands = nil
})

---------------------------------------------------------------------------------------------------
function GameState:constructor (name)
    self.name = name
    self.commands = CommandModule(self)
end

---------------------------------------------------------------------------------------------------
function GameState:enter (player)
end

---------------------------------------------------------------------------------------------------
function GameState:exit ()
end

---------------------------------------------------------------------------------------------------
function GameState:giveInput (command, params)
    params = params or {}
    return self.commands:runCommand(command, params)
end

return GameState
