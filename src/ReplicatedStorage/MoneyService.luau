--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local MONEY_CONTAINER_NAME = "PlayerMoneyAttribute"

local MoneyService = {}

---- Any side

-- Returns the players money
-- NOTE: Although this can be run on the client-side, it should only be run on the server
-- for important tasks such as shop purchasing. Use with caution.
function MoneyService.GetMoney(player: Player)
	local leaderstats = player:FindFirstChild("leaderstats")
	
	if not leaderstats then
		error("Cannot get money; leaderstats does not exist!")
	end
	local moneyVal = leaderstats:FindFirstChild(MONEY_CONTAINER_NAME) :: NumberValue

	if not moneyVal then
		error("Cannot get money; money value does not exist!")
	end

	return moneyVal.Value
end

---- Client side

---- Server side

function MoneyService.AddMoney(player: Player, amount: number)
	if not RunService:IsServer() then
		error("Attempting to run AddMoney() outside of server-side")
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	
	if not leaderstats then
		error("Cannot get money; leaderstats does not exist!")
	end
	local moneyVal = leaderstats:FindFirstChild(MONEY_CONTAINER_NAME) :: NumberValue

	if not moneyVal then
		error("Cannot get money; money value does not exist!")
	end

	moneyVal.Value += amount
	
end

---- On load
--TODO: data store
local function InitializePlayerData(player: Player): NumberValue
	if not RunService:IsServer() then
		error("Cannot initialize player data outside of server")
	end

	local alreadyExists: Instance? = player:FindFirstChild("leaderstats")

	if alreadyExists then
		print("Player data already initialized")
		return alreadyExists :: NumberValue
	end

	local ls = Instance.new("Folder")
	local money: NumberValue = Instance.new("NumberValue")
	money.Value = 500
	money.Parent = ls
	ls.Name = "leaderstats"
	ls.Parent = player
	return money
end

@native
local function MoneySpeedCurve(speed: number): number
	if speed >= 15 and speed <= 30 then
		return 650
	elseif speed < 15 then
		local denom = 1 + math.exp(-speed + 8.5)
		return 750 / denom
	else
		local denom = 1 + math.exp(-1.5 * speed + 52)
		return -(650 / denom) + 750
	end
end

function MoneyService.init()
	Players.PlayerAdded:Connect(function(player: Player)
    	InitializePlayerData(player)
		
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

    	        -- divide by 3.57 to convert to meters
    	        local magnitude = (currentPos - lastPos).Magnitude / 3.57

    	        oneMinuteVelocity += magnitude / dt
			
    	        if cycleTime >= 60 then
    	            local average = oneMinuteVelocity / timeCounter
    	            timeCounter = 0
    	            oneMinuteVelocity = 0
    	            cycleTime = 0
    	            return MoneySpeedCurve(average)
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
end

return MoneyService
