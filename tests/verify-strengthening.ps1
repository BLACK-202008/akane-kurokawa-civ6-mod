$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot

$districts = Get-Content -Raw (Join-Path $projectRoot 'Data\Akane_Districts.xml')
$units = Get-Content -Raw (Join-Path $projectRoot 'Data\Akane_Units.xml')
$modifiers = Get-Content -Raw (Join-Path $projectRoot 'Data\Akane_Modifiers.sql')
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

Expect-NotMatch $units 'UnitReplaces' 'Stage Actor should no longer replace Rock Band.'
Expect-NotMatch $units 'CLASS_ROCK_BAND' 'Stage Actor should not retain the Rock Band class tag.'
Expect-NotMatch $units 'PROMOTION_CLASS_ROCK_BAND' 'Stage Actor should not retain Rock Band promotions.'
Expect-NotMatch $units 'NumRandomChoices' 'Stage Actor should not expose Rock Band promotion choices.'
Expect-NotMatch $units 'InitialLevel=' 'Stage Actor should not start with Rock Band promotion level data.'

Expect-Match $modifiers "\('AKANE_CITY_SCIENCE_FROM_LALALAI', 'Amount', '20'\)" 'Adjacent district building boost should be +20%.'
Expect-Match $modifiers "\('AKANE_CITY_GOLD_FROM_LALALAI_COMMERCIAL', 'Amount', '20'\)" 'Commercial Hub building boost should be +20%.'
Expect-Match $modifiers "\('AKANE_CITY_GOLD_FROM_LALALAI_HARBOR', 'Amount', '20'\)" 'Harbor building boost should be +20%.'
Expect-Match $modifiers "\('AKANE_CITY_PRODUCTION_FROM_LALALAI_ENCAMPMENT', 'Amount', '20'\)" 'Encampment building boost should be +20%.'
Expect-Match $modifiers "\('AKANE_CITY_PRODUCTION_FROM_LALALAI_INDUSTRIAL', 'Amount', '20'\)" 'Industrial Zone building boost should be +20%.'
Expect-Match $modifiers "\('AKANE_CITY_FAITH_FROM_LALALAI_HOLY_SITE', 'Amount', '20'\)" 'Holy Site building boost should be +20%.'

Expect-Match $gameplay 'PROPERTY_PLAYER_ART_STACKS' 'Art Prosperity should track player-wide stacks.'
Expect-Match $gameplay 'PROPERTY_PLAYER_ART_TURNS' 'Art Prosperity should track player-wide duration.'
Expect-Match $gameplay 'Players\[playerID\]' 'Art Prosperity strengthening should operate at player scope.'

Expect-Match $modifiers "\('AKANE_MODE_ACTOR_TOURISM_PERCENT', 'MODIFIER_PLAYER_ADJUST_TOURISM', NULL\)" 'Sayahime mode should add a tourism modifier.'
Expect-Match $modifiers "\('AKANE_MODE_ACTOR_TOURISM_PERCENT', 'Amount', '30'\)" 'Sayahime tourism modifier should be +30%.'

Expect-Match $modifiers "\('AKANE_MODE_SWITCH_BUFF_FOOD', 'Amount', '8'\)" 'Mode switch all-yield buff should be +8%.'
Expect-Match $modifiers "\('AKANE_MODE_SWITCH_BUFF_GOLD', 'Amount', '8'\)" 'Mode switch all-yield buff should be +8%.'
Expect-Match $modeSystem 'GrantSwitchGoldReward' 'Mode switch should grant a gold reward.'
Expect-Match $modeSystem 'currentTurn \+ 9' 'Gold reward should scale with current turn plus 9.'
Expect-Match $modeSystem '\* 4' 'Mode switch gold reward should now use half-strength scaling.'
Expect-NotMatch $modeSystem '\(currentTurn \+ 9\) \* 8' 'Mode switch gold reward should no longer use the old full-strength scaling.'

Expect-Match $modifiers "\('AKANE_CAMPUS_SCIENCE_FROM_ADJACENT_LALALAI', 'MODIFIER_PLAYER_DISTRICTS_ADJUST_YIELD_CHANGE', 'AKANE_DISTRICT_IS_CAMPUS_AND_ADJ_LALALAI'\)" 'Leader base ability should add science to Campuses adjacent to LALALAI.'
Expect-Match $modifiers "\('AKANE_CAMPUS_SCIENCE_FROM_ADJACENT_LALALAI', 'YieldType', 'YIELD_SCIENCE'\)" 'Adjacent Campus bonus should grant science.'
Expect-Match $modifiers "\('AKANE_CAMPUS_SCIENCE_FROM_ADJACENT_LALALAI', 'Amount', '1'\)" 'Adjacent Campus bonus should grant +1 science.'

Expect-Match $textZh '\+20%' 'Chinese text should describe strengthened bonuses.'
Expect-Match $textZh 'LOC_AKANE_MODE_ACTOR_TOOLTIP[\s\S]*\+30%' 'Chinese text should mention Sayahime tourism bonus.'
Expect-Match $textEn '\+20%' 'English text should describe strengthened bonuses.'
Expect-Match $textEn 'Tourism' 'English text should mention Sayahime tourism bonus.'

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Strengthening verification passed.'
