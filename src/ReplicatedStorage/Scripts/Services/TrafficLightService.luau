--!strict

local TrafficLightService = {}

function TrafficLightService.init()
    for _, junction in workspace.TrafficLights:GetChildren() do
        if not junction:IsA("Folder") then
            continue
        end

        task.spawn(function()
            local junctionLights = junction:GetChildren()
            for _, light in junctionLights do
                
            end
        end)
    end
end

return TrafficLightService