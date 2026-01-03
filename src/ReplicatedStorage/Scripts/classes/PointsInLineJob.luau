--!strict
local RunService = game:GetService("RunService")
-- Class for making checkpoint-based jobs, such as races, mail delivery, bus services, and similar. 
-- Intended to be reusable.

---- Requires
local MoneyService = require('../MoneyService')

---- OOP setup ----
local PointsInLineJob = {}

type WaypointInfo = {
    WorldPosition: Vector3, -- points 3d position in the world
	Order: number, -- its order in the list of waypoints
    Completed: boolean -- whether or not the player has completed it
}

type PointsInLineJobData = {
    Player: Player, -- The player who started the job, or the "owner"
    RewardPerWaypoint: number, -- How much money each waypoint gives out
    RewardOnCompletion: number, -- How much money is rewarded after completing every waypoint
    StopOnFinalWaypoint: boolean, -- Does the player need to stop on the final waypoint?
	StopOnMidpoints: boolean, -- Does the player need to stop on all points that are not the first or last
	ShowWaypoints: boolean, -- Do each of the waypoints show up?

	PermittedVehicles: (string | {string})?, -- What vehicle(s) does the job need to be completed?


    -- NOTE: any user-defined functions will run *AFTER* the built-in functions.
    -- The built-in functions can be overridden with the On<x>Override boolean.

    -- **if you don't know what you're doing, dont set the overrides to true**

    OnStart: (self: PointsInLineJob, ...any?) -> ()?, -- Function that runs when a player starts the job
    OnStartOverride: boolean,

    OnWaypoint: (self: PointsInLineJob, waypointNumber: number?, ...any?) -> ()?, -- Function that runs when a player passes through a waypoint
    OnWaypointOverride: boolean,

    OnFinish: (self: PointsInLineJob, ...any?) -> ()?, -- Function that runs after finishing the job
    OnFinishOverride: boolean,

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

function PointsInLineJob.new(points: {Vector3}, player: Player): PointsInLineJob
    local newJob = {} :: PointsInLineJob

    newJob.Player = player
    newJob.RewardPerWaypoint = 0
    newJob.RewardOnCompletion = 0
    newJob.StopOnFinalWaypoint = false
    newJob.StopOnMidpoints = false
    newJob.ShowWaypoints = false
    newJob.PermittedVehicles = "any"

    newJob.OnStart = PointsInLineJob.OnStart
    newJob.OnStartOverride = false
    newJob.OnWaypoint = PointsInLineJob.OnWaypoint
    newJob.OnWaypointOverride = false
    newJob.OnFinish = PointsInLineJob.OnFinish
    newJob.OnFinishOverride = false
    
    newJob.BoundingBox = Vector3.new(15, 15, 15)

    for i, point in points do
        
    end

    return newJob
end

function PointsInLineJob.StartWaypointListener(self: PointsInLineJob)
    
end

function PointsInLineJob.EndWaypointListener(self: PointsInLineJob)
    
end

--- On Start functions
local function DefaultOnStartClientSide(self: PointsInLineJob)
    if self.ShowWaypoints then
        for _, wp in self.Waypoints do
            local p = waypointVisiblePart:Clone()
            p.Size = self.BoundingBox
            p.Parent = workspace
        end
    end
end

function PointsInLineJob.DefaultOnStart(self: PointsInLineJob)
    if self.OnStartOverride then
        self:OnStart()
        return
    end

    -- if its being called on the client, run the client-side function and skip the rest
    if RunService:IsClient() then   
        DefaultOnStartClientSide(self)
        return
    end
    -- below will only run on the server side
end
--- On Waypoint functions
local function DefaultOnWaypointClientSide(self: PointsInLineJob, waypointNumber: number)
--TODO
end

function PointsInLineJob.DefaultOnWaypoint(self: PointsInLineJob, waypointNumber: number)
    if self.OnWaypointOverride then 
        self:OnWaypoint()
        return
    end

    if RunService:IsClient() then
        DefaultOnWaypointClientSide(self, waypointNumber)
        return
    end

    MoneyService.AddMoney(self.Player, self.RewardPerWaypoint)    

    self:OnWaypoint()
end
--- On Finish functions
local function DefaultOnFinishClientSide(self: PointsInLineJob)
    -- TODO
end

function PointsInLineJob.DefaultOnFinish(self: PointsInLineJob)
    if self.OnFinishOverride then
        self:OnFinish()
        return
    end

    if RunService:IsClient() then
        DefaultOnFinishClientSide(self)
        return
    end

    MoneyService.AddMoney(self.Player, self.RewardOnCompletion)
end

---- The do-block below has no functionality and exists for error prevention and ease of use. It can safely be ignored.
do
    function PointsInLineJob.OnStart(self: PointsInLineJob)
        -- This function is intentionally left blank
    end 

    function PointsInLineJob.OnWaypoint(self: PointsInLineJob, waypointNumber: number?)
        -- This function is intentionally left blank
    end

    function PointsInLineJob.OnFinish(self: PointsInLineJob)
        -- This function is intentionally left blank
    end
end

return PointsInLineJob