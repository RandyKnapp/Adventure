-- entity.lua
-- Adventure game
-- Randy Knapp - 2014
---------------------------------------------------------------------------------------------------

local class = require 'util.class'
local Color = require 'util.color'
local util  = require 'util.util'

-- Aliases
local type        = type
local assert      = assert
local getFunction = util.getFunction

--=================================================================================================
local Entity = class.define({
})

---------------------------------------------------------------------------------------------------
function Entity:constructor (id, data, defaultActions)
    self.id      = id
    self.data    = data
    self.names   = {}
    self.actions = {}

    -- Create name set
    if data.name ~= nil then
        --print("entity name: " .. data.name)
        self.names[data.name] = true
        self.name = data.name
    end
    if data.synonyms ~= nil and type(data.synonyms) == "table" then
        for i, name in ipairs(data.synonyms) do
            self.names[name] = true
        end
    end

    -- Get functions
    self.data.onLook     = getFunction(self.data.onLook, "self, player, room")
    self.data.onInteract = getFunction(self.data.onInteract, "self, player, room, action")

    -- Create action set
    defaultActions = defaultActions or { "use", "interact" }
    for i, action in ipairs(defaultActions) do
        self.actions[action] = true
    end

    if data.actions ~= nil and type(data.actions) == "table" then
        for i, action in ipairs(data.actions) do
            self.actions[action] = true
        end
    end

    -- Gather properties
    if data.properties ~= nil and type(data.properties) == "table" then
        for k, v in pairs(data.properties) do
            if self[k] == nil then self[k] = v end
        end
    end
end

---------------------------------------------------------------------------------------------------
local function getIndefiniteArticle (word)
    local first = string.lower(word:sub(1, 1))
    local vowels = { a = true, e = true, i = true, o = true, u = true }
    if vowels[first] then
        return "an " .. word
    else
        return "a " .. word
    end
end

---------------------------------------------------------------------------------------------------
function Entity:getNameWithArticle ()
    if self.name ~= nil then
        return getIndefiniteArticle(self.name)
    else
        return nil
    end
end

---------------------------------------------------------------------------------------------------
function Entity:hasName (name)
    return self.names[name] ~= nil
end

---------------------------------------------------------------------------------------------------
function Entity:hasAction (action)
    return self.actions[action]
end

---------------------------------------------------------------------------------------------------
function Entity:onLook (player, room)
    local text   = self.data.look
    local script = self.data.onLook
    if script ~= nil and type(script) == "function" then
        text = script(self, player, room)
    end

    game:write(text)
end

---------------------------------------------------------------------------------------------------
function Entity:onInteract (player, room, action)
    local canInteract = self:hasAction(action)
    local script = self.data.onInteract

    if not canInteract or script == nil or type(script) ~= "function" then
        game:write(Color.noEffect("You cannot " .. action .. " the " .. self.data.name .. "."))
        return false
    else
        local canUse, text = script(self, player, room, action)
        assert(text == nil or type(text) == "string")
        game:write(text)
        return canUse
    end
end

return Entity
