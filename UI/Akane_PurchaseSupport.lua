-- Wrap native purchase callbacks without replacing their purchasing behavior.
-- The two ordered gameplay operations measure only the request between them.
local serial = 0
local function WrapFaithPurchase(original, kind, formation, costField)
  return function(city, entry, ...)
    local playerID = Game.GetLocalPlayer()
    local config = PlayerConfigurations[playerID]
    local player = Players[playerID]
    local cost = entry ~= nil and tonumber(entry[costField]) or nil
    if city == nil or entry == nil or entry.Yield ~= "YIELD_FAITH" or playerID == -1
      or city:GetOwner() ~= playerID or config == nil
      or config:GetLeaderTypeName() ~= "LEADER_KUROKAWA_AKANE" or player == nil
      or player:GetProperty("AKANE_MODE_CURRENT") ~= "MODE_AI" or cost == nil or cost <= 0 then
      return original(city, entry, ...)
    end
    -- Refresh a cached panel price immediately before submitting this request.
    local cityGold = city.GetGold ~= nil and city:GetGold() or nil
    if cityGold ~= nil and cityGold.GetPurchaseCost ~= nil then
      local faithYield = GameInfo.Yields.YIELD_FAITH
      if faithYield ~= nil then
        if kind == "UNIT" then
          cost = cityGold:GetPurchaseCost(faithYield.Index, entry.Hash, formation)
        else
          cost = cityGold:GetPurchaseCost(faithYield.Index, entry.Hash)
        end
      end
    end
    if type(cost) ~= "number" or cost ~= cost or cost <= 0 or cost == math.huge then
      return original(city, entry, ...)
    end
    serial = serial + 1
    local requestID = tostring(Game.GetCurrentGameTurn()) .. ":" .. tostring(city:GetID()) .. ":" .. tostring(serial)
    UI.RequestPlayerOperation(playerID, PlayerOperations.EXECUTE_SCRIPT, {
      OnStart="AKANE_FAITH_PURCHASE_BEGIN", requestID=requestID,
      cityID=city:GetID(), itemKind=kind, itemType=entry.Type,
      expectedCost=cost, formation=formation,
    })
    local results = table.pack(original(city, entry, ...))
    UI.RequestPlayerOperation(playerID, PlayerOperations.EXECUTE_SCRIPT, {
      OnStart="AKANE_FAITH_PURCHASE_COMPLETE", requestID=requestID,
    })
    return table.unpack(results, 1, results.n)
  end
end
local formations = MilitaryFormationTypes
if PurchaseUnit ~= nil then
  PurchaseUnit = WrapFaithPurchase(PurchaseUnit, "UNIT", formations.STANDARD_MILITARY_FORMATION, "Cost")
end
if PurchaseUnitCorps ~= nil then
  PurchaseUnitCorps = WrapFaithPurchase(PurchaseUnitCorps, "UNIT", formations.CORPS_MILITARY_FORMATION, "CorpsCost")
end
if PurchaseUnitArmy ~= nil then
  PurchaseUnitArmy = WrapFaithPurchase(PurchaseUnitArmy, "UNIT", formations.ARMY_MILITARY_FORMATION, "ArmyCost")
end
if PurchaseBuilding ~= nil then
  PurchaseBuilding = WrapFaithPurchase(PurchaseBuilding, "BUILDING", nil, "Cost")
end
