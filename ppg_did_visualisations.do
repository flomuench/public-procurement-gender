***********************************************************************
* 			ppg did event study visualisations							  	  
***********************************************************************
*																	   
*	PURPOSE: Visualise the DiD event study set-up															
*			
*	OUTLINE:														  
*	1)	leads and lags around the cutoff					  						  
*	2)  			  		    
*	3)  				  
*	4)  			
* 																				  
*	Author:  	Florian Muench					          															      
*	ID variable: 	process level id = firm_occurence ; firm level id = firmid
*	Requires:  	   	sicop_did.dta							  
*	Creates:  		sicop_did.dta	   						  
*																	  
***********************************************************************
* 	PART START:  Load data set		  			
***********************************************************************
use "${ppg_intermediate}/sicop_did", clear


***********************************************************************
* 	PART 1:  visualise how many lags and leaps before treatment (change in reps gender)
***********************************************************************
cd "$ppg_figures"
	
	* visualise number of observations per process around change
twoway  (histogram nttt50 if nttt50 <= 100 & nttt50 > = 0 & m2f == 1, width(1) frequency color(maroon%30)) ///
		(histogram nttt50 if nttt50 <= 100 & nttt50 > = 0 & m2f == 0, width(1) frequency color(navy%30)), ///
			xline(50) ///
			legend(order(1 "Male to female" 2 "Male to male")) ///
			title("{bf:Lags and leaps around gender change of firm representative}") ///
			subtitle("{it:Process-level by treatment and control group}") ///
			xtitle("Time to treatment") xlabel(#10) ///
			note("Bin width = 1. N = 39,876 processes out of which 1,761 male-to-female & 38,115 male-to-male.", size(vsmall)) ///
			ylabel(0(50)500) ytitle("Total number of procurement processes")
*graph export lags_leaps_around_gender_change_process_level_m2f_50.png, replace
			
twoway  (histogram nttt10 if nttt10 <= 20 & nttt10 > = 0 & m2f == 1, width(1) frequency color(maroon%30)) ///
		(histogram nttt10 if nttt10 <= 20 & nttt10 > = 0 & m2f == 0, width(1) frequency color(navy%30)), ///
			xline(20) ///
			legend(order(1 "Male to female" 2 "Male to male")) ///
			title("{bf:Lags and leaps around gender change of firm representative}") ///
			subtitle("{it:Process-level by treatment and control group}") ///
			xtitle("Time to treatment") xlabel(#10) ///
			ylabel(0(50)500) ytitle("Total number of procurement processes")
*graph export lags_leaps_around_gender_change_process_level_m2f_10.png, replace

***********************************************************************
* 	PART 2:  balance table 
***********************************************************************
	* process level balance table (uncorrected for frequency of firm particiation)
local balvar "firm_age_ca firm_age_2019 firm_capital firm_international firm_location1 firm_location2 firm_location3 firm_location4 firm_location5 firm_location6 firm_location7 firm_size1 firm_size2 firm_size3 firm_size4 firm_size5 monto_crc" 
iebaltab `balvar', grpvar(m2f) save(baltab_m2f) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
			 
	* firm level balance table (after collapsing to have just one line per firm)
			 
***********************************************************************
* 	PART 3:  Amount won (by gender) 
***********************************************************************
histogram monto_crc if monto_crc < 10000000 & monto_crc > 0


	* by gender change of firm
twoway  (histogram monto_crc if monto_crc < 10000000 & monto_crc > 0 & m2f == 1, width(1) frequency color(maroon%30)) ///
		(histogram monto_crc if monto_crc < 10000000 & monto_crc > 0 & m2f == 0, width(1) frequency color(navy%30)), ///
			legend(order(1 "Male to female" 2 "Male to male")) ///
			title("{bf: Amount by female2male and male2male firms}") ///
			subtitle("{it:Process-level by treatment and control group}") ///
			xtitle("Time to treatment") xlabel(#10) ///
			note("Bin width = 1. N = 39,876 processes out of which 1,761 male-to-female & 38,115 male-to-male.", size(vsmall)) ///
			ylabel(0(50)500) ytitle("Total number of procurement processes")

		
	* sum won before and after change of representative
graph bar (sum) monto_crc if nttt10 <=20, over(post10) over(m2f) blabel(bar) ///
	ytitle("total amount won", size(vsmall)) ///
	legend(off) ///
	name(sum_won_gender_ba, replace)

graph bar (sum) monto_crc if nttt10 <=20, over(post10) over(female_po, lab(labsize(vsmall))) over(m2f) blabel(bar, size(vsmall)) ///
	ytitle("total amount won", size(vsmall)) ///
	legend(off) ///
	name(sum_won_gender_ba_po, replace)

graph bar (mean) monto_crc if nttt10 <=20, over(post10) over(m2f) blabel(bar) ///
	ytitle("average amount won", size(vsmall)) ///
	legend(off) ///
	name(mean_won_gender_ba, replace)

graph bar (mean) monto_crc if nttt10 <=20, over(post10) over(female_po, lab(labsize(vsmall))) over(m2f) blabel(bar, size(vsmall)) ///
	ytitle("average amount won", size(vsmall)) ///
	name(mean_won_gender_ba_po, replace)

grc1leg sum_won_gender_ba sum_won_gender_ba_po mean_won_gender_ba mean_won_gender_ba_po, ///
	title("{bf:Amount won 10 bids before and after change in representatives}") ///
	subtitle("{it: Female2male vs. male2male firms under (fe-) male procurement officials}", size(small)) ///
	legendfrom(mean_won_gender_ba_po)
gr export won_before_after10.pgn, replace









* archive of code
histogram time_to_treat, title("{bf:Lags and leaps around gender change of firm representative}") ///
	subtitle("{it:Process-level}") ///
	xtitle("Number of bids") xlabel(#10) ///
	note("Bin width = ", size(small))
	
histogram time_to_treat if time_to_treat <= 50 & time_to_treat > = - 50, frequency ///
	width(5) ///
	title("{bf:Lags and leaps around gender change of firm representative}") ///
	subtitle("{it:Process-level}") ///
	xtitle("Time to treatment") xlabel(#10) ///
	note("Bin width = 5", size(small)) ///
	ylabel(0(500)4000) ytitle("Total number of procurement processes")
graph export lags_leaps_around_gender_change_process_level.png, replace

histogram time_to_treat if time_to_treat <= 50 & time_to_treat > = - 50 & f2m!= ., frequency ///
	width(1) ///
	title("{bf:Lags and leaps around gender change of firm representative}") ///
	subtitle("{it:Process-level}") ///
	xtitle("Time to treatment") xlabel(#10) ///
	note("Bin width = 1. N = 8165 processes.", size(small)) ///
	ylabel(0(10)200) ytitle("Total number of procurement processes")
graph export lags_leaps_around_gender_change_process_level_sample.png, replace
twoway  (histogram time_to_treat if time_to_treat <= 50 & time_to_treat > = - 50 & f2m == 1, width(1) frequency color(maroon%30)) ///
		(histogram time_to_treat if time_to_treat <= 50 & time_to_treat > = - 50 & f2m == 0, width(1) frequency color(navy%30)), ///
			legend(order(1 "Female to male" 2 "Female to female")) ///
			title("{bf:Lags and leaps around gender change of firm representative}") ///
			subtitle("{it:Process-level by treatment and control group}") ///
			xtitle("Time to treatment") xlabel(#10) ///
			note("Bin width = 1. N = 8165 processes out of which 2,385 female-to-male & female-to-female 5,780.", size(vsmall)) ///
			ylabel(0(10)100) ytitle("Total number of procurement processes")
graph export lags_leaps_around_gender_change_process_level_f2m.png, replace
	
twoway  (histogram time_to_treat if time_to_treat <= 50 & time_to_treat > = - 50 & m2f == 1, width(1) frequency color(maroon%30)) ///
		(histogram time_to_treat if time_to_treat <= 50 & time_to_treat > = - 50 & m2f == 0, width(1) frequency color(navy%30)), ///
			legend(order(1 "Male to female" 2 "Male to male")) ///
			title("{bf:Lags and leaps around gender change of firm representative}") ///
			subtitle("{it:Process-level by treatment and control group}") ///
			xtitle("Time to treatment") xlabel(#10) ///
			note("Bin width = 1. N = 39,876 processes out of which 1,761 male-to-female & 38,115 male-to-male.", size(vsmall)) ///
			ylabel(0(50)500) ytitle("Total number of procurement processes")
graph export lags_leaps_around_gender_change_process_level_m2f.png, replace
