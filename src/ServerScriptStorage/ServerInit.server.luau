--!strict
local MoneyService = require('../ReplicatedStorage/Scripts/Services/MoneyService')
local SpawnCarService = require('../ReplicatedStorage/Scripts/Services/SpawnCarService')
local UiInit = require('../ReplicatedStorage/Scripts/misc/UiInit')
local RaceTest = require('../ReplicatedStorage/Scripts/misc/RaceTest')

MoneyService.init()
UiInit()
SpawnCarService.init()
RaceTest()