***********************************************************************
* 			ppg did event study visualisations							  	  
***********************************************************************
*																	   
*	PURPOSE: Visualise the DiD event study set-up															
*			
*	OUTLINE:														  
*	1)						  						  
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
