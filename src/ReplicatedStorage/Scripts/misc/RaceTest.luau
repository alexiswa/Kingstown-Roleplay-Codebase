local Players = game:GetService("Players")

local PointsInLineJob = require('../Classes/PointsInLineJob')

return function()
    local parts = workspace.racetest:GetChildren()
    table.sort(parts, function(a0: Instance, a1: Instance): boolean  
        if a0.Name < a1.Name then
            return true
        else
            return false
        end
    end)
    local points = {}
    for _, p in parts do
        table.insert(points, p.Position)
    end

    local plr = Players:GetChildren()[1]
    if not plr then 
        plr = Players.PlayerAdded:Wait()
    end

    local race = PointsInLineJob.new(points, plr)
    race.BoundingBox = Vector3.new(35, 1000, 35)
    race.RewardOnCompletion = 1000
    race.PermittedVehicles = {"A-Chassis 1.7.1"}

    race:init()

    while true do 
        race.OnFinish.Event:Wait()

        race:Reset()
    end
end
