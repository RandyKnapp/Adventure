-- prop.lua
-- Adventure game
-- Randy Knapp - 2014
---------------------------------------------------------------------------------------------------

local class = require 'util.class'
local Entity = require 'game.adventure.entity'

--=================================================================================================
local Prop = Entity:extends({
})

---------------------------------------------------------------------------------------------------
function Prop:constructor (id, data)
    assert(data.name ~= nil, "Props must have a name! (Prop: " .. id .. ")")
    self:super("constructor", id, data)
end

return Prop
