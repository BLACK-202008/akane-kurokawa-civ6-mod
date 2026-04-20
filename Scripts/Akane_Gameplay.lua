print("[Akane Task5 Gameplay] Akane_Gameplay.lua loaded")

local AKANE_EVENT_STAGE_PERFORM = "AKANE_STAGE_ACTOR_PERFORM"
local AKANE_UNIT_STAGE_ACTOR = "UNIT_STAGE_ACTOR"
local AKANE_DISTRICT_LALALAI = "DISTRICT_LALALAI_TROUPE"
local AKANE_LOG_PREFIX = "[Akane Task5 Gameplay]"
local AKANE_LEADER_TYPE = "LEADER_KUROKAWA_AKANE"
local PROPERTY_MODE_CURRENT = "AKANE_MODE_CURRENT"
local MODE_NONE = "MODE_NONE"
local MODE_AI = "MODE_AI"
local MODE_ACTOR = "MODE_ACTOR"
local MODE_WARRIOR = "MODE_WARRIOR"
local WARRIOR_MODE_FAITH_REWARD_RATIO = 0.8
local STAGE_REWARD_MODIFIERS = {
  "AKANE_CITY_STAGE_AMPHITHEATER_CULTURE",
  "AKANE_CITY_STAGE_ART_MUSEUM_CULTURE",
  "AKANE_CITY_STAGE_ARCHAEOLOGICAL_MUSEUM_CULTURE",
  "AKANE_CITY_STAGE_BROADCAST_CENTER_CULTURE",
  "AKANE_CITY_STAGE_AMPHITHEATER_TOURISM_ALL",
  "AKANE_CITY_STAGE_ART_MUSEUM_TOURISM_ALL",
  "AKANE_CITY_STAGE_ARCHAEOLOGICAL_MUSEUM_TOURISM_ALL",
  "AKANE_CITY_STAGE_BROADCAST_CENTER_TOURISM_ALL"
}
local MODIFIER_CITY_STAGE_LALALAI_CULTURE_BONUS = "AKANE_CITY_STAGE_LALALAI_CULTURE_BONUS"
local MODIFIER_CITY_STAGE_LALALAI_GOLD_BONUS = "AKANE_CITY_STAGE_LALALAI_GOLD_BONUS"
local MODIFIER_CITY_STAGE_CAMPUS_DOUBLE_ADJACENCY = "AKANE_CITY_STAGE_CAMPUS_DOUBLE_ADJACENCY"
local MODIFIER_CITY_STAGE_COMMERCIAL_DOUBLE_ADJACENCY = "AKANE_CITY_STAGE_COMMERCIAL_DOUBLE_ADJACENCY"
local MODIFIER_CITY_STAGE_HARBOR_DOUBLE_ADJACENCY = "AKANE_CITY_STAGE_HARBOR_DOUBLE_ADJACENCY"
local MODIFIER_CITY_STAGE_ENTERTAINMENT_COMPLEX_DOUBLE_ADJACENCY = "AKANE_CITY_STAGE_ENTERTAINMENT_COMPLEX_DOUBLE_ADJACENCY"
local MODIFIER_CITY_STAGE_WATER_PARK_DOUBLE_ADJACENCY = "AKANE_CITY_STAGE_WATER_PARK_DOUBLE_ADJACENCY"
local MODIFIER_CITY_STAGE_ENCAMPMENT_DOUBLE_ADJACENCY = "AKANE_CITY_STAGE_ENCAMPMENT_DOUBLE_ADJACENCY"
local MODIFIER_CITY_STAGE_INDUSTRIAL_ZONE_DOUBLE_ADJACENCY = "AKANE_CITY_STAGE_INDUSTRIAL_ZONE_DOUBLE_ADJACENCY"
local MODIFIER_CITY_STAGE_HOLY_SITE_DOUBLE_ADJACENCY = "AKANE_CITY_STAGE_HOLY_SITE_DOUBLE_ADJACENCY"
local MODIFIER_CITY_STAGE_LALALAI_CULTURE_BONUS_NEGATIVE = "AKANE_CITY_STAGE_LALALAI_CULTURE_BONUS_NEGATIVE"
local MODIFIER_CITY_STAGE_LALALAI_GOLD_BONUS_NEGATIVE = "AKANE_CITY_STAGE_LALALAI_GOLD_BONUS_NEGATIVE"
local MODIFIER_CITY_STAGE_CAMPUS_DOUBLE_ADJACENCY_NEGATIVE = "AKANE_CITY_STAGE_CAMPUS_DOUBLE_ADJACENCY_NEGATIVE"
local MODIFIER_CITY_STAGE_COMMERCIAL_DOUBLE_ADJACENCY_NEGATIVE = "AKANE_CITY_STAGE_COMMERCIAL_DOUBLE_ADJACENCY_NEGATIVE"
local MODIFIER_CITY_STAGE_HARBOR_DOUBLE_ADJACENCY_NEGATIVE = "AKANE_CITY_STAGE_HARBOR_DOUBLE_ADJACENCY_NEGATIVE"
local MODIFIER_CITY_STAGE_ENTERTAINMENT_COMPLEX_DOUBLE_ADJACENCY_NEGATIVE = "AKANE_CITY_STAGE_ENTERTAINMENT_COMPLEX_DOUBLE_ADJACENCY_NEGATIVE"
local MODIFIER_CITY_STAGE_WATER_PARK_DOUBLE_ADJACENCY_NEGATIVE = "AKANE_CITY_STAGE_WATER_PARK_DOUBLE_ADJACENCY_NEGATIVE"
local MODIFIER_CITY_STAGE_ENCAMPMENT_DOUBLE_ADJACENCY_NEGATIVE = "AKANE_CITY_STAGE_ENCAMPMENT_DOUBLE_ADJACENCY_NEGATIVE"
local MODIFIER_CITY_STAGE_INDUSTRIAL_ZONE_DOUBLE_ADJACENCY_NEGATIVE = "AKANE_CITY_STAGE_INDUSTRIAL_ZONE_DOUBLE_ADJACENCY_NEGATIVE"
local MODIFIER_CITY_STAGE_HOLY_SITE_DOUBLE_ADJACENCY_NEGATIVE = "AKANE_CITY_STAGE_HOLY_SITE_DOUBLE_ADJACENCY_NEGATIVE"
local ART_PROSPERITY_MODIFIERS_POSITIVE = {
  "AKANE_ART_PROSPERITY_FOOD",
  "AKANE_ART_PROSPERITY_PRODUCTION",
  "AKANE_ART_PROSPERITY_GOLD",
  "AKANE_ART_PROSPERITY_SCIENCE",
  "AKANE_ART_PROSPERITY_CULTURE",
  "AKANE_ART_PROSPERITY_FAITH"
}
local ART_PROSPERITY_MODIFIERS_NEGATIVE = {
  "AKANE_ART_PROSPERITY_FOOD_NEGATIVE",
  "AKANE_ART_PROSPERITY_PRODUCTION_NEGATIVE",
  "AKANE_ART_PROSPERITY_GOLD_NEGATIVE",
  "AKANE_ART_PROSPERITY_SCIENCE_NEGATIVE",
  "AKANE_ART_PROSPERITY_CULTURE_NEGATIVE",
  "AKANE_ART_PROSPERITY_FAITH_NEGATIVE"
}
local ART_PROSPERITY_STANDARD_TURN_EXTENSION = 25
local ART_PROSPERITY_STANDARD_TURN_CAP = 100
local STAGE_ACTOR_MAX_CHARGES = 3

