
---- NO TOUCHY ZONE ----
export type light = {
    location: Instance,
    runPhases: () -> ()
}

function setIndividualPhase(light: Model, color: string)
    for _, bulb: Instance in light.Lights:GetChildren() do
        if not bulb:IsA("BasePart") then
            continue
        end
        
        if bulb.Name == color then
            bulb.DynamicLight.Enabled = true
            bulb.Lamp.Enabled = true
        else
            bulb.DynamicLight.Enabled = false
            bulb.Lamp.Enabled = false
        end
    end
end

function setGroupPhase(lightGroup: Folder, color: string, flashing: boolean?)
    flashing = flashing or false

    if flashing then
        --TODO
    end

    for _, light in lightGroup:GetChildren() do
        setIndividualPhase(light, color)
    end
end

function setDirectionTo(direction: Folder, color: string)
    for _, i in direction:GetChildren() do
        if not i:IsA("Folder") then
            continue
        end
        setGroupPhase(i, color)
    end
end

---- END OF NO TOUCHY ZONE ----

local junctions = workspace.TrafficLights
local CF_11B = junctions.chesterfield_11B

return {
    {
        location = CF_11B,
        runPhases = function()

            setGroupPhase(CF_11B.N.fwd, "Green")
            setGroupPhase(CF_11B.N.left, "Green")

            task.wait(5)

            setGroupPhase(CF_11B.N.left, "Yellow", true)
            task.wait(1)
            setGroupPhase(CF_11B.S.fwd, "Green")

            task.wait(5)

            setDirectionTo(CF_11B.N, "Yellow")
            setDirectionTo(CF_11B.S, "Yellow")
            task.wait(1)
            setDirectionTo(CF_11B.N, "Red")
            setDirectionTo(CF_11B.S, "Red")
            task.wait(1)

            setGroupPhase(CF_11B.E.left, "Green")
            setGroupPhase(CF_11B.W.left, "Green")

            task.wait(5)

            setGroupPhase(CF_11B.E.left, "Yellow", true)
            setGroupPhase(CF_11B.W.left, "Yellow", true)
            task.wait(1)
            setGroupPhase(CF_11B.E.fwd, "Green")
            setGroupPhase(CF_11B.W.fwd, "Green")
            setIndividualPhase(CF_11B.W["Eagle Flatback Pedestrian Signal"], "Walk")

            task.wait(5)

            setDirectionTo(CF_11B.E, "Yellow")
            setDirectionTo(CF_11B.W, "Yellow")
            task.wait(1)
            setIndividualPhase(CF_11B.W["Eagle Flatback Pedestrian Signal"], "DontWalk")
            setDirectionTo(CF_11B.E, "Red")
            setDirectionTo(CF_11B.W, "Red")
            task.wait(1)
        end
    } :: light,
}