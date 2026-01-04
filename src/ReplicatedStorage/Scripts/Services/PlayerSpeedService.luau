--!strict
local RunService = game:GetService("RunService")

local PlayerSpeedService = {}

---@param plr: The player to get the speed of
---@param tp: the time frame, in ms, to get the players speed over. Optional, defaults to 500
function PlayerSpeedService.GetAveragePlayerSpeedOverTime(plr: Player, tp: number?)
    local trackTime = tp or 500
    -- convert to seconds
    trackTime /= 1000

    local char: Model = if plr.Character ~= nil then plr.Character else plr.CharacterAdded:Wait()
    local numCycle: number = 0
    local elapsed: number = 0
    local currentPos: Vector3 = char:GetPivot().Position
    local lastPos: Vector3 = currentPos
    local distCounter: number = 0
    local result: number = 0
    local resultIsReady: boolean = false
    local connection: RBXScriptConnection
    local resultReadyEvent: BindableEvent = Instance.new("BindableEvent")

    @native
    local function runGetter(pos: Vector3, dt: number)
        lastPos = currentPos
        currentPos = pos
        numCycle += 1
        elapsed += dt

        distCounter += ((lastPos - currentPos).Magnitude / 3.57) / dt

        if elapsed >= trackTime then
            result = distCounter / numCycle
            resultIsReady = true
        end
    end

    connection = RunService.Heartbeat:Connect(function(dt: number)
        runGetter(char:GetPivot().Position, dt)
        if resultIsReady then
            resultReadyEvent:Fire()
        end
    end)

    resultReadyEvent.Event:Wait()
    connection:Disconnect()
    return result
end

return PlayerSpeedService