local PROPERTY_CITY_STAGE_PERFORMED = "AKANE_CITY_STAGE_PERFORMED"
local PROPERTY_UNIT_STAGE_ACTOR_CHARGES = "AKANE_STAGE_ACTOR_CHARGES"
local PROPERTY_PLAYER_ART_STACKS = "AKANE_PLAYER_ART_PROSPERITY_STACKS"
local PROPERTY_PLAYER_ART_TURNS = "AKANE_PLAYER_ART_PROSPERITY_TURNS"
local PROPERTY_PLAYER_ART_APPLIED_STACKS = "AKANE_PLAYER_ART_PROSPERITY_APPLIED_STACKS"
local PROPERTY_PLAYER_ART_CLEARED_STACKS = "AKANE_PLAYER_ART_PROSPERITY_CLEARED_STACKS"
local PROPERTY_PLAYER_ART_NEG_APPLIED_STACKS = "AKANE_PLAYER_ART_PROSPERITY_NEG_APPLIED_STACKS"
local PROPERTY_PLAYER_LAST_FAITH_BALANCE = "AKANE_PLAYER_LAST_FAITH_BALANCE"
local PROPERTY_PLAYER_LAST_FAITH_SPEND = "AKANE_PLAYER_LAST_FAITH_SPEND"
local PROPERTY_PLAYER_LAST_FAITH_SPEND_TURN = "AKANE_PLAYER_LAST_FAITH_SPEND_TURN"
local PROPERTY_PLAYER_PENDING_AI_PURCHASE = "AKANE_PLAYER_PENDING_AI_PURCHASE"
local PROPERTY_CITY_STAGE_LALALAI_CULTURE_STACKS = "AKANE_CITY_STAGE_LALALAI_CULTURE_STACKS"
local PROPERTY_CITY_STAGE_LALALAI_GOLD_STACKS = "AKANE_CITY_STAGE_LALALAI_GOLD_STACKS"
local PROPERTY_CITY_STAGE_CAMPUS_BONUS_APPLIED = "AKANE_CITY_STAGE_CAMPUS_BONUS_APPLIED"
local PROPERTY_CITY_STAGE_COMMERCIAL_BONUS_APPLIED = "AKANE_CITY_STAGE_COMMERCIAL_BONUS_APPLIED"
local PROPERTY_CITY_STAGE_HARBOR_BONUS_APPLIED = "AKANE_CITY_STAGE_HARBOR_BONUS_APPLIED"
local PROPERTY_CITY_STAGE_ENTERTAINMENT_COMPLEX_BONUS_APPLIED = "AKANE_CITY_STAGE_ENTERTAINMENT_COMPLEX_BONUS_APPLIED"
local PROPERTY_CITY_STAGE_WATER_PARK_BONUS_APPLIED = "AKANE_CITY_STAGE_WATER_PARK_BONUS_APPLIED"
local PROPERTY_CITY_STAGE_ENCAMPMENT_BONUS_APPLIED = "AKANE_CITY_STAGE_ENCAMPMENT_BONUS_APPLIED"
local PROPERTY_CITY_STAGE_INDUSTRIAL_ZONE_BONUS_APPLIED = "AKANE_CITY_STAGE_INDUSTRIAL_ZONE_BONUS_APPLIED"
local PROPERTY_CITY_STAGE_HOLY_SITE_BONUS_APPLIED = "AKANE_CITY_STAGE_HOLY_SITE_BONUS_APPLIED"
local g_unitCostCache = {}
local g_lastWarriorFaithRewardKey = nil

local UNIT_STAGE_ACTOR_INDEX = GameInfo.Units[AKANE_UNIT_STAGE_ACTOR] and GameInfo.Units[AKANE_UNIT_STAGE_ACTOR].Index or -1
local DISTRICT_LALALAI_INDEX = GameInfo.Districts[AKANE_DISTRICT_LALALAI] and GameInfo.Districts[AKANE_DISTRICT_LALALAI].Index or -1
local DISTRICT_CITY_CENTER_INDEX = GameInfo.Districts["DISTRICT_CITY_CENTER"] and GameInfo.Districts["DISTRICT_CITY_CENTER"].Index or -1
local DISTRICT_ENTERTAINMENT_COMPLEX_INDEX = GameInfo.Districts["DISTRICT_ENTERTAINMENT_COMPLEX"] and GameInfo.Districts["DISTRICT_ENTERTAINMENT_COMPLEX"].Index or -1
local DISTRICT_CAMPUS_INDEX = GameInfo.Districts["DISTRICT_CAMPUS"] and GameInfo.Districts["DISTRICT_CAMPUS"].Index or -1
local DISTRICT_COMMERCIAL_HUB_INDEX = GameInfo.Districts["DISTRICT_COMMERCIAL_HUB"] and GameInfo.Districts["DISTRICT_COMMERCIAL_HUB"].Index or -1
local DISTRICT_HARBOR_INDEX = GameInfo.Districts["DISTRICT_HARBOR"] and GameInfo.Districts["DISTRICT_HARBOR"].Index or -1
local DISTRICT_WATER_PARK_INDEX = GameInfo.Districts["DISTRICT_WATER_ENTERTAINMENT_COMPLEX"] and GameInfo.Districts["DISTRICT_WATER_ENTERTAINMENT_COMPLEX"].Index or -1
local DISTRICT_ENCAMPMENT_INDEX = GameInfo.Districts["DISTRICT_ENCAMPMENT"] and GameInfo.Districts["DISTRICT_ENCAMPMENT"].Index or -1
local DISTRICT_INDUSTRIAL_ZONE_INDEX = GameInfo.Districts["DISTRICT_INDUSTRIAL_ZONE"] and GameInfo.Districts["DISTRICT_INDUSTRIAL_ZONE"].Index or -1
local DISTRICT_HOLY_SITE_INDEX = GameInfo.Districts["DISTRICT_HOLY_SITE"] and GameInfo.Districts["DISTRICT_HOLY_SITE"].Index or -1
local YIELD_CULTURE_INDEX = GameInfo.Yields["YIELD_CULTURE"] and GameInfo.Yields["YIELD_CULTURE"].Index or -1
local YIELD_FAITH_INDEX = GameInfo.Yields["YIELD_FAITH"] and GameInfo.Yields["YIELD_FAITH"].Index or -1
local YIELD_GOLD_INDEX = GameInfo.Yields["YIELD_GOLD"] and GameInfo.Yields["YIELD_GOLD"].Index or -1
local YIELD_PRODUCTION_INDEX = GameInfo.Yields["YIELD_PRODUCTION"] and GameInfo.Yields["YIELD_PRODUCTION"].Index or -1
local YIELD_SCIENCE_INDEX = GameInfo.Yields["YIELD_SCIENCE"] and GameInfo.Yields["YIELD_SCIENCE"].Index or -1

local function Log(message)
  print(AKANE_LOG_PREFIX .. " " .. tostring(message))
end

Log("gameplay handlers ready: stageActorIndex=" .. tostring(UNIT_STAGE_ACTOR_INDEX) .. ", lalalaiIndex=" .. tostring(DISTRICT_LALALAI_INDEX))

local function ToInt(v)
  if v == nil then
    return 0
  end
  return tonumber(v) or 0
end

local function GetCurrentTurnNumber()
  return math.max(0, Game.GetCurrentGameTurn())
end

local function IsAkanePlayer(playerID)
  local playerConfig = PlayerConfigurations[playerID]
  if playerConfig == nil then
    return false
  end
  return playerConfig:GetLeaderTypeName() == AKANE_LEADER_TYPE
end

local function GetCurrentMode(pPlayer)
  if pPlayer == nil then
    return MODE_NONE
  end

  local currentMode = pPlayer:GetProperty(PROPERTY_MODE_CURRENT)
  if currentMode == nil then
    return MODE_NONE
  end
  return tostring(currentMode)
end

local function GetUnitDefinitionByIndex(unitTypeIndex)
  if unitTypeIndex == nil or unitTypeIndex < 0 then
    return nil
  end
  return GameInfo.Units[unitTypeIndex]
end

local function GetUnitBaseCostFromDefinition(unitDef)
  if unitDef == nil then
    return 0
  end
  return math.max(0, ToInt(unitDef.Cost))
