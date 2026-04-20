$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot

$districts = Get-Content -Raw (Join-Path $projectRoot 'Data\Akane_Districts.xml')
$modifiers = Get-Content -Raw (Join-Path $projectRoot 'Data\Akane_Modifiers.sql')
$requirements = Get-Content -Raw (Join-Path $projectRoot 'Data\Akane_Requirements.sql')
$gameplay = Get-Content -Raw (Join-Path $projectRoot 'Scripts\Akane_Gameplay.lua')
$modeSystem = Get-Content -Raw (Join-Path $projectRoot 'Scripts\Akane_ModeSystem.lua')
$textZh = Get-Content -Raw (Join-Path $projectRoot 'Text\Akane_Text_zh_Hans_CN.xml')
$textEn = Get-Content -Raw (Join-Path $projectRoot 'Text\Akane_Text_en_US.xml')
$readme = Get-Content -Raw -Encoding UTF8 (Join-Path $projectRoot 'README.md')

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
Expect-Match $districts 'Lalalai_To_CommercialHub_Gold[\s\S]*YieldChange="2"' 'Commercial Hub adjacency from LALALAI should now be +2 gold.'
Expect-Match $districts 'Lalalai_To_Harbor_Gold[\s\S]*YieldChange="2"' 'Harbor adjacency from LALALAI should now be +2 gold.'
Expect-Match $districts 'Lalalai_To_EntertainmentComplex_Production' 'LALALAI should now grant Entertainment Complex production adjacency.'
Expect-Match $districts 'Lalalai_To_WaterPark_Production' 'LALALAI should now grant Water Park production adjacency.'

Expect-NotMatch $modifiers 'AKANE_CAMPUS_SCIENCE_FROM_ADJACENT_LALALAI' 'Reasoning Master should no longer grant flat Campus science adjacency.'
Expect-NotMatch $modifiers 'AKANE_CITY_ATTACH_REASONING_SCIENCE_FROM_LIBRARY' 'Reasoning Master should no longer add a Library-stage science bonus.'
Expect-NotMatch $modifiers 'AKANE_CITY_ATTACH_REASONING_SCIENCE_FROM_UNIVERSITY' 'Reasoning Master should no longer add a University-stage science bonus.'
Expect-NotMatch $modifiers 'AKANE_CITY_ATTACH_REASONING_SCIENCE_FROM_RESEARCH_LAB' 'Reasoning Master should no longer add a Research Lab-stage science bonus.'
Expect-NotMatch $modifiers 'AKANE_CITY_REASONING_SCIENCE_FROM_LIBRARY' 'Library-stage science bonus definition should be removed.'
Expect-NotMatch $modifiers 'AKANE_CITY_REASONING_SCIENCE_FROM_UNIVERSITY' 'University-stage science bonus definition should be removed.'
Expect-NotMatch $modifiers 'AKANE_CITY_REASONING_SCIENCE_FROM_RESEARCH_LAB' 'Research Lab-stage science bonus definition should be removed.'
Expect-Match $modifiers "\('AKANE_LEADER_REASONING_SCIENCE_PERCENT', 'Amount', '10'\)" 'Mathematics bonus should remain +10% science.'
Expect-Match $modifiers "\('AKANE_LEADER_REASONING_SCIENCE_THEORY_PERCENT', 'Amount', '10'\)" 'Scientific Theory bonus should now be +10% science.'
Expect-Match $modifiers 'AKANE_LEADER_REASONING_CULTURE_FLAT' 'Reasoning Master should define a flat culture modifier with the corrected name.'
Expect-Match $modifiers "\('AKANE_LEADER_REASONING_CULTURE_FLAT', 'YieldType', 'YIELD_CULTURE'\)" 'Flat culture modifier should grant culture.'
Expect-Match $modifiers "\('AKANE_LEADER_REASONING_CULTURE_FLAT', 'Amount', '1'\)" 'Flat culture modifier should grant +1 culture.'
Expect-Match $modifiers "\('TRAIT_LEADER_KUROKAWA_AKANE', 'AKANE_LEADER_REASONING_CULTURE_FLAT'\)" 'Leader trait should include the flat culture modifier.'
Expect-NotMatch $modifiers 'AKANE_LEADER_REASONING_SCIENCE_FLAT' 'Old misleading flat science modifier id should no longer exist.'

