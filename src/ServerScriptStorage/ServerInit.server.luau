--!strict
local MoneyService = require('../ReplicatedStorage/Scripts/Services/MoneyService')
local PlayerCarService = require('../ReplicatedStorage/Scripts/Services/PlayerCarService')
local PotholeGenerationService = require('../ReplicatedStorage/Scripts/Services/PotholeGenerationService')
local PrepWorkspace = require('../ReplicatedStorage/Scripts/misc/PrepWorkspace')
local TrafficLightService = require('../ReplicatedStorage/Scripts/Services/TrafficLightService')
local UiInit = require('../ReplicatedStorage/Scripts/misc/UiInit')

MoneyService.init()
UiInit()
PlayerCarService.init()
PrepWorkspace()
PotholeGenerationService.StartGeneration()
TrafficLightService.init()
