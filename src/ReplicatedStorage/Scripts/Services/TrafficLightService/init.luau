local TrafficLightService = {}

local lights = require('@self/defs')
local _, _, setDirectionPhase = require('@self/_getPhaseFunctions')()

function setToRed(folder: Folder)
    for _, direction in folder:GetChildren() do
        if not direction:IsA("Folder") then
            continue
        end

        task.spawn(setDirectionPhase, direction, "Red")
    end
end

function TrafficLightService.init()
    for _, junction in lights do
        -- initialize junction to red
        setToRed(junction.location)
        -- run each light in its own thread
        task.spawn(function()
            while true do
                junction.runPhases()
            end
        end)
    end
end

return TrafficLightService