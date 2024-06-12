## Documentation for `envi-interact`

The `envi-interact` script provides a versatile interaction system for creating dynamic menus, handling NPC interactions, and managing UI elements in your FiveM Server.

Below is a detailed guide on how to utilize the exported functions from this script in other resources.

### Exported Functions

#### 1. `OpenChoiceMenu`
Opens a menu with multiple choice options.

**Parameters:**
- `data` (table): A table containing the menu configuration.
  - `menuID` (string): A unique identifier for the menu. - NOTE: MUST BE UNIQUE TO AVOID CONFLICTS
  - `title` (string): The title of the menu.
  - `speech` (string): A speech or description associated with the menu. If false, the menu will be a simple choice menu.
  - `position` (string): The position on the screen (e.g., 'left', 'right').
  - `timeout` (number): Time in seconds before the interaction is considered a failure and menu is closed.
  - `options` (table): A list of options, each being a table with keys `key`, `label`, and `selected`.

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
  timeout = 60,
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
  speech = 'Choose your option wisely.',
  menuID = 'decision-menu',
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
Creates an NPC with specified attributes and interaction options.
This will:
- Spawn the NPC at the specified coordinates.
- Add an InteractionPoint - (0.0ms Press E to Interact)
- Open a choice menu when the NPC is interacted with.

**Parameters:**
- `pedData` (table): Data about the NPC model and spawn location.
  - `model` (string): Model name of the NPC.
  - `coords` (vector3): Coordinates where the NPC will spawn.
  - `heading` (number): Direction the NPC faces.
  - `isFrozen` (boolean): Whether the NPC should be immobile.
- `interactionData` (table): Interaction options and UI settings.
  - `title`, `speech`, `menuID`, `position`, `timeout`, `options` as in `OpenChoiceMenu`. - NOTE: MENUID MUST BE UNIQUE TO AVOID CONFLICTS
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
  menuID = 'npc-greeting', 
  position = 'right',
  greeting = 'GENERIC_HI',
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
        exports['envi-interact']:CloseMenu(data.menuID)   -- To close the current menu after interaction
      end
    },
    {
      key = 'X',
      label = 'Leave', 
      selected = function(data)
        print('Leaving the conversation...')
        exports['envi-interact']:CloseMenu(data.menuID)   -- To close the current menu after interaction
      end
    }
  } 
})
```


#### 3. `PedInteraction`
Handles interactions with a ped, typically used to initiate dialogues or actions.

**Parameters:**
- `ped` (entity): The ped entity to interact with.
- `interactionData` (table): Interaction options and UI settings.
  - `title`, `speech`, `menuID`, `position`,`timeout`, `options` as in `OpenChoiceMenu`. - NOTE: MENUID MUST BE UNIQUE TO AVOID CONFLICTS
  - `focusCam` (boolean): Whether the camera should focus on the NPC when interacting.
  - `greeting` (string): The VOICE PARAM to use when interacting.

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
      exports['envi-interact']:CloseMenu(data.menuID)   -- To close the current menu after interaction
    end,
  }
})
```


#### 5. `PercentageBar`
Displays a percentage bar on the screen.

**Parameters:**
- `menuID` (string): A unique identifier for the percentage bar. - NOTE: MUST BE UNIQUE TO AVOID CONFLICTS
- `percent` (number): The percentage value to display (0-100).
- `title` (string): The title of the percentage bar.
- `position` (string): The position on the screen.
- `tooltip` (string, optional): Tooltip behavior ('hover', 'always', 'none').

**Returns:**
- `string`: The menu ID of the percentage bar.

**Example:**
```lua
exports['envi-interact']:PercentageBar('relationship-bar', 75, 'Relationship Status', 'top', 'hover')
```


#### 6. `UseSlider`
Allows interaction with a slider within a menu.

**Parameters:**
- `menuID` (string): The ID of the menu containing the slider. - NOTE: NEEDS TO MATCH THE MENU ID OF THE OPEN MENU
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


#### 7. `InteractionPoint` and `InteractionEntity`
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

#### 8. `UpdateSpeech`
Updates the speech of a specific menu.

**Parameters:**
- `menuID` (string): The ID of the menu to update. - NOTE: NEEDS TO MATCH THE MENU ID OF THE OPEN MENU
- `speech` (string): The new speech to display.

**Example:**
```lua
exports['envi-interact']:UpdateSpeech('decision-menu', 'New speech text to display here.')
```

#### 9. `CloseMenu`
Closes a specific menu by its ID.

**Parameters:**
- `menuID` (string): The ID of the menu to close. - NOTE: NEEDS TO MATCH THE MENU ID OF THE OPEN MENU

**Example:**
```lua
exports['envi-interact']:CloseMenu('decision-menu')
```


#### 10. `CloseAllMenus`
Closes all currently open menus.

**Example:**
```lua
exports['envi-interact']:CloseAllMenus()
```