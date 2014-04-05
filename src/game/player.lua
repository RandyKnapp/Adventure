-- player.lua
-- Adventure game
-- Randy Knapp - 2014
---------------------------------------------------------------------------------------------------

local class = require 'util.class'
local Item = require 'game.adventure.item'
local Color = require 'util.color'

--=================================================================================================
local Player = class.define()

---------------------------------------------------------------------------------------------------
function Player:constructor ()
    self.goals = {}
    self.inventory = {}
end

---------------------------------------------------------------------------------------------------
function Player:getGoal (name)
    local adventureId = game:getCurrentAdventure().adventure.id
    if self.goals[adventureId] == nil then
        self.goals[adventureId] = {}
    end

    if self.goals[adventureId][name] then
        return self.goals[adventureId][name]
    else
        local goal = {
            complete = false
        }
        self.goals[adventureId][name] = goal
        return goal
    end
end

---------------------------------------------------------------------------------------------------
function Player:completeGoal (name)
    local goal = self:getGoal(name)
    goal.complete = true
    return goal
end

---------------------------------------------------------------------------------------------------
function Player:addItem (item)
    assert(item:isA(Item), "Player:addItem: item must be Item type")
    local id = item.id
    if self.inventory[id] == nil then
        self.inventory[id] = { item }
    else
        table.insert(self.inventory[id], item)
    end
end

---------------------------------------------------------------------------------------------------
function Player:removeItem (item)
    assert(item:isA(Item), "Player:removeItem: item must be Item type")
    local id = item.id
    if self.inventory[id] ~= nil then
        for i, v in ipairs(self.inventory[id]) do
            if v == item then
                table.remove(self.inventory[id], i)
                return true
            end
        end
    end

    return false
end

---------------------------------------------------------------------------------------------------
function Player:hasItemById (itemId)
    local items = self.inventory[itemId]
    return items ~= nil
end

---------------------------------------------------------------------------------------------------
function Player:hasItemEntity (item)
    assert(item:isA(Item), "Player:hasItem: item must be Item type")
    local itemId = item.id
    local items = self.inventory[itemId]
    if items == nil then
        return false
    end

    for i, v in ipairs(items) do
        if v == item then
            return true
        end
    end

    return false
end

---------------------------------------------------------------------------------------------------
function Player:hasItem (itemName)

    for itemId, items in pairs(self.inventory) do
        for i, item in ipairs(items) do
            if item:hasName(itemName) then
                return true, item
            end
        end
    end

    return false
end

---------------------------------------------------------------------------------------------------
function Player:getItemsOfType (itemId)
    return self.inventory[itemId]
end

---------------------------------------------------------------------------------------------------
function Player:getItemsOfTypeIf (itemId, predicate)
    local items = self.inventory[itemId]
    local out = {}
    if items == nil then
        return nil
    else
        for i, v in ipairs(items) do
            if predicate(v) then
                table.insert(out, v)
            end
        end
    end

    if #out > 0 then
        return out
    else
        return nil
    end
end

---------------------------------------------------------------------------------------------------
function Player:onLookInventory ()
    local allItemNames = {}
    for itemId, items in pairs(self.inventory) do
        for i, item in ipairs(items) do
            table.insert(allItemNames, Color.item(item:getNameWithArticle()))
        end
    end

    local count = #allItemNames
    if count == 0 then
        game:write("You are not carrying anything.")
    else
        game:write("You are carrying: " .. table.concat(allItemNames, ", "))
    end

    return true
end

---------------------------------------------------------------------------------------------------
function Player:onInteractInventory (room, itemId, action)
    local items = self:getItemsOfType(itemId)
    if items ~= nil and #items > 0 then
        local success = items[1]:onInteract(self, room, action)
        return success
    end
    return false
end

---------------------------------------------------------------------------------------------------
function Player:onDropItem (room, itemName)
    local hasItem, item = self:hasItem(itemName)

    if hasItem and item ~= nil then
        local success = item:onDrop(self, room)
        if success then
            self:removeItem(item)
        end
        return success, item
    end

    return false
end

return Player
