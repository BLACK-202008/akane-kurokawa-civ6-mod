$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/TestHelpers.ps1"

$modifiers = Get-TestContent 'Data\Akane_Modifiers.sql'
$requirements = Get-TestContent 'Data\Akane_Requirements.sql'
$failures = New-FailureList

Expect-Match $requirements "AKANE_REQUIRES_CITY_HAS_BUILDING_ART_MUSEUM', 'RequirementSetId', 'AKANE_CITY_HAS_ANY_BUILDING_ART_MUSEUM'" $failures 'Stage reward requirements should resolve Art Museum replacements through an aggregate requirement set.'
Expect-Match $requirements "AKANE_REQUIRES_CITY_HAS_BUILDING_ARCHAEOLOGICAL_MUSEUM', 'RequirementSetId', 'AKANE_CITY_HAS_ANY_BUILDING_ARCHAEOLOGICAL_MUSEUM'" $failures 'Stage reward requirements should resolve Archaeological Museum replacements through an aggregate requirement set.'
Expect-Match $requirements "AKANE_REQUIRES_CITY_HAS_BUILDING_ART_MUSEUM_BASE', 'BuildingType', 'BUILDING_MUSEUM_ART'" $failures 'Art Museum aggregate requirements should still target the real Art Museum building type at the base layer.'
Expect-Match $requirements "AKANE_REQUIRES_CITY_HAS_BUILDING_ARCHAEOLOGICAL_MUSEUM_BASE', 'BuildingType', 'BUILDING_MUSEUM_ARTIFACT'" $failures 'Archaeological Museum aggregate requirements should still target the real Archaeological Museum building type at the base layer.'
Expect-Match $requirements 'BuildingReplaces' $failures 'Building chain requirements should auto-expand unique replacement buildings.'

Expect-Match $modifiers "\('AKANE_BUILDING_COAL_POWER_PLANT_FROM_LALALAI', 'BuildingType', 'BUILDING_COAL_POWER_PLANT'\)" $failures 'Industrial Zone building boosts should include Coal Power Plants.'
Expect-Match $modifiers "\('AKANE_BUILDING_FOSSIL_FUEL_POWER_PLANT_FROM_LALALAI', 'BuildingType', 'BUILDING_FOSSIL_FUEL_POWER_PLANT'\)" $failures 'Industrial Zone building boosts should include Oil Power Plants.'
Expect-Match $modifiers "\('AKANE_BUILDING_POWER_PLANT_FROM_LALALAI', 'BuildingType', 'BUILDING_POWER_PLANT'\)" $failures 'Industrial Zone building boosts should still include Nuclear Power Plants.'
Expect-Match $modifiers "\('TRAIT_CIVILIZATION_LALALAI', 'AKANE_BUILDING_COAL_POWER_PLANT_FROM_LALALAI'\)" $failures 'Civilization trait should attach the Coal Power Plant boost.'
Expect-Match $modifiers "\('TRAIT_CIVILIZATION_LALALAI', 'AKANE_BUILDING_FOSSIL_FUEL_POWER_PLANT_FROM_LALALAI'\)" $failures 'Civilization trait should attach the Oil Power Plant boost.'
Expect-Match $modifiers "\('TRAIT_CIVILIZATION_LALALAI', 'AKANE_BUILDING_POWER_PLANT_FROM_LALALAI'\)" $failures 'Civilization trait should attach the Nuclear Power Plant boost.'

Complete-Test $failures 'Building chain verification passed.'
