print("[Akane Task7 Mode] Akane_ModeSystem.lua loaded")

local AKANE_LOG_PREFIX = "[Akane Task7 Mode]"
local AKANE_LEADER_TYPE = "LEADER_KUROKAWA_AKANE"

local PROPERTY_MODE_CURRENT = "AKANE_MODE_CURRENT"
local PROPERTY_MODE_LAST_SWITCH_TURN = "AKANE_MODE_LAST_SWITCH_TURN"
local PROPERTY_MODE_LAST_READY_ALERT_SWITCH_TURN = "AKANE_MODE_LAST_READY_ALERT_SWITCH_TURN"
local PROPERTY_MODE_LEDGER_VERSION = "AKANE_MODE_LEDGER_VERSION"
local PROPERTY_MODE_APPLIED_CURRENT = "AKANE_MODE_APPLIED_CURRENT"
local PROPERTY_MODE_BUFF_APPLIED_SWITCH_TURN = "AKANE_MODE_BUFF_APPLIED_SWITCH_TURN"
local PROPERTY_MODE_BUFF_CLEARED_SWITCH_TURN = "AKANE_MODE_BUFF_CLEARED_SWITCH_TURN"
local AKANE_EVENT_MODE_SWITCH = "AKANE_MODE_SWITCH"

local MODE_NONE = "MODE_NONE"
local MODE_AI = "MODE_AI"
local MODE_ACTOR = "MODE_ACTOR"
local MODE_WARRIOR = "MODE_WARRIOR"

local MODE_LABEL_KEYS = {
  [MODE_NONE] = "LOC_AKANE_MODE_NONE_NAME",
  [MODE_AI] = "LOC_AKANE_MODE_AI_NAME",
  [MODE_ACTOR] = "LOC_AKANE_MODE_ACTOR_NAME",
  [MODE_WARRIOR] = "LOC_AKANE_MODE_WARRIOR_NAME"
}

local MODE_POSITIVE_MODIFIERS = {
  [MODE_AI] = {
    "AKANE_MODE_AI_FAITH_FLAT",
    "AKANE_MODE_AI_PROPHET_POINTS",
    "AKANE_MODE_AI_PROPHET_POINTS_PER_HOLY_SITE",
    "AKANE_MODE_AI_FAITH_PERCENT",
    "AKANE_MODE_AI_RELIGIOUS_STRENGTH"
  },
  [MODE_ACTOR] = {
    "AKANE_MODE_ACTOR_CULTURE_FLAT",
    "AKANE_MODE_ACTOR_ARTIST_POINTS",
    "AKANE_MODE_ACTOR_ARTIST_POINTS_FLAT",
    "AKANE_MODE_ACTOR_WRITER_POINTS",
    "AKANE_MODE_ACTOR_WRITER_POINTS_FLAT",
    "AKANE_MODE_ACTOR_MUSICIAN_POINTS",
    "AKANE_MODE_ACTOR_MUSICIAN_POINTS_FLAT",
    "AKANE_MODE_ACTOR_CULTURE_PERCENT",
    "AKANE_MODE_ACTOR_TOURISM_PERCENT"
  },
  [MODE_WARRIOR] = {
    "AKANE_MODE_WARRIOR_COMBAT",
    "AKANE_MODE_WARRIOR_MOVEMENT",
    "AKANE_MODE_WARRIOR_PRODUCTION_FLAT",
    "AKANE_MODE_WARRIOR_GENERAL_POINTS",
    "AKANE_MODE_WARRIOR_GENERAL_POINTS_PER_ENCAMPMENT",
    "AKANE_MODE_WARRIOR_ENCAMPMENT_PRODUCTION"
  }
}

