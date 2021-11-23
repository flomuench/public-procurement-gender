***********************************************************************
* 			ppg did event study regressions + coefplot		
***********************************************************************
*																	  
*	PURPOSE: replace					  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		 Load, directory for export, declare panel			  				  
* 	2) 	     Estimate the coef, se & visualise them
*	3)   							  
*	4)  		  				  	  
*																	  															      
*	Author:  	Florian Muench						  
*	ID variable: 	process level id = id ; firm level id = firmid			  					  
*	Requires: 	  	sicop_did.dta							  
*	Creates:  		sicop_did.dta	                          
*	
***********************************************************************
* 	PART START: 	Load, directory for export, declare panel		  			
***********************************************************************
	* extend maximum variables and matsize to accomdate size of data
set maxvar 32767
set matsize 11000

use "${ppg_intermediate}/sicop_did", clear
	
	* set export folder for regression tables
cd "$ppg_regression_tables"

	* set panel data
xtset firmid firm_occurence

	*


***********************************************************************
* 	PART 2: multivariate regression
***********************************************************************	
	* replicate mv regression but add
		* occurence fixed effects (year fixed effects/dummies already included --> general time trend)
		* firm fixed effects
		* control variables for ith occurence
preserve 
sum firm_occurence, d
keep if firm_occurence < r(p95) 
xtlogit winner i.female_firm##i.female_po i.firm_occurence $process_controls $firm_controls, fe vce(boot, reps(10))
margins i.female_firm##i.female_po, post
estimates store predictedprob_mv_did, title("Predicted probabilities")
coefplot predictedprob_mv_did, drop(_cons) xline(0) ///
	xtitle("Predicted probability of winning") xlab(0.2(0.01)0.3) ///
	graphr(color(white)) bgcol(white) plotr(color(white)) ///
	title("{bf:Predicted probabilities of winning a public contract}") ///
	subtitle("Robustness check 3: Two-way fixed effects vs. pooled", size(vsmall)) ///
	note("N = 707,717", size(small))
gr export predicted_probabilities_mv_did.png, replace
restore


	* marginsplot to calculate a learning effect differential by gender
preserve 
sum firm_occurence, d
keep if firm_occurence <= r(p50)
xtlogit winner i.female_firm##i.female_po i.firm_occurence $process_controls $firm_controls, fe vce(boot, reps(10))
quietly margins arrest, at(firm_occurence=(1(5)160)) /* 700 ~ 75th percentile, 160 ~ median */
marginsplot, recast(line) noci title("Winning a public contract, Predictive probability") xtitle("nth bid") ytitle("Pr(Winning = 1)") plot1opts(lcolor(black)) plot2opts(lcolor(gs6) lpattern("--")) legend(on order(1 "female firm" 0 "male firm")) name(learning_gender)
graph export learning_gender.png, replace
restore
***********************************************************************
* 	PART 3: define & set the event window
***********************************************************************	
/* notes: 
	* problem: stata does not allow negative factors
	* solution: shift time to treat variable by a certain factor to make it all positive
	* shift factor should correspond to event window width, which needs to be determined arbitrarily
*/

*egen shift_factor = min(time_to_treat) if gender_change_single == 1, by(firmid)
	
	* set window size & shift factor
gen nttt10 = time_to_treat + 10
lab var nttt10 "normalised time to treatment, +/- 10 window"

gen nttt50 = time_to_treat + 50
lab var nttt50 "normalised time to treatment, +/- 10 window"
	
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
* 	PART 2: estimate the coef, se & visualise them
***********************************************************************	
	* only keep observations within the event window
preserve 
drop if nttt10<0
	
	* run the diff-in-diff regression around the event window 
logit winner i.m2f##ib20.nttt10 if nttt10 <= 20 & nttt10 > 0, vce(robust)
margins  i.m2f##ib20.nttt10, post
matrix list e(b)
	
	* create empty variables for coefficients, standard errors, & confidence intervals
gen coef_treat = .
gen coef_control = .
gen se = .

	* loop to list the coefficients for each process lag & leap
forvalues x = 1(1)20 {
	replace coef_treat = _b[1.m2f#`x'o.nttt10] if nttt10 == `x' /* but this gener */
	replace coef_control = _b[0.m2f#`x'o.nttt10] if nttt10 == `x' 
	replace se   = _se[1.m2f#`x'o.nttt10] if nttt10 == `x'
	}
	
	* create ci intervals
gen ci_top_treat = coef_treat + 1.96*se
gen ci_bottom_treat = coef_treat - 1.96*se
gen ci_top_control = coef_control + 1.96*se
gen ci_bottom_control = coef_control - 1.96*se
	
	* keep only
keep time_to_treat coef_* se ci_*
duplicates drop 
sort time_to_treat

	* create a scatterplot of coefficients with confidence intervals
keep if time_to_treat <= 10 & time_to_treat > = - 10
local status "treat control"
foreach x of local status {
sum coef_`x' if time_to_treat < 0
local mean_before_`x' = r(mean)
sum coef_`x' if time_to_treat > 0
local mean_after_`x' = r(mean)
summ ci_top_`x'
local top_range_`x' = r(max)
summ ci_bottom_`x'
local bottom_range_`x' = r(min)
}
/*twoway (sc coef_treat coef_control time_to_treat, connect(line) connect(line)) ///
	(rcap ci_top_treat ci_bottom_treat time_to_treat)	///
	(rcap ci_top_control ci_bottom_control time_to_treat)	///
	(function y = 0, range(time_to_treat)) ///
	(function y = 0, range(`bottom_range_treat' `top_range_treat') horiz) ///
	(function y = 0, range(`bottom_range_control' `top_range_control') horiz), ///
	xtitle("Time to Treatment") caption("95% Confidence Intervals Shown") ///
	title("{bf: Event study difference-in-difference}") ///
	subtitle("{it:Male-to-female vs. male to male}") ///
	ytitle("Predicted probability to win a public contract")
graph export event-study-diff-in-diff_10.png, replace
	*yline(`mean_before', lcolor(navy)) yline(`mean_after', lcolor(maroon))
*/
twoway (sc coef_treat coef_control time_to_treat, connect(line) connect(line)) ///
	(rcap ci_top_treat ci_bottom_treat time_to_treat)	///
	(rcap ci_top_control ci_bottom_control time_to_treat)	///
	(function y = 0, range(time_to_treat)) ///
	xtitle("Time to Treatment") caption("95% Confidence Intervals Shown") ///
	title("{bf: Event study difference-in-difference}") ///
	subtitle("{it:Male-to-female vs. male to male}") ///
	ytitle("Predicted probability to win a public contract")
*graph export event-study-diff-in-diff_10_exp.png, replace
	
restore