end

local function GetUnitBaseCost(pUnit)
  if pUnit == nil or pUnit.GetType == nil then
    return 0
  end
  return GetUnitBaseCostFromDefinition(GetUnitDefinitionByIndex(pUnit:GetType()))
end

local function EnsureUnitCostCacheForPlayer(playerID)
  if g_unitCostCache[playerID] == nil then
    g_unitCostCache[playerID] = {}
  end
  return g_unitCostCache[playerID]
end

local function CacheUnitBaseCost(playerID, unitID, pUnit)
  if playerID == nil or unitID == nil or pUnit == nil then
    return 0
  end

  local unitCost = GetUnitBaseCost(pUnit)
  EnsureUnitCostCacheForPlayer(playerID)[unitID] = unitCost
  return unitCost
end

local function GetCachedUnitBaseCost(playerID, unitID)
  if playerID == nil or unitID == nil then
    return 0
  end

  local cacheForPlayer = g_unitCostCache[playerID]
  if cacheForPlayer == nil then
    return 0
  end

  return math.max(0, ToInt(cacheForPlayer[unitID]))
end

local function ClearCachedUnitBaseCost(playerID, unitID)
  if playerID == nil or unitID == nil then
    return
  end

  local cacheForPlayer = g_unitCostCache[playerID]
  if cacheForPlayer ~= nil then
    cacheForPlayer[unitID] = nil
  end
end

local function RefreshPlayerUnitCostCache(playerID)
  local pPlayer = Players[playerID]
  if pPlayer == nil or not pPlayer:IsAlive() then
    return
  end

  local pUnits = pPlayer:GetUnits()
  if pUnits == nil then
    return
  end

  local cacheForPlayer = EnsureUnitCostCacheForPlayer(playerID)
  for key, _ in pairs(cacheForPlayer) do
    cacheForPlayer[key] = nil
  end

  for _, pUnit in pUnits:Members() do
    CacheUnitBaseCost(playerID, pUnit:GetID(), pUnit)
  end
end

local function RefreshAllUnitCostCaches()
  g_unitCostCache = {}
  for playerID, pPlayer in pairs(Players) do
    if pPlayer ~= nil and pPlayer:IsAlive() then
      RefreshPlayerUnitCostCache(playerID)
    end
  end
end

local function GetPlayerAnchorCity(pPlayer)
  if pPlayer == nil then
    return nil
  end

  local pCities = pPlayer:GetCities()
  if pCities == nil then
    return nil
  end

  local pCapital = pCities:GetCapitalCity()
  if pCapital ~= nil then
    return pCapital
  end

  for _, pCity in pCities:Members() do
    return pCity
  end

  return nil
end

local function GetWorldTextLocationForUnitOrPlayer(pPlayer, unitID)
  if pPlayer ~= nil and unitID ~= nil and unitID >= 0 then
    local pUnits = pPlayer:GetUnits()
    if pUnits ~= nil then
      local pUnit = pUnits:FindID(unitID)
      if pUnit ~= nil then
        return pUnit:GetX(), pUnit:GetY()
      end
    end
  end

  local pCity = GetPlayerAnchorCity(pPlayer)
  if pCity ~= nil then
    return pCity:GetX(), pCity:GetY()
  end

  return nil, nil
end

local function GetModeCooldownForCurrentGameSpeed()
  local modeAPI = ExposedMembers ~= nil and ExposedMembers.AkaneModeSystem or nil
  if modeAPI ~= nil and modeAPI.GetModeCooldownForCurrentGameSpeed ~= nil then
    return modeAPI.GetModeCooldownForCurrentGameSpeed()
  end

  local speedRow = GameInfo.GameSpeeds[GameConfiguration.GetGameSpeedType()]
  local speedType = speedRow and speedRow.GameSpeedType or "GAMESPEED_STANDARD"

  if speedType == "GAMESPEED_ONLINE" then
    return 5
  end
  if speedType == "GAMESPEED_QUICK" then
    return 7
  end
  if speedType == "GAMESPEED_EPIC" then
    return 15
  end
  if speedType == "GAMESPEED_MARATHON" then
    return 20
  end
  return 10
end

local function GetScaledArtProsperityTurns(standardTurns)
  return math.max(1, math.floor((standardTurns * GetModeCooldownForCurrentGameSpeed()) / 10))
end

local function GetArtProsperityTurnExtensionForCurrentGameSpeed()
  return GetScaledArtProsperityTurns(ART_PROSPERITY_STANDARD_TURN_EXTENSION)
end

local function GetArtProsperityTurnCapForCurrentGameSpeed()
  return GetScaledArtProsperityTurns(ART_PROSPERITY_STANDARD_TURN_CAP)
end

local function ResolveStagePerformUnitID(playerID, unitIDOrParams)
  if type(unitIDOrParams) == "table" then
    local params = unitIDOrParams
    local rawUnitID = params.UnitID or params.unitID
    if rawUnitID == nil then
      return -1, "player_operation"
    end

    local unitID = ToInt(rawUnitID)
    local rawOwnerID = params.OwnerID or params.ownerID
    if rawOwnerID ~= nil and ToInt(rawOwnerID) ~= playerID then
      Log("event owner mismatch: eventPlayerID=" .. tostring(playerID) .. ", paramOwnerID=" .. tostring(rawOwnerID))
    end
    return unitID, "player_operation"
  end

  return ToInt(unitIDOrParams), "unit_command"
end

local function Localize(tag, ...)
  if Locale ~= nil and Locale.Lookup ~= nil then
    return Locale.Lookup(tag, ...)
  end
  return tostring(tag)
end

local function GetRemainingStageActorCharges(pUnit)
  if pUnit == nil then
    return 0
  end

  local charges = pUnit:GetProperty(PROPERTY_UNIT_STAGE_ACTOR_CHARGES)
  if charges == nil then
    return STAGE_ACTOR_MAX_CHARGES
  end

  return math.max(0, ToInt(charges))
end

local function GetWarriorModeFaithRewardAmount(defeatedPlayerID, defeatedUnitID)
  local pDefeatedPlayer = Players[defeatedPlayerID]
  if pDefeatedPlayer ~= nil then
    local pUnits = pDefeatedPlayer:GetUnits()
    if pUnits ~= nil then
      local pDefeatedUnit = pUnits:FindID(defeatedUnitID)
      if pDefeatedUnit ~= nil then
        CacheUnitBaseCost(defeatedPlayerID, defeatedUnitID, pDefeatedUnit)
      end
    end
  end

  local unitCost = GetCachedUnitBaseCost(defeatedPlayerID, defeatedUnitID)
  if unitCost <= 0 then
    return 0
  end

  return math.max(0, math.floor(unitCost * WARRIOR_MODE_FAITH_REWARD_RATIO))
end

local function ResolveOwningCityFromDistrict(ownerID, pDistrict)
  if pDistrict == nil then
    return nil
  end

  local pPlayer = Players[ownerID]
  if pPlayer == nil then
    return nil
  end

  local districtType = pDistrict:GetType()
  local districtX = pDistrict:GetX()
  local districtY = pDistrict:GetY()
  if districtType == nil or districtType < 0 or districtX == nil or districtY == nil then
    return nil
  end

  local pCities = pPlayer:GetCities()
  if pCities == nil then
    return nil
  end

  for _, pCity in pCities:Members() do
    local pCityDistricts = pCity:GetDistricts()
    if pCityDistricts ~= nil and pCityDistricts:HasDistrict(districtType) then
      local cityDistrictX, cityDistrictY = pCityDistricts:GetDistrictLocation(districtType)
      if cityDistrictX == districtX and cityDistrictY == districtY then
        return pCity
      end
    end
  end

  return nil
end

