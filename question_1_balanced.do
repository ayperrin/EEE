/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"Does Directed Innovation Mitigate Climate Damage? Evidence from US Agriculture " 
by Jacob Moscona and Karthik Sastry


*******************************************************************************/
*Set Working Directory:
global project "C:\Users\Marion\Dropbox\Research\Teaching\2023-2024\exam\agriculture\Moscona et al 2024\for students\data"
*******************************************************************************/

clear all
set more off
cd "${project}/Data"

use "$project/yield_heat_balanced.dta",clear

cd "${project}/Results"
*set scheme eop

*******************************************************************************/
*QUESTION 1
*******************************************************************************/

*ssc install ftools
*ssc install reghdfe

describe
tab state
tab fips
tab id
tab id state
sum gddHot_1950
sum yield

*************************
******* Table A.2 *******
*************************

*Only 5 states, we don't cluster the observations
tab state id
reghdfe yield gddHot_1950, absorb(fips id) 
outreg2 using question_1_balanced.xls, replace e(r2_within)

*Cotton
reg yield gddHot_1950 if id==139, r
outreg2 using question_1_crop_balanced.xls,replace 

*Soybeans
reg yield gddHot_1950 if id==130, r
outreg2 using question_1_crop_balanced.xls

*Corn
reg yield gddHot_1950 if id==115, r
outreg2 using question_1_crop_balanced.xls




/******************************************************************************
end of file
*******************************************************************************/
