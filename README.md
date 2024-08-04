## Documentation for `envi-interact`

The `envi-interact` script provides a versatile interaction system for creating dynamic menus (such as multi-choice menus, speech bubbles, percentage bars, and sliders), easily handling NPC interactions, providing an optimized solution to 'Press E' interactions within in your FiveM Server.

![Alt text](https://media.discordapp.net/attachments/1174950183570776075/1250773951320162399/image.png?ex=666d7b04&is=666c2984&hm=578ece92a1ba05e1008580266d4db442d6766e102234dadf7ff3eccf3aa2f5e1&=&format=webp&quality=lossless&width=2493&height=1334)


Below is a detailed guide on how to use the exported functions from this script in your other lua scripts/resources.

### Exported Functions

#### 1. `OpenChoiceMenu`
Opens a menu with multiple choice options.

**Parameters:**
- `data` (table): A table containing the menu configuration.
  - `menuID` (string): A unique identifier for the menu. - NOTE: MUST BE UNIQUE TO AVOID CONFLICTS
  - `title` (string): The title of the menu.
  - `speech` (string): A speech or description associated with the menu. If false, the menu will be a simple choice menu.
  - `speechOptions` (table): A table of speech options (more added soon)
      - `duration` (number): The duration it takes for the speech to show from start to end
  - `position` (string): The position on the screen (e.g., 'left', 'right').
  - `timeout` (table): A table containing timeout configuration with keys `time` (number) and `closeEverything` (boolean).
  - `options` (table): A list of options, each being a table with keys `key`, `label`, `selected`, `closeAll`, `speech`, and `reaction`.


  NOTE:
  Some options are only avaliable when use PedInteraction or CreateNPC ChoiceMenus such as:
  - `reaction` (string): The VOICE PARAM to use when the option is selected.
  - `speech` (string): A speech to display when the option is selected.

**Returns:**
- `string`: The key of the selected option if not using callbacks in options.

**Example using 'selected' functions:**
```lua
exports['envi-interact']:OpenChoiceMenu({
  title = 'Decision Time',
  menuID = 'decision-menu',
  position = 'right',
  timeout = {time = 60, closeEverything = true},
  options = {
    {   
      key = 'A',
      label = 'Option A',
      selected = function()
        print('Option A selected')
     end
    },
    { 
      key = 'B',
      label = 'Option B',
      selected = function() 
        print('Option B selected') 
      end 
    }
  }
})
```

**Example returning option Chosen/ Key Pressed:**
```lua
local optionChosen = exports['envi-interact']:OpenChoiceMenu({
  title = 'Decision Time',
  menuID = 'simple-decision-menu',
  position = 'right',
  options = {
    {   
      key = 'A',
      label = 'Option A',
      speech = 'You chose Option A.',
    },
    { 
      key = 'B',
      label = 'Option B',
      speech = 'You chose Option B.',
    }
  }
})
if optionChosen == 'A' then
  print('Option A selected')
elseif optionChosen == 'B' then
  print('Option B selected')
end
```


#### 2. `CreateNPC`
Creates an all-in-one NPC with specified attributes and interaction options.
This will:
- Spawn the NPC
- Set up Press E to interact keybind for the NPC
- Set up a menu for the NPC to interact with the player

**Parameters:**
- `pedData` (table): Data about the NPC model and spawn location.
  - `model` (string): Model name of the NPC.
  - `coords` (vector3): Coordinates where the NPC will spawn.
  - `heading` (number): Direction the NPC faces.
  - `isFrozen` (boolean): Whether the NPC should be immobile.
- `interactionData` (table): Interaction options and UI settings.
  - `title`, `speech`, `speechOptions`, `menuID`, `position`, `timeout`, `options` as in `OpenChoiceMenu`.
  - `focusCam` (boolean): Whether the camera should focus on the NPC when interacting.
  - `greeting` (string): The VOICE PARAM to use when interacting.

**Returns:**
- `entity`: The spawned NPC entity.

**Example:**
```lua
local npc = exports['envi-interact']:CreateNPC({ -- Table of NPC Attributes (pedData)
  model = 'a_m_m_business_01', 
  coords = vector3(-138.9195, -633.8308, 168.8205), 
  heading = 90, 
  isFrozen = true
}, {    -- Table of Choice Menu Data (interactionData)
  title = 'Greetings', 
  speech = 'Hello there! Let\'s choose an option. What would you like to talk about?', 
  speechOptions = {   -- table of speech options (more added soon)
    duration = 2000,
  },
  menuID = 'npc-interaction-menu-1', 
  position = 'right',
  greeting = 'GENERIC_HI',
  timeout = {time = 60},
  focusCam = true,
  options = {   -- Table of Choice Menu Options
    { 
      key = 'E',
      label = 'Talk about the weather',
      reaction = 'GENERIC_SHOCKED_MED',
      selected = function(data) -- data is a table of the current menu data
        print('Talking about the weather...')
        exports['envi-interact']:CloseMenu(data.menuID)   -- To close the current menu after interaction
      end
    },
    {
      key = 'F',
      label = 'Talk about sports',
      reaction = 'GENERIC_SHOCKED_HIGH',
      selected = function(data)
        print('Talking about sports...')
        exports['envi-interact']:CloseAllMenus()   -- To close all menus after interaction
      end
    },
    {
      key = 'X',
      label = 'Leave', 
      selected = function(data)
        print('Leaving the conversation...')
        exports['envi-interact']:CloseEverything()  -- To close all menus and percentage bars after interaction
      end
    }
  } 
})
```



#### 3. `PedInteraction`
Handles interactions with a ped, typically used to initiate dialogues or actions.

**Parameters:**
- `entity` (entity): The ped entity to interact with.
- `data` (table): Interaction options and UI settings.
  - `title`, `speech`, `speechOptions`, `menuID`, `position`, `timeout`, `options` as in `OpenChoiceMenu`.
  - `focusCam` (boolean): Whether the camera should focus on the NPC when interacting.
  - `greeting` (string): The VOICE PARAM to use when interacting.
  - `freeze` (boolean): Whether the NPC should be frozen during interaction.


**Example:**
```lua
exports['envi-interact']:PedInteraction(ped, {
  title = 'Greetings',  
  speech = 'Hello there! Let\'s choose an option. What would you like to talk about?',
  menuID = 'npc-interaction',
  position = 'right',
  greeting = 'GENERIC_HI',
  focusCam = true,
  options = {
    {
      key = 'E',
      label = 'Talk',
      reaction = 'CHAT_STATE',
      selected = function(data) 
        print('Initiating conversation...')
        exports['envi-interact']:CloseMenu(data.menuID)  -- To close the current menu after interaction
      end,
    },
    {
      key = 'I',
      label = 'Insult',
      reaction = 'GENERIC_SHOCKED_HIGH',
      selected = function(data)
        print('Insulting the ped...')
        exports['envi-interact']:CloseEverything()  -- To close all menus and percentage bars after interaction
      end
    }
  }
})
```


#### 4. `PercentageBar`
Displays a percentage bar on the screen.

**Parameters:**
- `menuID` (string): A unique identifier for the percentage bar.
- `percent` (number): The percentage value to display (0-100).
- `title` (string): The title of the percentage bar.
- `position` (string): The position on the screen.
- `tooltip` (string, optional): Tooltip behavior ('hover', 'always', 'none').
- `c1`, `c2`, `c3` (string, optional): Color values for different percentage ranges.

**Returns:**
- `string`: The menu ID of the percentage bar.

**Example:**
```lua
exports['envi-interact']:PercentageBar('relationship-bar', 75, 'Relationship Status', 'top', 'hover')
```


#### 5. `UseSlider`
Allows interaction with a slider within a menu.

**Parameters:**
- `menuID` (string): The ID of the menu containing the slider.
- `data` (table): Configuration for the slider.
  - `title` (string): Title of the slider.
  - `min`, `max` (number): Minimum and maximum values.
  - `sliderState` (string): State of the slider ('locked', 'unlocked', 'disabled').
  - `sliderValue` (number): Initial value of the slider.
  - `nextState` (string): State after interaction.
  - `confirm` (function): Callback function executed on confirmation.

**Example:**
```lua
exports['envi-interact']:UseSlider('decision-menu', {
  title = 'Adjust Value', 
  min = 1, 
  max = 100, 
  sliderState = 'unlocked', 
  sliderValue = 50, 
  nextState = 'locked', 
  confirm = function(newVal, oldVal) 
    -- Do something when clicking submit
    print('Value changed from', oldVal, 'to', newVal) 
  end 
})
```


#### 6. `CloseMenu`
Closes a specific menu by its ID.

**Parameters:**
- `menuID` (string): The ID of the menu to close. - NOTE: NEEDS TO MATCH THE MENU ID OF THE OPEN MENU

**Example:**
```lua
exports['envi-interact']:CloseMenu('decision-menu')
```


#### 7. `CloseAllMenus`
Closes all currently open menus.

**Example:**
```lua
exports['envi-interact']:CloseAllMenus()
```


#### 8. `CloseAllPercentBars`
Closes all open percentage bars.

**Example:**
```lua
exports['envi-interact']:CloseAllPercentBars()
```


#### 9. `GetOpenMenus`
Returns a table of all open menus.

**Example:**
```lua
local openMenus = exports['envi-interact']:GetOpenMenus()
print(json.encode(openMenus, { indent = true }))
```


#### 10. `IsAnyMenuOpen`
Returns a boolean value indicating if any menus are open.

**Example:**
```lua
local isAnyMenuOpen = exports['envi-interact']:IsAnyMenuOpen()
print(isAnyMenuOpen)
```

#### 11. `IsAnyPercentBarOpen`
Returns a boolean value indicating if any percentage bars are open.

**Example:**
```lua
local isAnyPercentBarOpen = exports['envi-interact']:IsAnyPercentBarOpen()
print(isAnyPercentBarOpen)
```

#### 12. `GetInteractionPed`
Returns the ped entity that is interacting with the player.

**Parameters:**
- `menuID` (string): The ID of the menu to get the ped entity from.

**Example:**
```lua
local interactionPed = exports['envi-interact']:GetInteractionPed('npc-interaction-menu-1')
print('entity = ', interactionPed)
```

#### 13. `InteractionPoint` and `InteractionEntity`
These functions enable a raycasting-based interaction system, allowing players to press 'E' to interact with points or entities in the game world. This system supports multiple options which you may select using the scroll-wheel and runs at 0.00ms constantly, ensuring minimal performance impact without the use of a target system.


**InteractionPoint Parameters:**
- `position` (vector3): The position to check for interactions.
- `options` (table): Interaction options.
  - `name` (string): The name of the interaction point.
  - `distance` (number): The maximum distance at which the interaction point will be active.
  - `margin` (number): The margin around the interaction point that will be active.

**Example:**
```lua
-- Example of using InteractionPoint
exports['envi-interact']:InteractionPoint(vector3(100, 100, 20), {
  {
    label = 'Interaction Point - Choice 1',
    selected = function(data)
      -- Additional logic can be added here to handle the result
      print('Interacting with point - selected choice 1...')
      exports['envi-interact']:CloseMenu(data.menuID)   -- To close the current menu after interaction
    end
  },
  {
    label = 'Interaction Point - Choice 2',
    selected = function()
      print('Interacting with point - scrolled down and selected choice 2...')
      exports['envi-interact']:CloseMenu(data.menuID)   -- To close the current menu after interaction
    end
  },
  {
    label = 'Interaction Point - Choice 3',
    selected = function(data)
      print('Interacting with point - scrolled down and selected choice 3...')
      exports['envi-interact']:CloseMenu(data.menuID)   -- To close the current menu after interaction
    end
  },
  {
    label = 'Interaction Point - Choice 4',
    selected = function(data)
      print('Interacting with point - scrolled down and selected choice 4...')
      exports['envi-interact']:CloseMenu(data.menuID)   -- To close the current menu after interaction
    end
  },
})
```


**InteractionEntity Parameters:**
- `entity` (entity, optional): The specific entity to interact with.
- `options` (table): Interaction options.
  - `name` (string): The name of the interaction point.
  - `distance` (number): The maximum distance at which the interaction point will be active.
  - `margin` (number): The margin around the interaction point that will be active.

**Example:**
```lua
-- Example of using InteractionEntity
exports['envi-interact']:InteractionEntity(entity, {
  {
    label = 'Interaction Entity - Choice 1',
    selected = function()
      print('Interacting with entity - selected choice 1...')
      -- Additional logic can be added here to handle the entity usage
    end
  },
  {
    label = 'Interaction Entity - Choice 2',
    selected = function()
      print('Interacting with entity - selected choice 2...')
      -- Additional logic can be added here to handle the entity usage
    end
  },
  {
    label = 'Interaction Entity - Choice 3',
    selected = function()
      print('Interacting with entity - selected choice 3...')
      -- Additional logic can be added here to handle the entity usage
    end
  },
  {
    label = 'Interaction Entity - Choice 4',
    selected = function()
      print('Interacting with entity - selected choice 4...')
      -- Additional logic can be added here to handle the entity usage
    end
  },
})
```

#### 14. `UpdateSpeech`
Updates the speech of a specific menu.

**Parameters:**
- `menuID` (string): The ID of the menu to update. - NOTE: NEEDS TO MATCH THE MENU ID OF THE OPEN MENU
- `speech` (string): The new speech to display.
- `duration` (int): The duration it takes for the speech to show from start to end

**Example:**
```lua
exports['envi-interact']:UpdateSpeech('decision-menu', 'New speech text to display here.', 3000)
```