local function IsActorOnOwnedLalalaiDistrict(pUnit)
  if pUnit == nil then
    return false, nil, nil, nil
  end
  if UNIT_STAGE_ACTOR_INDEX < 0 or pUnit:GetType() ~= UNIT_STAGE_ACTOR_INDEX then
    return false, nil, nil, nil
  end

  local x = pUnit:GetX()
  local y = pUnit:GetY()
  local pPlot = Map.GetPlot(x, y)
  if pPlot == nil then
    return false, nil, nil, nil
  end

  local pDistrict = CityManager.GetDistrictAt(x, y)
  if pDistrict == nil or DISTRICT_LALALAI_INDEX < 0 or pDistrict:GetType() ~= DISTRICT_LALALAI_INDEX then
    return false, nil, nil, nil
  end

  local ownerID = pUnit:GetOwner()
  local plotOwnerID = pPlot:GetOwner()
  if plotOwnerID ~= ownerID then
    return false, nil, nil, nil
  end

  if pDistrict:GetOwner() ~= ownerID then
    return false, nil, nil, nil
  end

  local pCity = ResolveOwningCityFromDistrict(ownerID, pDistrict)
  if pCity == nil or pCity:GetOwner() ~= ownerID then
    Log("abort: district city resolution failed ownerID=" .. tostring(ownerID) .. ", districtType=" .. tostring(pDistrict:GetType()) .. ", plot=" .. tostring(x) .. "," .. tostring(y))
    return false, nil, nil, nil
  end

  return true, pCity, pDistrict, pPlot
end

local function AttachCityModifierStack(pCity, modifierID, count)
  if pCity == nil or pCity.AttachModifierByID == nil or count <= 0 then
    return 0
  end

  for _ = 1, count do
    pCity:AttachModifierByID(modifierID)
  end

  return count
end

local function GetCityDistrictByType(pCity, districtTypeIndex)
  if pCity == nil or districtTypeIndex == nil or districtTypeIndex < 0 then
    return nil
  end

  local pDistricts = pCity:GetDistricts()
  if pDistricts == nil or not pDistricts:HasDistrict(districtTypeIndex) then
    return nil
  end

  local districtX, districtY = pDistricts:GetDistrictLocation(districtTypeIndex)
  if districtX == nil or districtY == nil then
    return nil
  end

  return CityManager.GetDistrictAt(districtX, districtY)
end

local function GetDistrictAdjacencyHalfSteps(pDistrict, yieldIndex)
  if pDistrict == nil or yieldIndex == nil or yieldIndex < 0 or pDistrict.GetAdjacencyYield == nil then
    return 0
  end

  local adjacencyYield = tonumber(pDistrict:GetAdjacencyYield(yieldIndex)) or 0
  return math.max(0, math.floor((adjacencyYield * 2) + 0.001))
end

local function AreDistrictsAdjacent(pDistrictA, pDistrictB)
  if pDistrictA == nil or pDistrictB == nil then
    return false
  end

  local ax, ay = pDistrictA:GetX(), pDistrictA:GetY()
  local bx, by = pDistrictB:GetX(), pDistrictB:GetY()
  if ax == nil or ay == nil or bx == nil or by == nil then
    return false
  end

  for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
    local adjacentPlot = Map.GetAdjacentPlot(ax, ay, direction)
    if adjacentPlot ~= nil and adjacentPlot:GetX() == bx and adjacentPlot:GetY() == by then
      return true
    end
  end

  return false
end

local function ReconcileCityModifierHalfSteps(pCity, propertyKey, desiredHalfSteps, positiveModifierID, negativeModifierID)
  if pCity == nil then
    return
  end

  local currentHalfSteps = ToInt(pCity:GetProperty(propertyKey))
  if currentHalfSteps < desiredHalfSteps then
    AttachCityModifierStack(pCity, positiveModifierID, desiredHalfSteps - currentHalfSteps)
  elseif currentHalfSteps > desiredHalfSteps then
    AttachCityModifierStack(pCity, negativeModifierID, currentHalfSteps - desiredHalfSteps)
  end

  if currentHalfSteps ~= desiredHalfSteps then
    pCity:SetProperty(propertyKey, desiredHalfSteps)
  end
end

