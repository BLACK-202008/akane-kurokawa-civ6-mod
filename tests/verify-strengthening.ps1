$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot

$districts = Get-Content -Raw (Join-Path $projectRoot 'Data\Akane_Districts.xml')
$units = Get-Content -Raw (Join-Path $projectRoot 'Data\Akane_Units.xml')
$modifiers = Get-Content -Raw (Join-Path $projectRoot 'Data\Akane_Modifiers.sql')
$requirements = Get-Content -Raw (Join-Path $projectRoot 'Data\Akane_Requirements.sql')
$gameplay = Get-Content -Raw (Join-Path $projectRoot 'Scripts\Akane_Gameplay.lua')
$modeSystem = Get-Content -Raw (Join-Path $projectRoot 'Scripts\Akane_ModeSystem.lua')
$textZh = Get-Content -Raw (Join-Path $projectRoot 'Text\Akane_Text_zh_Hans_CN.xml')
$textEn = Get-Content -Raw (Join-Path $projectRoot 'Text\Akane_Text_en_US.xml')

$failures = New-Object System.Collections.Generic.List[string]

function Expect-Match {
  param(
    [string]$Content,
    [string]$Pattern,
    [string]$Message
  )

  if ($Content -notmatch $Pattern) {
    $failures.Add($Message)
  }
}

function Expect-NotMatch {
  param(
    [string]$Content,
    [string]$Pattern,
    [string]$Message
  )

  if ($Content -match $Pattern) {
    $failures.Add($Message)
  }
}

Expect-Match $districts 'Lalalai_CityCenter_Gold' 'LALALAI district should gain gold adjacency from city centers.'
Expect-Match $districts 'Lalalai_Wonder_Gold' 'LALALAI district should gain gold adjacency from wonders.'
Expect-Match $districts 'YieldType="YIELD_GOLD"\s+YieldChange="2"\s+TilesRequired="1"\s+AdjacentDistrict="DISTRICT_CITY_CENTER"' 'City center gold adjacency should be +2 gold.'
Expect-Match $districts 'YieldType="YIELD_GOLD"\s+YieldChange="2"\s+TilesRequired="1"\s+AdjacentWonder="true"' 'Wonder gold adjacency should be +2 gold.'
Expect-Match $districts 'DistrictType="DISTRICT_LALALAI_TROUPE"\s+YieldType="YIELD_FOOD"\s+YieldChange="2"' 'LALALAI specialists should provide +2 food.'
Expect-Match $districts 'DistrictType="DISTRICT_LALALAI_TROUPE"\s+YieldType="YIELD_PRODUCTION"\s+YieldChange="1"' 'LALALAI specialists should provide +1 production.'

Expect-NotMatch $units 'UnitReplaces' 'Stage Actor should no longer replace Rock Band.'
Expect-NotMatch $units 'CLASS_ROCK_BAND' 'Stage Actor should not retain the Rock Band class tag.'
Expect-NotMatch $units 'PROMOTION_CLASS_ROCK_BAND' 'Stage Actor should not retain Rock Band promotions.'
Expect-NotMatch $units 'NumRandomChoices' 'Stage Actor should not expose Rock Band promotion choices.'
Expect-NotMatch $units 'InitialLevel=' 'Stage Actor should not start with Rock Band promotion level data.'

