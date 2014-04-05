-- prop.lua
-- Adventure game
-- Randy Knapp - 2014
---------------------------------------------------------------------------------------------------

local class = require 'util.class'
local Entity = require 'game.adventure.entity'
local util  = require 'util.util'

-- Aliases
local type        = type
local assert      = assert
local getFunction = util.getFunction

--=================================================================================================
local Item = Entity:extends({
})

---------------------------------------------------------------------------------------------------
function Item:constructor (id, data)
    self:super("constructor", id, data, { "use", "interact", "pickup", "get", "drop" })

    -- Get functions
    self.data.onPickup = getFunction(self.data.onPickup, "self, player, room")
    self.data.onDrop   = getFunction(self.data.onDrop, "self, player, room")

    -- Defaults
    if self.data.pickup == nil and self.data.onPickup == nil then
        self.data.pickup = "You picked up the " .. self.name .. "."
    end
    if self.data.drop == nil and self.data.onDrop == nil then
        self.data.drop = "You dropped the " .. self.name .. "."
    end
end

---------------------------------------------------------------------------------------------------
function Item:onPickup (player, room)
    local text    = self.data.pickup
    local script  = self.data.onPickup
    local canPickup = true
    if script ~= nil and type(script) == "function" then
        canPickup, text = script(self, player, room)
        assert(type(canPickup) == "boolean")
        assert(text == nil or type(text) == "string")
    end

    game:write(text)
    return canPickup
end

---------------------------------------------------------------------------------------------------
function Item:onDrop (player, room)
    local text    = self.data.drop
    local script  = self.data.onDrop
    local canDrop = true
    if script ~= nil and type(script) == "function" then
        canDrop, text = script(self, player, room)
        assert(type(canDrop) == "boolean")
        assert(text == nil or type(text) == "string")
    end

    game:write(text)
    return canDrop
end

return Item
