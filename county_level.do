/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"Does Directed Innovation Mitigate Climate Damage? Evidence from US Agriculture " 
by Jacob Moscona and Karthik Sastry

Crop-level analysis (Table 3 and Figure 6)

** Before running, set working directory on line 11 

*******************************************************************************/
*Set Working Directory:
global project ".../Replication"
*******************************************************************************/

clear all
set more off
cd "${project}/Data"

use county_level_data.dta

cd "${project}/Results"
set scheme eop


*************************
******** Table 3 ********
*************************

reghdfe lland_value_acre ee loo ee_innov if year==1950 | year==2010, absorb(id year#state) cluster(id state_year)
outreg2 using Table_3.xls, keep(ee ee_innov)
reghdfe lland_value_acre ee loo ee_innov [aweight = area_init] if year==1950 | year==2010, absorb(id year#state) cluster(id state_year)
outreg2 using Table_3.xls, keep(ee ee_innov)
reghdfe lland_value_acre ee loo ee_innov logprice_own ee_price if year==1950 | year==2010, absorb(id year#state) cluster(id state_year)
outreg2 using Table_3.xls, keep(ee ee_innov)
reghdfe lland_value_acre ee loo ee_innov avgtemp_own avgtemp_loo avgtemp_interaction if year==1950 | year==2010, absorb(id year#state) cluster(id state_year)
outreg2 using Table_3.xls, keep(ee ee_innov)
reghdfe lland_value_acre ee loo ee_innov logprice_own ee_price avgtemp_own avgtemp_loo avgtemp_interaction if year==1950 | year==2010, absorb(id year#state) cluster(id state_year)
outreg2 using Table_3.xls, keep(ee ee_innov)
reghdfe lland_value_acre ee loo ee_innov , absorb(id year#state) cluster(id state_year)
outreg2 using Table_3.xls, keep(ee ee_innov)
reghdfe lland_value_acre ee loo ee_innov  [aweight = area_init], absorb(id year#state) cluster(id state_year)
outreg2 using Table_3.xls, keep(ee ee_innov)


**************************
******** Figure 6 ********
**************************

preserve
gen quantile = _n
replace quantile = . if quantile>100
gen beta_quant = .
gen se_quant = .
reghdfe lland_value_acre ee loo ee_innov if year==1950 | year==2010, absorb(id year#state) cluster(id state_year)
lincom ee + .3718689*ee_innov
replace beta_quant = r(estimate) if quantile==10
replace se_quant = r(se) if quantile==10
lincom ee + .8036412*ee_innov
replace beta_quant = r(estimate) if quantile==25
replace se_quant = r(se) if quantile==25
lincom ee + 1.298155*ee_innov
replace beta_quant = r(estimate) if quantile==50
replace se_quant = r(se) if quantile==50
lincom ee + 1.959741*ee_innov
replace beta_quant = r(estimate) if quantile==75
replace se_quant = r(se) if quantile==75
lincom ee + 2.779312*ee_innov
replace beta_quant = r(estimate) if quantile==90
replace se_quant = r(se) if quantile==90

gen ci_up = beta_quant + 1.96*se_quant
gen ci_down = beta_quant - 1.96*se_quant
gen ci_up_90 = beta_quant + 1.645*se_quant
gen ci_down_90 = beta_quant - 1.645*se_quant

tw (rcap ci_up ci_down quantile ,  lcolor(gray) lpattern(shortdash)) (rcap ci_up_90 ci_down_90 quantile ,  lcolor(gray)) (scatter beta_quant quantile, color(black) msize(medium) mlwidth(medthick)) , xtitle(Innovation Exposure Quantile) ytitle(Marginal Effect of Extreme Temperature Exposure) legend(off) yline(0, lcolor(black)) xlabel(0 10 25 50 75 90 100)
graph export "${project}/Results/Figure_6.pdf",replace
restore


/******************************************************************************
end of file
*******************************************************************************/