local function ApplyStageAdjacencyDoublingForCity(pCity)
  if pCity == nil or ToInt(pCity:GetProperty(PROPERTY_CITY_STAGE_PERFORMED)) < 1 then
    return
  end

  local pLalalaiDistrict = GetCityDistrictByType(pCity, DISTRICT_LALALAI_INDEX)
  if pLalalaiDistrict == nil then
    return
  end

  ReconcileCityModifierHalfSteps(
    pCity,
    PROPERTY_CITY_STAGE_LALALAI_CULTURE_STACKS,
    GetDistrictAdjacencyHalfSteps(pLalalaiDistrict, YIELD_CULTURE_INDEX),
    MODIFIER_CITY_STAGE_LALALAI_CULTURE_BONUS,
    MODIFIER_CITY_STAGE_LALALAI_CULTURE_BONUS_NEGATIVE
  )

  ReconcileCityModifierHalfSteps(
    pCity,
    PROPERTY_CITY_STAGE_LALALAI_GOLD_STACKS,
    GetDistrictAdjacencyHalfSteps(pLalalaiDistrict, YIELD_GOLD_INDEX),
    MODIFIER_CITY_STAGE_LALALAI_GOLD_BONUS,
    MODIFIER_CITY_STAGE_LALALAI_GOLD_BONUS_NEGATIVE
  )

  local pCampusDistrict = GetCityDistrictByType(pCity, DISTRICT_CAMPUS_INDEX)
  local campusHalfSteps = 0
  if AreDistrictsAdjacent(pLalalaiDistrict, pCampusDistrict) then
    campusHalfSteps = GetDistrictAdjacencyHalfSteps(pCampusDistrict, YIELD_SCIENCE_INDEX)
  end
  ReconcileCityModifierHalfSteps(pCity, PROPERTY_CITY_STAGE_CAMPUS_BONUS_APPLIED, campusHalfSteps, MODIFIER_CITY_STAGE_CAMPUS_DOUBLE_ADJACENCY, MODIFIER_CITY_STAGE_CAMPUS_DOUBLE_ADJACENCY_NEGATIVE)

  local pCommercialDistrict = GetCityDistrictByType(pCity, DISTRICT_COMMERCIAL_HUB_INDEX)
  local commercialHalfSteps = 0
  if AreDistrictsAdjacent(pLalalaiDistrict, pCommercialDistrict) then
    commercialHalfSteps = GetDistrictAdjacencyHalfSteps(pCommercialDistrict, YIELD_GOLD_INDEX)
  end
  ReconcileCityModifierHalfSteps(pCity, PROPERTY_CITY_STAGE_COMMERCIAL_BONUS_APPLIED, commercialHalfSteps, MODIFIER_CITY_STAGE_COMMERCIAL_DOUBLE_ADJACENCY, MODIFIER_CITY_STAGE_COMMERCIAL_DOUBLE_ADJACENCY_NEGATIVE)

  local pHarborDistrict = GetCityDistrictByType(pCity, DISTRICT_HARBOR_INDEX)
  local harborHalfSteps = 0
  if AreDistrictsAdjacent(pLalalaiDistrict, pHarborDistrict) then
    harborHalfSteps = GetDistrictAdjacencyHalfSteps(pHarborDistrict, YIELD_GOLD_INDEX)
  end
  ReconcileCityModifierHalfSteps(pCity, PROPERTY_CITY_STAGE_HARBOR_BONUS_APPLIED, harborHalfSteps, MODIFIER_CITY_STAGE_HARBOR_DOUBLE_ADJACENCY, MODIFIER_CITY_STAGE_HARBOR_DOUBLE_ADJACENCY_NEGATIVE)

  local pEntertainmentComplexDistrict = GetCityDistrictByType(pCity, DISTRICT_ENTERTAINMENT_COMPLEX_INDEX)
  local entertainmentComplexHalfSteps = 0
  if AreDistrictsAdjacent(pLalalaiDistrict, pEntertainmentComplexDistrict) then
    entertainmentComplexHalfSteps = GetDistrictAdjacencyHalfSteps(pEntertainmentComplexDistrict, YIELD_PRODUCTION_INDEX)
  end
  ReconcileCityModifierHalfSteps(pCity, PROPERTY_CITY_STAGE_ENTERTAINMENT_COMPLEX_BONUS_APPLIED, entertainmentComplexHalfSteps, MODIFIER_CITY_STAGE_ENTERTAINMENT_COMPLEX_DOUBLE_ADJACENCY, MODIFIER_CITY_STAGE_ENTERTAINMENT_COMPLEX_DOUBLE_ADJACENCY_NEGATIVE)

  local pWaterParkDistrict = GetCityDistrictByType(pCity, DISTRICT_WATER_PARK_INDEX)
  local waterParkHalfSteps = 0
  if AreDistrictsAdjacent(pLalalaiDistrict, pWaterParkDistrict) then
    waterParkHalfSteps = GetDistrictAdjacencyHalfSteps(pWaterParkDistrict, YIELD_PRODUCTION_INDEX)
  end
  ReconcileCityModifierHalfSteps(pCity, PROPERTY_CITY_STAGE_WATER_PARK_BONUS_APPLIED, waterParkHalfSteps, MODIFIER_CITY_STAGE_WATER_PARK_DOUBLE_ADJACENCY, MODIFIER_CITY_STAGE_WATER_PARK_DOUBLE_ADJACENCY_NEGATIVE)

  local pEncampmentDistrict = GetCityDistrictByType(pCity, DISTRICT_ENCAMPMENT_INDEX)
  local encampmentHalfSteps = 0
  if AreDistrictsAdjacent(pLalalaiDistrict, pEncampmentDistrict) then
    encampmentHalfSteps = GetDistrictAdjacencyHalfSteps(pEncampmentDistrict, YIELD_PRODUCTION_INDEX)
  end
  ReconcileCityModifierHalfSteps(pCity, PROPERTY_CITY_STAGE_ENCAMPMENT_BONUS_APPLIED, encampmentHalfSteps, MODIFIER_CITY_STAGE_ENCAMPMENT_DOUBLE_ADJACENCY, MODIFIER_CITY_STAGE_ENCAMPMENT_DOUBLE_ADJACENCY_NEGATIVE)

  local pIndustrialZoneDistrict = GetCityDistrictByType(pCity, DISTRICT_INDUSTRIAL_ZONE_INDEX)
  local industrialZoneHalfSteps = 0
  if AreDistrictsAdjacent(pLalalaiDistrict, pIndustrialZoneDistrict) then
    industrialZoneHalfSteps = GetDistrictAdjacencyHalfSteps(pIndustrialZoneDistrict, YIELD_PRODUCTION_INDEX)
  end
  ReconcileCityModifierHalfSteps(pCity, PROPERTY_CITY_STAGE_INDUSTRIAL_ZONE_BONUS_APPLIED, industrialZoneHalfSteps, MODIFIER_CITY_STAGE_INDUSTRIAL_ZONE_DOUBLE_ADJACENCY, MODIFIER_CITY_STAGE_INDUSTRIAL_ZONE_DOUBLE_ADJACENCY_NEGATIVE)

  local pHolySiteDistrict = GetCityDistrictByType(pCity, DISTRICT_HOLY_SITE_INDEX)
  local holySiteHalfSteps = 0
  if AreDistrictsAdjacent(pLalalaiDistrict, pHolySiteDistrict) then
    holySiteHalfSteps = GetDistrictAdjacencyHalfSteps(pHolySiteDistrict, YIELD_FAITH_INDEX)
  end
  ReconcileCityModifierHalfSteps(pCity, PROPERTY_CITY_STAGE_HOLY_SITE_BONUS_APPLIED, holySiteHalfSteps, MODIFIER_CITY_STAGE_HOLY_SITE_DOUBLE_ADJACENCY, MODIFIER_CITY_STAGE_HOLY_SITE_DOUBLE_ADJACENCY_NEGATIVE)
end