Expect-NotMatch $modifiers "\('AKANE_CITY_SCIENCE_FROM_LALALAI', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER'" 'LALALAI adjacency should no longer boost city-wide yields.'
Expect-Match $modifiers 'AKANE_BUILDING_LIBRARY_FROM_LALALAI' 'Campus building boost should target the Library directly.'
Expect-Match $modifiers "\('AKANE_BUILDING_LIBRARY_FROM_LALALAI', 'MODIFIER_PLAYER_CITIES_ADJUST_BUILDING_YIELD_MODIFIER', 'AKANE_CITY_HAS_CAMPUS_AND_LALALAI'\)" 'Library boost should require Campus plus LALALAI.'
Expect-Match $modifiers "\('AKANE_BUILDING_LIBRARY_FROM_LALALAI', 'BuildingType', 'BUILDING_LIBRARY'\)" 'Library boost should target the Library building.'
Expect-Match $modifiers "\('AKANE_BUILDING_LIBRARY_FROM_LALALAI', 'YieldType', 'YIELD_SCIENCE'\)" 'Library boost should affect science yield.'
Expect-Match $modifiers "\('AKANE_BUILDING_LIBRARY_FROM_LALALAI', 'Amount', '50'\)" 'Library boost should be +50%.'
Expect-Match $modifiers "\('AKANE_BUILDING_MARKET_FROM_LALALAI', 'BuildingType', 'BUILDING_MARKET'\)" 'Commercial Hub boost should target the Market building.'
Expect-Match $modifiers "\('AKANE_BUILDING_MARKET_FROM_LALALAI', 'YieldType', 'YIELD_GOLD'\)" 'Market boost should affect gold yield.'
Expect-Match $modifiers "\('AKANE_BUILDING_LIGHTHOUSE_GOLD_FROM_LALALAI', 'BuildingType', 'BUILDING_LIGHTHOUSE'\)" 'Harbor boost should target the Lighthouse building.'
Expect-Match $modifiers "\('AKANE_BUILDING_LIGHTHOUSE_GOLD_FROM_LALALAI', 'YieldType', 'YIELD_GOLD'\)" 'Lighthouse boost should affect gold yield.'
Expect-Match $modifiers "\('AKANE_BUILDING_BARRACKS_FROM_LALALAI', 'BuildingType', 'BUILDING_BARRACKS'\)" 'Encampment boost should target Barracks.'
Expect-Match $modifiers "\('AKANE_BUILDING_BARRACKS_FROM_LALALAI', 'YieldType', 'YIELD_PRODUCTION'\)" 'Barracks boost should affect production yield.'
Expect-Match $modifiers "\('AKANE_BUILDING_WORKSHOP_FROM_LALALAI', 'BuildingType', 'BUILDING_WORKSHOP'\)" 'Industrial Zone boost should target Workshop.'
Expect-Match $modifiers "\('AKANE_BUILDING_WORKSHOP_FROM_LALALAI', 'YieldType', 'YIELD_PRODUCTION'\)" 'Workshop boost should affect production yield.'
Expect-Match $modifiers "\('AKANE_BUILDING_SHRINE_FROM_LALALAI', 'BuildingType', 'BUILDING_SHRINE'\)" 'Holy Site boost should target Shrine.'
Expect-Match $modifiers "\('AKANE_BUILDING_SHRINE_FROM_LALALAI', 'YieldType', 'YIELD_FAITH'\)" 'Shrine boost should affect faith yield.'
Expect-Match $modifiers 'AKANE_CITY_ATTACH_SCIENTIST_FROM_LIBRARY' 'Campus great person points should scale with building tiers.'
Expect-Match $modifiers 'AKANE_CITY_ATTACH_MERCHANT_FROM_MARKET' 'Commercial Hub great person points should scale with building tiers.'
Expect-Match $modifiers 'AKANE_CITY_ATTACH_ADMIRAL_FROM_LIGHTHOUSE' 'Harbor great person points should scale with building tiers.'
Expect-Match $modifiers 'AKANE_CITY_ATTACH_GENERAL_FROM_BARRACKS' 'Encampment great person points should scale with building tiers.'
Expect-Match $modifiers 'AKANE_CITY_ATTACH_GENERAL_FROM_STABLE' 'Encampment great person points should support the Stable branch.'
Expect-Match $modifiers 'AKANE_CITY_ATTACH_PROPHET_FROM_SHRINE' 'Holy Site great person points should scale with building tiers.'
Expect-Match $requirements 'AKANE_CITY_HAS_LIBRARY_AND_CAMPUS_AND_LALALAI' 'Campus building-tier requirement set should exist.'
Expect-Match $requirements 'AKANE_CITY_HAS_MARKET_AND_COMMERCIAL_HUB_AND_LALALAI' 'Commercial Hub building-tier requirement set should exist.'
Expect-Match $requirements 'AKANE_CITY_HAS_LIGHTHOUSE_AND_HARBOR_AND_LALALAI' 'Harbor building-tier requirement set should exist.'
Expect-Match $requirements 'AKANE_CITY_HAS_BARRACKS_AND_ENCAMPMENT_AND_LALALAI' 'Encampment barracks requirement set should exist.'
Expect-Match $requirements 'AKANE_CITY_HAS_SHRINE_AND_HOLY_SITE_AND_LALALAI' 'Holy Site building-tier requirement set should exist.'

