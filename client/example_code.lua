RegisterCommand('testChoice', function()
    exports['envi-interact']:OpenChoiceMenu({  -- Using 'selected' function to execute code when the option is pressed -- does not return result when selected functions are used
        title = 'Pick A Choice?',
        speech = 'OxLib Inspired theme to complement everyone\'s favorite menu system!',
        duration = 1000, -- Amount of TICKS the type writer takes to show all the speech text
        menuID = 'choice-menu-testChoice',
        position = 'right',
        options = {
            {
                key = 'E',
                label = 'This One',
                selected = function(data)
                    print('Pressed E')
                    CloseMenu(data.menuID)
                end,
            },
            {
                key = 'G',
                label = 'That One',
                selected = function(data)
                    print('Pressed G')
                end,
            },
            {
                key = 'F',
                label = 'The F One',
                selected = function(data)
                    print('Pressed F')
                end,
            },
            {
                key = 'J',
                label = 'That Other One',
                selected = function(data)
                    print('Pressed J')
                end,
            },
        },
    })
end, false)

RegisterCommand('testChoice2', function()   -- Alternative way to use if you want to return the key/option pressed and use the result to execute code
    local key = exports['envi-interact']:OpenChoiceMenu({
        title = 'Pick A Choice?',
        speech = 'This is a long test speech to evaluate the text rendering capabilities of the system and to ensure that the speech bubble can handle longer strings of text without any issues.',
        duration = 1000, -- Amount of TICKS the type writer takes to show all the speech text
        menuID = 'choice-menu-testChoice2',
        position = 'right',
        options = {
            {
                key = 'E',
                label = 'This One',
            },
            {
                key = 'G',
                label = 'That One',
            },
            {
                key = 'F',
                label = 'The F One',
            },
            {
                key = 'J',
                label = 'That Other One',
            },
        },
    })
    if key == 'E' then
        local key2 = exports['envi-interact']:OpenChoiceMenu({ -- Opening a second choice menu to test the functionality
            title = 'Pick Another Choice?',
            speech = 'This is an EVEN LONGER test speech to evaluate the text rendering capabilities of the system and to ensure that the speech bubble can handle longer strings of text without any issues.',
            duration = 1000, -- Amount of TICKS the type writer takes to show all the speech text
            menuID = 'choice-menu-testChoice-E',
            position = 'right',
            options = {
                {
                    key = 'E',
                    label = 'This One',
                },
                {
                    key = 'G',
                    label = 'That One',
                },
                {
                    key = 'F',
                    label = 'The F One',
                },
                {
                    key = 'J',
                    label = 'That Other One',
                },
                {
                    key = 'X',
                    label = 'This One',
                },
            },
        })
        if key2 == 'E' then        -- If the key/option pressed is 'E'
            print('You pressed E and won the game!')
        elseif key2 == 'G' then    -- If the key/option pressed is 'G'
            print('You pressed G and lost the game! - LOSER!')
        elseif key2 == 'F' then    -- If the key/option pressed is 'F'
            print('You pressed F and lost the game! - LOSER!')
        elseif key2 == 'J' then    -- If the key/option pressed is 'J'
            print('You pressed J and lost the game! - LOSER!')
        else
            print('You pressed '..key2..' and lost the game! - LOSER!')
        end
    else
        print('You pressed '..key)
    end
end, false)

RegisterCommand('testPercentage', function(source, args)
    local value = tonumber(args[1])
    if not value then value = 50 end
    local pecent = exports['envi-interact']:PercentageBar('percent-bar-name', value, 'Percentage Title', 'left', 'always', false, false, false)
end, false)

RegisterCommand('closeMenu', function()
    exports['envi-interact']:CloseMenu('percent-bar-name')
    Wait(3000)
    exports['envi-interact']:CloseMenu('choice-menu')
end, false)


--- Video Preview Example Code -- 

local toldMore = false

