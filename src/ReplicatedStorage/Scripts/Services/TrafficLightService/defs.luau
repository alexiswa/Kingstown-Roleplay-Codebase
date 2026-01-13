local setIndividualPhase, setGroupPhase, setDirectionPhase = require('./_getPhaseFunctions')()

local junctions = workspace.TrafficLights
local CF_11B = junctions.chesterfield_11B

return {
    {
        location = CF_11B,
        runPhases = function()

            setGroupPhase(CF_11B.N.fwd, "Green")
            setGroupPhase(CF_11B.N.left, "Green")

            task.wait(15)

            setGroupPhase(CF_11B.N.left, "Yellow", true)
            task.wait(3)
            setGroupPhase(CF_11B.S.fwd, "Green")

            task.wait(15)

            setDirectionPhase(CF_11B.N, "Yellow")
            setDirectionPhase(CF_11B.S, "Yellow")
            task.wait(3)
            setDirectionPhase(CF_11B.N, "Red")
            setDirectionPhase(CF_11B.S, "Red")
            task.wait(3)

            setGroupPhase(CF_11B.E.left, "Green")
            setGroupPhase(CF_11B.W.left, "Green")

            task.wait(15)

            setGroupPhase(CF_11B.E.left, "Yellow", true)
            setGroupPhase(CF_11B.W.left, "Yellow", true)
            task.wait(3)
            setGroupPhase(CF_11B.E.fwd, "Green")
            setGroupPhase(CF_11B.W.fwd, "Green")
            setIndividualPhase(CF_11B.W["Eagle Flatback Pedestrian Signal"], "Walk")
            setIndividualPhase(CF_11B.W["Eagle Flatback Pedestrian Signal 2"], "Walk")

            task.wait(15)

            setDirectionPhase(CF_11B.E, "Yellow")
            setDirectionPhase(CF_11B.W, "Yellow")
            task.wait(3)
            setIndividualPhase(CF_11B.W["Eagle Flatback Pedestrian Signal"], "DontWalk")
            setIndividualPhase(CF_11B.W["Eagle Flatback Pedestrian Signal 2"], "DontWalk")
            setDirectionPhase(CF_11B.E, "Red")
            setDirectionPhase(CF_11B.W, "Red")
            task.wait(3)
        end
    }
}