local function AttachStageRewardModifiers(pCity)
  if pCity == nil then
    return false
  end

  if pCity.AttachModifierByID == nil then
    Log("abort: city modifier attach API unavailable cityID=" .. tostring(pCity:GetID()))
    return false
  end

  for _, modifierID in ipairs(STAGE_REWARD_MODIFIERS) do
    pCity:AttachModifierByID(modifierID)
  end

  ApplyStageAdjacencyDoublingForCity(pCity)

  Log("attached stage reward modifiers cityID=" .. tostring(pCity:GetID()) .. ", modifierCount=" .. tostring(#STAGE_REWARD_MODIFIERS))
  return true
end

local function AttachModifierStacksToPlayer(pPlayer, modifierIDs, stackCount)
  if pPlayer == nil or stackCount <= 0 then
    return 0
  end
  if pPlayer.AttachModifierByID == nil then
    Log("abort: player modifier attach API unavailable playerID=" .. tostring(pPlayer:GetID()))
    return 0
  end

  local attachCount = 0
  for _ = 1, stackCount do
    for _, modifierID in ipairs(modifierIDs) do
      pPlayer:AttachModifierByID(modifierID)
      attachCount = attachCount + 1
    end
  end
  return attachCount
end

local function GrantRandomActorModeEureka(playerID, unitID)
  local pPlayer = Players[playerID]
  if pPlayer == nil or not pPlayer:IsAlive() or not IsAkanePlayer(playerID) then
    return
  end
  if GetCurrentMode(pPlayer) ~= MODE_ACTOR then
    return
  end

  local pTechs = pPlayer:GetTechs()
  if pTechs == nil or pTechs.TriggerBoost == nil or pTechs.HasTech == nil or pTechs.HasBoostBeenTriggered == nil or pTechs.CanResearch == nil then
    Log("actor eureka skipped: player tech API unavailable playerID=" .. tostring(playerID))
    return
  end

  local eligibleTechs = {}
  for tech in GameInfo.Technologies() do
    local techIndex = tech.Index
    local canTrigger = true
    if pTechs.CanTriggerBoost ~= nil then
      canTrigger = pTechs:CanTriggerBoost(techIndex)
    end

    if pTechs:CanResearch(techIndex) and not pTechs:HasTech(techIndex) and not pTechs:HasBoostBeenTriggered(techIndex) and canTrigger then
      table.insert(eligibleTechs, tech)
    end
  end

  if #eligibleTechs == 0 then
    Log("actor eureka skipped: no currently researchable techs playerID=" .. tostring(playerID))
    return
  end

  local randomIndex = Game.GetRandNum(#eligibleTechs, "Akane Actor Mode Random Eureka") + 1
  local tech = eligibleTechs[randomIndex]
  pTechs:TriggerBoost(tech.Index)

  local x, y = GetWorldTextLocationForUnitOrPlayer(pPlayer, unitID)
  if x ~= nil and y ~= nil then
    Game.AddWorldViewText(
      playerID,
      Localize("LOC_AKANE_MODE_ACTOR_EUREKA_WORLD_TEXT", Locale.Lookup(tech.Name)),
      x,
      y,
      0
    )
  end

  Log("actor eureka granted playerID=" .. tostring(playerID) .. ", tech=" .. tostring(tech.TechnologyType))
end

local function AreCivicPrereqsSatisfied(pCulture, civicType)
  if pCulture == nil or civicType == nil then
    return false
  end

  local hasAnyPrereq = false
  for prereq in GameInfo.CivicPrereqs() do
    if prereq.Civic == civicType then
      hasAnyPrereq = true
      local prereqCivic = GameInfo.Civics[prereq.PrereqCivic]
      if prereqCivic == nil or not pCulture:HasCivic(prereqCivic.Index) then
        return false
      end
    end
  end

  return hasAnyPrereq or civicType == "CIVIC_CODE_OF_LAWS"
end

local function GrantRandomAiModeInspiration(playerID, unitID)
  local pPlayer = Players[playerID]
  if pPlayer == nil or not pPlayer:IsAlive() or not IsAkanePlayer(playerID) then
    return
  end
  if GetCurrentMode(pPlayer) ~= MODE_AI then
    return
  end

  local pCulture = pPlayer:GetCulture()
  if pCulture == nil or pCulture.TriggerBoost == nil or pCulture.HasCivic == nil or pCulture.HasBoostBeenTriggered == nil then
    Log("ai inspiration skipped: player culture API unavailable playerID=" .. tostring(playerID))
    return
  end

  local eligibleCivics = {}
  for civic in GameInfo.Civics() do
    local civicIndex = civic.Index
    local canTrigger = true
    if pCulture.CanTriggerBoost ~= nil then
      canTrigger = pCulture:CanTriggerBoost(civicIndex)
    end

    if not pCulture:HasCivic(civicIndex)
      and not pCulture:HasBoostBeenTriggered(civicIndex)
      and AreCivicPrereqsSatisfied(pCulture, civic.CivicType)
      and canTrigger then
      table.insert(eligibleCivics, civic)
    end
  end

  if #eligibleCivics == 0 then
    Log("ai inspiration skipped: no currently progressable civics playerID=" .. tostring(playerID))
    return
  end

  local randomIndex = Game.GetRandNum(#eligibleCivics, "Akane Ai Mode Random Inspiration") + 1
  local civic = eligibleCivics[randomIndex]
  pCulture:TriggerBoost(civic.Index)

  local x, y = GetWorldTextLocationForUnitOrPlayer(pPlayer, unitID)
  if x ~= nil and y ~= nil then
    Game.AddWorldViewText(
      playerID,
      Localize("LOC_AKANE_MODE_AI_INSPIRATION_WORLD_TEXT", Locale.Lookup(civic.Name)),
      x,
      y,
      0
    )
  end

  Log("ai inspiration granted playerID=" .. tostring(playerID) .. ", civic=" .. tostring(civic.CivicType))
end

local function GetFaithBalance(pPlayer)
  if pPlayer == nil then
    return 0
  end

  local pReligion = pPlayer:GetReligion()
  if pReligion == nil or pReligion.GetFaithBalance == nil then
    return 0
  end

  return ToInt(pReligion:GetFaithBalance())
end

local function SyncFaithBalanceSnapshot(pPlayer)
  if pPlayer == nil then
    return
  end

  pPlayer:SetProperty(PROPERTY_PLAYER_LAST_FAITH_BALANCE, GetFaithBalance(pPlayer))
end

local function ClearPendingAiPurchase(pPlayer)
  if pPlayer == nil then
    return
  end

  pPlayer:SetProperty(PROPERTY_PLAYER_PENDING_AI_PURCHASE, nil)
  pPlayer:SetProperty(PROPERTY_PLAYER_LAST_FAITH_SPEND, 0)
  pPlayer:SetProperty(PROPERTY_PLAYER_LAST_FAITH_SPEND_TURN, -1)
end

local function TryResolveAiModeFaithPurchaseRefund(playerID)
  local pPlayer = Players[playerID]
  if pPlayer == nil or not pPlayer:IsAlive() or not IsAkanePlayer(playerID) then
    return false
  end
  if GetCurrentMode(pPlayer) ~= MODE_AI then
    ClearPendingAiPurchase(pPlayer)
    return false
  end

  local pendingPurchase = pPlayer:GetProperty(PROPERTY_PLAYER_PENDING_AI_PURCHASE)
  if pendingPurchase == nil then
    return false
  end

  local lastFaithSpendTurn = ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_LAST_FAITH_SPEND_TURN))
  local lastFaithSpend = ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_LAST_FAITH_SPEND))
  if lastFaithSpend <= 0 or lastFaithSpendTurn ~= GetCurrentTurnNumber() then
    return false
  end

  local refundAmount = math.floor(lastFaithSpend * 0.8)
  if refundAmount > 0 then
    local pTreasury = pPlayer:GetTreasury()
    if pTreasury ~= nil and pTreasury.ChangeGoldBalance ~= nil then
      pTreasury:ChangeGoldBalance(refundAmount)
    end

    local textX = pendingPurchase.x
    local textY = pendingPurchase.y
    if textX ~= nil and textY ~= nil then
      Game.AddWorldViewText(
        playerID,
        Localize("LOC_AKANE_MODE_AI_FAITH_REFUND_WORLD_TEXT", refundAmount),
        textX,
        textY,
        0
      )
    end

    Log("ai faith purchase refund granted playerID=" .. tostring(playerID) .. ", spentFaith=" .. tostring(lastFaithSpend) .. ", refundGold=" .. tostring(refundAmount))
  end

  ClearPendingAiPurchase(pPlayer)
  SyncFaithBalanceSnapshot(pPlayer)
  return refundAmount > 0
end

local function TryGrantWarriorModeFaithReward(defeatedPlayerID, defeatedUnitID, attackerPlayerID, attackerUnitID)
  local pAttackerPlayer = Players[attackerPlayerID]
  if pAttackerPlayer == nil or not pAttackerPlayer:IsAlive() or not IsAkanePlayer(attackerPlayerID) then
    ClearCachedUnitBaseCost(defeatedPlayerID, defeatedUnitID)
    return false
  end
  if defeatedPlayerID == attackerPlayerID then
    ClearCachedUnitBaseCost(defeatedPlayerID, defeatedUnitID)
    return false
  end
  if GetCurrentMode(pAttackerPlayer) ~= MODE_WARRIOR then
    ClearCachedUnitBaseCost(defeatedPlayerID, defeatedUnitID)
    return false
  end

  local rewardKey = table.concat({
    tostring(GetCurrentTurnNumber()),
    tostring(defeatedPlayerID),
    tostring(defeatedUnitID),
    tostring(attackerPlayerID),
    tostring(attackerUnitID)
  }, ":")
  if g_lastWarriorFaithRewardKey == rewardKey then
    return false
  end

  local rewardFaith = GetWarriorModeFaithRewardAmount(defeatedPlayerID, defeatedUnitID)
  ClearCachedUnitBaseCost(defeatedPlayerID, defeatedUnitID)
  if rewardFaith <= 0 then
    return false
  end

  local pReligion = pAttackerPlayer:GetReligion()
  if pReligion == nil or pReligion.ChangeFaithBalance == nil then
    Log("warrior faith reward skipped: religion API unavailable playerID=" .. tostring(attackerPlayerID))
    return false
  end

  g_lastWarriorFaithRewardKey = rewardKey
  pReligion:ChangeFaithBalance(rewardFaith)

  local textX, textY = GetWorldTextLocationForUnitOrPlayer(pAttackerPlayer, attackerUnitID)
  if textX ~= nil and textY ~= nil then
    Game.AddWorldViewText(
      attackerPlayerID,
      Localize("LOC_AKANE_MODE_WARRIOR_FAITH_REWARD_WORLD_TEXT", rewardFaith),
      textX,
      textY,
      0
    )
  end

  Log("warrior faith reward granted attackerPlayerID=" .. tostring(attackerPlayerID) .. ", defeatedPlayerID=" .. tostring(defeatedPlayerID) .. ", defeatedUnitID=" .. tostring(defeatedUnitID) .. ", rewardFaith=" .. tostring(rewardFaith))
  return true
end

local function UpdateArtProsperityWorldText(pPlayer, pSourceCity, stacks, turns, textTag)
  local pCity = pSourceCity or GetPlayerAnchorCity(pPlayer)
  if pCity == nil then
    return
  end

  Game.AddWorldViewText(
    pPlayer ~= nil and pPlayer:GetID() or 0,
    Localize(textTag, stacks, turns),
    pCity:GetX(),
    pCity:GetY(),
    0
  )
