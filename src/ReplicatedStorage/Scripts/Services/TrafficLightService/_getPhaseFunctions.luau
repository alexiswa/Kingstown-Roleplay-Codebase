function SetIndividualPhase(light: Model, color: string, flashing: boolean?, flashingRate: number?)
    flashing = flashing or false

    for _, bulb: Instance in light.Lights:GetChildren() do
        if bulb:IsA("ObjectValue") then
            (bulb.Value :: BindableEvent):Fire()
        end
        if not bulb:IsA("BasePart") then
            continue
        end

        if bulb.Name == color then
            if flashing then
                local cancelEventVal = Instance.new("ObjectValue")
                cancelEventVal.Value = Instance.new("BindableEvent")
                cancelEventVal.Parent = bulb.Parent

                flashingRate = flashingRate or 1

                local thread: thread = coroutine.create(function()
                    while coroutine.running() do
                        bulb.DynamicLight.Enabled = true
                        bulb.Lamp.Enabled = true
                        task.wait(flashingRate)
                        bulb.DynamicLight.Enabled = false
                        bulb.Lamp.Enabled = false
                        task.wait(flashingRate)
                    end
                end)
                coroutine.resume(thread);

                (cancelEventVal.Value  :: BindableEvent).Event:Connect(function(...)
                    coroutine.close(thread)
                end)
            else
                bulb.DynamicLight.Enabled = true
                bulb.Lamp.Enabled = true
            end
        else
            bulb.DynamicLight.Enabled = false
            bulb.Lamp.Enabled = false
        end
    end
end

function SetGroupPhase(lightGroup: Folder, color: string, flashing: boolean?, flashingTime: number?)
    flashing = flashing or false

    for _, light in lightGroup:GetChildren() do
        if not light:IsA("Model") then
            continue
        end
        SetIndividualPhase(light, color, flashing, flashingTime)
    end
end

function SetDirectionPhase(direction: Folder, color: string, flashing: boolean?, flashingTime: number?)
    flashing = flashing or false

    for _, i in direction:GetChildren() do
        if not i:IsA("Folder") then
            continue
        end
        task.spawn(SetGroupPhase, i, color, flashing, flashingTime)
    end
end

return function()
    return SetIndividualPhase, SetGroupPhase, SetDirectionPhase
end
