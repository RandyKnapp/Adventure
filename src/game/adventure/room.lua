-- room.lua
-- Adventure game
-- Randy Knapp - 2014
---------------------------------------------------------------------------------------------------

local class = require 'util.class'
local Exit  = require 'game.adventure.exit'
local Prop  = require 'game.adventure.prop'
local Item  = require 'game.adventure.item'
local Color = require 'util.color'
local util  = require 'util.util'

-- aliases
local type        = type
local assert      = assert
local next        = next
local concat      = table.concat
local getFunction = util.getFunction

--=================================================================================================
local Room = class.define({
})

---------------------------------------------------------------------------------------------------
function Room:constructor (id, data, entityData)

    -- Data
    self.id       = id
    self.exits    = {}
    self.entities = {}
    self.data     = data
    self.isStart  = data.start
    self.name     = data.name

    -- Gather properties
    if data.properties ~= nil and type(data.properties) == "table" then
        for k, v in data.properties do
            if self[k] == nil then self[k] = v end
        end
    end

    -- Create exits
    local exits = data.exits
    assert(exits ~= nil and type(exits) == "table" and next(exits) ~= nil)
    for id, data in pairs(exits) do
        local exit = Exit(id, data)
        self.exits[id] = exit
    end

    -- Get functions
    self.data.onEnter = getFunction(self.data.onEnter, "self, player")
    self.data.onLook  = getFunction(self.data.onLook, "self, player")

    -- Create entities
    local props = data.entities.props
    local items = data.entities.items

    if props ~= nil and type(props) == "table" then
        for i, propId in ipairs(props) do
            local data = entityData.props[propId]
            local prop = Prop(propId, data)
            self.entities[propId] = prop
        end
    end

    if items ~= nil and type(items) == "table" then
        for i, itemId in pairs(items) do
            local data = entityData.items[itemId]
            local item = Item(itemId, data)
            self.entities[itemId] = item
        end
    end
end

---------------------------------------------------------------------------------------------------
function Room:getEntity (entityId)
    -- Return the entity, if it exists
    local entity = self.entities[entityId]
    assert(entity ~= nil)
    return entity
end

---------------------------------------------------------------------------------------------------
function Room:onEnter (player)
    -- Check for an onEnter script
    local onEnter   = self.data.onEnter
    local enterText = self.data.enter
    if onEnter == nil and enterText == nil then
        return self:onLook(player)
    elseif onEnter ~= nil and type(onEnter) == "function" then
        enterText = onEnter(self, player)
    end

    -- Write the enter text
    game:write(enterText)
end

---------------------------------------------------------------------------------------------------
function Room:onLook (player, params)
    -- Look at room
    if params == nil or (type(params) == "table" and next(params) == nil) then
        -- Check for an onLook script
        local onLook   = self.data.onLook
        local lookText = self.data.look
        if onLook ~= nil and type(onLook) == "function" then
            lookText = onLook(self, player)
        end

        -- Write the enter text
        game:write(lookText)

        -- Write text for exits and entities
        self:onLookListExits()
        self:onLookListEntities()
    else
        -- Look at an entity in the room
        local entityName = concat(params, " ")
        local lookedAtEntity = self:onLookAtEntity(player, entityName)
        if not lookedAtEntity then
            -- Look at an exit of the room
            local exitId = entityName
            local lookedAtExit = self:onLookAtExit(player, exitId)
            if not lookedAtExit then
                game:write(Color.noEffect("There is no " .. entityName .. " to look at."))
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
function Room:onLookAtEntity (player, entityName)
    -- Check for entities with this name
    for id, entity in pairs(self.entities) do
        local hasName = entity:hasName(entityName)
        if hasName then
            entity:onLook(player, self)
            return true
        end
    end

    return false
end

---------------------------------------------------------------------------------------------------
function Room:onLookAtExit (player, exitId)
    -- Check for exits with that ID
    local exit = self.exits[exitId]
    if exit ~= nil then
        exit:onLook(player, self)
        return true
    end

    -- Check for exits with synonyms
    for id, exit in pairs(self.exits) do
        if exit:hasName(exitId) then
            exit:onLook(player, self)
            return true
        end
    end

    return false
end

