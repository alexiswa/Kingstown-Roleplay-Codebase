--!strict
local MoneyService = require('../ReplicatedStorage/Scripts/Services/MoneyService')
local PlayerCarService = require('../ReplicatedStorage/Scripts/Services/PlayerCarService')
local PotholeGenerationService = require('../ReplicatedStorage/Scripts/Services/PotholeGenerationService')
local UiInit = require('../ReplicatedStorage/Scripts/misc/UiInit')
local RaceTest = require('../ReplicatedStorage/Scripts/misc/RaceTest')
local PrepWorkspace = require('../ReplicatedStorage/Scripts/misc/PrepWorkspace')


MoneyService.init()
UiInit()
PlayerCarService.init()
PrepWorkspace()
PotholeGenerationService.StartGeneration()

-- asynchronous stuff here
task.spawn(function()
    RaceTest()
end)
