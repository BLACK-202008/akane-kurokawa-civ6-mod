print("[Akane Task5 UI] Akane_UnitPanel.lua shared injection loaded");

local BASE_GetUnitActionsTable = GetUnitActionsTable;
local BASE_GetCombatModifierList = GetCombatModifierList;

local AKANE_EVENT_STAGE_PERFORM = "AKANE_STAGE_ACTOR_PERFORM";
local AKANE_UNIT_STAGE_ACTOR = "UNIT_STAGE_ACTOR";
local AKANE_DISTRICT_LALALAI = "DISTRICT_LALALAI_TROUPE";
local AKANE_LOG_PREFIX = "[Akane Task5 UI]";
local AKANE_MODE_WARRIOR = "MODE_WARRIOR";

local PROPERTY_CITY_STAGE_PERFORMED = "AKANE_CITY_STAGE_PERFORMED";
local PROPERTY_PLAYER_MODE_CURRENT = "AKANE_MODE_CURRENT";
local PROPERTY_UNIT_STAGE_ACTOR_CHARGES = "AKANE_STAGE_ACTOR_CHARGES";
local STAGE_ACTOR_MAX_CHARGES = 3;

local UNIT_STAGE_ACTOR_INDEX = GameInfo.Units[AKANE_UNIT_STAGE_ACTOR] and GameInfo.Units[AKANE_UNIT_STAGE_ACTOR].Index or -1;
local DISTRICT_LALALAI_INDEX = GameInfo.Districts[AKANE_DISTRICT_LALALAI] and GameInfo.Districts[AKANE_DISTRICT_LALALAI].Index or -1;

local function Log(message)
  print(AKANE_LOG_PREFIX .. " " .. tostring(message));
end

Log("shared injection ready: stageActorIndex=" .. tostring(UNIT_STAGE_ACTOR_INDEX) .. ", lalalaiIndex=" .. tostring(DISTRICT_LALALAI_INDEX));

local function DescribeUnit(pUnit)
  if pUnit == nil then
    return "unit=nil";
  end

  return "owner=" .. tostring(pUnit:GetOwner())
    .. ", unitID=" .. tostring(pUnit:GetID())
    .. ", type=" .. tostring(pUnit:GetType())
    .. ", plot=" .. tostring(pUnit:GetX()) .. "," .. tostring(pUnit:GetY());
end

local function ToInt(v)
  if v == nil then
    return 0;
  end
  return tonumber(v) or 0;
end

local function GetRemainingStageActorCharges(pUnit)
  if pUnit == nil then
    return 0;
  end

  local charges = pUnit:GetProperty(PROPERTY_UNIT_STAGE_ACTOR_CHARGES);
  if charges == nil then
    return STAGE_ACTOR_MAX_CHARGES;
  end

  return math.max(0, ToInt(charges));
end

local function ResolveOwningCityFromDistrict(ownerID, pDistrict, districtX, districtY)
  if pDistrict == nil then
    return nil;
  end

  if pDistrict.GetCity ~= nil then
    local pDistrictCity = pDistrict:GetCity();
    if pDistrictCity ~= nil and pDistrictCity:GetOwner() == ownerID then
      return pDistrictCity;
    end
  end

  local pPlayer = Players[ownerID];
  if pPlayer == nil then
    return nil;
  end

  local districtType = pDistrict:GetType();
  if districtX == nil or districtY == nil then
    if pDistrict.GetX ~= nil and pDistrict.GetY ~= nil then
      districtX = pDistrict:GetX();
      districtY = pDistrict:GetY();
    end
  end
  if districtType == nil or districtType < 0 or districtX == nil or districtY == nil then
    return nil;
  end

  local pCities = pPlayer:GetCities();
  if pCities == nil then
    return nil;
  end

  for _, pCity in pCities:Members() do
    local pCityDistricts = pCity:GetDistricts();
    if pCityDistricts ~= nil and pCityDistricts:HasDistrict(districtType) then
      local cityDistrictX, cityDistrictY = pCityDistricts:GetDistrictLocation(districtType);
      if cityDistrictX == districtX and cityDistrictY == districtY then
        return pCity;
      end
    end
  end

  return nil;
end

local function CanShowStagePerformAction(pUnit)
  if pUnit == nil then
    return false, "unit=nil";
  end

  local localPlayerID = Game.GetLocalPlayer();
  if localPlayerID == -1 then
    return false, "local player unavailable";
  end

  if pUnit:GetOwner() ~= localPlayerID then
    return false, "not local player unit";
  end

  if UNIT_STAGE_ACTOR_INDEX < 0 or pUnit:GetType() ~= UNIT_STAGE_ACTOR_INDEX then
    return false, "not stage actor";
  end

  local x = pUnit:GetX();
  local y = pUnit:GetY();
  local pPlot = Map.GetPlot(x, y);
  if pPlot == nil then
    return false, "plot=nil";
  end

  local pDistrict = CityManager.GetDistrictAt(x, y);
  if pDistrict == nil or DISTRICT_LALALAI_INDEX < 0 or pDistrict:GetType() ~= DISTRICT_LALALAI_INDEX then
    return false, "not on owned LALALAI district";
  end

  if pPlot:GetOwner() ~= localPlayerID then
    return false, "plot not owned by local player";
  end

  if pDistrict:GetOwner() ~= localPlayerID then
    return false, "district not owned by local player";
  end

  if GetRemainingStageActorCharges(pUnit) <= 0 then
    return false, "unit has no charges";
  end

  local pCity = ResolveOwningCityFromDistrict(localPlayerID, pDistrict, x, y);
  if pCity == nil then
    return false, "city resolution failed";
  end

  if ToInt(pCity:GetProperty(PROPERTY_CITY_STAGE_PERFORMED)) >= 1 then
    return false, "city already performed cityID=" .. tostring(pCity:GetID());
  end

  return true, "visibility passed, cityID=" .. tostring(pCity:GetID()) .. ", districtID=" .. tostring(pDistrict:GetID()) .. ", plot=" .. tostring(x) .. "," .. tostring(y);
