$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot

$districts = Get-Content -Raw (Join-Path $projectRoot 'Data\Akane_Districts.xml')
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

Expect-Match $districts 'Lalalai_CityCenter_Gold' 'LALALAI should still keep its city-center gold adjacency.'
Expect-Match $districts 'Lalalai_Wonder_Gold' 'LALALAI should still keep its wonder gold adjacency.'
Expect-Match $districts 'Lalalai_To_Campus_Science' 'LALALAI should still grant Campus adjacency.'

Expect-Match $modifiers 'AKANE_CITY_ATTACH_REASONING_SCIENCE_FROM_LIBRARY' 'Reasoning Master should add a Library-stage science bonus.'
Expect-Match $modifiers 'AKANE_CITY_ATTACH_REASONING_SCIENCE_FROM_UNIVERSITY' 'Reasoning Master should add a University-stage science bonus.'
Expect-Match $modifiers 'AKANE_CITY_ATTACH_REASONING_SCIENCE_FROM_RESEARCH_LAB' 'Reasoning Master should add a Research Lab-stage science bonus.'
Expect-Match $modifiers "\('AKANE_CITY_REASONING_SCIENCE_FROM_LIBRARY', 'Amount', '1'\)" 'Library-stage science bonus should be +1.'
Expect-Match $modifiers "\('AKANE_CITY_REASONING_SCIENCE_FROM_UNIVERSITY', 'Amount', '1'\)" 'University-stage science bonus should be +1.'
Expect-Match $modifiers "\('AKANE_CITY_REASONING_SCIENCE_FROM_RESEARCH_LAB', 'Amount', '1'\)" 'Research Lab-stage science bonus should be +1.'
Expect-Match $modifiers "\('AKANE_LEADER_REASONING_SCIENCE_PERCENT', 'Amount', '10'\)" 'Mathematics bonus should remain +10% science.'
Expect-Match $modifiers "\('AKANE_LEADER_REASONING_SCIENCE_THEORY_PERCENT', 'Amount', '10'\)" 'Scientific Theory bonus should now be +10% science.'
Expect-NotMatch $modifiers "\('TRAIT_LEADER_KUROKAWA_AKANE', 'AKANE_LEADER_REASONING_SCIENCE_FLAT'\)" 'Leader trait should no longer include the old flat culture modifier.'

Expect-Match $requirements 'AKANE_DISTRICT_IS_INDUSTRIAL_ZONE_AND_ADJ_LALALAI' 'Industrial Zone adjacency requirement set should exist for stage doubling.'

Expect-Match $modifiers 'AKANE_CITY_STAGE_LALALAI_CULTURE_BONUS' 'Stage performance should define a LALALAI culture adjacency bonus.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_LALALAI_GOLD_BONUS' 'Stage performance should define a LALALAI gold adjacency bonus.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_CAMPUS_DOUBLE_ADJACENCY' 'Stage performance should double Campus adjacency.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_COMMERCIAL_DOUBLE_ADJACENCY' 'Stage performance should double Commercial Hub adjacency.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_HARBOR_DOUBLE_ADJACENCY' 'Stage performance should double Harbor adjacency.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_ENCAMPMENT_DOUBLE_ADJACENCY' 'Stage performance should double Encampment adjacency.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_INDUSTRIAL_ZONE_DOUBLE_ADJACENCY' 'Stage performance should double Industrial Zone adjacency.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_HOLY_SITE_DOUBLE_ADJACENCY' 'Stage performance should double Holy Site adjacency.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_AMPHITHEATER_TOURISM_ALL' 'Stage performance should define city-wide Amphitheater tourism scaling.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_ART_MUSEUM_TOURISM_ALL' 'Stage performance should define city-wide Art Museum tourism scaling.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_ARCHAEOLOGICAL_MUSEUM_TOURISM_ALL' 'Stage performance should define city-wide Archaeological Museum tourism scaling.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_BROADCAST_CENTER_TOURISM_ALL' 'Stage performance should define city-wide Broadcast Center tourism scaling.'

