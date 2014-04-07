-- game.lua
-- Adventure game
-- Randy Knapp - 2014
---------------------------------------------------------------------------------------------------

require 'util.string'
local class          = require 'util.class'
local Player         = require 'game.player'
local GameState      = require 'game.gamestate'
local HubState       = require 'game.states.hubstate'
local AdventureState = require 'game.states.adventurestate'
local Color          = require 'util.color'
local util           = require 'util.util'

-- Aliases
local stringRepeat, stringChar, stringLower = string.rep, string.char, string.lower
local floor, tableRemove, ipairs, assert, type, tostring = math.floor, table.remove, ipairs, assert, type, tostring
local getFunction = util.getFunction

--=================================================================================================
local Game = class.define({
    quit = false,
    config = nil,
    player = Player(),
    states = {
        hub       = HubState(),
        adventure = AdventureState()
    },
    currentState = nil,
    adventureData = nil,
    adventureList = nil,
    screenWidth = 80
})

---------------------------------------------------------------------------------------------------
function Game:start ()
    -- Load config
    self.config = require 'data.config'
    assert(self.config ~= nil, "ERROR: Config file (data/config.lua) is missing or has errors.")
    assert(self.config.game ~= nil, "ERROR: Config file missing 'game' table.")
    assert(self.config.events ~= nil, "ERROR: Config file missing 'events' table.")

    -- Get functions
    self.config.events.onStartGame = getFunction(self.config.events.onStartGame)

    -- onStartGame event
    local gameName    = self.config.game.name
    local onStartGame = self.config.events.onStartGame
    if onStartGame then
        assert(type(onStartGame) == "function", "ERROR: onStartGame must be a function.")
        onStartGame()
    elseif gameName then
        self:writeCentered(gameName)
    else
        self:writeCentered("Game Start (Unnamed Game)")
    end

    -- Load adventure data
    self:loadAdventureData()

    -- Start in the initial state (hub by default)
    local initialState = self.config.game.initialState
    if initialState then
        assert(type(initialState) == "string", "ERROR: Initial state must be a string name.")
        self:switchState(initialState)
    else
        self:switchState("hub")
    end
end

---------------------------------------------------------------------------------------------------
function Game:giveInput (input)
    input = input or ""
    input = stringLower(input)

    -- Split out input by spaces
    local params = string.split(input, "%S+")

    if not params then
        return false
    end

    local command = params[1]
    tableRemove(params, 1)
    
    if self.currentState then
        local state = self.states[self.currentState]
        if state and state:isA(GameState) then
            local success = state:giveInput(command, params)
            if success then
                return true;
            end
        end
    end

    return false
end

---------------------------------------------------------------------------------------------------
function Game:getState (name)
    return self.states[name]
end

---------------------------------------------------------------------------------------------------
function Game:getCurrentState ()
    return self:getState(self.currentState)
end

---------------------------------------------------------------------------------------------------
function Game:switchState (name, ...)
    local newState = self:getState(name)
    if not newState then
        return false
    end

    local prevState = self:getCurrentState()
    if prevState then
        prevState:exit()
    end

    self.currentState = name
    newState:enter(self.player, unpack(arg))
    return true
end

---------------------------------------------------------------------------------------------------
function Game:loadAdventureData ()
    assert(self.adventureData == nil, "ERROR: Redundant adventure data loading.")
    assert(self.config ~= nil, "ERROR: Must load config before loading adventure data.")
    assert(self.config.adventures ~= nil, "ERROR: Config file missing adventures list.")

    local adventureList = self.config.adventures
    self.adventureData  = {}
    self.adventureList  = {}

    for i, adventure in ipairs(adventureList) do
        assert(adventure.adventure ~= nil, "ERROR: Adventure #" .. i .. " is missing 'adventure' field.")
        assert(adventure.adventure.id ~= nil, "ERROR: Adventure #" .. i .. " is missing 'adventure.id' field.")
        local adventureId = adventure.adventure.id
        self.adventureData[adventureId] = adventure
        self.adventureList[i] = adventureId
    end
end

---------------------------------------------------------------------------------------------------
function Game:getAdventureData (adventureId)
    assert(self.adventureData ~= nil, "ERROR: Adventure data missing completely.")

    local adventure = self.adventureData[adventureId]
    return adventure