Expect-Match $gameplay 'PROPERTY_PLAYER_ART_STACKS' 'Art Prosperity should track player-wide stacks.'
Expect-Match $gameplay 'PROPERTY_PLAYER_ART_TURNS' 'Art Prosperity should track player-wide duration.'
Expect-Match $gameplay 'Players\[playerID\]' 'Art Prosperity strengthening should operate at player scope.'
Expect-Match $modifiers "\('AKANE_ART_PROSPERITY_FOOD', 'Amount', '8'\)" 'Art Prosperity should grant +8% yields.'
Expect-Match $modifiers "\('AKANE_ART_PROSPERITY_PRODUCTION', 'Amount', '8'\)" 'Art Prosperity should grant +8% yields.'
Expect-Match $modifiers "\('AKANE_ART_PROSPERITY_FAITH_NEGATIVE', 'Amount', '-8'\)" 'Art Prosperity cleanup should remove +8% yields.'
Expect-Match $gameplay 'ART_PROSPERITY_STANDARD_TURN_EXTENSION = 25' 'Art Prosperity should last 25 turns on Standard speed.'
Expect-Match $gameplay 'ART_PROSPERITY_STANDARD_TURN_CAP = 100' 'Art Prosperity should cap at 100 turns on Standard speed.'
Expect-Match $gameplay 'math\.min\(maxTurns,' 'Art Prosperity duration should be capped after speed scaling.'

Expect-Match $modifiers "\('AKANE_MODE_ACTOR_TOURISM_PERCENT', 'MODIFIER_PLAYER_ADJUST_TOURISM', NULL\)" 'Sayahime mode should add a tourism modifier.'
Expect-Match $modifiers "\('AKANE_MODE_ACTOR_TOURISM_PERCENT', 'Amount', '30'\)" 'Sayahime tourism modifier should be +30%.'
Expect-Match $modeSystem '"AKANE_MODE_AI_RELIGIOUS_STRENGTH"' 'Ai mode should attach a religious combat modifier.'
Expect-Match $modeSystem '"AKANE_MODE_AI_RELIGIOUS_STRENGTH_NEGATIVE"' 'Ai mode should include a negative religious combat modifier.'
Expect-Match $modifiers "\('AKANE_MODE_AI_RELIGIOUS_STRENGTH', 'MODIFIER_PLAYER_UNITS_ATTACH_MODIFIER', 'AKANE_UNIT_IS_RELIGIOUS_OR_INQUISITOR'\)" 'Ai mode should attach a combat modifier to religious units and inquisitors.'
Expect-Match $modifiers "\('AKANE_MODE_AI_RELIGIOUS_STRENGTH_MODIFIER', 'MODIFIER_UNIT_ADJUST_COMBAT_STRENGTH', NULL\)" 'Ai mode should use a unit combat strength modifier internally.'
Expect-Match $modifiers "\('AKANE_MODE_AI_RELIGIOUS_STRENGTH_MODIFIER', 'Amount', '10'\)" 'Ai mode religious combat bonus should be +10.'
Expect-Match $modifiers "\('AKANE_MODE_AI_RELIGIOUS_STRENGTH_NEGATIVE', 'MODIFIER_PLAYER_UNITS_ATTACH_MODIFIER', 'AKANE_UNIT_IS_RELIGIOUS_OR_INQUISITOR'\)" 'Ai mode should include a negative religious attach modifier for cleanup.'
Expect-Match $modifiers "\('AKANE_MODE_AI_RELIGIOUS_STRENGTH_NEGATIVE_MODIFIER', 'MODIFIER_UNIT_ADJUST_COMBAT_STRENGTH', NULL\)" 'Ai mode negative religious combat modifier should exist.'
Expect-Match $modifiers "\('AKANE_MODE_AI_RELIGIOUS_STRENGTH_NEGATIVE_MODIFIER', 'Amount', '-10'\)" 'Ai mode negative religious combat bonus should be -10.'
Expect-Match $requirements 'AKANE_UNIT_IS_RELIGIOUS_OR_INQUISITOR' 'Ai mode should define a requirement set for religious units and inquisitors.'
Expect-Match $requirements 'REQUIREMENT_UNIT_TAG_MATCHES' 'Ai mode unit filtering should use unit tag requirements.'
Expect-Match $requirements "'Tag', 'CLASS_RELIGIOUS'" 'Ai mode should target religious units by tag.'
Expect-Match $requirements "'Tag', 'CLASS_INQUISITOR'" 'Ai mode should target inquisitors by tag.'

