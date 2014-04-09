-- adventurestate.lua
-- Adventure game
-- Randy Knapp - 2014
---------------------------------------------------------------------------------------------------

local class = require 'util.class'
local GameState = require 'game.gamestate'
local Room = require 'game.adventure.room'
local Color = require 'util.color'

-- Aliases
local assert, require, pairs, type, tableConcat, tableInsert = assert, require, pairs, type, table.concat, table.insert

-- Helper methods
local function sortPredicate (a, b)
    if a.displayOrder ~= nil and b.displayOrder ~= nil then
        return a.displayOrder < b.displayOrder
    elseif a.displayOrder == nil and b.displayOrder ~= nil then
            return false
    elseif a.displayOrder ~= nil and b.displayOrder == nil then
        return true
    else
        return true
    end
end

--=================================================================================================
local AdventureState = GameState:extends({
    adventureData = nil,
    currentAdventure = nil,
    entities = {},
    rooms = {},
    startRoomId = nil,
    currentRoom = nil
})

---------------------------------------------------------------------------------------------------
function AdventureState:constructor ()
    self:super("constructor", "adventure")

    -- Help text
    local lookHelp = "Look at the room, look towards the exits of the room, or examine something in the room. You may also 'look inventory' to see a list of items you are carrying."
    local moveHelp = "Move to another room through one of the room's exits."
    local useHelp = "Use or interact with something in the room or an item in your inventory."
    local pickupHelp = "Pick up an item in the room and put it in your inventory."
    local dropHelp = "Take an item out of your inventory and leave it in the room."
    local quitHelp = "Return to the introduction."
    --local saveHelp = "Save your game."

    -- Build moveHelp using game config
    assert(game.config ~= nil, "ERROR: No game.config found!")
    if game.config.defaultExits then
        local exitData = {}
        for exitName, data in pairs(game.config.defaultExits) do
            data.name = exitName
            table.insert(exitData, data)
        end

        table.sort(exitData, sortPredicate)

        local exitStrings = {}
        for i, data in ipairs(exitData) do
            table.insert(exitStrings, data.name .. " = " .. table.concat(data.synonyms, ", "))
        end
        moveHelp = moveHelp .. " You can use shorthand for common directions: " .. table.concat(exitStrings, "; ")
    end

    -- Commands
    local commands = self.commands
    commands:addUnknownCommandProc(self.onUnknownCommand)
    commands:addCommand("look", { "examine" }, self.onLook, lookHelp)
    commands:addCommand("move", { "go" }, self.onMove, moveHelp)
    commands:addCommand("use", { "interact" }, self.onInteract, useHelp)
    commands:addCommand("pickup", { "get", "take" }, self.onPickup, pickupHelp)
    commands:addCommand("drop", {}, self.onDrop, dropHelp)
    commands:addCommand("quit", { "exit" }, self.onQuit, quitHelp)
    --commands:addCommand("save", self.onSave, saveHelp)

    if DEBUG then
        commands:addCommand("x", {}, function () game.quit = true; return true end, "")
    end
end

---------------------------------------------------------------------------------------------------
function AdventureState:enter (player, adventureId)
    -- Store the player reference
    self.player = player

    -- Start an adventure
    if adventureId ~= nil then
        self:startAdventure(adventureId)
    end
end