end

local function GetStagePerformTooltip(pUnit)
  return Locale.Lookup("LOC_AKANE_STAGE_ACTOR_PERFORM_TOOLTIP", GetRemainingStageActorCharges(pUnit));
end

local function ResolveStagePerformTargetUnit(actionOwnerID, actionUnitID)
  local resolvedUnit = nil;
  local actionOwner = Players[actionOwnerID];
  if actionOwner ~= nil then
    resolvedUnit = actionOwner:GetUnits():FindID(actionUnitID);
  end

  if resolvedUnit ~= nil then
    return resolvedUnit, "callback args";
  end

  resolvedUnit = UI.GetHeadSelectedUnit();
  if resolvedUnit ~= nil then
    return resolvedUnit, "selected unit fallback";
  end

  return nil, "no target unit";
end

function GetUnitActionsTable(pUnit)
  local actionsTable = BASE_GetUnitActionsTable(pUnit);
  if pUnit == nil or actionsTable == nil then
    return actionsTable;
  end

  local canShow, reason = CanShowStagePerformAction(pUnit);
  if not canShow then
    if Game.GetLocalPlayer() ~= -1 and pUnit:GetOwner() == Game.GetLocalPlayer() and pUnit:GetType() == UNIT_STAGE_ACTOR_INDEX then
      Log("hide stage action: " .. tostring(reason));
    end
    return actionsTable;
  end

  Log("show stage action: " .. tostring(reason));

  local actionDef = {
    CategoryInUI = "SPECIFIC",
    Icon = "ICON_UNITOPERATION_MUSICIAN_ACTION",
    ToolTipString = GetStagePerformTooltip(pUnit)
  };

  local callback = function(actionOwnerID, actionUnitID)
    local pSelectedUnit = UI.GetHeadSelectedUnit();
    Log("stage perform callback entered: actionOwnerID=" .. tostring(actionOwnerID)
      .. ", actionUnitID=" .. tostring(actionUnitID)
      .. ", selected=" .. DescribeUnit(pSelectedUnit));

    local pTargetUnit, resolveSource = ResolveStagePerformTargetUnit(actionOwnerID, actionUnitID);
    if pTargetUnit == nil then
      Log("abort request: target unit unavailable source=" .. tostring(resolveSource));
      return;
    end

    local commandParameters = {};
    commandParameters[UnitCommandTypes.PARAM_NAME] = AKANE_EVENT_STAGE_PERFORM;
    Log("dispatching stage perform via UnitCommand source=" .. tostring(resolveSource)
      .. ", target=" .. DescribeUnit(pTargetUnit));
    UnitManager.RequestCommand(pTargetUnit, UnitCommandTypes.EXECUTE_SCRIPT, commandParameters);
  end;

  AddActionToTable(
    actionsTable,
    actionDef,
    false,
    GetStagePerformTooltip(pUnit),
    UnitCommandTypes.EXECUTE_SCRIPT,
    callback,
    pUnit:GetOwner(),
    pUnit:GetID()
  );

  return actionsTable;
end

local function IsWarriorModeCombatSourceUnit(pUnit)
  if pUnit == nil then
    return false;
  end

  local pPlayer = Players[pUnit:GetOwner()];
  if pPlayer == nil then
    return false;
  end

  if pPlayer:GetProperty(PROPERTY_PLAYER_MODE_CURRENT) ~= AKANE_MODE_WARRIOR then
    return false;
  end

  local combatStrength = 0;
  if pUnit.GetCombat ~= nil then
    combatStrength = math.max(combatStrength, ToInt(pUnit:GetCombat()));
  end
  if pUnit.GetRangedCombat ~= nil then
    combatStrength = math.max(combatStrength, ToInt(pUnit:GetRangedCombat()));
  end

  return combatStrength > 0;
end

local function ResolveCombatSourceUnit(...)
  local args = { ... };
  for _, value in ipairs(args) do
    if type(value) == "table" and value.GetOwner ~= nil then
      return value;
    end
  end

  return UI.GetHeadSelectedUnit();
end

function GetCombatModifierList(...)
  local combatantHash = select(1, ...);
  local modifiers = {};
  local modifierListSize = 0;
  if BASE_GetCombatModifierList ~= nil then
    modifiers, modifierListSize = BASE_GetCombatModifierList(...);
    modifiers = modifiers or {};
    modifierListSize = ToInt(modifierListSize);
  end

  local pUnit = ResolveCombatSourceUnit(...);
  if not IsWarriorModeCombatSourceUnit(pUnit) then
    return modifiers, modifierListSize;
  end

  if combatantHash ~= CombatResultParameters.ATTACKER then
    return modifiers, modifierListSize;
  end

  if AddModifierToList ~= nil then
    modifiers, modifierListSize = AddModifierToList(
      modifiers,
      modifierListSize,
      Locale.Lookup("LOC_AKANE_MODE_WARRIOR_COMBAT_SOURCE"),
      "ICON_STRENGTH"
    );
  end

  return modifiers, modifierListSize;
end
