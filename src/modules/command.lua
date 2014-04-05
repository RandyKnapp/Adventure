-- Command Module
-- Adventure game
-- Randy Knapp - 2014
---------------------------------------------------------------------------------------------------

local class = require 'util.class'
local Color = require 'util.color'

--=================================================================================================
local CommandModule = class.define({
    commands = {},
    list = {},
    messageMode = false,
    yesText = "yes",
    noText = "no",
    onYes = nil,
    onNo = nil
})

---------------------------------------------------------------------------------------------------
function CommandModule:constructor (parent)
    assert(parent ~= nil, "Command module must have a parent reference")
    self.parent = parent
end

---------------------------------------------------------------------------------------------------
function CommandModule:addCommand (name, synonyms, proc, helpText)
    synonyms = synonyms or {}

    local commands = self.commands
    if commands[name] then
        return false
    end

    commands[name] = { name = name, proc = proc, helpText = helpText, synonyms = synonyms }

    for i, synonym in ipairs(synonyms) do
        commands[synonym] = { name = name, proc = proc, helpText = helpText, isSynonym = true }
    end

    table.insert(self.list, name)

    return true
end

---------------------------------------------------------------------------------------------------
function CommandModule:addUnknownCommandProc (proc)
    self.unknownCommandProc = proc
end

---------------------------------------------------------------------------------------------------
function CommandModule:hasCommand (name)
    return self.commands[name] ~= nil
end

---------------------------------------------------------------------------------------------------
function CommandModule:getCommandProc (name)
    local command = self.commands[name]
    if command then
        return command.proc
    else
        return nil
    end
end

---------------------------------------------------------------------------------------------------
function CommandModule:getCommandHelpText (name)
    local command = self.commands[name]
    if command then
        if #command.synonyms > 0 then
            return "(" .. table.concat(command.synonyms, ", ") .. ") " .. command.helpText
        else
            return command.helpText
        end
    else
        return nil
    end
end

---------------------------------------------------------------------------------------------------
function CommandModule:runCommand (name, params)
    if self.messageMode then
        return self:handleMessage(name)
    elseif name == "help" then
        return self:runHelp(params)
    else
        local command = self.commands[name]
        if command then
            return command.proc(self.parent, params)
        elseif self.unknownCommandProc ~= nil then
            return self.unknownCommandProc(self.parent, name, params)
        end
    end
end

---------------------------------------------------------------------------------------------------
function CommandModule:runHelp (params)
    if #params < 1 then
        return self:runStandardHelp()
    end

    local commmandName = params[1]
    if self:hasCommand(commmandName) then
        game:write(Color.help("HELP> ") .. commmandName .. ": " .. self:getCommandHelpText(commmandName))
    else
        game:write(Color.help("HELP> ") .. "I can't help you with '" .. commmandName .. "'\n  ")
        self:runStandardHelp()
    end

    return true
end

---------------------------------------------------------------------------------------------------
function CommandModule:runStandardHelp ()
    game:write(Color.help("HELP>") .. " Commands (type " .. Color.help("help <command>") .. " to get help about a specific command):")
    
    local i = 1
    for i, name in ipairs(self.list) do
        local data = self.commands[name]
        if not data.isSynonym then
            game:write(tostring(i) .. ": " .. name)
            i = i + 1
        end
    end

    return true
end

---------------------------------------------------------------------------------------------------
function CommandModule:message (text, onYes, onNo, yesText, noText)
    assert(not self.messageMode, "ERROR: Cannot begin a message while another message is active.")

    -- Defaults
    self.yesText = yesText or "yes"
    self.noText  = noText or "no"

    -- Store off callbacks
    self.onYes = onYes
    self.onNo = onNo

    -- Write the message
    game:write(text .. " (" .. self.yesText .. "/" .. self.noText .. ")")
    self.messageMode = true

    return true
end

---------------------------------------------------------------------------------------------------
function CommandModule:handleMessage (command)
    assert(self.messageMode, "ERROR: Trying to handle message while not in message mode.")

    if command == self.yesText then
        if self.onYes ~= nil then
            if type(self.onYes) == "function" then
                self.onYes(self.parent)
            elseif type(self.onYes) == "string" then
                game:write(self.onYes)
            end
        else
            game:write(self.yesText)
        end
        self.messageMode = false
        self.onYes       = nil
        self.onNo        = nil
    elseif command == self.noText then
        if self.onNo ~= nil then
            if type(self.onNo) == "function" then
                self.onNo(self.parent)
            elseif type(self.onNo) == "string" then
                game:write(self.onNo)
            end
        else
            game:write(self.noText)
        end
        self.messageMode = false
        self.onYes       = nil
        self.onNo        = nil
    else
        game:write("You must answer " .. self.yesText .. " or " .. self.noText)
    end

    return true
end

return CommandModule
