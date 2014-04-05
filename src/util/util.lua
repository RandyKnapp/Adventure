-- util.lua
-- Adventure game
-- Randy Knapp - 2014
---------------------------------------------------------------------------------------------------

local util = {}

---------------------------------------------------------------------------------------------------
function util.getFunction (funcOrString, paramString)
    if type(funcOrString) == "function" then
        return funcOrString
    elseif type(funcOrString) == "string" then
        local funcString = "return function (" .. (paramString or "") .. ")\n" .. funcOrString .. "\nend"
        return assert(loadstring(funcString))()
    else
        return nil
    end
end

return util