Expect-Match $requirements 'AKANE_DISTRICT_IS_INDUSTRIAL_ZONE_AND_ADJ_LALALAI' 'Industrial Zone adjacency requirement set should exist for stage doubling.'
Expect-Match $requirements 'AKANE_DISTRICT_IS_ENTERTAINMENT_COMPLEX_AND_ADJ_LALALAI' 'Entertainment Complex adjacency requirement set should exist for stage doubling.'
Expect-Match $requirements 'AKANE_DISTRICT_IS_WATER_PARK_AND_ADJ_LALALAI' 'Water Park adjacency requirement set should exist for stage doubling.'

Expect-Match $modifiers 'AKANE_CITY_STAGE_LALALAI_CULTURE_BONUS' 'Stage performance should define a LALALAI culture adjacency bonus.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_LALALAI_GOLD_BONUS' 'Stage performance should define a LALALAI gold adjacency bonus.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_CAMPUS_DOUBLE_ADJACENCY' 'Stage performance should double Campus adjacency.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_COMMERCIAL_DOUBLE_ADJACENCY' 'Stage performance should double Commercial Hub adjacency.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_HARBOR_DOUBLE_ADJACENCY' 'Stage performance should double Harbor adjacency.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_ENCAMPMENT_DOUBLE_ADJACENCY' 'Stage performance should double Encampment adjacency.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_INDUSTRIAL_ZONE_DOUBLE_ADJACENCY' 'Stage performance should double Industrial Zone adjacency.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_HOLY_SITE_DOUBLE_ADJACENCY' 'Stage performance should double Holy Site adjacency.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_ENTERTAINMENT_COMPLEX_DOUBLE_ADJACENCY' 'Stage performance should double Entertainment Complex adjacency.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_WATER_PARK_DOUBLE_ADJACENCY' 'Stage performance should double Water Park adjacency.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_AMPHITHEATER_TOURISM_ALL' 'Stage performance should define city-wide Amphitheater tourism scaling.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_ART_MUSEUM_TOURISM_ALL' 'Stage performance should define city-wide Art Museum tourism scaling.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_ARCHAEOLOGICAL_MUSEUM_TOURISM_ALL' 'Stage performance should define city-wide Archaeological Museum tourism scaling.'
Expect-Match $modifiers 'AKANE_CITY_STAGE_BROADCAST_CENTER_TOURISM_ALL' 'Stage performance should define city-wide Broadcast Center tourism scaling.'

Expect-NotMatch $gameplay 'MODIFIER_CITY_STAGE_LEGACY_CULTURE' 'Gameplay stage rewards should no longer grant flat permanent city culture.'
Expect-Match $gameplay 'ApplyStageAdjacencyDoublingForCity' 'Gameplay should permanently apply adjacency doubling after stage performances.'
Expect-Match $gameplay 'DistrictAddedToMap' 'Gameplay should refresh stage adjacency bonuses when new districts are added.'
Expect-Match $gameplay 'WonderCompleted' 'Gameplay should refresh stage adjacency bonuses when adjacent wonders are completed.'
Expect-Match $gameplay 'Map.GetAdjacentPlot' 'Gameplay should inspect adjacency around the LALALAI district.'
Expect-Match $gameplay 'GetDistrictAdjacencyHalfSteps' 'Gameplay should recompute adjacency from the current district state when doubling yields.'
Expect-Match $gameplay 'PROPERTY_CITY_STAGE_ENTERTAINMENT_COMPLEX_BONUS_APPLIED' 'Gameplay should track doubled Entertainment Complex adjacency.'
Expect-Match $gameplay 'PROPERTY_CITY_STAGE_WATER_PARK_BONUS_APPLIED' 'Gameplay should track doubled Water Park adjacency.'

Expect-Match $modifiers "\('AKANE_MODE_WARRIOR_PRODUCTION_FLAT', 'Amount', '1'\)" 'Ruby mode should keep its +1 flat production.'
Expect-Match $modifiers "\('AKANE_MODE_WARRIOR_ENCAMPMENT_PRODUCTION', 'Amount', '1'\)" 'Ruby mode should keep its +1 Encampment production.'
Expect-NotMatch $modifiers 'AKANE_MODE_WARRIOR_SCIENCE_PERCENT' 'Ruby mode should no longer use the old production-percent modifier id.'
Expect-Match $gameplay 'UnitKilledInCombat' 'Ruby mode faith reward should hook a combat kill event.'
Expect-Match $gameplay 'ChangeFaithBalance' 'Ruby mode faith reward should add faith to the attacker.'
Expect-Match $gameplay 'AKANE_MODE_WARRIOR_FAITH_REWARD_WORLD_TEXT' 'Ruby mode faith reward should show world text when triggered.'