---------------------------------------------------------------------------------------------------
function Room:onLookListExits ()
    local exitNames = {}
    for id, exit in pairs(self.exits) do
        table.insert(exitNames, Color.exit(exit:getNameWithArticle()))
    end
    local count = #exitNames
    if count == 0 then
        game:write("There are no exits to this room.")
    elseif count == 1 then
        game:write("There is an exit " .. exitNames[1])
    elseif count == 2 then
        game:write("There are exits " .. table.concat(exitNames, " and "))
    else
        game:write("There are exits " .. table.concat(exitNames, ", "))
    end
end

---------------------------------------------------------------------------------------------------
function Room:onLookListEntities ()
    local entityNames = {}
    for id, entity in pairs(self.entities) do
        table.insert(entityNames, Color.item(entity:getNameWithArticle()))
    end
    local count = #entityNames
    if count == 1 then
        game:write("You see " .. entityNames[1])
    elseif count == 2 then
        game:write("You see " .. table.concat(entityNames, " and "))
    else
        game:write("You see " .. table.concat(entityNames, ", "))
    end
end

---------------------------------------------------------------------------------------------------
function Room:onCustomCommand (command, params, player)
    -- Check exits for alternate move actions
    for id, exit in pairs(self.exits) do
        local hasAction = exit:hasAction(command)
        if hasAction then
            return "move"
        end
    end

    -- Check entities for alternate use actions
    for id, entity in pairs(self.entities) do
        local hasAction = entity:hasAction(command)
        if hasAction then
            return "interact"
        end
    end

    return false
end

---------------------------------------------------------------------------------------------------
function Room:onMove (player, params)
    if params == nil or (type(params) == "table" and #params == 0) then
        game:write(Color.noEffect("Move where?"))
        return false
    else
        local exitId   = concat(params, " ")
        local moveExit = nil
        for k, exit in pairs(self.exits) do
            if exit:hasName(exitId) then
                moveExit = exit
                break
            end
        end

        local success  = false
        local text     = nil
        local nextRoom = nil
        if moveExit ~= nil then
            success, text = moveExit:onMove(self.player, self)
            nextRoom = moveExit:getRoomId()
        end

        if moveExit == nil then
            text = Color.noEffect("You can't go that way.")
            local defaultExits = game.config.defaultExits
            if defaultExits and defaultExits[exitId] then
                local exitData = defaultExits[exitId]
                if exitData and exitData.article then
                    if #exitData.article > 0 then
                        text = Color.noEffect("There is no way to go " .. exitData.article .. " " .. exitId .. ".")
                    else
                        text = Color.noEffect("There is no way to go " .. exitId .. ".")
                    end
                end
            end
        end

        game:write(text)
        return success, nextRoom
    end

    return false
end

---------------------------------------------------------------------------------------------------
function Room:onInteract (player, params, action)
    if params == nil or (type(params) == "table" and #params == 0) then
        game:write(Color.noEffect("Interact with what?"))
        return false
    else
        local entityName = concat(params, " ")
        local usedEntity = self:onInteractWithEntity(player, entityName, action)
        return usedEntity
    end

    return false
end

---------------------------------------------------------------------------------------------------
function Room:onInteractWithEntity (player, entityName, action)
    -- Check for entities with this name
    for id, entity in pairs(self.entities) do
        local hasName = entity:hasName(entityName)
        if hasName then
            local success = entity:onInteract(player, self, action)
            return success
        end
    end

    return false
end

---------------------------------------------------------------------------------------------------
function Room:onPickup (player, params)
    if params == nil or (type(params) == "table" and #params == 0) then
        game:write(Color.noEffect("Pick up what?"))
        return false
    else
        local entityName = concat(params, " ")
        -- Check for entities with this name
        for id, entity in pairs(self.entities) do
            local hasName = entity:hasName(entityName)
            if hasName and entity:isA(Item) then
                local success = entity:onPickup(player, self)
                if success then
                    -- Remove from room
                    self:removeItem(entity)
                    -- Add to player's inventory
                    player:addItem(entity)
                    return true
                end
            end
        end

        game:write(Color.noEffect("You can't pickup the " .. entityName))
    end

    return false
end

---------------------------------------------------------------------------------------------------
function Room:removeItem (item)
    assert(item:isA(Item), "Room:removeItem: item must be Item type")
    assert(self.entities[item.id] ~= nil)
    self.entities[item.id] = nil
end

---------------------------------------------------------------------------------------------------
function Room:addItem (item)
    assert(item:isA(Item), "Room:addItem: item must be Item type")
    assert(self.entities[item.id] == nil)
    self.entities[item.id] = item
end

return Room
