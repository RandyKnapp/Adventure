Adventure
=========

Text-based adventure game written in Lua

How To Run Adventure
--------------------
1. Pull the repository to desktop using the GitHub for Windows tool.
2. Open the src folder and run the run.bat tool.

How To Create an Adventure
--------------------------
1. Add a new lua file to the data folder. Format it using viceroy.lua as an example and the following documentation.
2. Add the new adventure to config.lua. See the following documentation for details.
3. Test your adventure using the run.bat file.

Template adventure file
-----------------------
```
return {
    adventure = {
        id = "",
        name = "",
        description = "",
        author = "",
        date = "",
        notes = "",
        prereqs = {}
    },
    rooms = {
    },
    entities = {
        props = {
        },
        items = {
        }
    }
}
```

Data Format:
------------
- adventure (Table): Adventure specific data
- rooms (Table<Room>): A table of room definitions. The key is the ID for the room, and used to 
    reference the room in script.
- entities (Table): A table containing two subtables:
    - props (Table<Prop>): A table of prop definitions. The key is the ID for the prop, used in 
        room definitions and script.
    - items (Table<Item>): A table of item definitions. The key is the ID for the item, used in 
        room definitions and script.

Adventure Data Format:
----------------------
- id (String):            String identifier of the adventure. Used to switch adventures in script.
- name (String):          Human readable name of the adventure. Will display in the adventure list.
- description (String):   Human readable long description of the adventure. Will display when the 
    player gets more information about the adventure.
- start (String):         Human readable text to be displayed when the adventure first starts.
- author (String):        The in-canon name of the technician who created the level. I prefer the 
    format: "<Rank> <First Initial>. <Last Name>". I feel this should somewhat reflect the name of 
    the actual author of the adventure. For example, my name is Randy Knapp, and I game myself the 
    rank of Class-61 Technician (a tech who works on Mjolnir II armor) so my author entry is "C-61 
    Tech R. Knapp".
- date (String):          In-canon date when the level was created. 
- notes (String):         Human readable fluff text. This will be displayed along with the 
    description but with different formatting to show that it's fluff.
- prereqs (List<String>): A list of adventure ID strings that the player must complete before this 
    adventure becomes available. If this field is missing or is an empty table, then this adventure 
    will be available immediately.

** IMPORTANT ** 
    Be sure to add your new adventure to config.lua. See section below detailing the process.

Room Data Format:
-----------------
- start (Boolean):    Indicates if this is the starting room for the world. There should only be 
    one starting room in the world.
- name (String):      The human readable name of the room.
- enter (String):     Text to print when the player enters the room.
- onEnter (Function): [self, player]:String - The function called when the player enters the room. 
    Should return a line of text to print when the player enters the room. This field overrides the 
    enter text.
- look (String):      Text to print when the player looks at the room.
- onLook (Function):  [self, player]:String - The function called when the player looks at the room. 
    Should return a string to print when the player looks at the room. Overrides the look text.
- properties (Table): A set of key-value pairs to be accessible on the Room object in scripts.
- exits (Table):      A table containing the exit data for the room. The keys should be the 
    directions the player will go.
- entities (Table):   A table containing entity ids with the following optional fields:
    - props (List<String>): A list of prop entity ids
    - items (List<String>): A list of item entity ids

Exit Data Format:
-----------------
- to (String):              Room id to move to.
- article (String):         (Optional, default = "to the") String to be placed in front of the exit 
    id when listing exits in the room. 
- synonyms (List<String>):  List of alternate names for this exit.
- actions (List<String>):   List of alternate actions (besides 'go' and 'move').
- look (String):            String to print when the player looks at this exit.
- onLook (Function):        [self, player, room]:String - Function to call when the player looks at 
    this exit. Overrides look text. Should return a string to print.
- move (String):            String to print when the player moves through this exit.
- onMove (Function):        [self, player, room]:[Boolean, String] - Function to call when the 
    player tries to move through this exit. Overrides move text. Should return two values: the 
    first is a boolean value expressing whether the player may move through this exit, the second 
    is the string to print when the player tries to move through this exit.
- properties (Table):       A set of key-value pairs to be accessible on the Exit object in scripts.

Base Entity Data Format (all entities have this data):
------------------------------------------------------
- name (String):           Human readable name for the entity.
- synonyms (List<String>): List of alternate names for the entity.
- properties (Table):      A set of key-value pairs to be accessible on the Entity object in 
    scripts.
- look (String):           String to print when the player looks at the entity.
- onLook (Function):       [self, player, room]:String - Function to call when the player looks at 
    the entity. Overrides look text. Should return a string to print when looked at.
- actions (List<String>):  A list of alternate action verbs for this entity. Default interaction 
    verbs: 'use', 'interact'.
- onInteract (Function):   [self, player, room, action]:[Boolean, String] - Function to call when 
    the player interacts with this entity. Should return a bool if the player can use the entity 
    and a string to print when interacted with.

Item Data Format:
-----------------
-- (all Entity data plus:)
- pickup (String):     String to print when the player picks up the item into their inventory.
- onPickup (Function): [self, player, room]:[Boolean, String] - Function to call when the player 
    attempts to pick up the item. Overrides pickup text. Should return a bool saying if the pickup 
    was successful and a string to print.
- drop (String):       String to print when the player drops an item into the room from their 
    inventory.
- onDrop (Function):   [self, player, room]:[Boolean, String] - Function to call when the player 
    attempts to drop the item. Overrides drop text. Should return a bool saying if the drop was 
    successful and a string to print.

Adding your adventure to the game
---------------------------------
Be sure to add your new adventure to the adventures list in config.lua. Add the following line: 

    require 'data.<filename>',

to the list and it will become available from the hub. Note that the filename should not include 
".lua". For example, if your adventure was in viceroy.lua, you would put:

    require 'data.viceroy',

(with the trailing comma) into the list. The data list is in the order the adventures will appear 
when the player asks for available adventures in-game.
