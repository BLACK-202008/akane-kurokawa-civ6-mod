print("[Akane Task5 Gameplay] Akane_Gameplay.lua loaded")

local AKANE_EVENT_STAGE_PERFORM = "AKANE_STAGE_ACTOR_PERFORM"
local AKANE_UNIT_STAGE_ACTOR = "UNIT_STAGE_ACTOR"
local AKANE_DISTRICT_LALALAI = "DISTRICT_LALALAI_TROUPE"
local AKANE_LOG_PREFIX = "[Akane Task5 Gameplay]"
local AKANE_LEADER_TYPE = "LEADER_KUROKAWA_AKANE"
local MODIFIER_CITY_STAGE_LEGACY_CULTURE = "AKANE_CITY_STAGE_LEGACY_CULTURE"
local PROPERTY_MODE_CURRENT = "AKANE_MODE_CURRENT"
local MODE_NONE = "MODE_NONE"
local MODE_ACTOR = "MODE_ACTOR"
local STAGE_REWARD_MODIFIERS = {
  MODIFIER_CITY_STAGE_LEGACY_CULTURE,
  "AKANE_CITY_STAGE_AMPHITHEATER_CULTURE",
  "AKANE_CITY_STAGE_ART_MUSEUM_CULTURE",
  "AKANE_CITY_STAGE_ARCHAEOLOGICAL_MUSEUM_CULTURE",
  "AKANE_CITY_STAGE_BROADCAST_CENTER_CULTURE",
  "AKANE_CITY_STAGE_AMPHITHEATER_TOURISM",
  "AKANE_CITY_STAGE_ART_MUSEUM_LANDSCAPE_TOURISM",
  "AKANE_CITY_STAGE_ART_MUSEUM_PORTRAIT_TOURISM",
  "AKANE_CITY_STAGE_ART_MUSEUM_RELIGIOUS_TOURISM",
  "AKANE_CITY_STAGE_ART_MUSEUM_SCULPTURE_TOURISM",
  "AKANE_CITY_STAGE_ARCHAEOLOGICAL_MUSEUM_TOURISM",
  "AKANE_CITY_STAGE_BROADCAST_CENTER_TOURISM"
}
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

local UNIT_STAGE_ACTOR_INDEX = GameInfo.Units[AKANE_UNIT_STAGE_ACTOR] and GameInfo.Units[AKANE_UNIT_STAGE_ACTOR].Index or -1
local DISTRICT_LALALAI_INDEX = GameInfo.Districts[AKANE_DISTRICT_LALALAI] and GameInfo.Districts[AKANE_DISTRICT_LALALAI].Index or -1

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

function OnUnitGreatPersonActivated(playerID, unitID, _greatPersonClass, _greatPersonType)
  GrantRandomActorModeEureka(playerID, unitID)
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
GameEvents[AKANE_EVENT_STAGE_PERFORM].Add(AKANE_STAGE_ACTOR_PERFORM)
GameEvents.PlayerTurnStarted.Add(OnPlayerTurnStarted)
if Events ~= nil and Events.UnitGreatPersonActivated ~= nil then
  Events.UnitGreatPersonActivated.Add(OnUnitGreatPersonActivated)
elseif GameEvents ~= nil and GameEvents.UnitGreatPersonActivated ~= nil then
  GameEvents.UnitGreatPersonActivated.Add(OnUnitGreatPersonActivated)
elseif GameEvents ~= nil and GameEvents.OnGreatPersonActivated ~= nil then
  GameEvents.OnGreatPersonActivated.Add(OnUnitGreatPersonActivated)
end
