print("[Akane Task7 UI] Akane_TopPanel.lua loaded")

local AKANE_UI_LOG_PREFIX = "[Akane Task7 UI]"
local g_pendingMode = nil
local g_pendingElapsed = 0
local g_pendingRefreshElapsed = 0

local function ClearPendingRequest()
  g_pendingMode = nil
  ContextPtr:ClearUpdate()
end

local function Log(message)
  print(AKANE_UI_LOG_PREFIX .. " " .. tostring(message))
end

local function GetModeAPI()
  if ExposedMembers == nil then
    return nil
  end
  return ExposedMembers.AkaneModeSystem
end

local function GetLocalModeState()
  local localPlayerID = Game.GetLocalPlayer()
  if localPlayerID == -1 then
    return nil
  end

  local api = GetModeAPI()
  if api == nil or api.GetModeState == nil then
    return nil
  end

  local state = api.GetModeState(localPlayerID)
  state.localPlayerID = localPlayerID
  return state
end

local function AttachPanelToWorldTracker()
  local topPanelRoot = ContextPtr:LookUpControl("/InGame/TopPanel")
  if topPanelRoot ~= nil then
    Controls.AkaneModePanelRoot:ChangeParent(topPanelRoot)
    topPanelRoot:AddChild(Controls.AkaneModePanelRoot)
    topPanelRoot:CalculateSize()
    topPanelRoot:ReprocessAnchoring()
    Log("attached mode panel to TopPanel")
    return
  end

  local worldTrackerPanel = ContextPtr:LookUpControl("/InGame/WorldTracker/PanelStack")
  if worldTrackerPanel ~= nil then
    Controls.AkaneModePanelRoot:ChangeParent(worldTrackerPanel)
    worldTrackerPanel:AddChildAtIndex(Controls.AkaneModePanelRoot, 1)
    worldTrackerPanel:CalculateSize()
    worldTrackerPanel:ReprocessAnchoring()
    Log("attached mode panel to WorldTracker fallback")
  end
end

local function RefreshModePanel()
  local state = GetLocalModeState()
  local api = GetModeAPI()
  if state == nil or api == nil or not state.isAkanePlayer or not state.isHuman then
    ClearPendingRequest()
    Controls.AkaneModePanelRoot:SetHide(true)
    return
  end

  Controls.AkaneModePanelRoot:SetHide(false)
  if g_pendingMode ~= nil and state.currentMode == g_pendingMode then
    ClearPendingRequest()
  end

  local modeKey = "LOC_AKANE_MODE_NONE_NAME"
  if state.currentMode == api.MODE_AI then
    modeKey = "LOC_AKANE_MODE_AI_NAME"
  elseif state.currentMode == api.MODE_ACTOR then
    modeKey = "LOC_AKANE_MODE_ACTOR_NAME"
  elseif state.currentMode == api.MODE_WARRIOR then
    modeKey = "LOC_AKANE_MODE_WARRIOR_NAME"
  end

  Controls.ModeCurrentValue:SetText(Locale.Lookup(modeKey))
  if state.cooldownRemaining > 0 then
    Controls.ModeCooldownValue:SetText(Locale.Lookup("LOC_AKANE_MODE_COOLDOWN_TURNS", state.cooldownRemaining))
  else
    Controls.ModeCooldownValue:SetText(Locale.Lookup("LOC_AKANE_MODE_READY"))
  end

  local unavailable = not state.isTurnActive or g_pendingMode ~= nil or state.cooldownRemaining > 0
  Controls.ModeAIButton:SetDisabled(state.currentMode == api.MODE_AI or unavailable)
  Controls.ModeActorButton:SetDisabled(state.currentMode == api.MODE_ACTOR or unavailable)
  Controls.ModeWarriorButton:SetDisabled(state.currentMode == api.MODE_WARRIOR or unavailable)
end

local function OnPendingRequestUpdate(deltaTime)
  local elapsed = tonumber(deltaTime) or 0
  g_pendingElapsed = g_pendingElapsed + elapsed
  g_pendingRefreshElapsed = g_pendingRefreshElapsed + elapsed
  if g_pendingElapsed >= 10 then
    ClearPendingRequest()
    RefreshModePanel()
  elseif g_pendingRefreshElapsed >= 0.1 then
    g_pendingRefreshElapsed = 0
    RefreshModePanel()
  end
end

local function RequestSwitch(mode)
  local state = GetLocalModeState()
  local api = GetModeAPI()
  if state == nil or api == nil or not state.isAkanePlayer or not state.isHuman
    or not state.isTurnActive or state.cooldownRemaining > 0
    or state.currentMode == mode or g_pendingMode ~= nil then
    return
  end

  g_pendingMode = mode
  g_pendingElapsed = 0
  g_pendingRefreshElapsed = 0
  UI.RequestPlayerOperation(state.localPlayerID, PlayerOperations.EXECUTE_SCRIPT, {
    OnStart = "AKANE_MODE_SWITCH",
    mode = mode
  })
  -- A player operation completes asynchronously. Read its resulting state for up
  -- to ten seconds, then remove this update callback even if it was rejected.
  ContextPtr:SetUpdate(OnPendingRequestUpdate)
  RefreshModePanel()
end

local function InitializeControls()
  local api = GetModeAPI()
  if api == nil then
    return
  end

  Controls.ModeAIButton:RegisterCallback(Mouse.eLClick, function()
    RequestSwitch(api.MODE_AI)
  end)
  Controls.ModeActorButton:RegisterCallback(Mouse.eLClick, function()
    RequestSwitch(api.MODE_ACTOR)
  end)
  Controls.ModeWarriorButton:RegisterCallback(Mouse.eLClick, function()
    RequestSwitch(api.MODE_WARRIOR)
  end)
end

local function OnLoadGameViewStateDone()
  InitializeControls()
  AttachPanelToWorldTracker()
  RefreshModePanel()
end

local function OnLocalPlayerChanged()
  ClearPendingRequest()
  RefreshModePanel()
end

local function OnLocalPlayerTurnBegin()
  RefreshModePanel()
end

InitializeControls()
Events.LoadGameViewStateDone.Add(OnLoadGameViewStateDone)
Events.LocalPlayerChanged.Add(OnLocalPlayerChanged)
Events.LocalPlayerTurnBegin.Add(OnLocalPlayerTurnBegin)
if Events.LocalPlayerTurnEnd ~= nil then
  Events.LocalPlayerTurnEnd.Add(RefreshModePanel)
end
if Events.PlayerOperationComplete ~= nil then
  Events.PlayerOperationComplete.Add(RefreshModePanel)
end