local MODE_NEGATIVE_MODIFIERS = {
  [MODE_AI] = {
    "AKANE_MODE_AI_FAITH_FLAT_NEGATIVE",
    "AKANE_MODE_AI_PROPHET_POINTS_NEGATIVE",
    "AKANE_MODE_AI_PROPHET_POINTS_PER_HOLY_SITE_NEGATIVE",
    "AKANE_MODE_AI_FAITH_PERCENT_NEGATIVE",
    "AKANE_MODE_AI_RELIGIOUS_STRENGTH_NEGATIVE"
  },
  [MODE_ACTOR] = {
    "AKANE_MODE_ACTOR_CULTURE_FLAT_NEGATIVE",
    "AKANE_MODE_ACTOR_ARTIST_POINTS_NEGATIVE",
    "AKANE_MODE_ACTOR_ARTIST_POINTS_FLAT_NEGATIVE",
    "AKANE_MODE_ACTOR_WRITER_POINTS_NEGATIVE",
    "AKANE_MODE_ACTOR_WRITER_POINTS_FLAT_NEGATIVE",
    "AKANE_MODE_ACTOR_MUSICIAN_POINTS_NEGATIVE",
    "AKANE_MODE_ACTOR_MUSICIAN_POINTS_FLAT_NEGATIVE",
    "AKANE_MODE_ACTOR_CULTURE_PERCENT_NEGATIVE",
    "AKANE_MODE_ACTOR_TOURISM_PERCENT_NEGATIVE"
  },
  [MODE_WARRIOR] = {
    "AKANE_MODE_WARRIOR_COMBAT_NEGATIVE",
    "AKANE_MODE_WARRIOR_MOVEMENT_NEGATIVE",
    "AKANE_MODE_WARRIOR_PRODUCTION_FLAT_NEGATIVE",
    "AKANE_MODE_WARRIOR_GENERAL_POINTS_NEGATIVE",
    "AKANE_MODE_WARRIOR_GENERAL_POINTS_PER_ENCAMPMENT_NEGATIVE",
    "AKANE_MODE_WARRIOR_ENCAMPMENT_PRODUCTION_NEGATIVE"
  }
}

local MODE_SWITCH_BUFF_POSITIVE_MODIFIERS = {
  "AKANE_MODE_SWITCH_BUFF_FOOD",
  "AKANE_MODE_SWITCH_BUFF_PRODUCTION",
  "AKANE_MODE_SWITCH_BUFF_GOLD",
  "AKANE_MODE_SWITCH_BUFF_SCIENCE",
  "AKANE_MODE_SWITCH_BUFF_CULTURE",
  "AKANE_MODE_SWITCH_BUFF_FAITH"
}

local MODE_SWITCH_BUFF_NEGATIVE_MODIFIERS = {
  "AKANE_MODE_SWITCH_BUFF_FOOD_NEGATIVE",
  "AKANE_MODE_SWITCH_BUFF_PRODUCTION_NEGATIVE",
  "AKANE_MODE_SWITCH_BUFF_GOLD_NEGATIVE",
  "AKANE_MODE_SWITCH_BUFF_SCIENCE_NEGATIVE",
  "AKANE_MODE_SWITCH_BUFF_CULTURE_NEGATIVE",
  "AKANE_MODE_SWITCH_BUFF_FAITH_NEGATIVE"
}

local function Log(message)
  print(AKANE_LOG_PREFIX .. " " .. tostring(message))
end

local function ToInt(value)
  if value == nil then
    return 0
  end
  return tonumber(value) or 0
end

local function IsSupportedMode(mode)
  return mode == MODE_NONE or mode == MODE_AI or mode == MODE_ACTOR or mode == MODE_WARRIOR
end

local function IsAkanePlayer(playerID)
  local playerConfig = PlayerConfigurations[playerID]
  if playerConfig == nil then
    return false
  end
  return playerConfig:GetLeaderTypeName() == AKANE_LEADER_TYPE
end

local function GetModeCooldownForCurrentGameSpeed()
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

local function GetModeLabelKey(mode)
  return MODE_LABEL_KEYS[mode] or MODE_LABEL_KEYS[MODE_NONE]
end

local function GetCurrentMode(pPlayer)
  if pPlayer == nil then
    return MODE_NONE
  end

  local currentMode = pPlayer:GetProperty(PROPERTY_MODE_CURRENT)
  if not IsSupportedMode(currentMode) then
    return MODE_NONE
  end
  return currentMode
end

local function AttachModifierBundle(pPlayer, modifierIDs)
  if pPlayer == nil or pPlayer.AttachModifierByID == nil or modifierIDs == nil then
    return 0
  end

  local count = 0
  for _, modifierID in ipairs(modifierIDs) do
    pPlayer:AttachModifierByID(modifierID)
    count = count + 1
  end
  return count
end

local function GetAnchorCity(pPlayer)
  if pPlayer == nil then
    return nil
  end

  local pCities = pPlayer:GetCities()
  if pCities == nil then
    return nil
  end

  local capital = pCities:GetCapitalCity()
  if capital ~= nil then
    return capital
  end

  for _, pCity in pCities:Members() do
    return pCity
  end

  return nil
end

