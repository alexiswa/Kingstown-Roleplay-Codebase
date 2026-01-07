local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage.Remotes.SpawnCar;

(script.Parent :: TextButton).MouseButton1Click:Connect(function()
    event:FireServer(script.Parent.Name)
end)