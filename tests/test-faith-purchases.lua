-- Runtime regression tests: execute the real gameplay/UI code with engine
-- boundaries replaced because Civilization VI is not a headless Lua library.
local testPath = debug.getinfo(1, "S").source:sub(2):gsub("\\", "/")
local root = testPath:match("^(.*)/tests/[^/]+$") or "."
local source = root .. "/Scripts/Akane_Gameplay.lua"
local passed = 0
local function equal(got, want, label)
  assert(got == want, label .. ": expected " .. tostring(want) .. ", got " .. tostring(got))
end
local function fixture()
  local state = {turn=10, faith=1000, gold=0, props={AKANE_MODE_CURRENT="MODE_AI"}, handlers={}}
  local units = {Members=function() return next, {}, nil end, FindID=function() return nil end}
  local city = {GetID=function() return 12 end, GetOwner=function() return 0 end,
    GetX=function() return 3 end, GetY=function() return 4 end}
  local player = {
    GetProperty=function(_, k) return state.props[k] end,
    SetProperty=function(_, k, v) state.props[k]=v end,
    IsAlive=function() return true end, IsHuman=function() return true end,
    GetID=function() return 0 end, GetCities=function() return nil end,
    GetUnits=function() return units end,
    GetReligion=function() return {GetFaithBalance=function() return state.faith end} end,
    GetTreasury=function() return {ChangeGoldBalance=function(_, n) state.gold=state.gold+n end} end,
  }
  Players={[0]=player}
  PlayerConfigurations={[0]={GetLeaderTypeName=function() return "LEADER_KUROKAWA_AKANE" end}}
  PlayerManager={GetAliveMajors=function() return {player} end}
  GameInfo=setmetatable({
    Units={UNIT_TEST={Index=99,Hash=999,UnitType="UNIT_TEST"}},
    Buildings={BUILDING_TEST={Index=55,Hash=555,BuildingType="BUILDING_TEST"}},
    Yields={YIELD_FAITH={Index=5}},
  }, {__index=function() return {} end})
  Game={GetCurrentGameTurn=function() return state.turn end, AddWorldViewText=function() end}
  CityManager={GetCity=function(owner,id)
    assert(type(id)=="number" and id==math.floor(id) and id>=0 and id<=2147483647, "invalid city ID reached native API")
    if owner==0 and id==12 then return city end
  end}
  EventSubTypes={UNIT=1,BUILDING=2}
  MilitaryFormationTypes={STANDARD_MILITARY_FORMATION=0,CORPS_MILITARY_FORMATION=1,ARMY_MILITARY_FORMATION=2}
  local function eventMap()
    return setmetatable({}, {__index=function(t,k)
      local e={Add=function(fn) state.handlers[k]=fn end}
      rawset(t,k,e)
      return e
    end})
  end
  GameEvents=eventMap(); Events=eventMap(); ExposedMembers={}
  Locale={Lookup=function(tag) return tag end}
  state.city=city
  dofile(source)
  function state:begin(id,kind,item,cost)
    local fn=self.handlers.AKANE_FAITH_PURCHASE_BEGIN
    assert(fn, "faith purchase begin operation must be registered")
    fn(0,{requestID=id,cityID=12,itemKind=kind,itemType=item,expectedCost=cost,formation=0})
  end
  function state:complete(id)
    local fn=self.handlers.AKANE_FAITH_PURCHASE_COMPLETE
    assert(fn, "faith purchase completion operation must be registered")
    fn(0,{requestID=id})
  end
  return state
end
local function test(name,fn)
  fn(); passed=passed+1; print("PASS: " .. name)
end

