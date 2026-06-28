$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/TestHelpers.ps1"

$requirements = Get-TestContent 'Data\Akane_Requirements.sql'
$modifiers = Get-TestContent 'Data\Akane_Modifiers.sql'
$failures = New-FailureList

Expect-Match $requirements "AKANE_REQUIRES_CITY_HAS_CAMPUS', 'RequirementSetId', 'AKANE_CITY_HAS_ANY_CAMPUS'" $failures 'City district checks should resolve Campus replacements through an aggregate requirement set.'
Expect-Match $requirements "AKANE_REQUIRES_DISTRICT_IS_CAMPUS', 'RequirementSetId', 'AKANE_DISTRICT_IS_ANY_CAMPUS'" $failures 'District type checks should resolve Campus replacements through an aggregate requirement set.'
Expect-Match $requirements "AKANE_REQUIRES_CITY_HAS_BUILDING_LIBRARY', 'RequirementSetId', 'AKANE_CITY_HAS_ANY_BUILDING_LIBRARY'" $failures 'Building checks should resolve Library replacements through an aggregate requirement set.'
Expect-Match $requirements 'DistrictReplaces' $failures 'Requirements should auto-expand unique replacement districts from the gameplay database.'
Expect-Match $requirements 'BuildingReplaces' $failures 'Requirements should auto-expand unique replacement buildings from the gameplay database.'

Expect-Match $modifiers 'INSERT INTO District_Adjacencies \(DistrictType, YieldChangeId\)' $failures 'LALALAI adjacency data should auto-attach to unique replacement districts.'
Expect-Match $modifiers 'INSERT INTO Adjacency_YieldChanges \(ID, Description, YieldType, YieldChange, TilesRequired, AdjacentDistrict\)' $failures 'LALALAI should synthesize adjacency definitions for captured Entertainment and Water Park replacements.'
Expect-Match $modifiers 'AKANE_DISTRICT_IS_ANY_HOLY_SITE' $failures 'Holy Site replacement-aware requirement set should be used by modifiers.'
Expect-Match $modifiers 'AKANE_DISTRICT_IS_ANY_ENCAMPMENT' $failures 'Encampment replacement-aware requirement set should be used by modifiers.'

Complete-Test $failures 'Unique replacement coverage verification passed.'