local function ShowModeTextForPlayer(playerID, textTag, ...)
  local pPlayer = Players[playerID]
  local pCity = GetAnchorCity(pPlayer)
  if pCity == nil then
    return
  end

  Game.AddWorldViewText(
    playerID,
    Locale.Lookup(textTag, ...),
    pCity:GetX(),
    pCity:GetY(),
    0
  )
end

local function ShowModeReadyText(playerID)
  local pPlayer = Players[playerID]
  if pPlayer == nil or not pPlayer:IsHuman() then
    return
  end
  ShowModeTextForPlayer(playerID, "LOC_AKANE_MODE_READY_ALERT")
end

local function GetSwitchBuffDurationFromCooldown(cooldownTurns)
  return math.max(0, math.floor(ToInt(cooldownTurns) / 2))
end

local function GetSwitchBuffDuration()
  return GetSwitchBuffDurationFromCooldown(GetModeCooldownForCurrentGameSpeed())
end

local function GetCurrentTurnNumber()
  return math.max(0, Game.GetCurrentGameTurn())
end

local function IsSwitchBuffActive(pPlayer)
  if pPlayer == nil then
    return false
  end

  local lastSwitchTurn = ToInt(pPlayer:GetProperty(PROPERTY_MODE_LAST_SWITCH_TURN))
  if lastSwitchTurn < 0 then
    return false
  end

  return math.max(0, Game.GetCurrentGameTurn() - lastSwitchTurn) < GetSwitchBuffDuration()
end

local function ApplyMode(mode, pPlayer)
  AttachModifierBundle(pPlayer, MODE_POSITIVE_MODIFIERS[mode])
end

local function RevertMode(mode, pPlayer)
  AttachModifierBundle(pPlayer, MODE_NEGATIVE_MODIFIERS[mode])
end

local function ApplySwitchBuff(pPlayer)
  AttachModifierBundle(pPlayer, MODE_SWITCH_BUFF_POSITIVE_MODIFIERS)
end

local function RevertSwitchBuff(pPlayer)
  AttachModifierBundle(pPlayer, MODE_SWITCH_BUFF_NEGATIVE_MODIFIERS)
end

local function GetLastSwitchTurn(pPlayer)
  if pPlayer == nil then
    return -1
  end
  return ToInt(pPlayer:GetProperty(PROPERTY_MODE_LAST_SWITCH_TURN))
end

local function GetCooldownRemainingBySchedule(pPlayer, currentTurn)
  local lastSwitchTurn = GetLastSwitchTurn(pPlayer)
  if lastSwitchTurn < 0 then
    return 0
  end

  local turnNow = currentTurn
  if turnNow == nil then
    turnNow = Game.GetCurrentGameTurn()
  end

  return math.max(0, (lastSwitchTurn + GetModeCooldownForCurrentGameSpeed()) - turnNow)
end

local function EnsureModeLedger(pPlayer)
  if ToInt(pPlayer:GetProperty(PROPERTY_MODE_LEDGER_VERSION)) >= 1 then
    return
  end

  -- AttachModifierByID effects and player properties survive save/load. Older
  -- saves already have the recorded current mode attached: adopt it, never replay
  -- it. An expired legacy buff is conservatively treated as already cleared.
  -- The old script did not record attachment counts, so pre-existing duplicate
  -- effects cannot be reconstructed or safely removed by this migration.
  local currentMode = GetCurrentMode(pPlayer)
  local lastSwitchTurn = GetLastSwitchTurn(pPlayer)
  pPlayer:SetProperty(PROPERTY_MODE_APPLIED_CURRENT, currentMode)
  pPlayer:SetProperty(PROPERTY_MODE_BUFF_APPLIED_SWITCH_TURN, lastSwitchTurn)
  pPlayer:SetProperty(PROPERTY_MODE_BUFF_CLEARED_SWITCH_TURN,
    IsSwitchBuffActive(pPlayer) and -1 or lastSwitchTurn)
  pPlayer:SetProperty(PROPERTY_MODE_LEDGER_VERSION, 1)
  if currentMode ~= MODE_NONE or lastSwitchTurn >= 0 then
    Log("adopted legacy mode effects without replay playerID=" .. tostring(pPlayer:GetID()))
  end
end