test("old gold purchase cannot refund next-turn faith patronage",function()
  local s=fixture()
  OnCityMadePurchase(0,12,3,4,EventSubTypes.UNIT,99)
  s.turn=11; OnPlayerTurnStarted(0,11)
  s.faith=800
  if OnFaithChanged then OnFaithChanged(0,0,s.faith) end
  equal(s.gold,0,"unrelated debit refund")
end)
test("successful faith unit purchase refunds actual cost once",function()
  local s=fixture(); s:begin("unit-1","UNIT","UNIT_TEST",200)
  s.faith=800; OnCityMadePurchase(0,12,3,4,EventSubTypes.UNIT,99); s:complete("unit-1")
  equal(s.gold,160,"faith unit refund")
  s:complete("unit-1"); OnCityMadePurchase(0,12,3,4,EventSubTypes.UNIT,99)
  equal(s.gold,160,"duplicate events")
end)
test("successful faith building purchase supports event after completion",function()
  local s=fixture(); s:begin("building-1","BUILDING","BUILDING_TEST",125)
  s.faith=875; s:complete("building-1")
  equal(s.gold,0,"unconfirmed transaction")
  OnCityMadePurchase(0,12,3,4,EventSubTypes.BUILDING,55)
  equal(s.gold,100,"building refund")
end)
test("failed purchase and unrelated faith debit grant nothing",function()
  local s=fixture(); s:begin("failed","UNIT","UNIT_TEST",200); s:complete("failed")
  s.faith=800
  if OnFaithChanged then OnFaithChanged(0,0,s.faith) end
  OnCityMadePurchase(0,12,3,4,EventSubTypes.UNIT,99)
  equal(s.gold,0,"failed purchase refund")
end)
test("different city or item does not confirm a transaction",function()
  local s=fixture(); s:begin("mismatch","UNIT","UNIT_TEST",200); s.faith=800
  OnCityMadePurchase(0,13,3,4,EventSubTypes.UNIT,99)
  OnCityMadePurchase(0,12,3,4,EventSubTypes.UNIT,98)
  s:complete("mismatch"); equal(s.gold,0,"mismatched purchase")
end)
test("wrong debit or changed mode cannot earn a refund",function()
  local s=fixture(); s:begin("wrong-cost","UNIT","UNIT_TEST",200); s.faith=700
  OnCityMadePurchase(0,12,3,4,EventSubTypes.UNIT,99); s:complete("wrong-cost")
  equal(s.gold,0,"wrong cost")
  s=fixture(); s:begin("changed-mode","UNIT","UNIT_TEST",200); s.faith=800
  s.props.AKANE_MODE_CURRENT="MODE_ACTOR"
  OnCityMadePurchase(0,12,3,4,EventSubTypes.UNIT,99); s:complete("changed-mode")
  equal(s.gold,0,"changed mode")
end)
test("completed but unconfirmed transactions cannot leak into a new turn",function()
  local s=fixture(); s:begin("stale","UNIT","UNIT_TEST",200); s.faith=800; s:complete("stale")
  s.turn=11; OnPlayerTurnStarted(0,11); OnCityMadePurchase(0,12,3,4,EventSubTypes.UNIT,99)
  equal(s.gold,0,"stale transaction")
end)

test("malformed operations never reach native APIs or grant refunds",function()
  local invalid={
    {cityID="not-a-city"}, {cityID=-1}, {cityID=12.5}, {cityID=1e300},
    {itemKind="DISTRICT"}, {itemType="UNIT_MISSING"},
    {expectedCost=0}, {expectedCost=math.huge}, {expectedCost=0/0},
    {formation="invalid"}, {formation=-1}, {formation=3}, {formation=0.5},
  }
  for index,overrides in ipairs(invalid) do
    local s=fixture()
    local p={requestID="invalid-"..index,cityID=12,itemKind="UNIT",itemType="UNIT_TEST",expectedCost=200,formation=0}
    for key,value in pairs(overrides) do p[key]=value end
    s.handlers.AKANE_FAITH_PURCHASE_BEGIN(0,p)
    s.faith=800; OnCityMadePurchase(0,12,3,4,EventSubTypes.UNIT,99); s:complete(p.requestID)
    equal(s.gold,0,"invalid operation "..index)
  end
end)

