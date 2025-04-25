/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"Does Directed Innovation Mitigate Climate Damage? Evidence from US Agriculture " 
by Jacob Moscona and Karthik Sastry

Crop-level analysis (Tables 1, 2 and Figures 2, 3, 4, 5)

** Before running, set working directory on line 11 

*******************************************************************************/
*Set Working Directory:
global project ".../Replication"
*******************************************************************************/

clear all
set more off
cd "${project}/Data"

use crop_level_data.dta

cd "${project}/Results"
set scheme eop

*************************
******** Table 1 ********
*************************

poisson ld_variety ld_hot_gdd_50 log_total_area, r
outreg2 using Table_1.xls, keep(ld_hot_gdd_50)
poisson ld_variety ld_hot_gdd_50 log_total_area pre_precip pre_avgtemp, r
outreg2 using Table_1.xls, keep(ld_hot_gdd_50)
poisson ld_variety ld_hot_gdd_50 log_total_area pre_precip pre_avgtemp asinh_ncrop_1960, r
outreg2 using Table_1.xls, keep(ld_hot_gdd_50)
poisson ld_variety ld_hot_gdd_50 log_total_area pre_precip pre_avgtemp asinh_ncrop_1960 max_temp max_temp_2, r
outreg2 using Table_1.xls, keep(ld_hot_gdd_50)
poisson ld_variety ld_hot_gdd_50 ld_avgtemp log_total_area pre_precip pre_avgtemp asinh_ncrop_1960 max_temp max_temp_2, r
outreg2 using Table_1.xls, keep(ld_hot_gdd_50)
poisson ld_variety80 ld_hot_gdd_80 log_total_area pre_precip pre_avgtemp asinh_ncrop_1960 max_temp max_temp_2, r
outreg2 using Table_1.xls, keep(ld_hot_gdd_80)


*************************
******** Table 2 ********
*************************

poisson tot_1960_2020_USA_not_cc ld_hot_gdd_50 log_total_area pre_precip pre_avgtemp max_temp max_temp_2 tot_1960_not_cc_USA if year==2010, r
outreg2 using Table_2.xls, keep(ld_hot_gdd_50)
poisson tot_1960_2020_USA_cc ld_hot_gdd_50 log_total_area pre_precip pre_avgtemp max_temp max_temp_2 tot_1960_cc_USA if year==2010, r
outreg2 using Table_2.xls, keep(ld_hot_gdd_50)


**************************
******** Figure 2 ********
**************************

sort id year 

twoway (connected ncrop_panel_log year if crop_censusname=="Corn" & year>1950, yaxis(1) ytitle(log New Varieties Released))(connected delta_hot_gdd_panel year if crop_censusname=="Corn"  & year>1950, ytitle(Change in Extreme Exposure, axis(2)) yaxis(2) legend(label(1 "New Varieties") label(2 "Extreme Exposure")) title(Corn))
graph export "${project}/Results/Figure_2a_corn.pdf",replace

twoway (connected ncrop_panel_log year if crop_censusname=="Cotton" & year>1950, yaxis(1) ytitle(log New Varieties Released))(connected delta_hot_gdd_panel year if crop_censusname=="Cotton"  & year>1950, ytitle(Change in Extreme Exposure, axis(2)) yaxis(2) legend(label(1 "New Varieties") label(2 "Extreme Exposure")) title(Cotton))
graph export "${project}/Results/Figure_2b_cotton.pdf",replace

twoway (connected ncrop_panel_log year if crop_censusname=="Rice" & year>1950, yaxis(1) ytitle(log New Varieties Released))(connected delta_hot_gdd_panel year if crop_censusname=="Rice"  & year>1950, ytitle(Change in Extreme Exposure, axis(2)) yaxis(2) legend(label(1 "New Varieties") label(2 "Extreme Exposure")) title(Rice))
graph export "${project}/Results/Figure_2c_rice.pdf",replace

twoway (connected ncrop_panel_log year if crop_censusname=="lettuce and romaine" & year>1950, yaxis(1) ytitle(log New Varieties Released))(connected delta_hot_gdd_panel year if crop_censusname=="lettuce and romaine"  & year>1950, ytitle(Change in Extreme Exposure, axis(2)) yaxis(2) legend(label(1 "New Varieties") label(2 "Extreme Exposure")) title(Lettuces))
graph export "${project}/Results/Figure_2d_lettuce.pdf",replace

twoway (connected ncrop_panel_log year if crop_censusname=="carrots" & year>1950, yaxis(1) ytitle(log New Varieties Released))(connected delta_hot_gdd_panel year if crop_censusname=="carrots"  & year>1950, ytitle(Change in Extreme Exposure, axis(2)) yaxis(2) legend(label(1 "New Varieties") label(2 "Extreme Exposure")) title(Carrot))
graph export "${project}/Results/Figure_2e_carrots.pdf",replace

