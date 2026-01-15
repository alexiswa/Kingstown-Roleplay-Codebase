--!strict
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local PotholeGenerationService = {}

local potholes: {BasePart} = {}

local GENERATION_ENABLED = true
local MAX_POTHOLES = 50
local POTHOLE_GENERATION_COOLDOWN = 1
local POTHOLE_GENERATION_COOLDOWN_VARIATION = 0
local MINIMUM_POTHOLE_DISTANCE = 5

local function filterRoadList(roadList: {Instance})
    for i, d in roadList do
        if typeof(d) ~= "BasePart" then
            table.remove(roadList, i)
        end
    end
    return roadList :: {BasePart}
end

local function GetRandomPointInsidePart(part: BasePart): Vector3
    local x = part.Position.X + math.random(-part.Size.X /2, part.Size.X /2)
    local y = part.Position.Y + math.random(-part.Size.Y /2, part.Size.Y /2)
    local z = part.Position.Z + math.random(-part.Size.Z /2, part.Size.Z /2)

    return Vector3.new(x, y, z)
end

@native
    local function potholeIsDistantEnough(existing: {BasePart}, newPothole: Vector3)
    if #existing == 0 then
        return true
    end

    for _, p1 in existing do
        if (p1.Position - newPothole).Magnitude <= MINIMUM_POTHOLE_DISTANCE then
            return false
        end
    end
    return true
end

function PotholeGenerationService.StartGeneration()
    print("Test")
    if not GENERATION_ENABLED then
        return
    end
    local generateTick = 0
    local variation = math.random(0, POTHOLE_GENERATION_COOLDOWN_VARIATION)
    local roadList = filterRoadList(CollectionService:GetTagged("Pavement"))

    RunService.Heartbeat:Connect(function(dt: number)
        generateTick += dt

        if generateTick >= POTHOLE_GENERATION_COOLDOWN + variation then
            variation = math.random(0, POTHOLE_GENERATION_COOLDOWN_VARIATION)
            generateTick = 0
            if #potholes >= MAX_POTHOLES then
                return
            end

            local selectedRoad: BasePart
            local i = 0
            repeat
                selectedRoad = roadList[math.random(1, #roadList)]
                i += 1
            until potholeIsDistantEnough(potholes, selectedRoad.Position) or i >= 256

            if i >= 256 then
                return
            end

            table.insert(potholes, selectedRoad)

            local pothole = Instance.new("Part")
            local pos = GetRandomPointInsidePart(selectedRoad)
            pothole.Position = Vector3.new(pos.X, selectedRoad.Position.Y + 0.5, pos.Z)
            pothole.Orientation = selectedRoad.Orientation + Vector3.new(0, 0, 90)
            pothole.Size = Vector3.new(selectedRoad.Size.Y / 2 + 0.75, 5, 5)
            pothole.Shape = Enum.PartType.Cylinder
            pothole.Anchored = true
            pothole.Parent = workspace

            local touchedParts = pothole:GetTouchingParts()
            print(touchedParts)
            table.insert(touchedParts, selectedRoad)
            for _, p in touchedParts do
                local _, result = pcall(function(...)
                   return p:SubtractAsync({pothole})
                end)

                result.Parent = selectedRoad.Parent
                p.Transparency = 1
            end
        end
    end)
end

return PotholeGenerationService
