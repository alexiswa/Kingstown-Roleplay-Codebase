--!strict
-- Class for making checkpoint-based jobs, such as races, mail delivery, bus services, and similar. 
-- Intended to be reusable.
local PointsInLineJob = {}

type PointsInLineJobData = {
   PermittedVehicles: (string | {string})?,
   Waypoints: {
        {
            WorldPosition: Vector3,
            Order: number,
        }
   },
   RewardPerWaypoint: number,
   RewardOnCompletion: number,
   
}

export type PointsInLineJob = setmetatable<PointsInLineJobData, typeof(PointsInLineJob)>

return PointsInLineJob