twoway (connected ncrop_panel_log year if  year>1950 & id==46, yaxis(1) ytitle(log New Varieties Released))(connected delta_hot_gdd_panel year if id==46  & year>1950, ytitle(Change in Extreme Exposure, axis(2)) yaxis(2) legend(label(1 "log New Varieties Released") label(2 "Extreme Exposure")) title(Lima Beans))
graph export "${project}/Results/Figure_2f_lima_beans.pdf",replace


**************************
******** Figure 3 ********
**************************

preserve
replace ld_hot_gdd_50 = ld_hot_gdd_50*10
replace ld_hot_gdd_80 = ld_hot_gdd_80*10
reg asinh_ld_variety ld_hot_gdd_50 log_total_area pre_precip pre_avgtemp asinh_ncrop_1960, r
avplot ld_hot_gdd_50, xtitle({&Delta} ExtremeExposure | X ) ytitle({&Delta} asinh(Varieties) | X) mcolor(eltblue) lcolor(navy) mlabel(graph_name) mlabsize(small) mcolor(%10) xscale(r(-500 800)) xlabel(-500(100)800) ylabel(-3(1)4) yscale(r(-3 4))
graph export "${project}/Results/Figure_3a.pdf",replace
reg asinh_ld_variety5080 ld_hot_gdd_80 log_total_area pre_precip pre_avgtemp asinh_ncrop_1960  if year==2010, r
avplot ld_hot_gdd_80,  xtitle({&Delta} ExtremeExposure 1980 to Present | X ) ytitle({&Delta} asinh(Varieties) 1950 to 1980 | X) mcolor(eltblue) lcolor(navy) mlabel(graph_name) mlabsize(small) mcolor(%10) xscale(r(-500 800)) xlabel(-500(100)800)
graph export "${project}/Results/Figure_3b.pdf",replace
restore


**************************
******** Figure 4 ********
**************************

preserve 
xtset id t
replace hot_gdd_panel = hot_gdd_panel/10
gen temp = .
replace temp = _n
gen x_axis = .
replace x_axis = -2 if temp==1
replace x_axis = -1 if temp==2
replace x_axis = 0 if temp==3
replace x_axis = 1 if temp==4
replace x_axis = 2 if temp==5
gen beta = .
gen se = .
ppmlhdfe ncrop  f2.hot_gdd_panel hot_gdd_panel  larea_yr_* ncrop60_yr_*   ,cluster(id) absorb(id t) 
replace beta= _b[f2.hot_gdd_panel] if temp==1
replace se= _se[f2.hot_gdd_panel] if temp==1
ppmlhdfe ncrop  f.hot_gdd_panel hot_gdd_panel  larea_yr_* ncrop60_yr_*   ,cluster(id) absorb(id t) 
replace beta= _b[f.hot_gdd_panel] if temp==2
replace se= _se[f.hot_gdd_panel] if temp==2
ppmlhdfe ncrop   hot_gdd_panel  larea_yr_* ncrop60_yr_*   ,cluster(id) absorb(id t) 
replace beta= _b[hot_gdd_panel] if temp==3
replace se= _se[hot_gdd_panel] if temp==3
ppmlhdfe ncrop   hot_gdd_panel l.hot_gdd_panel  larea_yr_* ncrop60_yr_*   ,cluster(id) absorb(id t) 
replace beta= _b[l.hot_gdd_panel] if temp==4
replace se= _se[l.hot_gdd_panel] if temp==4
ppmlhdfe ncrop   hot_gdd_panel l2.hot_gdd_panel  larea_yr_* ncrop60_yr_*   ,cluster(id) absorb(id t) 
replace beta= _b[l2.hot_gdd_panel] if temp==5
replace se= _se[l2.hot_gdd_panel] if temp==5
gen ci_up = beta + 1.96*se
gen ci_down = beta - 1.96*se
gen ci_up_90 = beta + 1.645*se
gen ci_down_90 = beta - 1.645*se
drop if beta==.
tw (rcap ci_up ci_down x_axis ,  lcolor(gray) lpattern(shortdash)) (rcap ci_up_90 ci_down_90 x_axis ,  lcolor(gray)) (scatter beta x_axis, color(black) msize(medium) mlwidth(medthick)) , xtitle(Decade Relative to Temperature Distress Shock) ytitle(Coefficient Estimate (New Varieties)) legend(off) yline(0, lcolor(black))
graph export "${project}/Results/Figure_4.pdf",replace
restore


**************************
******** Figure 5 ********
**************************

reg share_patent_cc ld_hot_gdd_50 log_total_area pre_precip pre_avgtemp tot_1960_not_cc_USA tot_1960_cc_USA , r
avplot ld_hot_gdd_50,  xtitle({&Delta} ExtremeExposure | X ) ytitle({&Delta} Share Climate Patents (1960-Present) | X) mcolor(eltblue) lcolor(navy) mlabel(graph_name) mlabsize(small) mcolor(%10)  plotregion(margin(0))  ylabel(,angle(horizontal) format(%3.1f))
graph export "${project}/Results/Figure_5.pdf",replace



/******************************************************************************
end of file
*******************************************************************************/





