-- Viceroy adventure data
-- Adventure game TEST GAME
-- Randy Knapp - 2014
---------------------------------------------------------------------------------------------------

return {
    --[[-----------------------------------------------------------------------------------------------
        Data Format:
        - adventure (Table): Adventure specific data
        - rooms (Table<Room>): A table of room definitions. The key is the ID for the room, and used to reference the room in script.
        - entities (Table): A table containing two subtables:
            - props (Table<Prop>): A table of prop definitions. The key is the ID for the prop, used in room definitions and script.
            - items (Table<Item>): A table of item definitions. The key is the ID for the item, used in room definitions and script.
    --]]
    --=================================================================================================
    adventure = {
        --[[-------------------------------------------------------------------------------------------
            Adventure Data Format:
            - id (String):            String identifier of the adventure. Used to switch adventures in script.
            - name (String):          Human readable name of the adventure. Will display in the adventure list.
            - description (String):   Human readable long description of the adventure. Will display when the player gets more information about the adventure.
            - start (String):         Human readable text to be displayed when the adventure first starts.
            - author (String):        The in-canon name of the technician who created the level. I prefer the format: "<Rank> <First Initial>. <Last Name>". I feel this should somewhat reflect the name of the actual author of the adventure. For example, my name is Randy Knapp, and I game myself the rank of Class-61 Technician (a tech who works on Mjolnir II armor) so my author entry is "C-61 Tech R. Knapp".
            - date (String):          In-canon date when the level was created. 
            - notes (String):         Human readable fluff text. This will be displayed along with the description but with different formatting to show that it's fluff.
            - prereqs (List<String>): A list of adventure ID strings that the player must complete before this adventure becomes available. If this field is missing or is an empty table, then this adventure will be available immediately.
        
            ** IMPORTANT ** 
                Be sure to add your new adventure to config.lua. Add the following line: "require 'data.<filename>'," to the list and it will become available from the hub. Note that the filename should not include ".lua". For example, if your adventure was in viceroy.lua, you would put "require 'data.viceroy',"  with the trailing comma into the list. The data list is in the order the adventures will appear when the player asks for available adventures in-game.
        --]]
        id = "viceroy",
        name = "USSS Viceroy Derelict",
        description = "The derelict remains of the USSS Viceroy, a Razor-class light cruiser lost to humanity during the Reaper war.",
        start = "I'm sending you to investigate the derelict USSS Viceroy, a Razor-class light cruiser that went dark during the war. It's almost certainly got valuable intel and we'll need you to recover whatever you can from the onboard computers. You mission is fairly simple, break in through and airlock and make your way to the bridge. Recover any data you can and then get yourself out. Good luck, soldier.",
        author = "C-61 Tech R. Knapp",
        date = "February 10th 2558",
        notes = "Last night the guys at poker said that the mech-troopers sometimes get bored waiting for drops and orders and shit. Thought I'd whip together a little \"visor-based-entertainment\" for 'em. Here's the first level.",
        prereqs = {}
    },
    --=================================================================================================
    rooms = {
        --[[-------------------------------------------------------------------------------------------
            Room Data Format
            - start (Boolean):    Indicates if this is the starting room for the world. There should only be one starting room in the world.
            - name (String):      The human readable name of the room.
            - enter (String):     Text to print when the player enters the room.
            - onEnter (Function): [self, player]:String - The function called when the player enters the room. Should return a line of text to print when the player enters the room. This field overrides the enter text.
            - look (String):      Text to print when the player looks at the room.
            - onLook (Function):  [self, player]:String - The function called when the player looks at the room. Should return a string to print when the player looks at the room. Overrides the look text.
            - properties (Table): A set of key-value pairs to be accessible on the Room object in scripts.
            - exits (Table):      A table containing the exit data for the room. The keys should be the directions the player will go.
            - entities (Table):   A table containing entity ids with the following optional fields:
                - props (List<String>): A list of prop entity ids
                - items (List<String>): A list of item entity ids
        --]]
        --[[-------------------------------------------------------------------------------------------
            Exit Data Format
            - to (String):              Room id to move to.
            - article (String):         (Optional, default = "to the") String to be placed in front of the exit id when listing exits in the room. 
            - synonyms (List<String>):  List of alternate names for this exit.
            - actions (List<String>):   List of alternate actions (besides 'go' and 'move').
            - look (String):            String to print when the player looks at this exit.
            - onLook (Function):        [self, player, room]:String - Function to call when the player looks at this exit. Overrides look text. Should return a string to print.
            - move (String):            String to print when the player moves through this exit.
            - onMove (Function):        [self, player, room]:[Boolean, String] - Function to call when the player tries to move through this exit. Overrides move text. Should return two values: the first is a boolean value expressing whether the player may move through this exit, the second is the string to print when the player tries to move through this exit.
            - properties (Table):       A set of key-value pairs to be accessible on the Exit object in scripts.
        --]]
        -----------------------------------------------------------------------------------------------
        airlock = {
            start = true,
            name = "Airlock entrance",
            onEnter = function (self, player)
                local beginMission = player:getGoal("beginMission")
                local electricalOn = player:getGoal("electricalOn")
                if not beginMission.complete then
                    player:completeGoal("beginMission")
                    -- Say first line
                    return "After parking your spacecraft outside the derelict and overriding the airlock, you carefully step inside and close the airlock door behind you with a clang."
                elseif player:hasItemById("intelligence") then
                    return "You've got the intelligence and you're ready to head back to the Adventure Hub. Well done."
                else
                    -- Otherwise, as if you had entered not the first time
                    if electricalOn.complete then
                        return "You are in the hallway by the airlock. The lights have come on since you started the emergency generators."
                    else
                        return "You are in the hallway by the airlock. It's still fairly dark."
                    end
                end
            end,
            onLook = function (self, player)
                local electricalOn = player:getGoal("electricalOn")
                if electricalOn.complete then
                    return "You are standing in the hallway just inside the derelict's airlock. The hallway is brightly lit."
                else
                    return "You are standing in the hallway just inside the derelict's airlock. The only illumination comes from your spacecraft outside through the airlock window. Your shadow paints your distorted silouette down the hallway's floor tiles."
                end
            end,
            exits = {
                bow = {
                    to = "accessLadder",
                    look = "Towards the bow, you see a darkened hallway with a metal grate set into the floor near the wall.",
                    move = "You walk towards the bow of the ship and the dark end of the hallway."
                },
                starboard = {
                    to = "securityDoor",
                    look = "The hallway continues across the derelict toward the starboard side.",
                    move = "You walk down the hallway towards the starboard side of the ship."
                }
            },
            entities = {
                props = { "airlock", "conduit2" }
            }
        },
        -----------------------------------------------------------------------------------------------
        accessLadder = {
            name = "Access Ladder",
            enter = "You are standing at the end of the hallway. There is a grate on the floor.",
            onLook = function (self, player)
                local electricalOn = player:getGoal("electricalOn")
                if electricalOn.complete then
                    return "The birghtly lit hallway ends here. Some conduit runs along the floor and into a grate on the floor."
                else
                    return "The hallway ends here in the dark. Some conduit runs along the floor and into a grate on the floor."
                end
            end,
            exits = {
                stern = {
                    to = "airlock",
                    look = "The hallway to the airlock door leads back towards the stern of the derelict.",
                    move = "You walk back down the hallway towards the airlock."
                },
                down = {
                    to = "electrical",
                    article = "",
                    synonyms = { "ladder" },
                    actions = { "climb" },
                    onLook = function (self, player, room)
                        local grate = room:getEntity("accessLadderGrate")
                        if grate.state == "open" then
                            return "The ladder leads down an access shaft into the darkness."
                        else
                            return "A metal grate covers the access shaft, barring your way down."
                        end
                    end,
                    onMove = function (self, player, room)
                        local grate = room:getEntity("accessLadderGrate")
                        if grate.state == "open" then
                            return true, "You climb down the ladder"
                        else
                            return false, "A metal grate covers the access shaft, barring your way down."
                        end
                    end
                }
            },
            entities = {
                props = { "accessLadderGrate", "conduit3" }
            }
        },
        -----------------------------------------------------------------------------------------------
        electrical = {
            name = "Electrical Maintenance",
            onLook = function (self, player, room)
                local electricalOn = player:getGoal("electricalOn")
                if electricalOn.complete then
                    return "The electrical maintenance room is well lit. The hum of the generators is loud here."
                else
                    return "The room is nearly dark. The only light in the room is the dim red light of a button on the wall in front of you."
                end
            end,
            exits = {
                up = {
                    to = "accessLadder",
                    article = "",
                    synonyms = { "ladder" },
                    actions = { "climb" },
                    onLook = function (self, player, room)
                        local electricalOn = player:getGoal("electricalOn")
                        if electricalOn.complete then
                            return "The ladder leads back up into the airlock hallway. It looks brighter up there now."
                        else
                            return "The ladder leads back up into the darkened end of the airlock hallway."
                        end
                    end,
                    move = "You climb up the ladder into the hallway above."
                }
            },
            entities = {
                props = { "electricalWallPanel", "generatorButton", "conduit4" }
            }
        },
        -----------------------------------------------------------------------------------------------
        securityDoor = {
            name = "Security Door",
            enter = "You are standing at the end of the hallway in front of a security door.",
            onLook = function (self, player)
                local electricalOn = player:getGoal("electricalOn")
                if electricalOn.complete then
                    return "The dark hallway ends in a thick bulkhead security door. A red emergency backup light glows on the control panel, partially illuminating the area near the door. The door has a small window, but it is too dark on the other side to see anything."
                else
                    return "The hallway ends in a bulkhead security door. A green light glows on the control panel. Light can be seen through the door's small window."
                end
            end,
            exits = {
                bow = {
                    to = "bridge",
                    synonyms = { "door" },
                    onLook = function (self, player, room)
                        local electricalOn = player:getGoal("electricalOn")
                        if electricalOn.complete then
                            local door = room:getEntity("securityDoorProp")
                            local look = ""
                            if door.state == "closed" then
                                look = "You peer through the door's window. "
                            end
                            return look .. "You see a short, narrow hallway leading to the Viceroy's bridge."
                        else
                            return "It is too dark to see anything through the window in the door."
                        end
                    end,
                    onMove = function (self, player, room)
                        local door = room:getEntity("securityDoorProp")
                        if door.state == "open" then
                            return true, "You step through the door."
                        else
                            return false, "The door is closed."
                        end
                    end
                },
                port = {
                    to = "airlock",
                    look = "That way leads back towards the airlock.",
                    move = "You walk down the hall towards the airlock"
                }
            },
            entities = {
                props = { "securityDoorProp", "securityDoorControlPanel", "conduit1" }
            }
        },
        -----------------------------------------------------------------------------------------------
        bridge = {
            name = "Bridge",
            look = "This is the bridge of the USSS Viceroy. TODO: More descriptions. You can clearly see the ship's black-box intelligence computer.",
            exits = {
                stern = {
                    to = "securityDoor",
                    look = "The way goes back through the security door.",
                    move = "You step through the security door."
                }
            },
            entities = {
                items = { "intelligence" }
            }
        }
    }, -- /rooms

    --=================================================================================================
    entities = {
        --[[-------------------------------------------------------------------------------------------
            Base Entity Data Format (all entities have this data)
            - name (String):           Human readable name for the entity.
            - synonyms (List<String>): List of alternate names for the entity.
            - properties (Table):      A set of key-value pairs to be accessible on the Entity object in scripts.
            - look (String):           String to print when the player looks at the entity.
            - onLook (Function):       [self, player, room]:String - Function to call when the player looks at the entity. Overrides look text. Should return a string to print when looked at.
            - actions (List<String>):  A list of alternate action verbs for this entity. Default interaction verbs: 'use', 'interact'.
            - onInteract (Function):   [self, player, room, action]:[Boolean, String] - Function to call when the player interacts with this entity. Should return a bool if the player can use the entity and a string to print when interacted with.
        --]]
        props = {
            -------------------------------------------------------------------------------------------
            airlock = {
                name = "airlock",
                onLook = function (self, player, room)
                    if player:hasItem("intelligence") then
                        return "Your shuttle is waiting outside to take you back to the Adventure."
                    else
                        return "The airlock entrance is shut and sealed. You should find the intelligence before leaving."
                    end
                end,
                actions = { "go", "use", "open" },
                onInteract = function (self, player, room, action)
                    if player:hasItem("intelligence") then
                        game:endAdventure()
                    else
                        game:write("Leaving the Viceroy now will end your mission.")
                        game:confirmEndAdventure()
                    end
                end
            },
            -------------------------------------------------------------------------------------------
            conduit1 = {
                name = "conduit",
                look = "Some conduit runs from the door along the wall back towards the airlock."
            },
            -------------------------------------------------------------------------------------------
            conduit2 = {
                name = "conduit",
                look = "Some conduit runs along the wall, going around the corner."
            },
            -------------------------------------------------------------------------------------------
            conduit3 = {
                name = "conduit",
                look = "Some conduit runs along the wall, down onto the floor and into a grate."
            },
            -------------------------------------------------------------------------------------------
            conduit4 = {
                name = "conduit",
                look = "Some conduit runs along the wall beside the ladder and into a panel on the wall."
            },
            -------------------------------------------------------------------------------------------
            accessLadderGrate = {
                name = "grate",
                properties = {
                    state = "closed"
                },
                onLook = function (self, player, room)
                    if self.state == "closed" then
                        return "The grate looks like it covers an access shaft to a lower level."
                    else
                        return "The open grate reveals a ladder leading down the access shaft."
                    end
                end,
                actions = { "open", "close" },
                onInteract = function (self, player, room, action)
                    if action == "open" and self.state == "open" then
                        return true, "The grate is already open."
                    elseif action == "close" and self.state == "closed" then
                        return true, "The grate is already closed."
                    end

                    if self.state == "closed" then
                        self.state = "open"
                        return true, "You opened the grate."
                    else
                        self.state = "closed"
                        return true, "You closed the grate."
                    end
                end
            },
            -------------------------------------------------------------------------------------------
            electricalWallPanel = {
                name = "wall panel",
                synonyms = { "panel", "metal panel" },
                onLook = function (self, player, room)
                    local electricalOn = player:getGoal("electricalOn")
                    if electricalOn.complete then
                        return "The panel with the button is mounted on the wall. It's labeled 'Emergency Power'."
                    else
                        return "It's too dark to see any details, but the button is mounted to the wall on some sort of metal panel."
                    end
                end
            },
            -------------------------------------------------------------------------------------------
            generatorButton = {
                name = "button",
                onLook = function (self, player, room)
                    local electricalOn = player:getGoal("electricalOn")
                    if electricalOn.complete then
                        return "The button on the front of the electrical control panel is glowing green. It's labeled 'Emergency Power'."
                    else
                        return "The button glows a very faint red. Without much light in the room, it's hard to see if the button is labeled."
                    end
                end,
                actions = { "push", "press" },
                onInteract = function (self, player, room, action)
                    local electricalOn = player:getGoal("electricalOn")
                    if electricalOn.complete then
                        return true, "Nothing more happens. The power is already on."
                    else
                        player:completeGoal("electricalOn")
                        return true, "You depress the button, pushing firmly. It makes a solid click and stays depressed as a loud whirring sound begins behind the wall. The button turns green and the lights come on. You can see clearly in the room now."
                    end
                end
            },
            -------------------------------------------------------------------------------------------
            securityDoorProp = {
                name = "door",
                properties = {
                    state = "closed"
                },
                onLook = function (self, player, room)
                    local look = "The thick door is enclosed in a bulkead, probably designed to maintain pressure in case of a hull breach. "
                    if self.state == "closed" then
                        return look .. "The door is closed."
                    else
                        return look .. "The door is open."
                    end
                end,
                actions = { "open", "close", },
                onInteract = function (self, player, room, action)
                    if action == "open" and self.state == "closed" then
                        return true, "There's no handle or hand-holds on the door. It seems to be controlled by a control panel mounted on the wall nearby."
                    elseif action == "open" and self.state == "open" then
                        return true, "The door is already open."
                    elseif action == "close" and self.state == "open" then
                        self.state = "closed"
                        return true, "You close the door with a loud clang."
                    elseif action == "close" and self.state == "closed" then
                        return true, "The door is already closed."
                    end
                end
            },
            -------------------------------------------------------------------------------------------
            securityDoorControlPanel = {
                name = "control panel",
                synonyms = { "button", "control", "panel" },
                onLook = function (self, player, room)
                    local electricalOn = player:getGoal("electricalOn")
                    if electricalOn.complete then
                        return "The control panel has a single button labeled 'Manual Door Control' lit up in green."
                    else
                        return "The control panel is unlit and dead looking. You can feel some conduit running out from the side along the wall."
                    end
                end,
                actions = { "push", "press" },
                onInteract = function (self, player, room, action)
                    local electricalOn = player:getGoal("electricalOn")
                    if electricalOn.complete then
                        local door = room:getEntity("securityDoorProp")
                        door.state = "open"
                        return true, "You press the button labeled 'Manual Door Control' and the door slowly opens with a hiss of stale air and pneumatics."
                    else
                        return true, "You fumble in the dark and press the only button on the panel. Nothing happens."
                    end
                end
            }
        }, -- /props

        --[[-------------------------------------------------------------------------------------------
            Item Data Format
            -- (all Entity data plus:)
            - pickup (String):     String to print when the player picks up the item into their inventory.
            - onPickup (Function): [self, player, room]:[Boolean, String] - Function to call when the player attempts to pick up the item. Overrides pickup text. Should return a bool saying if the pickup was successful and a string to print.
            - drop (String):       String to print when the player drops an item into the room from their inventory.
            - onDrop (Function):   [self, player, room]:[Boolean, String] - Function to call when the player attempts to drop the item. Overrides drop text. Should return a bool saying if the drop was successful and a string to print.
        --]]
        items = {
            intelligence = {
                name = "intelligence computer",
                synonyms = { "computer", "intelligence", "black box" },
                look = "It's a small black box with wires sticking out of one end. This computer holds all the data and information gathered by the crew of the Viceroy. Better get it back to Ares and the Adventure right away.",
                onPickup = function (self, player, room)
                    player:completeGoal("retrieveIntelligence")
                    return true, "You take the black box intelligence computer."
                end
            }
        } -- /items
    } -- /entities
} -- /data
