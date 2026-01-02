--!strict
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local MoneyService = require("../ReplicatedStorage/MoneyService")

Players.PlayerAdded:Connect(function(player: Player)
    MoneyService.InitializePlayerData(player)
    
    local heartbeatConnection: RBXScriptConnection

    player.CharacterAdded:Connect(function(char: Model)  
        local lastPos = char:GetPivot().Position
        local currentPos = char:GetPivot().Position
        local oneMinuteVelocity = 0
        local timeCounter = 0
        local cycleTime = 0

        -- defining this function in-scope to use above declared variables,
        -- and running it in native as it runs very frequently and does not make
        -- roblox API calls. Returns a number given from MoneySpeedCurve() every 60
        -- seconds, otherwise returns 0
        @native
        local function heartbeatCore(charPos: Vector3, dt: number): number
            cycleTime += dt
            timeCounter += 1
            lastPos = currentPos
            currentPos = charPos

            -- divide by 3.57 to convert to m/s
            local magnitude = (currentPos - lastPos).Magnitude / 3.57

            oneMinuteVelocity += magnitude / dt
            
            if cycleTime >= 60 then
                local average = oneMinuteVelocity / timeCounter
                print(average)
                timeCounter = 0
                oneMinuteVelocity = 0
                cycleTime = 0
                return MoneyService.MoneySpeedCurve(average)
            end
            return 0
        end

        heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)  
            local r = heartbeatCore(char:GetPivot().Position, dt)
            -- money wont be added if its under 5 dollars.
            if r > 5 then 
                MoneyService.AddMoney(player, r)
            end
        end)
    end)

    -- prevent heartbeat connections continuing for old characters
    player.CharacterRemoving:Connect(function()  
        heartbeatConnection:Disconnect()
    end)

end)