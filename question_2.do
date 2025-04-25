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

use "$project/crop_level_data_adapted.dta"

cd "${project}/Results"
*set scheme eop

*******************************************************************************/
*QUESTION 2
*******************************************************************************/

sum ld_variety_70,d
sum ld_hot_gdd_70,d
sum log_total_area,d


*************************
******* Table 1.1 *******
*************************

poisson ld_variety_70 ld_hot_gdd_70 log_total_area, r
outreg2 using question_2_1.xls, keep(ld_hot_gdd_70) e(r2_p)replace
poisson ld_variety_70 ld_hot_gdd_70 log_total_area pre_precip pre_avgtemp, r
outreg2 using question_2_1.xls, keep(ld_hot_gdd_70)e(r2_p)
poisson ld_variety_70 ld_hot_gdd_70 log_total_area pre_precip pre_avgtemp asinh_ncrop_1960, r
outreg2 using question_2_1.xls, keep(ld_hot_gdd_70)e(r2_p)
poisson ld_variety_70 ld_hot_gdd_70 log_total_area pre_precip pre_avgtemp asinh_ncrop_1960 max_temp max_temp_2, r
outreg2 using question_2_1.xls, keep(ld_hot_gdd_70)e(r2_p)
*poisson ld_variety_70 ld_hot_gdd_70 ld_avgtemp log_total_area pre_precip pre_avgtemp asinh_ncrop_1960 max_temp max_temp_2, r
*outreg2 using question_2_1.xls, keep(ld_hot_gdd_70)
*poisson ld_variety80 ld_hot_gdd_80 log_total_area pre_precip pre_avgtemp asinh_ncrop_1960 max_temp max_temp_2, r
*outreg2 using question_2_1.xls, keep(ld_hot_gdd_80)

*************************
******* Table 1.2 *******
*************************

reg ld_variety_70 ld_hot_gdd_70 log_total_area, r
outreg2 using question_2_2.xls, keep(ld_hot_gdd_70)replace
reg ld_variety_70 ld_hot_gdd_70 log_total_area pre_precip pre_avgtemp, r
outreg2 using question_2_2.xls, keep(ld_hot_gdd_70)
reg ld_variety_70 ld_hot_gdd_70 log_total_area pre_precip pre_avgtemp asinh_ncrop_1960, r
outreg2 using question_2_2.xls, keep(ld_hot_gdd_70)
reg ld_variety_70 ld_hot_gdd_70 log_total_area pre_precip pre_avgtemp asinh_ncrop_1960 max_temp max_temp_2, r
outreg2 using question_2_2.xls, keep(ld_hot_gdd_70)
*reg ld_variety_70 ld_hot_gdd_70 ld_avgtemp log_total_area pre_precip pre_avgtemp asinh_ncrop_1960 max_temp max_temp_2, r
*outreg2 using question_2_2.xls, keep(ld_hot_gdd_70)
*reg ld_variety80 ld_hot_gdd_80 log_total_area pre_precip pre_avgtemp asinh_ncrop_1960 max_temp max_temp_2, r
*outreg2 using question_2_2.xls, keep(ld_hot_gdd_80)

/******************************************************************************
end of file
*******************************************************************************/
