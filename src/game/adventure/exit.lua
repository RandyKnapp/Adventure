-- exit.lua
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
local Exit = Entity:extends({
})

---------------------------------------------------------------------------------------------------
function Exit:constructor (id, data)
    self:super("constructor", id, data, { "move", "go" })

    -- Check for required data
    assert(self.data.to ~= nil and type(self.data.to) == "string", "Exits need a 'to' field with the name of another room")

    -- Get functions
    self.data.onMove = getFunction(self.data.onMove, "self, player, room")

    -- ID is a valid name
    self.names[id] = true

    local defaultExits = game.config.defaultExits
    if defaultExits then
        for k, v in pairs(defaultExits) do
            if id == k then
                if v.synonyms then
                    for i, alias in ipairs(v.synonyms) do
                        self.names[alias] = true
                    end
                end
                if v.article and not self.data.article then
                    self.data.article = v.article
                end
                break
            end
        end
    end
    
end

---------------------------------------------------------------------------------------------------
function Exit:getRoomId ()
    return self.data.to
end

---------------------------------------------------------------------------------------------------
function Exit:onMove (player, room)
    local text    = self.data.move
    local script  = self.data.onMove
    local canMove = true
    if script ~= nil and type(script) == "function" then
        canMove, text = script(self, player, room)
        assert(type(canMove) == "boolean")
        assert(text == nil or type(text) == "string")
    end

    game:write(text)
    return canMove
end

---------------------------------------------------------------------------------------------------
function Exit:getNameWithArticle ()
    local article = self.data.article or ""
    return article .. " " .. self.id
end

return Exit