local function CleanupExpiredSwitchBuff(playerID, pPlayer)
  local lastSwitchTurn = GetLastSwitchTurn(pPlayer)
  local switchBuffDuration = GetSwitchBuffDuration()
  if lastSwitchTurn < 0 or switchBuffDuration <= 0 then
    return false
  end

  local elapsedTurns = math.max(0, Game.GetCurrentGameTurn() - lastSwitchTurn)
  local appliedTurn = ToInt(pPlayer:GetProperty(PROPERTY_MODE_BUFF_APPLIED_SWITCH_TURN))
  local clearedTurn = ToInt(pPlayer:GetProperty(PROPERTY_MODE_BUFF_CLEARED_SWITCH_TURN))
  if elapsedTurns >= switchBuffDuration and appliedTurn == lastSwitchTurn and clearedTurn ~= lastSwitchTurn then
    RevertSwitchBuff(pPlayer)
    pPlayer:SetProperty(PROPERTY_MODE_BUFF_CLEARED_SWITCH_TURN, lastSwitchTurn)
    Log("switch buff expired playerID=" .. tostring(playerID))
    return true
  end

  return false
end

local function RestoreAkaneModeState()
  local aliveMajors = PlayerManager.GetAliveMajors()
  if aliveMajors == nil then
    return
  end

  for _, pPlayer in ipairs(aliveMajors) do
    local playerID = pPlayer:GetID()
    if IsAkanePlayer(playerID) then
      local currentMode = GetCurrentMode(pPlayer)
      pPlayer:SetProperty(PROPERTY_MODE_CURRENT, currentMode)
      if pPlayer:GetProperty(PROPERTY_MODE_LAST_SWITCH_TURN) == nil then
        pPlayer:SetProperty(PROPERTY_MODE_LAST_SWITCH_TURN, -1)
      end
      if pPlayer:GetProperty(PROPERTY_MODE_LAST_READY_ALERT_SWITCH_TURN) == nil then
        pPlayer:SetProperty(PROPERTY_MODE_LAST_READY_ALERT_SWITCH_TURN, -1)
      end
      EnsureModeLedger(pPlayer)
      CleanupExpiredSwitchBuff(playerID, pPlayer)
      Log("restored mode=" .. tostring(currentMode) .. " playerID=" .. tostring(playerID))
    end
  end
end

local function SetAkaneMode(playerID, newMode)
  local pPlayer = Players[playerID]
  if pPlayer == nil or not pPlayer:IsAlive() then
    return false, "LOC_AKANE_MODE_NOT_AVAILABLE"
  end
  if not IsAkanePlayer(playerID) or not pPlayer:IsHuman() then
    return false, "LOC_AKANE_MODE_NOT_AVAILABLE"
  end
  if not pPlayer:IsTurnActive() or pPlayer.AttachModifierByID == nil then
    return false, "LOC_AKANE_MODE_NOT_AVAILABLE"
  end
  if not IsSupportedMode(newMode) or newMode == MODE_NONE then
    return false, "LOC_AKANE_MODE_NOT_AVAILABLE"
  end

  local currentMode = GetCurrentMode(pPlayer)
  local currentTurn = GetCurrentTurnNumber()
  local effectiveCooldownRemaining = GetCooldownRemainingBySchedule(pPlayer, currentTurn)

  if effectiveCooldownRemaining > 0 then
    ShowModeTextForPlayer(playerID, "LOC_AKANE_MODE_COOLDOWN_ACTIVE", effectiveCooldownRemaining)
    return false, "LOC_AKANE_MODE_COOLDOWN_ACTIVE", effectiveCooldownRemaining
  end

  if currentMode == newMode then
    return false, "LOC_AKANE_MODE_ALREADY_ACTIVE", GetModeLabelKey(currentMode)
  end

  EnsureModeLedger(pPlayer)
  CleanupExpiredSwitchBuff(playerID, pPlayer)
  local appliedMode = pPlayer:GetProperty(PROPERTY_MODE_APPLIED_CURRENT)
  if IsSupportedMode(appliedMode) and appliedMode ~= MODE_NONE then
    RevertMode(appliedMode, pPlayer)
  end
  ApplyMode(newMode, pPlayer)
  pPlayer:SetProperty(PROPERTY_MODE_APPLIED_CURRENT, newMode)

  local newCooldown = GetModeCooldownForCurrentGameSpeed()
  local switchBuffDuration = GetSwitchBuffDurationFromCooldown(newCooldown)
  if switchBuffDuration > 0 then
    ApplySwitchBuff(pPlayer)
    pPlayer:SetProperty(PROPERTY_MODE_BUFF_APPLIED_SWITCH_TURN, currentTurn)
  end
  pPlayer:SetProperty(PROPERTY_MODE_CURRENT, newMode)
  local switchTurn = GetCurrentTurnNumber()
  pPlayer:SetProperty(PROPERTY_MODE_LAST_SWITCH_TURN, switchTurn)
  pPlayer:SetProperty(PROPERTY_MODE_LAST_READY_ALERT_SWITCH_TURN, -1)
  ShowModeTextForPlayer(playerID, "LOC_AKANE_MODE_SWITCHED", GetModeLabelKey(newMode), newCooldown, switchBuffDuration)
  Log("mode switched playerID=" .. tostring(playerID) .. ", from=" .. tostring(currentMode) .. ", to=" .. tostring(newMode) .. ", cooldown=" .. tostring(newCooldown) .. ", switchBuffDuration=" .. tostring(switchBuffDuration))
  return true, "LOC_AKANE_MODE_SWITCHED", GetModeLabelKey(newMode), newCooldown, switchBuffDuration