Expect-Match $modeSystem '"AKANE_MODE_WARRIOR_MOVEMENT"' 'Ruby mode should attach a movement modifier.'
Expect-Match $modeSystem '"AKANE_MODE_WARRIOR_MOVEMENT_NEGATIVE"' 'Ruby mode should detach its movement modifier when switching away.'
Expect-NotMatch $modeSystem '"AKANE_MODE_WARRIOR_EXPERIENCE"' 'Ruby mode should no longer attach an experience modifier.'
Expect-NotMatch $modeSystem '"AKANE_MODE_WARRIOR_EXPERIENCE_NEGATIVE"' 'Ruby mode should no longer include an experience cleanup modifier.'
Expect-Match $modifiers "\('AKANE_MODE_WARRIOR_MOVEMENT', 'MODIFIER_PLAYER_UNITS_ADJUST_MOVEMENT', NULL\)" 'Ruby mode should add movement to all player units.'
Expect-Match $modifiers "\('AKANE_MODE_WARRIOR_MOVEMENT', 'Amount', '1'\)" 'Ruby mode movement bonus should be +1.'
Expect-Match $modifiers "\('AKANE_MODE_WARRIOR_MOVEMENT_NEGATIVE', 'MODIFIER_PLAYER_UNITS_ADJUST_MOVEMENT', NULL\)" 'Ruby mode should include a negative movement modifier for cleanup.'
Expect-Match $modifiers "\('AKANE_MODE_WARRIOR_MOVEMENT_NEGATIVE', 'Amount', '-1'\)" 'Ruby mode negative movement bonus should be -1.'
Expect-NotMatch $modifiers 'AKANE_MODE_WARRIOR_EXPERIENCE' 'Ruby mode should no longer define an experience bonus modifier.'
Expect-NotMatch $modifiers 'AKANE_MODE_WARRIOR_EXPERIENCE_NEGATIVE' 'Ruby mode should no longer define an experience cleanup modifier.'

Expect-Match $modifiers "\('AKANE_MODE_SWITCH_BUFF_FOOD', 'Amount', '15'\)" 'Mode switch all-yield buff should be +15%.'
Expect-Match $modifiers "\('AKANE_MODE_SWITCH_BUFF_GOLD', 'Amount', '15'\)" 'Mode switch all-yield buff should be +15%.'
Expect-Match $modeSystem 'GrantSwitchGoldReward' 'Mode switch should grant a gold reward.'
Expect-Match $modeSystem 'currentTurn \+ 9' 'Gold reward should scale with current turn plus 9.'
Expect-Match $modeSystem '\* 4' 'Mode switch gold reward should now use half-strength scaling.'
Expect-NotMatch $modeSystem '\(currentTurn \+ 9\) \* 8' 'Mode switch gold reward should no longer use the old full-strength scaling.'
Expect-Match $modeSystem 'math\.min\(800,' 'Mode switch gold reward should be capped at 800.'
Expect-Match $gameplay 'UnitGreatPersonActivated' 'Gameplay script should react to Great Person activation.'
Expect-Match $gameplay 'TriggerBoost' 'Sayahime mode should trigger a technology boost.'
Expect-Match $gameplay 'GetCurrentMode' 'Gameplay script should consult the current Akane mode before awarding a Eureka.'
Expect-Match $gameplay 'CanResearch' 'Sayahime mode should only target currently researchable technologies.'

