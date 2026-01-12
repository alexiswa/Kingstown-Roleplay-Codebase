--!strict
--TODO: extract max money to a single variable
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PlayerCarService = require('./PlayerCarService')

local MONEY_CONTAINER_NAME = "PlayerMoneyAttribute"

local MoneyService = {}

---- Any side

-- Returns the players money
-- NOTE: Although this can be run on the client-side, it should only be run on the server
-- for important tasks such as shop purchasing. Use with caution.
function MoneyService.GetMoney(player: Player, silenceClientSideWarning: boolean)
	silenceClientSideWarning = silenceClientSideWarning or false

	if RunService:IsClient() and not silenceClientSideWarning then
		warn("Warning! Getting the players money on the client side is unsafe" ..
			"for transaction use and should only be used for UI and effects!" ..
			"Set the second parameter to `true` to silence.")
	end

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
	money.Name = MONEY_CONTAINER_NAME
	money.Parent = ls
	ls.Name = "leaderstats"
	ls.Parent = player
	return money
end

@native
local function MoneySpeedCurve(speed: number): number
	if speed >= 15 and speed <= 30 then
		return 750
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
		
		local characterRemoving = false

		player.CharacterAdded:Connect(function(char: Model)  
			while not characterRemoving do
				local result = PlayerCarService.GetAveragePlayerSpeedOverTime(player, 60 * 1000)
				local moneyToAdd = math.round(MoneySpeedCurve(result))

				if moneyToAdd ~= moneyToAdd then
					warn("Warning: Got a NaN Value. Printing debug information:")
					print(`\tDebugInfo:\n\tplayer speed avg over 60 seconds: {result}\n\tmoney to add: {moneyToAdd}`)
					moneyToAdd = 0
				end

				MoneyService.AddMoney(player, moneyToAdd)
			end
		end)
	end)
end

return MoneyService
