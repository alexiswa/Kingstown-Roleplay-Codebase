--!strict
-- Class for making checkpoint-based jobs, such as races, mail delivery, bus services, and similar. 
-- Intended to be reusable.

---- requires
local PlayerSpeedService = require('../Services/PlayerSpeedService')
---- end requires

---- OOP setup ----
local PointsInLineJob = {}

type WaypointInfo = {
    WorldPosition: Vector3, -- points 3d position in the world
    CollisionPart: Part,
	Index: number, -- its order in the list of waypoints
    Completed: boolean -- whether or not the player has completed it
}

type PointsInLineJobData = {
    Player: Player, -- The player who started the job, or the "owner"
    RewardOnCompletion: number, -- How much money is rewarded after completing every waypoint
    StopOnFinalWaypoint: boolean, -- Does the player need to stop on the final waypoint?
	StopOnMidpoints: boolean, -- Does the player need to stop on all points that are not the first or last
	ShowWaypoints: boolean, -- Do each of the waypoints show up?

	PermittedVehicles: (string | {string}), -- What vehicle(s) does the job need to be completed? use "any" to allow any vehicle

    OnStart: BindableEvent, -- Function that runs when a player starts the job
    OnWaypoint: BindableEvent, -- Function that runs when a player passes through a waypoint
    OnFinish: BindableEvent, -- Function that runs after finishing the job

    ----------

    -- The area around each waypoint that the player needs to be in to be considered complete
    BoundingBox: Vector3, 
    -- The table that contains the info for each waypoint. Do not manually assign.
    Waypoints: {WaypointInfo},
}

PointsInLineJob.__index = PointsInLineJob
export type PointsInLineJob = setmetatable<PointsInLineJobData, typeof(PointsInLineJob)>
---- end OOP setup ----

-- misc local vars --
local waypointVisiblePart = Instance.new("Part")
waypointVisiblePart.Shape = Enum.PartType.Cylinder
waypointVisiblePart.Transparency = 0.75
waypointVisiblePart.Anchored = true
waypointVisiblePart.CanCollide = false
waypointVisiblePart.Orientation = Vector3.new(0, 0, 90)

function PointsInLineJob.new(points: {Vector3}, player: Player): PointsInLineJob
    local self = {} :: PointsInLineJob

    self.Player = player
    self.RewardOnCompletion = 0
    self.StopOnFinalWaypoint = false
    self.StopOnMidpoints = false
    self.ShowWaypoints = false
    self.PermittedVehicles = "any"

    self.OnStart = Instance.new("BindableEvent")
    self.OnWaypoint = Instance.new("BindableEvent")
    self.OnFinish = Instance.new("BindableEvent")

    self.BoundingBox = Vector3.new(15, 500, 15)

    self.Waypoints = {}
        
    for i, point in points do
        local pointInfo = {} :: WaypointInfo
        pointInfo.WorldPosition = point
        pointInfo.CollisionPart = waypointVisiblePart:Clone()
        pointInfo.CollisionPart.Size = self.BoundingBox
        pointInfo.CollisionPart.Position = point
        pointInfo.CollisionPart.Parent = workspace
        pointInfo.Index = i
        pointInfo.Completed = false

        local recentlyTouchedByPlayer = false
        local partTouched: BasePart?

        pointInfo.CollisionPart.Touched:Connect(function(part: BasePart)  
            -- TODO: Check if previous points have been completed before firing
            if not player.Character then
                player.CharacterAdded:Wait()
            end

            if part.Parent ~= player.Character or recentlyTouchedByPlayer or pointInfo.Completed  then
                return
            end

            recentlyTouchedByPlayer = true
            partTouched = part

            if self.StopOnMidpoints then
                while PlayerSpeedService.GetAveragePlayerSpeedOverTime(player, 250) > 1 do
                    -- do nothing
                end
                -- stop it from being triggered by stopping after leaving the waypoint 
                if not recentlyTouchedByPlayer then
                    return
                end
            end
            print('Hit waypoint!')
            self.OnWaypoint:Fire(pointInfo)
            pointInfo.Completed = true 
        end)

        pointInfo.CollisionPart.TouchEnded:Connect(function(part: BasePart)
            if part == partTouched and recentlyTouchedByPlayer then
                recentlyTouchedByPlayer = false
                partTouched = nil
            end
        end)

        table.insert(self.Waypoints, pointInfo)
    end

    return self
end


return PointsInLineJob