local sss = game:GetService("ServerStorage")

return function()
    local spawnUi = sss.UIinit.CarSpawnUi
    local frameTemplate = spawnUi.ScrollingFrame.TextButton
    for _, car: Model in sss.Cars:GetChildren() do
        local uiButton = frameTemplate:Clone()
        uiButton.Text = car.Name
        uiButton.Name = car.Name
        uiButton.Parent = spawnUi.ScrollingFrame
    end
    spawnUi.Parent = game:GetService("StarterGui")
    frameTemplate:Destroy()
end
