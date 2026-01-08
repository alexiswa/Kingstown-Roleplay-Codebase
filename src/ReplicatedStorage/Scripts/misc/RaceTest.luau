local Players = game:GetService("Players")

local PointsInLineJob = require('../Classes/PointsInLineJob')

return function()
    local parts = workspace.racetest:GetChildren()
    local points = {}
    for _, p in parts do
        table.insert(points, p.Position)
    end

    local plr = Players:GetChildren()[1]
    if not plr then 
        plr = Players.PlayerAdded:Wait()
    end

    local race = PointsInLineJob.new(points, plr)
    race.BoundingBox = Vector3.new(100, 500, 100)
    race.RewardOnCompletion = 1000
    race.PermittedVehicles = {"A-Chassis 1.7.1"}

    race:init()

    while true do 
        race.OnFinish.Event:Wait()

        race:Reset()
    end
end