end

local function ApplyArtProsperityStackModifiers(pPlayer, stackCount)
  local attached = AttachModifierStacksToPlayer(pPlayer, ART_PROSPERITY_MODIFIERS_POSITIVE, stackCount)
  if attached > 0 then
    Log("art prosperity positive modifiers attached playerID=" .. tostring(pPlayer:GetID()) .. ", stackCount=" .. tostring(stackCount) .. ", modifierAttachCount=" .. tostring(attached))
  end
  return attached
end

local function ApplyArtProsperityNegativeStacks(pPlayer, stackCount)
  local attached = AttachModifierStacksToPlayer(pPlayer, ART_PROSPERITY_MODIFIERS_NEGATIVE, stackCount)
  if attached > 0 then
    Log("art prosperity negative modifiers attached playerID=" .. tostring(pPlayer:GetID()) .. ", stackCount=" .. tostring(stackCount) .. ", modifierAttachCount=" .. tostring(attached))
  end
  return attached
end

local function ReconcileArtProsperityForPlayer(pPlayer)
  if pPlayer == nil then
    return
  end

  local stacks = ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_ART_STACKS))
  local clearedStacks = ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_ART_CLEARED_STACKS))
  local positiveAppliedStacks = ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_ART_APPLIED_STACKS))
  local negativeAppliedStacks = ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_ART_NEG_APPLIED_STACKS))

  local desiredPositiveStacks = math.max(0, stacks + clearedStacks)
  if positiveAppliedStacks < desiredPositiveStacks then
    local missing = desiredPositiveStacks - positiveAppliedStacks
    ApplyArtProsperityStackModifiers(pPlayer, missing)
    positiveAppliedStacks = desiredPositiveStacks
    pPlayer:SetProperty(PROPERTY_PLAYER_ART_APPLIED_STACKS, positiveAppliedStacks)
  end

  local desiredNegativeStacks = math.max(0, clearedStacks)
  if negativeAppliedStacks < desiredNegativeStacks then
    local missing = desiredNegativeStacks - negativeAppliedStacks
    ApplyArtProsperityNegativeStacks(pPlayer, missing)
    negativeAppliedStacks = desiredNegativeStacks
    pPlayer:SetProperty(PROPERTY_PLAYER_ART_NEG_APPLIED_STACKS, negativeAppliedStacks)
  end
end

local function ExpireArtProsperityForPlayer(pPlayer)
  if pPlayer == nil then
    return
  end

  local stacks = ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_ART_STACKS))
  if stacks <= 0 then
    pPlayer:SetProperty(PROPERTY_PLAYER_ART_TURNS, 0)
    return
  end

  local clearedStacks = ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_ART_CLEARED_STACKS)) + stacks
  local negativeAppliedStacks = ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_ART_NEG_APPLIED_STACKS)) + stacks
  ApplyArtProsperityNegativeStacks(pPlayer, stacks)

  pPlayer:SetProperty(PROPERTY_PLAYER_ART_STACKS, 0)
  pPlayer:SetProperty(PROPERTY_PLAYER_ART_TURNS, 0)
  pPlayer:SetProperty(PROPERTY_PLAYER_ART_CLEARED_STACKS, clearedStacks)
  pPlayer:SetProperty(PROPERTY_PLAYER_ART_NEG_APPLIED_STACKS, negativeAppliedStacks)

  Log("art prosperity expired playerID=" .. tostring(pPlayer:GetID()) .. ", expiredStacks=" .. tostring(stacks))
  UpdateArtProsperityWorldText(pPlayer, nil, 0, 0, "LOC_AKANE_ART_PROSPERITY_EXPIRED")
end

local function GrantArtProsperityFromPerformance(pPlayer, pSourceCity)
  if pPlayer == nil then
    return 0, 0
  end

  local currentStacks = ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_ART_STACKS))
  local currentTurns = ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_ART_TURNS))
  local turnExtension = GetArtProsperityTurnExtensionForCurrentGameSpeed()
  local maxTurns = GetArtProsperityTurnCapForCurrentGameSpeed()

  local newStacks = currentStacks + 1
  local newTurns = math.min(maxTurns, currentTurns + turnExtension)
  pPlayer:SetProperty(PROPERTY_PLAYER_ART_STACKS, newStacks)
  pPlayer:SetProperty(PROPERTY_PLAYER_ART_TURNS, newTurns)

  ReconcileArtProsperityForPlayer(pPlayer)
  UpdateArtProsperityWorldText(pPlayer, pSourceCity, newStacks, newTurns, "LOC_AKANE_ART_PROSPERITY_APPLIED")
  return newStacks, newTurns
end

local function GetArtProsperityState(pPlayer)
  if pPlayer == nil then
    return 0, 0
  end

  return ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_ART_STACKS)), ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_ART_TURNS))
end

local function RestoreStageLegacyCultureModifiers()
  local aliveMajors = PlayerManager.GetAliveMajors()
  local restoredCount = 0
  if aliveMajors == nil then
    Log("restore skipped: no alive majors available")
    return
  end

  for _, pPlayer in ipairs(aliveMajors) do
    local pCities = pPlayer:GetCities()
    if pCities ~= nil then
      for _, pCity in pCities:Members() do
        if ToInt(pCity:GetProperty(PROPERTY_CITY_STAGE_PERFORMED)) >= 1 then
          if AttachStageRewardModifiers(pCity) then
            restoredCount = restoredCount + 1
          end
        end
      end
    end
  end

  Log("restore complete: cityCount=" .. tostring(restoredCount))
end

local function RestoreArtProsperityModifiers()
  local aliveMajors = PlayerManager.GetAliveMajors()
  if aliveMajors == nil then
    Log("art prosperity restore skipped: no alive majors available")
    return
  end

  local restoredPlayerCount = 0
  for _, pPlayer in ipairs(aliveMajors) do
    local stacks = ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_ART_STACKS))
    local turns = ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_ART_TURNS))
    local hasHistory = ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_ART_CLEARED_STACKS)) > 0 or ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_ART_APPLIED_STACKS)) > 0
    if stacks > 0 or turns > 0 or hasHistory then
      ReconcileArtProsperityForPlayer(pPlayer)
      restoredPlayerCount = restoredPlayerCount + 1
    end
  end

  Log("art prosperity restore complete: playerCount=" .. tostring(restoredPlayerCount))
end

function OnPlayerTurnStarted(playerID, _turnNumber)
  local pPlayer = Players[playerID]
  if pPlayer == nil or not pPlayer:IsAlive() then
    return
  end

  SyncFaithBalanceSnapshot(pPlayer)
  RefreshPlayerUnitCostCache(playerID)

  local pCities = pPlayer:GetCities()
  if pCities ~= nil then
    for _, pCity in pCities:Members() do
      ApplyStageAdjacencyDoublingForCity(pCity)
    end
  end

  local stacks = ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_ART_STACKS))
  local turns = ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_ART_TURNS))

  if stacks > 0 then
    ReconcileArtProsperityForPlayer(pPlayer)

    local nextTurns = turns - 1
    pPlayer:SetProperty(PROPERTY_PLAYER_ART_TURNS, nextTurns)
    if nextTurns <= 0 then
      ExpireArtProsperityForPlayer(pPlayer)
    end
  elseif turns ~= 0 then
    pPlayer:SetProperty(PROPERTY_PLAYER_ART_TURNS, 0)
  end
end

function OnUnitKilledInCombat(defeatedPlayerID, defeatedUnitID, attackerPlayerID, attackerUnitID, ...)
  TryGrantWarriorModeFaithReward(
    ToInt(defeatedPlayerID),
    ToInt(defeatedUnitID),
    ToInt(attackerPlayerID),
    ToInt(attackerUnitID)
  )