end

local function OnPlayerTurnStarted(playerID, _turnNumber)
  local pPlayer = Players[playerID]
  if pPlayer == nil or not pPlayer:IsAlive() or not IsAkanePlayer(playerID) then
    return
  end

  local currentTurn = Game.GetCurrentGameTurn()
  local lastSwitchTurn = GetLastSwitchTurn(pPlayer)
  local cooldownRemaining = GetCooldownRemainingBySchedule(pPlayer, currentTurn)
  local lastReadyAlertSwitchTurn = ToInt(pPlayer:GetProperty(PROPERTY_MODE_LAST_READY_ALERT_SWITCH_TURN))
  if pPlayer:IsHuman() and cooldownRemaining <= 0 and lastSwitchTurn >= 0 and lastReadyAlertSwitchTurn ~= lastSwitchTurn then
    ShowModeReadyText(playerID)
    pPlayer:SetProperty(PROPERTY_MODE_LAST_READY_ALERT_SWITCH_TURN, lastSwitchTurn)
  end

  local elapsedTurns = math.max(0, currentTurn - lastSwitchTurn)
  local switchBuffDuration = GetSwitchBuffDuration()
  if switchBuffDuration <= 0 or lastSwitchTurn < 0 or elapsedTurns < switchBuffDuration then
    return
  end

  CleanupExpiredSwitchBuff(playerID, pPlayer)
end

local function OnModeSwitchRequested(playerID, params)
  if type(params) ~= "table" or type(params.mode) ~= "string" then
    return false, "LOC_AKANE_MODE_NOT_AVAILABLE"
  end
  -- playerID comes from the synchronized player operation, never from its payload.
  return SetAkaneMode(playerID, params.mode)
end

-- Replace the shared table so a reloaded context cannot retain old mutation APIs.
-- The UI reads state here and sends mutations through EXECUTE_SCRIPT operations.
ExposedMembers.AkaneModeSystem = {}
ExposedMembers.AkaneModeSystem.MODE_NONE = MODE_NONE
ExposedMembers.AkaneModeSystem.MODE_AI = MODE_AI
ExposedMembers.AkaneModeSystem.MODE_ACTOR = MODE_ACTOR
ExposedMembers.AkaneModeSystem.MODE_WARRIOR = MODE_WARRIOR
ExposedMembers.AkaneModeSystem.GetModeCooldownForCurrentGameSpeed = GetModeCooldownForCurrentGameSpeed
ExposedMembers.AkaneModeSystem.GetModeState = function(playerID)
  local pPlayer = Players[playerID]
  if pPlayer == nil then
    return {
      isAkanePlayer = false,
      isHuman = false,
      isTurnActive = false,
      currentMode = MODE_NONE,
      cooldownRemaining = 0
    }
  end

  local effectiveCooldownRemaining = GetCooldownRemainingBySchedule(pPlayer, Game.GetCurrentGameTurn())

  return {
    isAkanePlayer = IsAkanePlayer(playerID),
    isHuman = pPlayer:IsHuman(),
    isTurnActive = pPlayer:IsTurnActive(),
    currentMode = GetCurrentMode(pPlayer),
    cooldownRemaining = effectiveCooldownRemaining
  }
end

RestoreAkaneModeState()
GameEvents[AKANE_EVENT_MODE_SWITCH].Add(OnModeSwitchRequested)
GameEvents.PlayerTurnStarted.Add(OnPlayerTurnStarted)
