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
use "${ppg_final}/sicop_process", clear


***********************************************************************
* 	PART 1: Days between contract publication of subsequent bids
***********************************************************************
sum days_dif, d
/*
recall: these are actually the publication dates; we do not know when the firms applied
75% of days_dif is only 18 days
90% of days_dif is <= 66 ~ 2 months
*/
display 0.001517 * 1440 /* one day = 24 h, 24 * 60 minutes = 1440 minutes */
* min. or in other words quickest re-application: 2 minutes later
display 0.001517 * 1440

histogram days_dif, width(1)

histogram days_dif if days_dif < 437, width(1)
histogram days_dif if days_dif < 100, width(1) yline(30)


sum days_dif if time_to_treat == 1, d /* suggests only 25% within 30 days  */
sum days_dif if time_to_treat == 0, d /* suggests only 50% within 30 days  */
sum days_dif if time_to_treat == -1, d /* suggests only 50% within 30 days  */


***********************************************************************
* 	PART 2: Days contract publication and contract allocation
***********************************************************************
sum days_pub_adj, d
/* 
mean = 30, median = 20 --> implying that on average a firm know whether bid is
successful exactly around the time it bids for the next contract

min or quickest contract allocation happens in one days or even less, quickest 25% in two weeks,
75% within one month

*/

***********************************************************************
* 	PART 3:  visualise how many lags and leaps before treatment (change in reps gender)
***********************************************************************
cd "$ppg_figures/"
	
	* average number of bids
sum time_to_treat, d /* 12 */
	
	* m2f & m2m
twoway  ///
	(histogram time_to_treat if time_to_treat >= -50 & time_to_treat <= 50 & m2f == 1, bin(100) frequency color(black%30)) ///
	(histogram time_to_treat if time_to_treat > -50 & time_to_treat <= 50 & m2f == 0, bin(100) frequency color(gs10%30)), ///
			xline(0) ///
			legend(order(1 "Male to female" 2 "Male to male") pos(6) rows(1)) ///
			xtitle("time to treatment") xlabel(#10) ///
			ylabel(0(50)350) ytitle("total bids") ///
			xsize(2) ysize(1) ///
			name(leads_lags_ttt_m2f, replace)
graph export "$ppg_figures/leads_lags_ttt_m2f.png", replace
			
	* f2m & f2f
twoway  ///
	(histogram time_to_treat if time_to_treat >= -50 & time_to_treat <= 50 & f2m == 1, bin(100) frequency color(black%80)) ///
	(histogram time_to_treat if time_to_treat > -50 & time_to_treat <= 50 & f2m == 0, bin(100) frequency color(gs10%50)), ///
			xline(0) ///
			legend(order(1 "Female to male" 2 "Female to female") pos(6) rows(1)) ///
			xtitle("time to treatment") xlabel(#10) ///
			ylabel(0(50)350) ytitle("total bids") ///
			xsize(2) ysize(1) ///
			name(leads_lags_ttt_f2m, replace)
graph export "$ppg_figures/leads_lags_ttt_f2m.png", replace

***********************************************************************
* 	PART 3:  balance table 
***********************************************************************
	* process level balance table (uncorrected for frequency of firm particiation)
local balvar "firm_age_ca firm_age_2019 firm_capital firm_international firm_location1 firm_location2 firm_location3 firm_location4 firm_location5 firm_location6 firm_location7 firm_size1 firm_size2 firm_size3 firm_size4 firm_size5 monto_crc" 
iebaltab `balvar', grpvar(m2f) save(baltab_m2f) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
			 
	* firm level balance table (after collapsing to have just one line per firm)
			 
***********************************************************************
* 	PART 4:  Amount won (by gender) 
***********************************************************************
sum monto_usd_w if m2f == 1, d /* 50% = 0 */

	* by gender change of firm
twoway  ( monto_usd_w if m2f == 1 & monto_usd < 110143, width(1) frequency color(maroon%30)) ///
		( monto_usd_w if m2f == 0 & monto_usd < 110143, width(1) frequency color(navy%30)), ///
			legend(order(1 "Male to female" 2 "Male to male") pos(6) rows(1)) ///
			subtitle("{it:bid level by treatment and control group}") ///
			xtitle("time to treatment") xlabel(#10)

		
	* sum won before and after change of representative
		* m2f
graph bar (sum) monto_usd if inrange(time_to_treat,-10, 10), over(post) over(m2f) ///
	blabel(bar) ///
	ytitle("total amount won, usd", size(medium)) ///
	name(sum_won_gender_ba_m2f, replace)
	
		* f2m
graph bar (sum) monto_usd if inrange(time_to_treat,-10, 10), over(post) over(f2m) ///
	blabel(bar) ///
	ytitle("total amount won, usd", size(vsmall)) ///
	name(sum_won_gender_ba_f2m, replace)
	
	
		* m2f
graph bar (sum) monto_usd if inrange(time_to_treat,-10, 10), over(post) over(m2f) over(genderpo) ///
	blabel(bar) ///
	ytitle("total amount won, usd", size(medium)) ///
	name(sum_won_gender_ba_m2f_po, replace)
	
		* f2m
graph bar (sum) monto_usd if inrange(time_to_treat,-10, 10), over(post) over(f2m) over(genderpo) ///
	blabel(bar) ///
	ytitle("total amount won, usd", size(vsmall)) ///
	name(sum_won_gender_ba_f2m, replace)
	