end

function OnUnitGreatPersonActivated(playerID, unitID, _greatPersonClass, _greatPersonType)
  GrantRandomActorModeEureka(playerID, unitID)
end

function OnUnitGreatPersonCreated(playerID, unitID, _greatPersonClass, _greatPersonType)
  GrantRandomAiModeInspiration(playerID, unitID)
end

function OnFaithChanged(playerID, _yield, balance)
  local pPlayer = Players[playerID]
  if pPlayer == nil or not pPlayer:IsAlive() then
    return
  end

  local previousBalance = ToInt(pPlayer:GetProperty(PROPERTY_PLAYER_LAST_FAITH_BALANCE))
  local currentBalance = ToInt(balance)
  if currentBalance < previousBalance then
    pPlayer:SetProperty(PROPERTY_PLAYER_LAST_FAITH_SPEND, previousBalance - currentBalance)
    pPlayer:SetProperty(PROPERTY_PLAYER_LAST_FAITH_SPEND_TURN, GetCurrentTurnNumber())
  end
  pPlayer:SetProperty(PROPERTY_PLAYER_LAST_FAITH_BALANCE, currentBalance)

  TryResolveAiModeFaithPurchaseRefund(playerID)
end

function OnCityMadePurchase(playerID, cityID, iX, iY, purchaseType, objectType)
  local pPlayer = Players[playerID]
  if pPlayer == nil or not pPlayer:IsAlive() or not IsAkanePlayer(playerID) then
    return
  end
  if GetCurrentMode(pPlayer) ~= MODE_AI then
    ClearPendingAiPurchase(pPlayer)
    return
  end

  if purchaseType ~= EventSubTypes.UNIT and purchaseType ~= EventSubTypes.BUILDING then
    return
  end

  pPlayer:SetProperty(PROPERTY_PLAYER_PENDING_AI_PURCHASE, {
    cityID = cityID,
    objectType = objectType,
    purchaseType = purchaseType,
    turn = GetCurrentTurnNumber(),
    x = iX,
    y = iY
  })

  TryResolveAiModeFaithPurchaseRefund(playerID)
end

function OnDistrictAddedToMap(playerID, _districtID, cityID, _iX, _iY, _districtType, _percentComplete)
  local pPlayer = Players[playerID]
  if pPlayer == nil or not pPlayer:IsAlive() then
    return
  end

  local pCity = pPlayer:GetCities():FindID(cityID)
  if pCity == nil then
    return
  end

  ApplyStageAdjacencyDoublingForCity(pCity)
end

function OnWonderCompleted(iX, iY, _buildingIndex, playerIndex, cityID, _iPercentComplete, _iUnknown)
  local pPlayer = Players[playerIndex]
  if pPlayer == nil or not pPlayer:IsAlive() then
    return
  end

  local pCity = pPlayer:GetCities():FindID(cityID)
  if pCity ~= nil then
    ApplyStageAdjacencyDoublingForCity(pCity)
    return
  end

  local pPlot = Map.GetPlot(iX, iY)
  if pPlot == nil then
    return
  end

  local fallbackCity = Cities.GetPlotWorkingCity(pPlot:GetIndex())
  if fallbackCity ~= nil then
    ApplyStageAdjacencyDoublingForCity(fallbackCity)
  end
end

function AKANE_STAGE_ACTOR_PERFORM(playerID, unitIDOrParams)
  local unitID, requestSource = ResolveStagePerformUnitID(playerID, unitIDOrParams)
  Log("event received: source=" .. tostring(requestSource) .. ", playerID=" .. tostring(playerID) .. ", unitID=" .. tostring(unitID))

  if unitID < 0 then
    Log("abort: invalid unitID from request source=" .. tostring(requestSource))
    return
  end

  local pPlayer = Players[playerID]
  if pPlayer == nil then
    Log("abort: player not found")
    return
  end

  local pUnit = pPlayer:GetUnits():FindID(unitID)
  if pUnit == nil then
    Log("abort: unit not found")
    return
  end

  local isValid, pCity, pDistrict = IsActorOnOwnedLalalaiDistrict(pUnit)
  if not isValid or pCity == nil or pDistrict == nil then
    Log("abort: unit is not on owned LALALAI district")
    return
  end

  if ToInt(pCity:GetProperty(PROPERTY_CITY_STAGE_PERFORMED)) >= 1 then
    Log("abort: city already performed cityID=" .. tostring(pCity:GetID()))
    return
  end

  local remainingCharges = GetRemainingStageActorCharges(pUnit)
  if remainingCharges <= 0 then
    Log("abort: unit has no charges remaining unitID=" .. tostring(unitID))
    return
  end

  remainingCharges = remainingCharges - 1
  pUnit:SetProperty(PROPERTY_UNIT_STAGE_ACTOR_CHARGES, remainingCharges)
  pCity:SetProperty(PROPERTY_CITY_STAGE_PERFORMED, 1)
  local artStacks, artTurns = GrantArtProsperityFromPerformance(pPlayer, pCity)
  AttachStageRewardModifiers(pCity)

  Game.AddWorldViewText(
    0,
    Localize("LOC_AKANE_STAGE_ACTOR_PERFORM_WORLD_TEXT", remainingCharges, artStacks, artTurns),
    pUnit:GetX(),
    pUnit:GetY(),
    0
  )

  Log("success: cityID=" .. tostring(pCity:GetID()) .. ", districtID=" .. tostring(pDistrict:GetID()) .. ", unitID=" .. tostring(unitID) .. ", remainingCharges=" .. tostring(remainingCharges) .. ", artStacks=" .. tostring(artStacks) .. ", artTurns=" .. tostring(artTurns))
  if remainingCharges <= 0 then
    UnitManager.Kill(pUnit)
  end
end

RestoreStageLegacyCultureModifiers()
RestoreArtProsperityModifiers()
RefreshAllUnitCostCaches()
for _, pPlayer in ipairs(PlayerManager.GetAliveMajors() or {}) do
  SyncFaithBalanceSnapshot(pPlayer)
end
GameEvents[AKANE_EVENT_STAGE_PERFORM].Add(AKANE_STAGE_ACTOR_PERFORM)
GameEvents.PlayerTurnStarted.Add(OnPlayerTurnStarted)
if Events ~= nil and Events.DistrictAddedToMap ~= nil then
  Events.DistrictAddedToMap.Add(OnDistrictAddedToMap)
end
if Events ~= nil and Events.WonderCompleted ~= nil then
  Events.WonderCompleted.Add(OnWonderCompleted)
end
if Events ~= nil and Events.FaithChanged ~= nil then
  Events.FaithChanged.Add(OnFaithChanged)
end
if Events ~= nil and Events.CityMadePurchase ~= nil then
  Events.CityMadePurchase.Add(OnCityMadePurchase)
end
if Events ~= nil and Events.UnitGreatPersonActivated ~= nil then
  Events.UnitGreatPersonActivated.Add(OnUnitGreatPersonActivated)
elseif GameEvents ~= nil and GameEvents.UnitGreatPersonActivated ~= nil then
  GameEvents.UnitGreatPersonActivated.Add(OnUnitGreatPersonActivated)
elseif GameEvents ~= nil and GameEvents.OnGreatPersonActivated ~= nil then
  GameEvents.OnGreatPersonActivated.Add(OnUnitGreatPersonActivated)
end
if Events ~= nil and Events.UnitGreatPersonCreated ~= nil then
  Events.UnitGreatPersonCreated.Add(OnUnitGreatPersonCreated)
end
if Events ~= nil and Events.UnitKilledInCombat ~= nil then
  Events.UnitKilledInCombat.Add(OnUnitKilledInCombat)
end
if GameEvents ~= nil and GameEvents.UnitKilledInCombat ~= nil then
  GameEvents.UnitKilledInCombat.Add(OnUnitKilledInCombat)
end
