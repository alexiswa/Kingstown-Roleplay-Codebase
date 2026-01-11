local TrafficLightService = {}

local lights = require('./TrafficLightService/defs')

type light = lights.light

function setToRed(folder: Folder)
    for _, direction in folder:GetChildren() do
        if not direction:IsA("Folder") then
            continue
        end

        for _, group in direction:GetChildren() do
            for _, light in group:GetChildren() do
                for _, bulb in light.Lights:GetChildren() do
                    if not bulb:IsA("BasePart") then
                        continue
                    end

                    if bulb.Name == "Red" then
                        bulb.DynamicLight.Enabled = true
                        bulb.Lamp.Enabled = true
                    else
                        bulb.DynamicLight.Enabled = false
                        bulb.Lamp.Enabled = false
                    end
                end
            end
        end
    end
end

function TrafficLightService.init()
    for _, junction: light in lights do
        -- initialize junction to red
        setToRed(junction.location)
        -- run phases
        task.spawn(function()
            while true do
                junction.runPhases()
            end
        end)
    end
end

return TrafficLightService