-- hubstate.lua
-- Adventure game
-- Randy Knapp - 2014
---------------------------------------------------------------------------------------------------

local class = require 'util.class'
local GameState = require 'game.gamestate'
local Color = require 'util.color'

--=================================================================================================
local HubState = GameState:extends()

---------------------------------------------------------------------------------------------------
function HubState:constructor ()
    self:super("constructor", "intro")

    -- Commands
    self.commands:addCommand("list", {}, self.onListAdventures, "Show all available adventures.")
    self.commands:addCommand("about", { "describe", "desc", "description" }, self.onAboutAdventures, "Get more information about a particular adventure.")
    self.commands:addCommand("start", { "begin", "play" }, self.onStartAdventure, "Begin playing an adventure.")
    self.commands:addCommand("quit", { "exit" }, self.onQuit, "Exit Adventure.")
end

---------------------------------------------------------------------------------------------------
function HubState:enter ()
    game:writeCentered("*** Adventure Hub ***")
    game:write(
        "Welcome to the Adventure Hub, Player. " .. 
        "I'm " .. Color.person("Ares") ..", the AI coordinating and directing Adventure. I'll be guiding you through each adventure you play.",
        "Type " .. Color.help("list") .. " to see the available adventures. " ..
        "Type " .. Color.help("start <adventure name>") .. " to go on an adventure." ..
        " At any time, type " .. Color.help("help") .. " and I'll try to give you some advice."
    )
end

---------------------------------------------------------------------------------------------------
function HubState:onListAdventures ()
    game:listAdventures()
    return true
end

---------------------------------------------------------------------------------------------------
function HubState:onAboutAdventures (params)
    if not params or #params == 0 then
        game:write("What adventure do you want to know about?")
        return true
    end

    -- Get adventure ID from index
    local adventureIndex = tonumber(params[1])
    local adventureId = game:getAdventureId(adventureIndex)

    -- Check to make sure adventure exists
    local adventure = game:getAdventureData(adventureId)
    if not adventure then
        game:write("Adventure #" .. tostring(adventureIndex) .. " does not exist.")
        return true
    end

    -- Begin adventure
    game:displayAdventureInfo(adventureId)

    return true
end

---------------------------------------------------------------------------------------------------
function HubState:onStartAdventure (params)
    if not params or #params == 0 then
        game:write("What adventure do you want to start?")
        return true
    end

    -- Get adventure ID from index
    local adventureIndex = tonumber(params[1])
    local adventureId = game:getAdventureId(adventureIndex)

    -- Check to make sure adventure exists
    local adventure = game:getAdventureData(adventureId)
    if not adventure then
        game:write("Adventure #" .. tostring(adventureIndex) .. " does not exist.")
        return true
    end

    -- Begin adventure
    game:switchState("adventure", adventureId)

    return true
end

---------------------------------------------------------------------------------------------------
function HubState:onQuit ()
    game:write("Until next time, Player. Farewell.")
    game.quit = true
    return true
end

return HubState