function BackToMain(data)
    exports['envi-interact']:OpenChoiceMenu({
        title = 'Main Menu!',
        speech = 'What else would you like to know?',
        duration = 1000, -- Amount of TICKS the type writer takes to show all the speech text
        menuID = 'choice-backToMain'..math.random(11111, 99999),
        position = 'right',
        options = {
            { -- Table of Choice Menu Options
                key = 'E',
                stayOpen = true,
                reaction = 'GENERIC_INSULT_MED',
                label = 'Tell me more!',
                selected = function(data)
                    if not toldMore then
                        exports['envi-interact']:UpdateSpeech(data.menuID, 'The "CreateNPC" export allows you to easily create NPCs with a simple and easy to use API. Using this export will create an NPC, Add an "InteractionEntity" point, and a "ChoiceMenu" to the NPC that is activated when the player presses E!', 12000)
                        toldMore = true
                    else
                        exports['envi-interact']:UpdateSpeech(data.menuID, 'Maybe we should learn about something else?', 5000)
                    end
                end,
            },
            {
                key = 'N',
                label = 'You Got Sliders?',
                reaction = 'GENERIC_SHOCKED_MED',
                stayOpen = true,
                speech = 'Hell Yeah - We Got Sliders! You can use sliders to select a value between a minimum and maximum value and then use the confirm function to execute code using the new and old value selected. Try it out!',
                selected = function(data)
                    exports['envi-interact']:UseSlider(data.menuID, {
                        title = 'Pick a value:',
                        min = 1,
                        max = 500,
                        sliderState = 'unlocked',
                        sliderValue = 500,
                        nextState = 'disabled',
                        confirm = function(new, old)
                            if tonumber(new) == 69 then
                                exports['envi-interact']:UpdateSpeech(data.menuID, 'Hmmm.. ' .. new .. '?! Niiiiiiice! ;)', 5000)
                            elseif tonumber(new) == 420 then
                                exports['envi-interact']:UpdateSpeech(data.menuID, 'Yeahhhh! 420 Blaze It!!', 5000)
                            else
                                exports['envi-interact']:UpdateSpeech(data.menuID, 'Okay, so you changed the value to ' .. new .. '! We can then use this value to do stuff!', 5000)
                            end
                            exports['envi-interact']:OpenChoiceMenu({
                                title = 'You Selected: ' .. new,
                                speech = 'I hope you know more about Envi-Interact Sliders now!',
                                menuID = 'choice-slider-test',
                                position = 'right',
                                options = {
                                    {
                                        key = 'E',
                                        label = 'Go Back to Main Menu',
                                        reaction = 'GENERIC_HOWS_IT_GOING',
                                        selected = function(data)
                                            -- exports['envi-interact']:CloseMenu(data.menuID)
                                            -- Wait(1000)
                                            BackToMain(data)
                                        end,
                                    },
                                    {
                                        key = 'X',
                                        label = 'Exit Menu',
                                        reaction = 'GENERIC_BYE',
                                        selected = function(data)
                                            exports['envi-interact']:CloseAllMenus()
                                        end,
                                    },
                                }
                            })
                        end,
                    })
                end,
            },
            {
                key = 'V',
                label = 'Envi-Interact',
                speech = 'Envi-Interact is an easy to use API for FiveM that allows you to easily create interaction points, choice menus, sliders, and percentage bars.',
                selected = function(data)
                    exports['envi-interact']:UpdateSpeech(data.menuID, 'Let\'s try it out!', 2000)
                    local startingPercentage = 50
                    local bar = exports['envi-interact']:PercentageBar('percent-bar-name', startingPercentage, 'PERCENTAGE BAR TITLE - '..startingPercentage..'%', 'left', 'always')
                    exports['envi-interact']:OpenChoiceMenu({
                        title = 'Percentage Bar',
                        speech = 'Envi-Interact is an easy to use API for FiveM that allows you to easily create interaction points, choice menus, sliders, and percentage bars -WOW, so many options!',
                        duration = 1000, -- Amount of TICKS the type writer takes to show all the speech text
                        menuID = 'choice-percentage-bar-test'..math.random(11111, 99999),
                        position = 'right',
                        options = {
                            {
                                key = 'E',
                                label = 'Have a conversation',  
                                reaction = 'GENERIC_BYE',
                                selected = function(data)
                                    exports['envi-interact']:CloseAllMenus()
                                end,
                            },
                            {
                                key = 'R',
                                label = 'Tell me a joke',
                                reaction = 'GENERIC_BYE',
                                selected = function(data)
                                    exports['envi-interact']:CloseAllMenus()
                                end,
                            },
                            {
                                key = 'I',
                                label = 'Increase Value - 5%',
                                reaction = 'GENERIC_SHOCKED_MED',
                                stayOpen = true,
                                selected = function(data)
                                    startingPercentage = startingPercentage + 5
                                    if startingPercentage > 100 then
                                        startingPercentage = 100
                                    elseif startingPercentage < 0 then
                                        startingPercentage = 0
                                    end
                                    exports['envi-interact']:PercentageBar(bar, startingPercentage, 'CURRENT RELATIONSHIP - '..startingPercentage..'%', 'top', 'hover')
                                    exports['envi-interact']:UpdateSpeech(data.menuID, 'The value is now ' .. startingPercentage .. '%!')
                                end,
                            },
                            {
                                key = 'G',
                                label = 'Decrease Value - 5%',
                                reaction = 'GENERIC_SHOCKED_MED',
                                stayOpen = true,
                                selected = function(data)
                                    startingPercentage = startingPercentage - 5
                                    if startingPercentage > 100 then
                                        startingPercentage = 100
                                    elseif startingPercentage < 0 then
                                        startingPercentage = 0
                                    end
                                    exports['envi-interact']:PercentageBar(bar, startingPercentage, 'CURRENT RELATIONSHIP - '..startingPercentage..'%', 'top', 'hover')
                                    exports['envi-interact']:UpdateSpeech(data.menuID, 'The value is now ' .. startingPercentage .. '%!')
                                end,
                            },
                            {
                                key = 'H',
                                label = 'Increase Value - 10%',
                                reaction = 'GENERIC_THANKS',
                                stayOpen = true,
                                selected = function(data)
                                    startingPercentage = startingPercentage + 10
                                    if startingPercentage > 100 then
                                        startingPercentage = 100
                                    elseif startingPercentage < 0 then
                                        startingPercentage = 0
                                    end
                                    exports['envi-interact']:PercentageBar(bar, startingPercentage, 'CURRENT RELATIONSHIP - '..startingPercentage..'%', 'top', 'hover')
                                    exports['envi-interact']:UpdateSpeech(data.menuID, 'The value is now ' .. startingPercentage .. '%!')
                                end,
                            },
                            {
                                key = 'O',
                                label = 'Decrease Value - 10%',
                                reaction = 'GENERIC_SHOCKED_HIGH',
                                stayOpen = true,
                                selected = function(data)
                                    startingPercentage = startingPercentage - 10
                                    if startingPercentage > 100 then
                                        startingPercentage = 100
                                    elseif startingPercentage < 0 then
                                        startingPercentage = 0
                                    end
                                    exports['envi-interact']:PercentageBar(bar, startingPercentage, 'CURRENT RELATIONSHIP - '..startingPercentage..'%', 'top', 'hover')
                                    exports['envi-interact']:UpdateSpeech(data.menuID, 'The value is now ' .. startingPercentage .. '%!')
                                end,
                            },
                            {
                                key = 'C',
                                label = 'Enter Custom Value',
                                stayOpen = true,
                                selected = function(data)
                                    exports['envi-interact']:UseSlider(data.menuID, {
                                        title = 'Pick a value:',
                                        min = 1,
                                        max = 100,
                                        sliderState = 'unlocked',
                                        sliderValue = startingPercentage,
                                        nextState = 'disabled',
                                        confirm = function(new, old)
                                            startingPercentage = new
                                            exports['envi-interact']:PercentageBar(bar, startingPercentage, 'CURRENT RELATIONSHIP - '..startingPercentage..'%', 'top', 'hover')
                                            exports['envi-interact']:UpdateSpeech(data.menuID, 'You manually set the value to ' .. startingPercentage .. '%!')
                                        end,
                                    })
                                end,
                            },
                            {
                                key = 'X',
                                label = 'Exit Menu',
                                reaction = 'GENERIC_BYE',
                                selected = function(data)
                                    exports['envi-interact']:CloseAllMenus()
                                end,
                            },
                        }
                    })
                end,
            },
            {
                key = 'I',
                label = 'Interaction Point / Entity?',
                reaction = 'GENERIC_SHOCKED_MED',
                selected = function(data)
                    exports['envi-interact']:OpenChoiceMenu({
                        title = 'InteractionPoint/ InteractionEntity?',
                        speech = '"InteractionPoint" and "InteractionEntity" are interaction points for our "Press E to Interact" system that supports multiple options and is fully optimized to run at 0.00ms - just as efficient as Target Systems! More entity options coming soon??',
                        duration = 1000, -- Amount of TICKS the type writer takes to show all the speech text
                        menuID = 'choice-interaction-point-test'..math.random(11111, 99999),
                        position = 'right',
                        options = {
                            {
                                key = 'E',
                                label = 'Sounds Good! Thanks!',
                                reaction = 'GENERIC_THANKS',
                                selected = function(data)
                                    exports['envi-interact']:UpdateSpeech(data.menuID, 'You\'re welcome! Let\'s get you back to the main menu!', 4000)
                                    BackToMain(data)
                                end,
                            },
                            {
                                key = 'X',
                                label = 'Exit Menu',
                                reaction = 'GENERIC_BYE',
                                selected = function(data)
                                    exports['envi-interact']:CloseMenu(data.menuID)
                                end,
                            }
                        }
                    })
                end,
            },
            {
                key = 'X',
                label = 'Never Mind',
                reaction = 'GENERIC_BYE',
                selected = function(data)
                    exports['envi-interact']:CloseMenu(data.menuID)
                end,
            }
        }
    })
