--!strict
return function()
    local nodes = workspace.Nodes:GetDescendants()
    for _, i in nodes do
        i:Destroy()
    end
end
