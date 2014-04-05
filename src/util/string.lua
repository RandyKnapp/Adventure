-- string.lua
-- Adventure game
-- Randy Knapp - 2014
---------------------------------------------------------------------------------------------------

local tinsert = table.insert

function string.split (s, delim)
    if not s or s == "" or not delim or delim == "" then
        return nil
    end

    local result = nil

    for i in string.gmatch(s, delim) do
        result = result or {}
        tinsert(result, i)
    end

    return result
end
