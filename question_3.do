/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"Does Directed Innovation Mitigate Climate Damage? Evidence from US Agriculture " 
by Jacob Moscona and Karthik Sastry

Crop-level analysis (Table 3 and Figure 6)

** Before running, set working directory on line 11 

*******************************************************************************/
*Set Working Directory:
global project "C:\Users\Boubou\Documents\macro\Empirical-Environmental-Economics"
*******************************************************************************/

clear all
set more off
cd "${project}/Data"

use "$project/county_level_data.dta"

cd "${project}/Results"
*set scheme eop


**************************
******** Figure 6 ********
**************************

preserve
gen quantile = _n
replace quantile = . if quantile>100
gen beta_quant = .
gen se_quant = .
sum ee if year==1950|year==2010,d
reghdfe lland_value_acre ee loo ee_innov if year==1950 | year==2010, absorb(id year#state) cluster(id state_year)
outreg2 using question_3_1.xls
lincom loo + 0.435830*ee_innov
replace beta_quant = r(estimate) if quantile==10
replace se_quant = r(se) if quantile==10
lincom loo + 0.726166*ee_innov
replace beta_quant = r(estimate) if quantile==25
replace se_quant = r(se) if quantile==25
lincom loo + 1.064151*ee_innov
replace beta_quant = r(estimate) if quantile==50
replace se_quant = r(se) if quantile==50
lincom loo + 1.731524*ee_innov
replace beta_quant = r(estimate) if quantile==75
replace se_quant = r(se) if quantile==75
lincom loo + 3.076708*ee_innov
replace beta_quant = r(estimate) if quantile==90
replace se_quant = r(se) if quantile==90

gen ci_up = beta_quant + 1.96*se_quant
gen ci_down = beta_quant - 1.96*se_quant
gen ci_up_90 = beta_quant + 1.645*se_quant
gen ci_down_90 = beta_quant - 1.645*se_quant

tw (rcap ci_up ci_down quantile ,  lcolor(gray) lpattern(shortdash)) (rcap ci_up_90 ci_down_90 quantile ,  lcolor(gray)) (scatter beta_quant quantile, color(black) msize(medium) mlwidth(medthick)) , xtitle(Extreme Temperature Exposure Quantile) ytitle(Marginal Effect of Innovation Exposure) legend(off) yline(0, lcolor(black)) xlabel(0 10 25 50 75 90 100)
graph export "${project}/Results/question_3.pdf",replace
restore


/******************************************************************************
end of file
*******************************************************************************/