Expect-Match $modifiers "\('AKANE_MODE_SWITCH_BUFF_FOOD', 'Amount', '16'\)" 'Mode switch yield buff should be +16%.'
Expect-Match $modifiers "\('AKANE_MODE_SWITCH_BUFF_GOLD', 'Amount', '16'\)" 'Mode switch yield buff should be +16% for gold too.'
Expect-NotMatch $modeSystem 'GrantSwitchGoldReward' 'Mode switching should no longer grant a gold burst.'
Expect-Match $modifiers 'AKANE_MODE_ACTOR_WRITER_POINTS' 'Actor mode should define per-district Great Writer points.'
Expect-Match $modifiers 'AKANE_MODE_ACTOR_WRITER_POINTS_FLAT' 'Actor mode should define flat Great Writer points.'
Expect-Match $modifiers 'AKANE_MODE_ACTOR_MUSICIAN_POINTS' 'Actor mode should define per-district Great Musician points.'
Expect-Match $modifiers 'AKANE_MODE_ACTOR_MUSICIAN_POINTS_FLAT' 'Actor mode should define flat Great Musician points.'
Expect-Match $modifiers "\('AKANE_MODE_ACTOR_WRITER_POINTS', 'GreatPersonClassType', 'GREAT_PERSON_CLASS_WRITER'\)" 'Actor mode district writer bonus should target Great Writers.'
Expect-Match $modifiers "\('AKANE_MODE_ACTOR_WRITER_POINTS', 'Amount', '1'\)" 'Actor mode district writer bonus should be +1.'
Expect-Match $modifiers "\('AKANE_MODE_ACTOR_WRITER_POINTS_FLAT', 'GreatPersonClassType', 'GREAT_PERSON_CLASS_WRITER'\)" 'Actor mode flat writer bonus should target Great Writers.'
Expect-Match $modifiers "\('AKANE_MODE_ACTOR_WRITER_POINTS_FLAT', 'Amount', '1'\)" 'Actor mode flat writer bonus should be +1.'
Expect-Match $modifiers "\('AKANE_MODE_ACTOR_MUSICIAN_POINTS', 'GreatPersonClassType', 'GREAT_PERSON_CLASS_MUSICIAN'\)" 'Actor mode district musician bonus should target Great Musicians.'
Expect-Match $modifiers "\('AKANE_MODE_ACTOR_MUSICIAN_POINTS', 'Amount', '1'\)" 'Actor mode district musician bonus should be +1.'
Expect-Match $modifiers "\('AKANE_MODE_ACTOR_MUSICIAN_POINTS_FLAT', 'GreatPersonClassType', 'GREAT_PERSON_CLASS_MUSICIAN'\)" 'Actor mode flat musician bonus should target Great Musicians.'
Expect-Match $modifiers "\('AKANE_MODE_ACTOR_MUSICIAN_POINTS_FLAT', 'Amount', '1'\)" 'Actor mode flat musician bonus should be +1.'
Expect-Match $modeSystem 'AKANE_MODE_ACTOR_WRITER_POINTS' 'Actor mode positive modifier list should include Great Writer points.'
Expect-Match $modeSystem 'AKANE_MODE_ACTOR_WRITER_POINTS_FLAT' 'Actor mode positive modifier list should include flat Great Writer points.'
Expect-Match $modeSystem 'AKANE_MODE_ACTOR_MUSICIAN_POINTS' 'Actor mode positive modifier list should include Great Musician points.'
Expect-Match $modeSystem 'AKANE_MODE_ACTOR_MUSICIAN_POINTS_FLAT' 'Actor mode positive modifier list should include flat Great Musician points.'
Expect-Match $modeSystem 'AKANE_MODE_ACTOR_WRITER_POINTS_NEGATIVE' 'Actor mode negative modifier list should include Great Writer cleanup.'
Expect-Match $modeSystem 'AKANE_MODE_ACTOR_WRITER_POINTS_FLAT_NEGATIVE' 'Actor mode negative modifier list should include flat Great Writer cleanup.'
Expect-Match $modeSystem 'AKANE_MODE_ACTOR_MUSICIAN_POINTS_NEGATIVE' 'Actor mode negative modifier list should include Great Musician cleanup.'
Expect-Match $modeSystem 'AKANE_MODE_ACTOR_MUSICIAN_POINTS_FLAT_NEGATIVE' 'Actor mode negative modifier list should include flat Great Musician cleanup.'

