/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"Does Directed Innovation Mitigate Climate Damage? Evidence from US Agriculture " 
by Jacob Moscona and Karthik Sastry


*******************************************************************************/
*Set Working Directory:
global project "C:\Users\Boubou\Documents\macro\Empirical-Environmental-Economics"
*******************************************************************************/

clear all
set more off
cd "${project}/Data"

use yield_heat_unbalanced.dta

use "$project/yield_heat_unbalanced.dta",clear
cd "${project}/Results"
*set scheme eop

*******************************************************************************/
*QUESTION 1
*******************************************************************************/

*ssc install ftools
*ssc install reghdfe

describe
tab state
tab id
tab state id
sum gddHot_1950
sum yield

*************************
******* Table A.2 *******
*************************

reghdfe yield gddHot_1950, absorb(id) cluster(state)
outreg2 using question_1_unbalanced.xls,replace e(r2_within)

reghdfe yield gddHot_1950 if id == 115 | id == 130, absorb(id) cluster(state)
outreg2 using question_1_unbalanced.xls, e(r2_within)

*Less than 20 states, we don't cluster the observations
*Cotton
tab state id if id==139
reg yield gddHot_1950 if id==139, r
outreg2 using question_1_crop_unbalanced.xls,replace

*Soybeans
tab state id if id==130
reg yield gddHot_1950 if id==130, r
outreg2 using question_1_crop_unbalanced.xls

*Corn
tab state id if id==115
reg yield gddHot_1950 if id==115, r
outreg2 using question_1_crop_unbalanced.xls


**************************
******** Figure 2 ********
**************************

cd "${project}/Data"

use crop_level_data.dta

cd "${project}/Results"

sort id year 

twoway (connected delta_hot_gdd_panel year if crop_censusname=="Corn" & year>1950, yaxis(1) ytitle(Change in Extreme Exposure) xtitle(Year))
graph export "${project}/Results/Figure_2_corn.pdf",replace

twoway (connected delta_hot_gdd_panel year if crop_censusname=="Cotton" & year>1950, yaxis(1) ytitle(Change in Extreme Exposure) xtitle(Year))
graph export "${project}/Results/Figure_2_cotton.pdf",replace

twoway (connected delta_hot_gdd_panel year if crop_censusname=="Soybeans" & year>1950, yaxis(1) ytitle(Change in Extreme Exposure) xtitle(Year))
graph export "${project}/Results/Figure_2_soy.pdf",replace
/******************************************************************************
end of file
*******************************************************************************/
