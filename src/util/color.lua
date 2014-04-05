-- color.lua
-- Adventure game
-- Randy Knapp - 2014
---------------------------------------------------------------------------------------------------

-- Aliases
local pairs = pairs
local tostring = tostring
local setmetatable = setmetatable
local schar = string.char

-- Module
local USE_COLOR = IN_GAME
local Color = {}

-- Color close tag
if USE_COLOR then
    Color.close = "</Color>"
else
    Color.close = ""
end

-- Metatable
local colormt = {}

function colormt:__tostring()
    return self.value
end

function colormt:__concat(other)
    return tostring(self) .. tostring(other)
end

function colormt:__call(s)
    return self .. s .. Color.close
end

colormt.__metatable = {}

local function makecolor(value)
    if USE_COLOR then
        return setmetatable({ value = "<Color " .. value .. ">" }, colormt)
    else
        return setmetatable({ value = "" }, colormt)
    end
end

local colors = {
    red = "#FF7050",
    pink = "#FF6CCC",
    orange = "#F29E4A",
    yellow = "#FFED5D",
    green = "#93DE7F",
    blue = "#7BBADE",
    purple = "#CA71FF",
    gray = "#9CB0AF",
    darkGray = "#9CB0AF",
    white = "White"
}

for c, v in pairs(colors) do
    Color[c] = makecolor(v)
end

-- Custom
Color.person    = Color.red
Color.noEffect  = Color.darkGray
Color.help      = Color.green
Color.exit      = Color.yellow
Color.item      = Color.pink
Color.levelDesc = Color.orange
Color.begin     = Color.orange

return Color
