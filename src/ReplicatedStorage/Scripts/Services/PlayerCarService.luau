--!strict
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local ServerStorage = game:GetService('ServerStorage')

local SpawnCarEvent: RemoteEvent = ReplicatedStorage.Remotes.SpawnCar

local PlayerCarService = {}

function PlayerCarService.init()

    Players.PlayerAdded:Connect(function(plr: Player)
        local carTracker = Instance.new("ObjectValue")
        carTracker.Name = "CarTracker"
        carTracker.Parent = plr
    end)

    Players.PlayerRemoving:Connect(function(plr: Player)
        local CarTracker = plr:FindFirstChildWhichIsA("ObjectValue")
        -- silent fail
        if  CarTracker and CarTracker.Value ~= nil then
            (CarTracker.Value :: Instance):Destroy()
        end
    end)

    SpawnCarEvent.OnServerEvent:Connect(function(plr: Player, car: any)
        if typeof(car) ~= "string" then
            return
        end

        local CarTracker = plr:FindFirstChildWhichIsA("ObjectValue")
        if not CarTracker then
            print("Car Tracker not found!")
            return
        end
        if CarTracker.Value ~= nil then
            CarTracker.Value:Destroy()
        end

        local carModel = ServerStorage.Cars:FindFirstChild(car)

        if carModel == nil or not carModel:IsA("Model") then
            return
        end

        local newCar: Model = carModel:Clone()
        local char = plr.Character
        if not plr.Character then
           char = plr.CharacterAdded:Wait()
        end

        newCar:PivotTo((char :: Model):GetPivot() + Vector3.new(0, 5, 0))
        newCar.Parent = workspace
        CarTracker.Value = newCar
    end)
end

function PlayerCarService.GetPlayerActiveCar(plr: Player)
    local carval = plr:FindFirstAncestorWhichIsA("ObjectValue")
    if carval then
        return carval.Value
    else
        print("Carval not found")
        return nil
    end
end

---@param plr: The player to get the speed of
---@param tp: the time frame, in ms, to get the players speed over. Optional, defaults to 500
function PlayerCarService.GetAveragePlayerSpeedOverTime(plr: Player, tp: number?)
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

        -- avoid dividing by 0 and getting NaN values.
        -- although this shouldn't happen, it does, which is a problem.
        if dt > 0 then
            distCounter += ((lastPos - currentPos).Magnitude / 3.57) / dt
        end

        if distCounter ~= distCounter then
            print(`\ndebug info:\n\tlastpos: {lastPos}\n\tcurrentpos: {currentPos}\n\tmagnitude: {(lastPos - currentPos).Magnitude}\n\tdt: {dt}\n\trawresult: {((lastPos - currentPos).Magnitude) / dt}\n\tprocessedResult: {((lastPos - currentPos).Magnitude / 3.57) / dt}\n\tnumCycle: {numCycle}\n\t`)
            error("distCounter is Not a Number")
        end

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

return PlayerCarService
