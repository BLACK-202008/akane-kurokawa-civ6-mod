local AKANE_LEADER_TYPE = "LEADER_KUROKAWA_AKANE"

local function GetLeaderType(playerID)
  local playerConfig = PlayerConfigurations[playerID]
  if playerConfig == nil then
    return nil
  end

  return playerConfig:GetLeaderTypeName()
end

local function IsAkaneDiplomacy(playerID)
  return playerID ~= nil and playerID >= 0 and GetLeaderType(playerID) == AKANE_LEADER_TYPE
end

local function TryHideBaseLeaderVisuals()
  local leaderAnchor = ContextPtr:LookUpControl("/InGame/DiplomacyActionView/LeaderAnchor")
  if leaderAnchor ~= nil then
    leaderAnchor:SetHide(true)
  end

  local fallbackLeaderImage = ContextPtr:LookUpControl("/InGame/DiplomacyActionView/FallbackLeaderImage")
  if fallbackLeaderImage ~= nil then
    fallbackLeaderImage:SetHide(true)
  end

  UI.SetLeaderPosition(Controls.HiddenLeaderAnchor:GetScreenOffset())
end

local function TryRestoreBaseLeaderVisuals()
  local leaderAnchor = ContextPtr:LookUpControl("/InGame/DiplomacyActionView/LeaderAnchor")
  if leaderAnchor ~= nil then
    leaderAnchor:SetHide(false)
  end

  local fallbackLeaderImage = ContextPtr:LookUpControl("/InGame/DiplomacyActionView/FallbackLeaderImage")
  if fallbackLeaderImage ~= nil then
    fallbackLeaderImage:SetHide(false)
  end
end

local function ShowOverlay(playerID)
  if IsAkaneDiplomacy(playerID) then
    Controls.OverlayRoot:SetHide(false)
    TryHideBaseLeaderVisuals()
  else
    Controls.OverlayRoot:SetHide(true)
    TryRestoreBaseLeaderVisuals()
  end
end

local function HideOverlay()
  Controls.OverlayRoot:SetHide(true)
  TryRestoreBaseLeaderVisuals()
end

local function AttachToDiplomacyView()
  local diplomacyView = ContextPtr:LookUpControl("/InGame/DiplomacyActionView")
  if diplomacyView ~= nil then
    Controls.OverlayRoot:ChangeParent(diplomacyView)
    diplomacyView:AddChildAtIndex(Controls.OverlayRoot, 0)
    diplomacyView:CalculateSize()
    diplomacyView:ReprocessAnchoring()
  end
end

local function OnLoadGameViewStateDone()
  AttachToDiplomacyView()
end

local function OnDiplomacySceneOpened(playerID)
  ShowOverlay(playerID)
end

local function OnDiplomacyLeaderSelect(playerID)
  ShowOverlay(playerID)
end

local function OnDiplomacyCinemaSequence(playerID)
  ShowOverlay(playerID)
end

Events.LoadGameViewStateDone.Add(OnLoadGameViewStateDone)
LuaEvents.DiploScene_SceneOpened.Add(OnDiplomacySceneOpened)
LuaEvents.DiploScene_LeaderSelect.Add(OnDiplomacyLeaderSelect)
LuaEvents.DiploScene_CinemaSequence.Add(OnDiplomacyCinemaSequence)
LuaEvents.DiploScene_SceneClosed.Add(HideOverlay)