Expect-Match $gameplay 'UnitGreatPersonCreated' 'Great Person recruitment should still trigger a mode reward hook.'
Expect-Match $gameplay 'UnitGreatPersonActivated' 'Great Person retirement should still trigger a leader reward hook.'
Expect-Match $gameplay 'CityMadePurchase' 'Ai mode should still trigger on city purchases.'
Expect-Match $gameplay 'FaithChanged' 'Ai mode should still watch faith balance changes.'
Expect-Match $gameplay 'ChangeGoldBalance' 'Ai mode faith purchases should still refund gold.'
Expect-Match $gameplay 'LOC_AKANE_MODE_ACTOR_INSPIRATION_WORLD_TEXT' 'Actor mode should use its own Inspiration world text.'
Expect-Match $gameplay 'LOC_AKANE_REASONING_EUREKA_WORLD_TEXT' 'Reasoning Master should use its own Eureka world text.'
Expect-NotMatch $gameplay 'LOC_AKANE_MODE_AI_INSPIRATION_WORLD_TEXT' 'Ai mode should no longer use the Great Person Inspiration world text.'
Expect-NotMatch $gameplay 'LOC_AKANE_MODE_ACTOR_EUREKA_WORLD_TEXT' 'Actor mode should no longer use the Great Person Eureka world text.'

Expect-Match $textZh 'LOC_TRAIT_LEADER_KUROKAWA_AKANE_DESCRIPTION' 'Chinese leader text row should exist.'
Expect-Match $textZh 'LOC_TRAIT_LEADER_KUROKAWA_AKANE_DESCRIPTION[\s\S]*\+1 \[ICON_Culture\]' 'Chinese leader text should mention the new +1 culture bonus.'
Expect-NotMatch $textZh 'LOC_TRAIT_LEADER_KUROKAWA_AKANE_DESCRIPTION[\s\S]*图书馆' 'Chinese leader text should no longer mention the Campus science building chain.'
Expect-Match $textZh 'LOC_TRAIT_LEADER_KUROKAWA_AKANE_DESCRIPTION[\s\S]*伟人隐退[\s\S]*尤里卡' 'Chinese leader text should mention the Reasoning Master Eureka reward.'
Expect-Match $textZh '\+16%' 'Chinese text should mention the updated switch buff.'
Expect-Match $textZh 'LOC_UNIT_STAGE_ACTOR_DESCRIPTION' 'Chinese stage actor description row should exist.'
Expect-Match $textZh 'LOC_AKANE_STAGE_ACTOR_PERFORM_TOOLTIP' 'Chinese stage actor tooltip row should exist.'
Expect-Match $textZh 'LOC_AKANE_MODE_AI_TOOLTIP[\s\S]*80%' 'Chinese Ai mode tooltip should still mention the faith purchase gold refund.'
Expect-NotMatch $textZh 'LOC_AKANE_MODE_AI_TOOLTIP[^<]*招募伟人' 'Chinese Ai mode tooltip should no longer mention Great Person Inspiration.'
Expect-NotMatch $textZh 'LOC_AKANE_MODE_ACTOR_TOOLTIP[\s\S]*伟人隐退[\s\S]*尤里卡' 'Chinese Actor mode tooltip should no longer mention Great Person Eureka.'
Expect-Match $textZh 'LOC_AKANE_MODE_ACTOR_TOOLTIP[\s\S]*大作家' 'Chinese Actor mode tooltip should mention Great Writer points.'
Expect-Match $textZh 'LOC_AKANE_MODE_ACTOR_INSPIRATION_WORLD_TEXT' 'Chinese text should define the Actor mode Inspiration world text.'
Expect-Match $textZh 'LOC_AKANE_REASONING_EUREKA_WORLD_TEXT' 'Chinese text should define the Reasoning Master Eureka world text.'

