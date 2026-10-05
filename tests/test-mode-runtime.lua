-- Execute the production Lua in isolated contexts while preserving the game-owned
-- properties and attached modifiers across reloads. These API doubles model the
-- persistence boundary; they do not simulate Civ6 networking or yield calculation.
local modeSource = arg[1] or "Scripts/Akane_ModeSystem.lua"
local uiSource = arg[2] or "UI/Akane_TopPanel.lua"
local failures, passed = 0, 0

local function equal(actual, expected, message)
  assert(actual == expected, (message or "unexpected result") ..
    ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end

local function test(name, run)
  local ok, failure = pcall(run)
  if ok then
    passed = passed + 1
    print("PASS " .. name)
  else
    failures = failures + 1
    print("FAIL " .. name .. ": " .. tostring(failure))
  end
end

local function fixture(speed)
  local f = {
    turn = 100, properties = {}, attachments = {}, handlers = {},
    alive = true, human = true, active = true,
    leader = "LEADER_KUROKAWA_AKANE", operations = {}, controls = {}
  }
  local player = {}
  function player:GetID() return 0 end
  function player:IsAlive() return f.alive end
  function player:IsHuman() return f.human end
  function player:IsTurnActive() return f.active end
  function player:GetProperty(key) return f.properties[key] end
  function player:SetProperty(key, value) f.properties[key] = value end
  function player:AttachModifierByID(id)
    f.attachments[id] = (f.attachments[id] or 0) + 1
  end
  function player:GetCities()
    return {
      GetCapitalCity = function() return nil end,
      Members = function() return function() return nil end end
    }
  end
  local function event(name)
    return { Add = function(callback) f.handlers[name] = callback end }
  end
  local function control()
    return {
      SetHide = function(self, value) self.hidden = value end,
      SetText = function(self, value) self.text = value end,
      SetDisabled = function(self, value) self.disabled = value end,
      RegisterCallback = function(self, _, callback) self.callback = callback end
    }
  end
  for _, name in ipairs({ "AkaneModePanelRoot", "ModeCurrentValue", "ModeCooldownValue",
    "ModeAIButton", "ModeActorButton", "ModeWarriorButton" }) do
    f.controls[name] = control()
  end
  f.env = setmetatable({
    print = function() end,
    Players = { [0] = player },
    PlayerConfigurations = { [0] = { GetLeaderTypeName = function() return f.leader end } },
    PlayerManager = { GetAliveMajors = function() return { player } end },
    GameInfo = { GameSpeeds = { TEST = { GameSpeedType = speed or "GAMESPEED_STANDARD" } } },
    GameConfiguration = { GetGameSpeedType = function() return "TEST" end },
    Game = { GetCurrentGameTurn = function() return f.turn end, GetLocalPlayer = function() return 0 end },
    Locale = { Lookup = function(key) return key end },
    ExposedMembers = {},
    Events = {
      LoadGameViewStateDone = event("loaded"), LocalPlayerChanged = event("localChanged"),
      LocalPlayerTurnBegin = event("localTurn"), LocalPlayerTurnEnd = event("localTurnEnd"),
      PlayerOperationComplete = event("operationComplete")
    },
    Controls = f.controls, Mouse = { eLClick = 1 },
    PlayerOperations = { EXECUTE_SCRIPT = 77 },
    UI = { RequestPlayerOperation = function(playerID, operation, params)
      table.insert(f.operations, { playerID = playerID, operation = operation, params = params })
    end },
    ContextPtr = {
      LookUpControl = function() return nil end,
      SetUpdate = function(_, callback) f.update = callback end,
      ClearUpdate = function() f.update = nil end
    }
  }, { __index = _G })
  function f:reload()
    self.env.GameEvents = {
      PlayerTurnStarted = event("turn"), AKANE_MODE_SWITCH = event("switch")
    }
    self.handlers.switch = nil
    assert(loadfile(modeSource, "t", self.env))()
  end
  function f:request(mode, playerID)
    -- The compatibility branch lets the reload regressions exercise the old
    -- implementation during RED; the operation-specific test requires the event.
    if self.handlers.switch then return self.handlers.switch(playerID or 0, { mode = mode }) end
    return self.env.ExposedMembers.AkaneModeSystem.RequestModeSwitch(playerID or 0, mode)
  end
  function f:balance(id)
    return (self.attachments[id] or 0) - (self.attachments[id .. "_NEGATIVE"] or 0)
  end
  function f:beginTurn(turn)
    self.turn = turn
    self.handlers.turn(0, turn)
  end
  function f:loadUI()
    assert(loadfile(uiSource, "t", self.env))()
    self.handlers.loaded()
  end
  return f
end

test("first switch applies one mode and one temporary buff", function()
  local f = fixture()
  f:reload()
  equal(f:request("MODE_AI"), true)
  equal(f:balance("AKANE_MODE_AI_FAITH_PERCENT"), 1)
  equal(f:balance("AKANE_MODE_SWITCH_BUFF_FOOD"), 1)
  equal(f.env.ExposedMembers.AkaneModeSystem.GetModeState(0).cooldownRemaining, 10)
end)

test("active save reload preserves exactly one mode and buff", function()
  local f = fixture()
  f:reload(); f:request("MODE_AI"); f.turn = 102; f:reload()
  equal(f:balance("AKANE_MODE_AI_FAITH_PERCENT"), 1, "active mode after reload")
  equal(f:balance("AKANE_MODE_SWITCH_BUFF_FOOD"), 1, "active buff after reload")
end)

test("repeated active reloads never add effects", function()
  local f = fixture()
  f:reload(); f:request("MODE_ACTOR")
  for _ = 1, 3 do f:reload() end
  equal(f:balance("AKANE_MODE_ACTOR_CULTURE_PERCENT"), 1)
  equal(f:balance("AKANE_MODE_SWITCH_BUFF_SCIENCE"), 1)
end)

test("expired save reload never adds another negative buff", function()
  local f = fixture()
  f:reload(); f:request("MODE_AI"); f:beginTurn(105)
  equal(f:balance("AKANE_MODE_SWITCH_BUFF_FOOD"), 0)
  for _ = 1, 3 do f:reload() end
  equal(f:balance("AKANE_MODE_SWITCH_BUFF_FOOD"), 0, "expired buff after reloads")
  equal(f:balance("AKANE_MODE_AI_FAITH_PERCENT"), 1)
end)

test("loading at expiry settles an outstanding buff only once", function()
  local f = fixture()
  f:reload(); f:request("MODE_AI"); f.turn = 105; f:reload()
  equal(f:balance("AKANE_MODE_SWITCH_BUFF_FOOD"), 0)
  f:reload(); f:beginTurn(106)
  equal(f:balance("AKANE_MODE_SWITCH_BUFF_FOOD"), 0)
end)

test("switches cancel old modes after multiple reloads", function()
  local f = fixture()
  f:reload(); f:request("MODE_AI"); f:reload()
  f:beginTurn(105); f:beginTurn(110); equal(f:request("MODE_ACTOR"), true); f:reload()
  equal(f:balance("AKANE_MODE_AI_FAITH_PERCENT"), 0)
  equal(f:balance("AKANE_MODE_ACTOR_CULTURE_PERCENT"), 1)
  f:beginTurn(115); f:beginTurn(120); equal(f:request("MODE_WARRIOR"), true); f:reload()
  equal(f:balance("AKANE_MODE_ACTOR_CULTURE_PERCENT"), 0)
  equal(f:balance("AKANE_MODE_WARRIOR_COMBAT"), 1)
  f:beginTurn(125); f:beginTurn(130); equal(f:request("MODE_AI"), true)
  equal(f:balance("AKANE_MODE_WARRIOR_COMBAT"), 0)
  equal(f:balance("AKANE_MODE_AI_FAITH_PERCENT"), 1)
  equal(f:balance("AKANE_MODE_SWITCH_BUFF_FOOD"), 1)
end)

test("a switch settles an overdue buff even without a turn callback", function()
  local f = fixture()
  f:reload(); f:request("MODE_AI"); f.turn = 110
  equal(f:request("MODE_ACTOR"), true)
  equal(f:balance("AKANE_MODE_SWITCH_BUFF_FOOD"), 1)
end)

test("legacy active saves are adopted without duplicate attachments", function()
  local f = fixture()
  f.properties.AKANE_MODE_CURRENT = "MODE_AI"
  f.properties.AKANE_MODE_LAST_SWITCH_TURN = 100
  f.attachments.AKANE_MODE_AI_FAITH_PERCENT = 1
  f.attachments.AKANE_MODE_SWITCH_BUFF_FOOD = 1
  f.turn = 102; f:reload(); f:reload()
  equal(f:balance("AKANE_MODE_AI_FAITH_PERCENT"), 1)
  equal(f:balance("AKANE_MODE_SWITCH_BUFF_FOOD"), 1)
  f:beginTurn(105); f:reload()
  equal(f:balance("AKANE_MODE_SWITCH_BUFF_FOOD"), 0)
end)

test("legacy expired saves are adopted without another cleanup", function()
  local f = fixture()
  f.properties.AKANE_MODE_CURRENT = "MODE_AI"
  f.properties.AKANE_MODE_LAST_SWITCH_TURN = 100
  f.attachments.AKANE_MODE_AI_FAITH_PERCENT = 1
  f.attachments.AKANE_MODE_SWITCH_BUFF_FOOD = 1
  f.attachments.AKANE_MODE_SWITCH_BUFF_FOOD_NEGATIVE = 1
  f.turn = 107; f:reload(); f:reload(); f:beginTurn(108)
  equal(f:balance("AKANE_MODE_AI_FAITH_PERCENT"), 1)
  equal(f:balance("AKANE_MODE_SWITCH_BUFF_FOOD"), 0)
end)

test("cooldown and same-mode requests cause no attachments", function()
  local f = fixture()
  f:reload(); f:request("MODE_AI")
  equal(f:request("MODE_ACTOR"), false)
  f:beginTurn(110)
  equal(f:request("MODE_AI"), false)
  equal(f:balance("AKANE_MODE_AI_FAITH_PERCENT"), 1)
  equal(f:balance("AKANE_MODE_ACTOR_CULTURE_PERCENT"), 0)
end)

test("game-speed cooldown and buff expiry retain existing timing", function()
  for _, case in ipairs({
    { "GAMESPEED_ONLINE", 5, 2 }, { "GAMESPEED_QUICK", 7, 3 },
    { "GAMESPEED_STANDARD", 10, 5 }, { "GAMESPEED_EPIC", 15, 7 },
    { "GAMESPEED_MARATHON", 20, 10 }
  }) do
    local f = fixture(case[1])
    f:reload(); f:request("MODE_AI")
    equal(f.env.ExposedMembers.AkaneModeSystem.GetModeState(0).cooldownRemaining, case[2])
    f:beginTurn(100 + case[3] - 1)
    equal(f:balance("AKANE_MODE_SWITCH_BUFF_FOOD"), 1)
    f:beginTurn(100 + case[3]); f:reload()
    equal(f:balance("AKANE_MODE_SWITCH_BUFF_FOOD"), 0)
  end
end)

test("operation handler validates payload, player, and active turn", function()
  local f = fixture()
  f:reload()
  assert(f.handlers.switch, "AKANE_MODE_SWITCH gameplay handler is missing")
  equal(f.handlers.switch(0, nil), false)
  equal(f.handlers.switch(0, { mode = "UNSUPPORTED" }), false)
  equal(f.handlers.switch(0, { mode = "MODE_NONE" }), false)
  equal(f.handlers.switch(99, { mode = "MODE_AI" }), false)
  f.human = false; equal(f:request("MODE_AI"), false)
  f.human = true; f.alive = false; equal(f:request("MODE_AI"), false)
  f.alive = true; f.leader = "LEADER_OTHER"; equal(f:request("MODE_AI"), false)
  f.leader = "LEADER_KUROKAWA_AKANE"; f.active = false; equal(f:request("MODE_AI"), false)
  f.active = true; equal(f:request("MODE_AI"), true)
  equal(f:balance("AKANE_MODE_AI_FAITH_PERCENT"), 1)
end)

test("ExposedMembers contains no gameplay mutation functions", function()
  local f = fixture()
  f:reload()
  local api = f.env.ExposedMembers.AkaneModeSystem
  equal(api.SetAkaneMode, nil)
  equal(api.RequestModeSwitch, nil)
  equal(api.RestoreAkaneModeState, nil)
  equal(api.GetModeState(0).currentMode, "MODE_NONE")
end)

test("UI sends an operation before gameplay mutates or display changes", function()
  local f = fixture()
  f:reload(); f:loadUI()
  f.controls.ModeAIButton.callback()
  equal(#f.operations, 1, "UI operation count")
  equal(f.properties.AKANE_MODE_CURRENT, "MODE_NONE", "mode before operation processing")
  local request = f.operations[1]
  equal(request.playerID, 0)
  equal(request.operation, 77)
  equal(request.params.OnStart, "AKANE_MODE_SWITCH")
  equal(request.params.mode, "MODE_AI")
  f.handlers.switch(request.playerID, request.params)
  assert(f.handlers.operationComplete, "operation completion refresh is missing")
  f.handlers.operationComplete()
  equal(f.controls.ModeCurrentValue.text, "LOC_AKANE_MODE_AI_NAME")
  equal(f.update, nil, "polling stops after the acknowledged switch")
end)

test("UI does not request a switch outside the local player's active turn", function()
  local f = fixture()
  f:reload(); f:loadUI(); f.active = false
  f.controls.ModeAIButton.callback()
  equal(#f.operations, 0)
  equal(f.properties.AKANE_MODE_CURRENT, "MODE_NONE")
end)

test("UI polls for completion when no completion event is available", function()
  local f = fixture()
  f:reload(); f.env.Events.PlayerOperationComplete = nil; f:loadUI()
  f.controls.ModeAIButton.callback()
  equal(#f.operations, 1)
  assert(f.update, "pending operation polling is missing")
  f.controls.ModeActorButton.callback()
  equal(#f.operations, 1, "only one request may be pending")
  f.handlers.switch(0, f.operations[1].params)
  f.update(0.1)
  equal(f.controls.ModeCurrentValue.text, "LOC_AKANE_MODE_AI_NAME")
  equal(f.update, nil)
end)

test("UI stops polling an unacknowledged request and allows retry", function()
  local f = fixture()
  f:reload(); f:loadUI(); f.controls.ModeAIButton.callback()
  equal(#f.operations, 1)
  assert(f.update, "pending operation polling is missing")
  for _ = 1, 10 do f.update(1) end
  equal(f.update, nil, "unacknowledged request polling has a deadline")
  equal(f.properties.AKANE_MODE_CURRENT, "MODE_NONE")
  equal(f.controls.ModeAIButton.disabled, false)
  f.controls.ModeAIButton.callback()
  equal(#f.operations, 2, "request can be retried after the deadline")
end)

print(string.format("Mode runtime tests: %d passed, %d failed.", passed, failures))
if failures > 0 then os.exit(1) end