test("native quote is authoritative and receives the correct formation",function()
  local s=fixture(); local quotedFormation
  s.city.GetGold=function() return {GetPurchaseCost=function(_,yieldIndex,hash,formation)
    equal(yieldIndex,5,"faith quote yield"); equal(hash,999,"unit quote hash")
    quotedFormation=formation; return 300
  end} end
  s:begin("bad-quote","UNIT","UNIT_TEST",200); s.faith=800
  OnCityMadePurchase(0,12,3,4,EventSubTypes.UNIT,99); s:complete("bad-quote")
  equal(s.gold,0,"incorrect quote")
  s.handlers.AKANE_FAITH_PURCHASE_BEGIN(0,{requestID="corps",cityID=12,itemKind="UNIT",itemType="UNIT_TEST",expectedCost=300,formation=1})
  equal(quotedFormation,1,"corps gameplay quote")
  s.faith=500; OnCityMadePurchase(0,12,3,4,EventSubTypes.UNIT,99); s:complete("corps")
  equal(s.gold,240,"corps actual cost refund")
end)

test("fractional faith balances refund only the rounded purchase cost",function()
  local s=fixture(); s.faith=1000.75; s:begin("fractional","UNIT","UNIT_TEST",201)
  s.faith=799.75; OnCityMadePurchase(0,12,3,4,EventSubTypes.UNIT,99); s:complete("fractional")
  equal(s.gold,160,"floor gold refund")
end)

test("a legitimate purchase uses the current native price after a stale UI quote",function()
  local s=fixture()
  s.city.GetGold=function() return {GetPurchaseCost=function() return 300 end} end
  s:begin("new-price","UNIT","UNIT_TEST",200)
  s.faith=700; OnCityMadePurchase(0,12,3,4,EventSubTypes.UNIT,99); s:complete("new-price")
  equal(s.gold,240,"current native price refund")
end)

test("UI brackets only local Akane faith purchases and preserves formations",function()
  local order={}; local localID=0
  Game.GetLocalPlayer=function() return localID end
  PlayerOperations={EXECUTE_SCRIPT=9}
  MilitaryFormationTypes={STANDARD_MILITARY_FORMATION=0,CORPS_MILITARY_FORMATION=1,ARMY_MILITARY_FORMATION=2}
  UI={RequestPlayerOperation=function(owner,operation,p)
    equal(owner,0,"operation owner"); equal(operation,9,"operation kind")
    order[#order+1]=p
  end}
  local city={GetOwner=function() return 0 end,GetID=function() return 12 end}
  PurchaseUnit=function() order[#order+1]="purchase-unit" end
  PurchaseUnitCorps=function() order[#order+1]="purchase-corps" end
  PurchaseUnitArmy=function() order[#order+1]="purchase-army" end
  PurchaseBuilding=function() order[#order+1]="purchase-building" end
  dofile(root .. "/UI/Akane_PurchaseSupport.lua")
  local entry={Type="UNIT_TEST",Hash=999,Yield="YIELD_FAITH",Cost=200,CorpsCost=300,ArmyCost=400}
  PurchaseUnitCorps(city,entry)
  equal(#order,3,"request bracket length")
  equal(order[1].OnStart,"AKANE_FAITH_PURCHASE_BEGIN","begin event")
  equal(order[1].expectedCost,300,"corps cost")
  equal(order[1].formation,1,"corps formation")
  equal(order[2],"purchase-corps","original purchase preserved")
  equal(order[3].OnStart,"AKANE_FAITH_PURCHASE_COMPLETE","completion event")
  equal(order[3].requestID,order[1].requestID,"same transaction")
  order={}
  city.GetGold=function() return {GetPurchaseCost=function(_,yieldIndex,hash,formation)
    equal(yieldIndex,5,"UI faith quote"); equal(hash,999,"UI item hash"); equal(formation,1,"UI quote formation")
    return 340
  end} end
  PurchaseUnitCorps(city,entry)
  equal(order[1].expectedCost,340,"UI refreshes stale corps cost")
  order={}; entry.Yield="YIELD_GOLD"; PurchaseUnit(city,entry)
  equal(#order,1,"gold has no faith marker")
  order={}; entry.Yield="YIELD_FAITH"; localID=1; PurchaseUnit(city,entry)
  equal(#order,1,"remote city has no marker")
end)
print(string.format("Faith purchase runtime regression passed: %d tests.",passed))
