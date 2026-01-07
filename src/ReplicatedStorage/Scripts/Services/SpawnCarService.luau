local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local SpawnCarEvent: RemoteEvent = ReplicatedStorage.Remotes.SpawnCar

local SpawnCarService = {}

function SpawnCarService.init()
    SpawnCarEvent.OnServerEvent:Connect(function(plr: Player, car: string, ...)  
        local newCar: Model = ServerStorage.Cars:FindFirstChild(car):Clone()
        newCar:PivotTo(plr.Character:GetPivot())
        newCar.Parent = workspace
    end)
end

return SpawnCarService