end


local ped = exports['envi-interact']:CreateNPC({   -- Table of NPC Data
    name = 'testNPC',
    model = 'a_f_m_bevhills_01',
    coords = vector3(-1338.8363, -1255.9933, 4.9441),
    heading = 24.5156,
    isFrozen = true,
}, {                -- Table of Choice Menu Data
    title = 'CreateNPC Export!',
    speech = 'Hello! - Welcome to Envi-Interact! I\'m an NPC created using the "CreateNPC" Export!',
    duration = 1000, -- Amount of TICKS the type writer takes to show all the speech text
    menuID = 'choice-menu-test-1',
    greeting = 'GENERIC_HI',
    position = 'right',
    distance = 3.0,
    focusCam = true,
    options = {
        { -- Table of Choice Menu Options
            key = 'E',
            stayOpen = true,
            label = 'Tell me more!',
            reaction = 'GENERIC_SHOCKED_MED',
            selected = function(data)
                if not toldMore then
                    exports['envi-interact']:UpdateSpeech(data.menuID, 'The "CreateNPC" export allows you to easily create NPCs with a simple and easy to use API. Using this export will create an NPC, Add an "InteractionEntity" point, and a "ChoiceMenu" to the NPC that is activated when the player presses E!', 12000)
                    toldMore = true
                    BackToMain(data)
                else
                    exports['envi-interact']:UpdateSpeech(data.menuID, 'Maybe we should learn about something else?', 5000)
                end
            end,
        },
        {
            key = 'N',
            label = 'You Got Sliders?',
            speech = 'The "UseSlider" export allows you to easily create a slider that can be used to select a value between a minimum and maximum value. This could be used for anything your heart desires!',
            stayOpen = true,
            reaction = 'GENERIC_SHOCKED_MED',
            selected = function(data)
                exports['envi-interact']:UpdateSpeech(data.menuID, 'Hell Yeah! We Got Sliders! You can use sliders to select a value between a minimum and maximum value and then use the confirm function to execute code using the new and old value selected. Try it out!')
                exports['envi-interact']:UseSlider(data.menuID, {
                    title = 'Pick a value:',
                    min = 1,
                    max = 500,
                    sliderState = 'unlocked',
                    sliderValue = 500,
                    nextState = 'disabled',
                    hideChoice = true,
                    confirm = function(new, old)
                        local speech = 'Okay, so you changed the value to ' .. new .. '! We can then use this value to do stuff!'
                        if tonumber(new) == 69 then
                            speech = 'Hmmm.. ' .. new .. '?! Niiiiiiice! ;)'
                        elseif tonumber(new) == 420 then
                            speech = 'Yeahhhh! 420 Blaze It!!'
                        else
                            speech = 'Okay, so you changed the value to ' .. new .. '! We can then use this value to do stuff!'
                        end
                        exports['envi-interact']:OpenChoiceMenu({
                            title = 'You Selected: ' .. new,
                            speech = 'I hope you know more about Envi-Interact Sliders now!',
                            duration = 1000, -- Amount of TICKS the type writer takes to show all the speech text
                            menuID = 'choice-slider-test-2',
                            position = 'right',
                            options = {
                                {
                                    key = 'E',
                                    label = 'Go Back to Main Menu',
                                    reaction = 'GENERIC_HOWS_IT_GOING',
                                    selected = function(data)
                                        -- exports['envi-interact']:CloseMenu(data.menuID)
                                        -- Wait(1000)
                                        BackToMain(data)
                                    end,
                                },
                                {
                                    key = 'X',
                                    reaction = 'GENERIC_BYE',
                                    label = 'Exit Menu',
                                    selected = function(data)
                                        exports['envi-interact']:CloseAllMenus()
                                    end,
                                },
                            }
                        })
                    end,
                })
            end,
        },
        {
            key = 'V',
            label = 'Percentage Bar?',
            speech = 'The "PercentageBar" export allows you to easily create a percentage bar that can be used to show the player a percentage of a value. This could be used for anything your heart desires!',
            reaction = 'GENERIC_SHOCKED_MED',
            selected = function(data)
                print(json.encode(data, { indent = true }))
                --exports['envi-interact']:UpdateSpeech(data.menuID, 'The "PercentageBar" export allows you to easily create a percentage bar that can be used to show the player a percentage of a value. This could be used for anything your heart desires!', 11500)
                exports['envi-interact']:UpdateSpeech(data.menuID, 'Let\'s try it out!')
                local startingPercentage = 50
                local bar = exports['envi-interact']:PercentageBar('percent-bar-name', startingPercentage, 'CURRENT RELATIONSHIP - '..startingPercentage..'%', 'top', 'hover')
                exports['envi-interact']:OpenChoiceMenu({
                    title = 'Percentage Bar',
                    speech = 'Let\'s start the value at 50%! - WOW, so many options!',
                    duration = 1000, -- Amount of TICKS the type writer takes to show all the speech text
                    menuID = 'choice-percentage-bar-test-2',
                    position = 'right',
                    options = {
                        {
                            key = 'E',
                            label = 'Increase Value - 5%',
                            reaction = 'GENERIC_SHOCKED_MED',
                            stayOpen = true,
                            selected = function(data)
                                startingPercentage = startingPercentage + 5
                                if startingPercentage > 100 then
                                    startingPercentage = 100
                                elseif startingPercentage < 0 then
                                    startingPercentage = 0
                                end
                                exports['envi-interact']:PercentageBar(bar, startingPercentage, 'CURRENT RELATIONSHIP - '..startingPercentage..'%', 'top', 'hover')
                                exports['envi-interact']:UpdateSpeech(data.menuID, 'The value is now ' .. startingPercentage .. '%!')
                            end,
                        },
                        {
                            key = 'G',
                            label = 'Decrease Value - 5%',
                            reaction = 'GENERIC_SHOCKED_MED',
                            stayOpen = true,
                            selected = function(data)
                                startingPercentage = startingPercentage - 5
                                if startingPercentage > 100 then
                                    startingPercentage = 100
                                elseif startingPercentage < 0 then
                                    startingPercentage = 0
                                end
                                exports['envi-interact']:PercentageBar(bar, startingPercentage, 'CURRENT RELATIONSHIP - '..startingPercentage..'%', 'top', 'hover')
                                exports['envi-interact']:UpdateSpeech(data.menuID, 'The value is now ' .. startingPercentage .. '%!')
                            end,
                        },
                        {
                            key = 'H',
                            label = 'Increase Value - 10%',
                            reaction = 'GENERIC_THANKS',
                            stayOpen = true,
                            selected = function(data)
                                startingPercentage = startingPercentage + 10
                                if startingPercentage > 100 then
                                    startingPercentage = 100
                                elseif startingPercentage < 0 then
                                    startingPercentage = 0
                                end
                                exports['envi-interact']:PercentageBar(bar, startingPercentage, 'CURRENT RELATIONSHIP - '..startingPercentage..'%', 'top', 'hover')
                                exports['envi-interact']:UpdateSpeech(data.menuID, 'The value is now ' .. startingPercentage .. '%!')
                            end,
                        },
                        {
                            key = 'O',
                            label = 'Decrease Value - 10%',
                            reaction = 'GENERIC_SHOCKED_HIGH',
                            stayOpen = true,
                            selected = function(data)
                                startingPercentage = startingPercentage - 10
                                if startingPercentage > 100 then
                                    startingPercentage = 100
                                elseif startingPercentage < 0 then
                                    startingPercentage = 0
                                end
                                exports['envi-interact']:PercentageBar(bar, startingPercentage, 'CURRENT RELATIONSHIP - '..startingPercentage..'%', 'top', 'hover')
                                exports['envi-interact']:UpdateSpeech(data.menuID, 'The value is now ' .. startingPercentage .. '%!')
                            end,
                        },
                        {
                            key = 'R',
                            label = 'Reset Value - 50%',
                            reaction = 'GENERIC_HOWS_IT_GOING',
                            stayOpen = true,
                            selected = function(data)
                                startingPercentage = 50
                                exports['envi-interact']:PercentageBar(bar, startingPercentage, 'CURRENT RELATIONSHIP - '..startingPercentage..'%', 'top', 'hover')
                                exports['envi-interact']:UpdateSpeech(data.menuID, 'The value is now back to ' .. startingPercentage .. '%!')
                            end,
                        },
                        {
                            key = 'C',
                            label = 'Enter Custom Value',
                            reaction = 'GENERIC_HOWS_IT_GOING',
                            stayOpen = true,
                            selected = function(data)
                                local menuID = data.menuID
                                exports['envi-interact']:UseSlider(menuID, {
                                    title = 'Pick a value:',
                                    min = 1,
                                    max = 100,
                                    sliderState = 'unlocked',
                                    sliderValue = startingPercentage,
                                    nextState = 'disabled',
                                    confirm = function(new, old)
                                        startingPercentage = new
                                        exports['envi-interact']:PercentageBar(bar, startingPercentage, 'CURRENT RELATIONSHIP - '..startingPercentage..'%', 'top', 'hover')
                                        exports['envi-interact']:UpdateSpeech(menuID, 'You manually set the value to ' .. startingPercentage .. '%!')
                                    end,
                                })
                            end,
                        },
                        {
                            key = 'B',
                            label = 'Back to Main Menu',
                            reaction = 'GENERIC_SHOCKED_MED',
                            selected = function(data)
                                BackToMain(data)
                            end,
                        },
                        {
                            key = 'X',
                            label = 'Exit Menu',
                            reaction = 'GENERIC_BYE',
                            selected = function(data)
                                exports['envi-interact']:CloseAllMenus()
                            end,
                        },
                    }
                })
            end,
        },
        {
            key = 'I',
            label = 'Interaction Point / Entity?',
            reaction = 'GUN_COOL',
            selected = function(data)
                exports['envi-interact']:OpenChoiceMenu({
                    title = 'InteractionPoint/ InteractionEntity?',
                    speech = '"InteractionPoint" and "InteractionEntity" are interaction points for our "Press E to Interact" system that supports multiple options and is fully optimized to run at 0.00ms - just as efficient as Target Systems! More entity options coming soon??',
                    duration = 1000, -- Amount of TICKS the type writer takes to show all the speech text
                    menuID = 'choice-interaction-point-test-2'..math.random(11111, 99999),
                    position = 'right',
                    options = {
                        {
                            key = 'E',
                            label = 'Sounds Good! Thanks!',
                            reaction = 'GENERIC_THANKS',
                            selected = function(data)
                                exports['envi-interact']:UpdateSpeech(data.menuID, 'You\'re welcome! Let\'s get you back to the main menu!', 4000)
                                
                                BackToMain(data)
                            end,
                        },
                        {
                            key = 'X',
                            label = 'Exit Menu',
                            reaction = 'GENERIC_BYE',
                            selected = function(data)
                                exports['envi-interact']:CloseMenu(data.menuID)
                            end,
                        }
                    }
                })
            end,
        },
        {
            key = 'X',
            label = 'Never Mind',
            reaction = 'GENERIC_BYE',
            selected = function(data)
                exports['envi-interact']:CloseMenu(data.menuID)
            end,
        }
    }
})



