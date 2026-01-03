--!strict
local RunService = game:GetService("RunService")

local MONEY_CONTAINER_NAME = "PlayerMoneyAttribute"

local MoneyService = {}

---- Any side

function MoneyService.GetMoney(player: Player)
	local leaderstats = player:FindFirstChild("Leaderstats")
	
	if not leaderstats then
		error("Cannot get money; leaderstats does not exist!")
	end
	local moneyVal = leaderstats:FindFirstChild(MONEY_CONTAINER_NAME) :: NumberValue

	if not moneyVal then
		error("Cannot get money; money value does not exist!")
	end

	return moneyVal.Value
end

@native
function MoneyService.MoneySpeedCurve(speed: number): number
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

---- Client side


---- Server side

function MoneyService.AddMoney(player: Player, amount: number)
	if not RunService:IsServer() then
		error("Attempting to run AddMoney() outside of server-side")
	end

	local leaderstats = player:FindFirstChild("Leaderstats")
	
	if not leaderstats then
		error("Cannot get money; leaderstats does not exist!")
	end
	local moneyVal = leaderstats:FindFirstChild(MONEY_CONTAINER_NAME) :: NumberValue

	if not moneyVal then
		error("Cannot get money; money value does not exist!")
	end

	moneyVal.Value += amount
	
end

--TODO: data store
function MoneyService.InitializePlayerData(player: Player): NumberValue
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


return MoneyService
