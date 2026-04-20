$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/TestHelpers.ps1"

$modifiers = Get-TestContent 'Data\Akane_Modifiers.sql'
$requirements = Get-TestContent 'Data\Akane_Requirements.sql'
$failures = New-FailureList

Expect-Match $requirements "AKANE_REQUIRES_CITY_HAS_BUILDING_ART_MUSEUM', 'BuildingType', 'BUILDING_MUSEUM_ART'" $failures 'Stage reward requirements should target the real Art Museum building type.'
Expect-Match $requirements "AKANE_REQUIRES_CITY_HAS_BUILDING_ARCHAEOLOGICAL_MUSEUM', 'BuildingType', 'BUILDING_MUSEUM_ARTIFACT'" $failures 'Stage reward requirements should target the real Archaeological Museum building type.'
Expect-NotMatch $requirements "AKANE_REQUIRES_CITY_HAS_BUILDING_ART_MUSEUM', 'BuildingType', 'BUILDING_ART_MUSEUM'" $failures 'Stage reward requirements should not use the wrong Art Museum building type id.'
Expect-NotMatch $requirements "AKANE_REQUIRES_CITY_HAS_BUILDING_ARCHAEOLOGICAL_MUSEUM', 'BuildingType', 'BUILDING_ARCHAEOLOGICAL_MUSEUM'" $failures 'Stage reward requirements should not use the wrong Archaeological Museum building type id.'

Expect-Match $modifiers "\('AKANE_BUILDING_COAL_POWER_PLANT_FROM_LALALAI', 'BuildingType', 'BUILDING_COAL_POWER_PLANT'\)" $failures 'Industrial Zone building boosts should include Coal Power Plants.'
Expect-Match $modifiers "\('AKANE_BUILDING_FOSSIL_FUEL_POWER_PLANT_FROM_LALALAI', 'BuildingType', 'BUILDING_FOSSIL_FUEL_POWER_PLANT'\)" $failures 'Industrial Zone building boosts should include Oil Power Plants.'
Expect-Match $modifiers "\('AKANE_BUILDING_POWER_PLANT_FROM_LALALAI', 'BuildingType', 'BUILDING_POWER_PLANT'\)" $failures 'Industrial Zone building boosts should still include Nuclear Power Plants.'
Expect-Match $modifiers "\('TRAIT_CIVILIZATION_LALALAI', 'AKANE_BUILDING_COAL_POWER_PLANT_FROM_LALALAI'\)" $failures 'Civilization trait should attach the Coal Power Plant boost.'
Expect-Match $modifiers "\('TRAIT_CIVILIZATION_LALALAI', 'AKANE_BUILDING_FOSSIL_FUEL_POWER_PLANT_FROM_LALALAI'\)" $failures 'Civilization trait should attach the Oil Power Plant boost.'
Expect-Match $modifiers "\('TRAIT_CIVILIZATION_LALALAI', 'AKANE_BUILDING_POWER_PLANT_FROM_LALALAI'\)" $failures 'Civilization trait should attach the Nuclear Power Plant boost.'

Complete-Test $failures 'Building chain verification passed.'