local currentOffer = 420
local willAccept = 350
local npcRelationship = 30

    local ped = exports['envi-interact']:CreateNPC({   -- Table of NPC Data
        name = 'testNPC',
        model = 'a_m_m_tramp_01',
        coords = vector3(-138.8170, -625.3212, 167.8204),
        heading = 32.65,
        isFrozen = true,
    }, {                -- Table of Choice Menu Data
        title = 'What do you say?',
        speech = 'I need to lend $100! Please?! Help a brother out...',
        menuID = 'choice-menu-1', -- MUST BE UNIQUE
        greeting = 'GENERIC_HOWS_IT_GOING',
        position = 'right',
        focusCam = true,
        options = {
            { -- Table of Choice Menu Options
                key = 'E',
                label = 'No Problem!',
                reaction = 'GENERIC_THANKS',
                selected = function(data)
                    print('Accepted offer of ' .. data.menuID)
                    exports['envi-interact']:CloseMenu(data.menuID)
                end,
            },
            {
                key = 'X',
                label = 'Sorry, I\'m too poor!',
                reaction = 'GENERIC_CURSE_HIGH',
                selected = function(data)
                    exports['envi-interact']:CloseMenu(data.menuID)
                end,
            },
        }
    })

    local ped2 = exports['envi-interact']:CreateNPC({   -- Table of NPC Data
        name = 'testNPC2',
        model = 'a_f_m_downtown_01',
        coords = vector3(-138.9446, -633.8333, 167.8205),
        heading = 7.75,
        isFrozen = true,
        focusCam = true
    }, {                -- Table of Choice Menu Data
        title = 'Time to Haggle?',
        speech = 'I am willing to sell you this item for $' .. currentOffer .. '!',
        menuID = 'choice-menu2',
        greeting = 'GENERIC_HI',
        position = 'right',
        focusCam = true,
        options = {
            { -- Table of Choice Menu Options
                key = 'E',
                label = 'Accept Offer',
                selected = function(data)
                    exports['envi-interact']:OpenChoiceMenu({
                        title = 'Sale Agreed!',
                        speech = 'Sounds like a deal! That\'ll cost you $' .. currentOffer .. '!',
                        duration = 1000, -- Amount of TICKS the type writer takes to show all the speech text
                        menuID = 'choice-menu3',
                        position = 'right',
                        options = {
                            {
                                key = 'E',
                                label = 'Collect Goods',
                                reaction = 'GENERIC_THANKS',
                                selected = function(data)
                                    print('bought the item for ' .. currentOffer)
                                    npcRelationship = npcRelationship + 10
                                    exports['envi-interact']:CloseAllMenus()
                                end,
                            },
                            {
                                key = 'X',
                                label = 'Run Away',
                                reaction = 'GENERIC_CURSE_MED',
                                selected = function(data)
                                    print('You ran away from ' .. data.menuID)
                                    npcRelationship = npcRelationship - 20
                                    exports['envi-interact']:CloseAllMenus()
                                end,
                            }
                        }
                    })
                end,
            },
            {
                key = 'G',
                label = 'Counter Offer',
                reaction = 'GENERIC_SHOCKED_MED ',
                stayOpen = true,
                selected = function(data)
                    print(data.menuID)
                    local percentageBar = exports['envi-interact']:PercentageBar('percent-bar-name', npcRelationship, 'CURRENT RELATIONSHIP - '..npcRelationship..'%', 'top', 'hover')
                    exports['envi-interact']:UpdateSpeech(data.menuID, 'Okay then, give me your best offer!')
                    exports['envi-interact']:UseSlider(data.menuID, {
                        title = 'Make A Counter Offer?',
                        min = 1,
                        max = currentOffer,
                        sliderState = 'unlocked',
                        sliderValue = currentOffer,
                        nextState = 'disabled',
                        confirm = function(new, old)
                            print('Confirmed')
                            print('Value changed from ' .. old .. ' to ' .. new)
                            if tonumber(new) > tonumber(willAccept) then
                                print('Counter offer of $' .. new .. ' is greater than the amount I will accept of $' .. willAccept)
                                print('Counter offer accepted')
                                npcRelationship = npcRelationship + 10
                                local percentageBar = exports['envi-interact']:PercentageBar('percent-bar-name', npcRelationship, 'CURRENT RELATIONSHIP - '..npcRelationship..'%', 'top', 'hover')
                                exports['envi-interact']:OpenChoiceMenu({
                                    title = 'Sale Agreed!',
                                    speech = 'Sounds like a deal! That\'ll cost you $' .. currentOffer .. '!',
                                    duration = 1000, -- Amount of TICKS the type writer takes to show all the speech text
                                    menuID = 'choice-menu',
                                    position = 'right',
                                    options = {
                                        {
                                            key = 'E',
                                            label = 'Collect Goods',
                                            reaction = 'GENERIC_THANKS',
                                            selected = function(data)
                                                currentOffer = willAccept
                                                print('bought the item for ' .. currentOffer)
                                                npcRelationship = npcRelationship + 5
                                                local percentageBar = exports['envi-interact']:PercentageBar('percent-bar-name', npcRelationship, 'CURRENT RELATIONSHIP - '..npcRelationship..'%', 'top', 'hover')
                                                exports['envi-interact']:CloseAllMenus()
                                            end,
                                        },
                                        {
                                            key = 'X',
                                            label = 'Run Away',
                                            reaction = 'GENERIC_CURSE_MED',
                                            selected = function(data)
                                                npcRelationship = npcRelationship - 25
                                                local percentageBar = exports['envi-interact']:PercentageBar('percent-bar-name', npcRelationship, 'CURRENT RELATIONSHIP - '..npcRelationship..'%', 'top', 'hover')
                                                print('You ran away from ' .. data.menuID)
                                                exports['envi-interact']:CloseAllMenus()
                                            end,
                                        }
                                    }
                                })
                            else
                                print('Counter offer of $' .. new .. ' is less than the amount I will accept of $' .. willAccept)
                                print('Counter offer rejected')
                                currentOffer = new
                                npcRelationship = npcRelationship - 10
                                local percentageBar = exports['envi-interact']:PercentageBar('percent-bar-name', npcRelationship, 'CURRENT RELATIONSHIP - '..npcRelationship..'%', 'top', 'hover')
                                exports['envi-interact']:OpenChoiceMenu({
                                    title = 'Final Offer!',
                                    speech = 'No way! I can\'t sell you this item for $' .. currentOffer .. '! The lowest I can take is $' .. willAccept .. '!',
                                    duration = 1000, -- Amount of TICKS the type writer takes to show all the speech text
                                    menuID = 'choice-menu',
                                    position = 'right',
                                    options = {
                                        {
                                            key = 'E',
                                            label = 'Accept Offer',
                                            selected = function(data)
                                                npcRelationship = npcRelationship + 10
                                                local percentageBar = exports['envi-interact']:PercentageBar('percent-bar-name', npcRelationship, 'CURRENT RELATIONSHIP - '..npcRelationship..'%', 'top', 'hover')
                                                exports['envi-interact']:OpenChoiceMenu({
                                                    title = 'Sale Agreed!',
                                                    speech = 'Sounds like a deal! That\'ll cost you $' .. currentOffer .. '!',
                                                    duration = 1000, -- Amount of TICKS the type writer takes to show all the speech text
                                                    menuID = 'choice-menu-agreed',
                                                    position = 'right',
                                                    options = {
                                                        {
                                                            key = 'E',
                                                            label = 'Pay & Collect Goods',
                                                            reaction = 'GENERIC_THANKS',
                                                            selected = function(data)
                                                                currentOffer = willAccept
                                                                npcRelationship = npcRelationship + 10
                                                                local percentageBar = exports['envi-interact']:PercentageBar('percent-bar-name', npcRelationship, 'CURRENT RELATIONSHIP - '..npcRelationship..'%', 'top', 'hover')
                                                                print('bought the item for ' .. currentOffer)
                                                                Wait(500)
                                                                exports['envi-interact']:CloseAllMenus()
                                                            end,
                                                        },
                                                        {
                                                            key = 'X',
                                                            label = 'Run Away',
                                                            reaction = 'GENERIC_CURSE_MED',
                                                            selected = function(data)
                                                                npcRelationship = npcRelationship - 25
                                                                local percentageBar = exports['envi-interact']:PercentageBar('percent-bar-name', npcRelationship, 'CURRENT RELATIONSHIP - '..npcRelationship..'%', 'top', 'hover')
                                                                print('You ran away from ' .. data.menuID)
                                                                Wait(500)
                                                                exports['envi-interact']:CloseAllMenus()
                                                            end,
                                                        }
                                                    }
                                                })
                                            end,
                                        },
                                        {
                                            key = 'X',
                                            label = 'Leave Conversation',
                                            reaction = 'GENERIC_BYE',
                                            selected = function(data)
                                                npcRelationship = npcRelationship - 50
                                                local percentageBar = exports['envi-interact']:PercentageBar('percent-bar-name', npcRelationship, 'CURRENT RELATIONSHIP - '..npcRelationship..'%', 'top', 'hover')
                                                print('Fucked off from ' .. data.menuID)
                                                Wait(500)
                                                exports['envi-interact']:CloseAllMenus()
                                            end,
                                        }
                                    }
                                })
                            end
                        end
                    })
                end,
            },  
            {
                key = 'X',
                label = 'Never Mind',
                reaction = 'GENERIC_BYE',
                selected = function(data)
                    exports['envi-interact']:CloseAllMenus()
                end,
            },
        }
    })

    local ped3 = exports['envi-interact']:CreateNPC({   -- Table of NPC Data
        name = 'testNPC3',
        model = 'a_m_m_og_boss_01',
        coords = vector3(-149.2743, -632.5180, 167.8326),
        heading = 280.90,
        isFrozen = true,
    }, {                -- Table of Choice Menu Data
        title = 'Oh No!!',
        speech = 'I am robbing you. Give me all your money!',
        menuID = 'choice-menu4',
        greeting = 'GENERIC_CURSE_HIGH',
        position = 'right',
        options = {
            { -- Table of Choice Menu Options
                key = 'E',
                label = 'Accept Being Robbed',
                reaction = 'GENERIC_CURSE_MED',
                selected = function(data)
                    exports['envi-interact']:CloseMenu(data.menuID)
                end,
            },
            {
                key = 'X',
                label = 'Run for Your Life',
                reaction = 'GENERIC_CURSE_HIGH',
                selected = function(data)
                    exports['envi-interact']:CloseMenu(data.menuID)
                end,
            },
        }
    })


    exports['envi-interact']:InteractionPoint(vector3(-136.4381, -629.6122, 168.8205),{
        name = 'testInteractionPoint',
        distance = 1.0,
        margin = 1.0,
        options = {
            {
                label = 'Check Center Cupboard',
                selected = function(data)
                    lib.notify({
                        title = 'Nothing here..',
                        description = 'You searched the center cupboard and found nothing!',
                        type = 'error'
                    })
                end,
            },
            {
                label = 'Check Left Cupboard',
                selected = function(data)
                    lib.notify({
                        title = 'Nothing here..',
                        description = 'You searched the left cupboard and found nothing!',
                        type = 'error'
                    })
                end,
            },
            {
                label = 'Check Right Cupboard',
                selected = function(data)
                    lib.notify({
                        title = 'Found something!',
                        description = 'You searched the right cupboard and found $500!',
                        type = 'success'
                    })
                    exports['envi-interact']:OpenChoiceMenu({
                        title = 'Found $500 - Take it or Leave it?!',
                        menuID = 'decision-menu',
                        position = 'right',
                        options = {
                          {   
                            key = 'E',
                            label = 'Take it!',
                            selected = function(data)
                              lib.notify({
                                title = 'You took the money!',
                                description = 'You took the money without anybody noticing!',
                                type = 'error'
                              })
                              exports['envi-interact']:CloseAllMenus()
                            end
                          },
                          { 
                            key = 'X',
                            label = 'Leave it!',
                            selected = function(data) 
                              lib.notify({
                                title = 'You left the money behind!',
                                description = 'You left the money behind!',
                                type = 'success'
                              }) 
                              exports['envi-interact']:CloseAllMenus()
                            end 
                          }
                        }
                      })
                end,
            },
        }
    })