---------------------------------------------------------------------------------------------------
function AdventureState:startAdventure (adventureId)
    local adventure = game:getAdventureData(adventureId)
    assert(adventure ~= nil, "ERROR: Adventure (" .. tostring(adventureId) .. ") does not exist.")

    -- Clear current data
    self.currentRoom = nil
    self.startRoomId = nil
    for id, room in pairs(self.rooms) do
        assert(room.shutdown ~= nil, "ERROR: Rooms must have a shutdown method that clears all references.")
        room:shutdown()
    end
    for id, entity in pairs(self.entities) do
        assert(entity.shutdown ~= nil, "ERROR: Entities must have a shutdown method that clears all references.")
        entity:shutdown()
    end

    self.currentAdventure = adventure

    -- Gather entity and room data
    local entityData = adventure.entities
    local roomData   = adventure.rooms

    -- Create rooms
    for id, data in pairs(roomData) do
        local room = Room(id, data, entityData)
        self.rooms[id] = room

        if room.isStart then
            assert(self.startRoomId == nil, "ERROR: Adventure may only have one start room.")
            self.startRoomId = id
        end
    end

    -- Display start text
    if adventure.adventure.start and type(adventure.adventure.start) == "string" then
        game:write(adventure.adventure.start)
    end

    -- Display break
    game:writeCentered(Color.begin("*** BEGIN ADVENTURE: " .. adventure.adventure.name .. " ***"))

    -- Start in the first room
    assert(self.startRoomId ~= nil, "ERROR: Must mark a room as a start room.")
    self:enterRoom(self.startRoomId)
end

---------------------------------------------------------------------------------------------------
function AdventureState:getCurrentAdventure ()
    return self.currentAdventure
end

---------------------------------------------------------------------------------------------------
function AdventureState:getRoom (roomId)
    local room = self.rooms[roomId]
    assert(room ~= nil)
    return room
end

---------------------------------------------------------------------------------------------------
function AdventureState:enterRoom (roomId)
    local room = self:getRoom(roomId)
    self.currentRoom = room
    room:onEnter(self.player)
end

---------------------------------------------------------------------------------------------------
function AdventureState:onLook (params)
    if #params == 1 and params[1] == "inventory" then
        self.player:onLookInventory()
        return true
    end

    assert(self.currentRoom ~= nil)
    self.currentRoom:onLook(self.player, params)
    return true
end

---------------------------------------------------------------------------------------------------
function AdventureState:onMove (params)
    assert(self.currentRoom ~= nil)
    local moved, nextRoom = self.currentRoom:onMove(self.player, params)
    if moved == true then
        assert(self.rooms[nextRoom] ~= nil, "Tried to move to invalid room: " .. nextRoom)
        self:enterRoom(nextRoom)
    end
    return true
end

---------------------------------------------------------------------------------------------------
function AdventureState:onUnknownCommand (command, params)
    assert(self.currentRoom ~= nil)
    local realCommand = self.currentRoom:onCustomCommand(command, params, self.player)
    if realCommand == "move" then
        return self:onMove(params)
    elseif realCommand == "interact" then
        return self:onInteract(params, command)
    else
        return false
    end
end

---------------------------------------------------------------------------------------------------
function AdventureState:onInteract (params, command)
    command = command or "use"
    local usedInventoryItem = self.player:onInteractInventory()
    if usedInventoryItem then
        return true
    end

    assert(self.currentRoom ~= nil)
    self.currentRoom:onInteract(self.player, params, command)
    return true
end

---------------------------------------------------------------------------------------------------
function AdventureState:onPickup (params)
    assert(self.currentRoom ~= nil)
    self.currentRoom:onPickup(self.player, params)
    return true
end

---------------------------------------------------------------------------------------------------
function AdventureState:onDrop (params)
    if params == nil or (type(params) == "table" and #params == 0) then
        game:write(Color.noEffect("Drop what?"))
        return true
    end

    assert(self.currentRoom ~= nil)
    local itemId = tableConcat(params, " ")
    local dropped, item = self.player:onDropItem(self.currentRoom, itemId)
    if dropped and item ~= nil then
        self.currentRoom:addItem(item)
    else
        game:write(Color.noEffect("You can't drop " .. itemId .. "."))
    end

    return true
end

---------------------------------------------------------------------------------------------------
function AdventureState:onQuit ()
    self.commands:message("Are you sure you want to quit?", self.endAdventure, "You continue playing.")
    return true
end

---------------------------------------------------------------------------------------------------
function AdventureState:endAdventure ()
    game:write("Returning to Adventure Hub...")
    game:switchState("hub")
end

---------------------------------------------------------------------------------------------------
function AdventureState:onSave (params)
    game:write(Color.purple .. "Game Saved []" .. Color.close)
    return true
end

return AdventureState
