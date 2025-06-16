Config = {}
Config.TextState = false
Config.CurrentLabel = nil
Config.DefaultTypeDelay = 1500 -- 1.5 Seconds
Config.EnableDebugLine = false
ShownNoti = false

function ShowText(label, state, options)
    if state == TextState and label == CurrentLabel then
        return
    end
    TextState = state
    CurrentLabel = label
    if state then
        lib.showTextUI(label)
        if not ShownNoti and #options > 1 then
            local text = 'USE SCROLL-WHEEL FOR MORE OPTIONS'
            local time = 4000
            local icon = 'arrow-down'
            lib.notify({
                id = 'interaction',
                title = 'Envi-Interact',
                description = text,
                position = 'top-right',
                duration = time,
                style = {
                    backgroundColor = '#141517',
                    color = '#C1C2C5',
                    ['.description'] = {
                      color = '#909296'
                    }
                },
                icon = icon,
                iconColor = '#A020F0'
            })
            ShownNoti = true
        end
    else
        lib.hideTextUI()
        ShownNoti = false
        CurrentLabel = nil
    end
end

function HideText()
    lib.hideTextUI()
end