Expect-NotMatch $gameplay 'MODIFIER_CITY_STAGE_LEGACY_CULTURE' 'Gameplay stage rewards should no longer grant flat permanent city culture.'
Expect-Match $gameplay 'ApplyStageAdjacencyDoublingForCity' 'Gameplay should permanently apply adjacency doubling after stage performances.'
Expect-Match $gameplay 'DistrictAddedToMap' 'Gameplay should refresh stage adjacency bonuses when new districts are added.'
Expect-Match $gameplay 'WonderCompleted' 'Gameplay should refresh stage adjacency bonuses when adjacent wonders are completed.'
Expect-Match $gameplay 'Map.GetAdjacentPlot' 'Gameplay should inspect adjacency around the LALALAI district.'
Expect-Match $gameplay 'GetWonderType' 'Gameplay should count adjacent wonders for LALALAI doubling.'

Expect-Match $modifiers "\('AKANE_MODE_WARRIOR_PRODUCTION_FLAT', 'Amount', '1'\)" 'Ruby mode should keep its +1 flat production.'
Expect-Match $modifiers "\('AKANE_MODE_WARRIOR_ENCAMPMENT_PRODUCTION', 'Amount', '1'\)" 'Ruby mode should keep its +1 Encampment production.'
Expect-NotMatch $modifiers 'AKANE_MODE_WARRIOR_SCIENCE_PERCENT' 'Ruby mode should no longer use the old production-percent modifier id.'

Expect-Match $modifiers "\('AKANE_MODE_SWITCH_BUFF_FOOD', 'Amount', '16'\)" 'Mode switch yield buff should be +16%.'
Expect-Match $modifiers "\('AKANE_MODE_SWITCH_BUFF_GOLD', 'Amount', '16'\)" 'Mode switch yield buff should be +16% for gold too.'
Expect-NotMatch $modeSystem 'GrantSwitchGoldReward' 'Mode switching should no longer grant a gold burst.'

Expect-Match $gameplay 'UnitGreatPersonCreated' 'Ai mode should still trigger on Great Person recruitment.'
Expect-Match $gameplay 'CityMadePurchase' 'Ai mode should still trigger on city purchases.'
Expect-Match $gameplay 'FaithChanged' 'Ai mode should still watch faith balance changes.'
Expect-Match $gameplay 'ChangeGoldBalance' 'Ai mode faith purchases should still refund gold.'

Expect-Match $textZh 'LOC_TRAIT_LEADER_KUROKAWA_AKANE_DESCRIPTION' 'Chinese leader text row should exist.'
Expect-Match $textZh '\+16%' 'Chinese text should mention the updated switch buff.'
Expect-Match $textZh 'LOC_UNIT_STAGE_ACTOR_DESCRIPTION' 'Chinese stage actor description row should exist.'
Expect-Match $textZh 'LOC_AKANE_STAGE_ACTOR_PERFORM_TOOLTIP' 'Chinese stage actor tooltip row should exist.'

Expect-Match $textEn 'Library, University, Research Lab' 'English leader text should mention the Campus building science chain.'
Expect-Match $textEn 'Scientific Theory' 'English leader text should still mention Scientific Theory.'
Expect-Match $textEn '\+16% to all yields' 'English text should mention the updated switch buff.'
Expect-Match $textEn 'double.*adjacency bonuses' 'English stage actor text should mention doubled adjacency.'
Expect-Match $textEn '\+20% Tourism' 'English stage actor text should mention the tourism boost.'
Expect-NotMatch $textEn 'always grants \+1 \[ICON_Culture\] Culture' 'English leader text should no longer mention the removed flat culture.'
Expect-NotMatch $textEn 'Scientific Theory[\s\S]*\+15%' 'English leader text should no longer say Scientific Theory gives +15% science.'

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host $_ }
  exit 1
}

Write-Host 'Strengthening verification passed.'