Expect-Match $textEn '\+1 \[ICON_Culture\] Culture' 'English leader text should mention the new +1 culture bonus.'
Expect-NotMatch $textEn 'Libraries, Universities, and Research Labs' 'English leader text should no longer mention the Campus building science chain.'
Expect-Match $textEn 'Great Person retirement grants a random Eureka' 'English leader text should mention the Reasoning Master Eureka reward.'
Expect-Match $textEn 'Scientific Theory' 'English leader text should still mention Scientific Theory.'
Expect-Match $textEn '\+16% to all yields' 'English text should mention the updated switch buff.'
Expect-Match $textEn 'doubled' 'English stage actor text should mention doubled adjacency.'
Expect-Match $textEn '\+30% Tourism' 'English stage actor text should mention the tourism boost.'
Expect-Match $textEn 'Faith-purchased units and buildings refund 80%' 'English Ai mode tooltip should still mention the faith purchase gold refund.'
Expect-NotMatch $textEn 'Hoshino Ai.*recruiting a Great Person grants a random Inspiration' 'English Ai mode tooltip should no longer mention Great Person Inspiration.'
Expect-Match $textEn 'Sayahime.*recruiting a Great Person grants a random Inspiration' 'English Actor mode tooltip should mention Great Person Inspiration.'
Expect-NotMatch $textEn 'Sayahime.*Great Person retirement also grants a random Eureka' 'English Actor mode tooltip should no longer mention Great Person Eureka.'
Expect-Match $textEn 'Great Writer' 'English Actor mode tooltip should mention Great Writer points.'
Expect-Match $textEn 'Great Musician points' 'English Actor mode tooltip should mention Great Musician points.'
Expect-Match $textEn 'LOC_AKANE_MODE_ACTOR_INSPIRATION_WORLD_TEXT' 'English text should define the Actor mode Inspiration world text.'
Expect-Match $textEn 'LOC_AKANE_REASONING_EUREKA_WORLD_TEXT' 'English text should define the Reasoning Master Eureka world text.'
Expect-Match $textZh 'LOC_AKANE_ADJ_LALALAI_TO_ENTERTAINMENT_PRODUCTION' 'Chinese text should define the Entertainment Complex production adjacency row.'
Expect-Match $textZh 'LOC_AKANE_ADJ_LALALAI_TO_WATER_PARK_PRODUCTION' 'Chinese text should define the Water Park production adjacency row.'
Expect-Match $textEn 'Commercial Hubs and Harbors gain \+2 \[ICON_Gold\] Gold' 'English district text should mention +2 gold for Commercial Hubs and Harbors.'
Expect-Match $textEn 'Entertainment Complexes and Water Parks gain \+2 \[ICON_Production\] Production' 'English district text should mention +2 production for Entertainment Complexes and Water Parks.'
Expect-Match $textEn 'Entertainment Complexes, Water Parks,' 'English stage actor tooltip should include Entertainment Complexes and Water Parks in doubled adjacency.'
Expect-Match $textZh 'LOC_AKANE_MODE_WARRIOR_TOOLTIP[\s\S]*80%[\s\S]*ICON_Faith' 'Chinese text should mention Ruby mode''s faith-on-kill reward.'
Expect-Match $textZh 'LOC_AKANE_MODE_WARRIOR_FAITH_REWARD_WORLD_TEXT' 'Chinese text should define Ruby mode''s faith reward world text.'
Expect-Match $textEn 'defeating enemy units grants' 'English text should mention Ruby mode''s faith-on-kill reward.'
Expect-Match $textEn '80%[^<]*Faith' 'English text should mention the 80% faith reward amount.'
Expect-Match $readme '80% Cost[\s\S]*ICON_Faith' 'README should mention Ruby mode''s faith-on-kill reward.'
Expect-Match $readme '基础能力：推理大师[\s\S]*伟人隐退[\s\S]*尤里卡' 'README should move the Great Person Eureka reward into Reasoning Master.'
Expect-NotMatch $textEn 'Scientific Theory[\s\S]*\+15%' 'English leader text should no longer say Scientific Theory gives +15% science.'

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host $_ }
  exit 1
}

Write-Host 'Strengthening verification passed.'
