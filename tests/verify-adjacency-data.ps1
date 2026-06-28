$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/TestHelpers.ps1"

$districts = Get-TestContent 'Data\Akane_Districts.xml'
$requirements = Get-TestContent 'Data\Akane_Requirements.sql'
$failures = New-FailureList

Expect-Match $districts 'Lalalai_CityCenter_Gold' $failures 'LALALAI should still keep its city-center gold adjacency.'
Expect-Match $districts 'Lalalai_Wonder_Gold' $failures 'LALALAI should still keep its wonder gold adjacency.'
Expect-Match $districts 'Lalalai_To_Campus_Science' $failures 'LALALAI should still grant Campus adjacency.'
Expect-Match $districts 'Lalalai_To_CommercialHub_Gold[\s\S]*YieldChange="2"' $failures 'Commercial Hub adjacency from LALALAI should now be +2 gold.'
Expect-Match $districts 'Lalalai_To_Harbor_Gold[\s\S]*YieldChange="2"' $failures 'Harbor adjacency from LALALAI should now be +2 gold.'
Expect-Match $districts 'Lalalai_To_EntertainmentComplex_Production' $failures 'LALALAI should now grant Entertainment Complex production adjacency.'
Expect-Match $districts 'Lalalai_To_WaterPark_Production' $failures 'LALALAI should now grant Water Park production adjacency.'
Expect-NotMatch $districts 'Lalalai_Entertainment_Culture' $failures 'LALALAI should not define a duplicate Entertainment Complex culture adjacency row.'

Expect-Match $requirements 'AKANE_DISTRICT_IS_INDUSTRIAL_ZONE_AND_ADJ_LALALAI' $failures 'Industrial Zone adjacency requirement set should exist for stage doubling.'
Expect-Match $requirements 'AKANE_DISTRICT_IS_ENTERTAINMENT_COMPLEX_AND_ADJ_LALALAI' $failures 'Entertainment Complex adjacency requirement set should exist for stage doubling.'
Expect-Match $requirements 'AKANE_DISTRICT_IS_WATER_PARK_AND_ADJ_LALALAI' $failures 'Water Park adjacency requirement set should exist for stage doubling.'
Expect-Match $requirements 'AKANE_DISTRICT_IS_CAMPUS_AND_ADJ_LALALAI' $failures 'Campus adjacency requirement set should exist for stage doubling.'
Expect-Match $requirements 'AKANE_DISTRICT_IS_COMMERCIAL_HUB_AND_ADJ_LALALAI' $failures 'Commercial Hub adjacency requirement set should exist for stage doubling.'
Expect-Match $requirements 'AKANE_DISTRICT_IS_HARBOR_AND_ADJ_LALALAI' $failures 'Harbor adjacency requirement set should exist for stage doubling.'
Expect-Match $requirements 'AKANE_DISTRICT_IS_ENCAMPMENT_AND_ADJ_LALALAI' $failures 'Encampment adjacency requirement set should exist for stage doubling.'
Expect-Match $requirements 'AKANE_DISTRICT_IS_HOLY_SITE_AND_ADJ_LALALAI' $failures 'Holy Site adjacency requirement set should exist for stage doubling.'

Complete-Test $failures 'Adjacency data verification passed.'