Expect-Match $modifiers "\('AKANE_CAMPUS_SCIENCE_FROM_ADJACENT_LALALAI', 'MODIFIER_PLAYER_DISTRICTS_ADJUST_YIELD_CHANGE', 'AKANE_DISTRICT_IS_CAMPUS_AND_ADJ_LALALAI'\)" 'Leader base ability should add science to Campuses adjacent to LALALAI.'
Expect-Match $modifiers "\('AKANE_CAMPUS_SCIENCE_FROM_ADJACENT_LALALAI', 'YieldType', 'YIELD_SCIENCE'\)" 'Adjacent Campus bonus should grant science.'
Expect-Match $modifiers "\('AKANE_CAMPUS_SCIENCE_FROM_ADJACENT_LALALAI', 'Amount', '1'\)" 'Adjacent Campus bonus should grant +1 science.'
Expect-Match $modifiers "\('AKANE_LEADER_REASONING_SCIENCE_PERCENT', 'Amount', '10'\)" 'Leader base ability should grant +10% science after Mathematics.'
Expect-Match $modifiers "\('AKANE_LEADER_REASONING_SCIENCE_THEORY_PERCENT', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER', NULL\)" 'Leader base ability should add a Scientific Theory science modifier.'
Expect-Match $modifiers "\('AKANE_LEADER_REASONING_SCIENCE_THEORY_PERCENT', 'Amount', '15'\)" 'Leader base ability should grant +15% science after Scientific Theory.'
Expect-Match $requirements 'AKANE_PLAYER_HAS_SCIENTIFIC_THEORY' 'Scientific Theory requirement set should exist.'
Expect-Match $requirements "'TechnologyType', 'TECH_SCIENTIFIC_THEORY'" 'Scientific Theory requirement should target the Scientific Theory technology.'

Expect-Match $textZh '\+50%' 'Chinese text should describe strengthened bonuses.'
Expect-Match $textZh 'LOC_AKANE_MODE_AI_TOOLTIP[\s\S]*\+10' 'Chinese text should mention the religious strength bonus.'
Expect-Match $textZh 'LOC_DISTRICT_LALALAI_TROUPE_DESCRIPTION[\s\S]*\+2 \[ICON_Food\][\s\S]*\+1 \[ICON_Production\]' 'Chinese text should mention LALALAI specialist food and production.'
Expect-Match $textZh 'LOC_AKANE_MODE_ACTOR_TOOLTIP[\s\S]*\+30%' 'Chinese text should mention Sayahime tourism bonus.'
Expect-Match $textZh '\+15%' 'Chinese text should mention the stronger mode-switch yield bonus.'
Expect-Match $textZh 'LOC_AKANE_MODE_WARRIOR_TOOLTIP[\s\S]*\+5 \[ICON_Strength\][\s\S]*\+1 ' 'Chinese text should still mention Ruby movement bonus.'
Expect-Match $textZh 'LOC_TRAIT_LEADER_KUROKAWA_AKANE_DESCRIPTION[\s\S]*\+10%[\s\S]*\+15%' 'Chinese text should mention the stacked Mathematics and Scientific Theory science bonuses.'
Expect-Match $textEn '\+50%' 'English text should describe strengthened bonuses.'
Expect-Match $textEn 'random Eureka' 'English text should mention the random Eureka effect.'
Expect-Match $textEn 'religious units' 'English text should mention religious units.'
Expect-Match $textEn 'specialists' 'English text should mention LALALAI specialist yields.'
Expect-Match $textEn 'Tourism' 'English text should mention Sayahime tourism bonus.'
Expect-Match $textEn '\+15%' 'English text should mention the stronger mode-switch yield bonus.'
Expect-Match $textEn 'LOC_AKANE_MODE_WARRIOR_TOOLTIP[\s\S]*\+1 Movement' 'English text should mention Ruby movement bonus.'
Expect-NotMatch $textEn 'LOC_AKANE_MODE_WARRIOR_TOOLTIP[\s\S]*experience' 'English text should no longer mention Ruby experience bonus.'
Expect-Match $textEn 'Scientific Theory' 'English text should mention Scientific Theory in the leader bonus description.'

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Strengthening verification passed.'