end

---------------------------------------------------------------------------------------------------
function Game:getAdventureId (adventureIndex)
    assert(self.adventureList ~= nil, "ERROR: Adventure list missing completely.")

    local adventureId = self.adventureList[adventureIndex]
    return adventureId
end

---------------------------------------------------------------------------------------------------
function Game:listAdventures ()
    for i, adventureId in ipairs(self.adventureList) do
        local adventure = self:getAdventureData(adventureId)
        if not adventure.excludeFromList then
            game:write(Color.levelDesc(tostring(i) .. ": ") .. adventure.adventure.name)
        end
    end
end

---------------------------------------------------------------------------------------------------
function Game:displayAdventureInfo (adventureId)
    local adventure = self:getAdventureData(adventureId)
    assert(adventure ~= nil, "ERROR: Adventure (" .. tostring(adventureId) .. ") does not exist.")

    game:write(Color.levelDesc("Adventure: ") .. adventure.adventure.name)
    if adventure.adventure.description ~= nil then
        game:write(Color.levelDesc("Author: ") .. adventure.adventure.author)
        game:write(Color.levelDesc("Created: ") .. adventure.adventure.date)
        game:write(Color.levelDesc("Description: ") .. adventure.adventure.description)
        if adventure.adventure.notes ~= nil then
            game:write(Color.levelDesc("Author's Note: ") .. Color.noEffect(adventure.adventure.notes))
        end
    end
end

---------------------------------------------------------------------------------------------------
function Game:getCurrentAdventure ()
    local currentState = self:getCurrentState()
    if currentState:isA(AdventureState) then
        return currentState:getCurrentAdventure()
    else
        return nil
    end
end

---------------------------------------------------------------------------------------------------
function Game:confirmEndAdventure ()
    local currentState = self:getCurrentState()
    if currentState:isA(AdventureState) then
        currentState:onQuit()
    end
end

---------------------------------------------------------------------------------------------------
function Game:endAdventure ()
    local currentState = self:getCurrentState()
    if currentState:isA(AdventureState) then
        currentState:endAdventure()
    end
end

---------------------------------------------------------------------------------------------------
function Game:dispatchConfigEvent (eventName, ...)
    assert(self.config, "ERROR: Game config does not exist.")

    local events = self.config.events
    if events then
        local event = self.config.events[eventName]
        if event and type(event) == "function" then
            event(unpack(arg))
        end
    end
end

---------------------------------------------------------------------------------------------------
function Game:formatStringForWidth (s, firstIndent, indent)
    firstIndent = firstIndent or "- "
    indent      = indent or "  "
    local width = self.screenWidth

    -- Add the first indent
    local out = firstIndent

    local lastSpace = 0
    local currentLength = 2
    for word in s:gmatch("%S+") do

        -- Get the length of all color codes in the word
        local colorCodeLength = 0
        for colorCode in word:gmatch(stringChar(27) .. "%[%d+m") do
            colorCodeLength = colorCodeLength + #colorCode
        end
        
        -- Find the new length of the line adding the word length without color code characters
        local newLength = currentLength + #word + 1 - colorCodeLength
        if newLength < width - 1 then
            out = out .. word .. " "
            currentLength = newLength
        else
            out = out .. "\n" .. indent .. word .. " "
            currentLength = #indent + #word + 1
        end
    end

    return (out .. "\n")
end

---------------------------------------------------------------------------------------------------
function Game:write (...)
    for i, v in ipairs(arg) do
        if v ~= nil then
            if IN_GAME then
                io_write(v)
            else
                local out = self:formatStringForWidth(v)
                io_write(out)
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
function Game:writeNoIndent (...)
    for i, v in ipairs(arg) do
        if v ~= nil then
            if IN_GAME then
                io_write(v)
            else
                local out = self:formatStringForWidth(v, "", "")
                io_write(out)
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
function Game:writeCentered (...)
    for i, v in ipairs(arg) do
        if v ~= nil then
            if IN_GAME then
                io_write(v)
            else
                local width = self.screenWidth
                assert(#v <= width, "ERROR: String is too long to write centered: " .. v)
                local out = stringRepeat(" ", floor((width - #v) / 2)) .. v .. "\n"
                io_write(out)
            end
        end
    end
end

return Game
