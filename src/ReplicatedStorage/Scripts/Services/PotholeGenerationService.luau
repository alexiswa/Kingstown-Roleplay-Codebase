--!strict
local RunService = game:GetService("RunService")
local PotholeGenerationService = {}

local potholes = {}

local MAX_POTHOLES = 5
local POTHOLE_GENERATION_COOLDOWN = 1
local POTHOLE_GENERATION_COOLDOWN_VARIATION = 0
local MINIMUM_POTHOLE_DISTANCE = 1000

local function filterRoadList(roadList: {Instance})
    for i, d in roadList do
        if typeof(d) ~= "Model" then
            table.remove(roadList, i)
        end
        if d.Name ~= "Model" then
            table.remove(roadList, i)
        end
    end
    return roadList :: {Model}
end

@native
function PotholeIsDistantEnough(existing: {Vector3}, newPothole: Vector3)
    if #existing == 0 then
        return true
    end

    for _, p1 in existing do
        if (p1 - newPothole).Magnitude <= MINIMUM_POTHOLE_DISTANCE then
            return false
        end
    end
    return true
end

function PotholeGenerationService.StartGeneration()
    local generateTick = 0
    local variation = math.random(0, POTHOLE_GENERATION_COOLDOWN_VARIATION)
    local roadList = filterRoadList(workspace.Roads:GetChildren())

    RunService.Heartbeat:Connect(function(dt: number)  
        generateTick += dt

        if generateTick >= POTHOLE_GENERATION_COOLDOWN + variation then
            variation = math.random(0, POTHOLE_GENERATION_COOLDOWN_VARIATION)
            generateTick = 0
            if #potholes >= MAX_POTHOLES then
                return
            end
            
            local selectedRoad: Vector3
            repeat
                selectedRoad = roadList[math.random(1, #roadList)]:GetPivot().Position
            until PotholeIsDistantEnough(potholes, selectedRoad)

            table.insert(potholes, selectedRoad)

            local pothole = Instance.new("Part")
            pothole.Position = selectedRoad
            pothole.Orientation = Vector3.new(0, 0, 90)
            pothole.Size = Vector3.new(15, 15, 15)
            pothole.Shape = Enum.PartType.Cylinder
            pothole.Anchored = true
            pothole.Parent = workspace
        end
    end)
end

return PotholeGenerationService