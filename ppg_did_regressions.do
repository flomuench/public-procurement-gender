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
xtset firmid firm_occurence, delta(1)
	/* requires capture drop due to some mistake */

***********************************************************************
* 	PART 2: pooled bid level multivariate regression
***********************************************************************	
	* replication of pooled bid level mv regression but removing subcontracts
cd "$ppg_pooled"
logit winner i.female_firm##i.female_po $process_controls $firm_controls, vce(robust)
margins i.female_firm##i.female_po, post
outreg2 using pooled_bidlevel, excel replace
estimates store pooled_bidlevel, title("Predicted probabilities")
coefplot pooled_bidlevel, drop(_cons) xline(0) ///
	xtitle("Predicted probability of winning a public contract", size(small)) xlab(0.2(0.01)0.3) ///
	graphr(color(white)) bgcol(white) plotr(color(white)) ///
	title("{bf:Do procurement officials discriminate in their allocation decision?}") ///
	subtitle("Full sample", size(small)) ///
	note("Sample size = 169,105 bids.", size(vsmall))
gr export pooled_bidlevel.png, replace
	
	
	* alternative identification: compare the same firm either represented by a women or a men
logit winner i.female_firm##i.female_po $process_controls $firm_controls if multiple_change == 1, vce(robust)
margins i.female_firm##i.female_po, post
outreg2 using pooled_switchers, excel replace
estimates store pooled_switchers, title("Predicted probabilities")
coefplot pooled_switchers, drop(_cons) xline(0) ///
	xtitle("Predicted probability of winning a public contract", size(small)) xlab(0.2(0.01)0.3) ///
	graphr(color(white)) bgcol(white) plotr(color(white)) ///
	title("{bf:Do procurement officials discriminate in their allocation decision?}") ///
	subtitle("Sample: Only firms switching between male & female representatives.", size(small)) ///
	note("Sample size = 44,270 bids.", size(vsmall))
gr export pooled_switchers.png, replace


***********************************************************************
* 	PART 3: Visualising leaps and lags around the event window
***********************************************************************	
/* notes: 
	* problem: stata does not allow negative factors
	* solution: shift time to treat variable by a certain factor to make it all positive
	* shift factor should correspond to event window width, which needs to be determined arbitrarily
*/
	
	* set window size & shift factor
foreach t of num 10 25 50 {
gen nttt`t' = time_to_treat + `t'
lab var nttt`t' "normalised time to treatment, +/- `t' window"
}
	
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
* 	PART 3: Event study DiD predicted probabilities
***********************************************************************	
	* only keep observations within the event window
foreach t of num 10 25 50 {
	preserve 
	drop if nttt`t'<0
	local wmax = 2*`t'
		
		* run the diff-in-diff regression around the event window 
	logit winner i.m2f##ib`wmax'.nttt`t' if nttt`t' <= `wmax' & nttt`t' > 0, vce(robust)
	margins i.m2f##ib`wmax'.nttt`t', post
	cd "$ppg_event"
	outreg2 using event_predictedprob`wmax', excel replace
	matrix list e(b)
		
		* create empty variables for coefficients, standard errors, & confidence intervals
	gen coef_m2f = .
	gen coef_m2m = .
	gen se_m2f = .
	gen se_m2m = .


	* loop to list the coefficients for each process lag & leap
	forvalues x = 1(1) `wmax' {
		replace coef_m2f = _b[1.m2f#`x'o.nttt`t'] if nttt`t' == `x' /* but this gener */
		replace coef_m2m = _b[0.m2f#`x'o.nttt`t'] if nttt`t' == `x' 
		replace se_m2f   = _se[1.m2f#`x'o.nttt`t'] if nttt`t' == `x'
		replace se_m2m   = _se[0.m2f#`x'o.nttt`t'] if nttt`t' == `x'

	}
	
		* create ci intervals
	gen ci_top_m2f = coef_m2f + 1.96*se_m2f
	gen ci_bottom_m2f = coef_m2f - 1.96*se_m2f
	gen ci_top_m2m = coef_m2m + 1.96*se_m2m
	gen ci_bottom_m2m = coef_m2m - 1.96*se_m2m
		
		* keep only
	keep time_to_treat coef_* se_* ci_*
	duplicates drop 
	sort time_to_treat

	* create a scatterplot of coefficients with confidence intervals
	keep if time_to_treat <= `t' & time_to_treat > = - `t'
	local status "m2f m2m"
	foreach x of local status {
		sum ci_top_`x'
		local top_range_`x' = r(max)
		sum ci_bottom_`x'
		local bottom_range_`x' = r(min)
	}

	twoway (sc coef_m2f time_to_treat, connect(line)) ///
		(sc coef_m2m time_to_treat, connect(line)) ///
		(rcap ci_top_m2f ci_bottom_m2f time_to_treat)	///
		(rcap ci_top_m2m ci_bottom_m2m time_to_treat)	///
		(function y = 0, range(`bottom_range_m2f' `top_range_m2f') horiz) ///
		(function y = 0, range(`bottom_range_m2m' `top_range_m2m') horiz), ///
		xtitle("Time to Treatment") caption("95% Confidence Intervals Shown") ///
		title("{bf: Event study difference-in-difference}") ///
		subtitle("{it:Male-to-female vs. male to male}") ///
		ytitle("Predicted probability to win a public contract") ///
		caption("Sample size = 6959 procurement processes of firms with a single change in their representatives gender. 85% are m2m.", size(vsmall))
	graph export event_predictedprob`wmax'.png, replace
		
	restore
}
***********************************************************************
* 	PART : Event study DiD marginal probabilities at nttt
***********************************************************************	
	* set window size & shift factor
foreach t of num 10 25 50 {
	gen nttt`t' = time_to_treat + `t'
	lab var nttt`t' "normalised time to treatment, +/- `t' window"

	/*gen nttt50 = time_to_treat + 50
	lab var nttt50 "normalised time to treatment, +/- `t' window" */
		* only keep observations within the event window
	preserve 
	drop if nttt`t'<0
		
		* run the diff-in-diff regression around the event window 
	logit winner i.m2f##ib`t'.nttt`t' if nttt`t' <= `wmax' & nttt`t' > 0, vce(robust)
	*margins, dydx(m2f) at(nttt`t' = 1(1)`wmax') post
	*margins m2f, at(nttt`t' = 1(1)`wmax') post
	*margins i.m2f##ib`t'.nttt`t'
	margins, dydx(m2f) at(nttt`t'=(1(1)`wmax')) post
	cd "$ppg_event"
	outreg2 using event_marginalprob`wmax', excel replace
	matrix list e(b)

		
		* create empty variables for coefficients, standard errors, & confidence intervals
	gen coef = .
	gen se = .

		* loop to list the coefficients for each process lag & leap
	forvalues x = 1(1)`wmax' {
		replace coef = _b[1.m2f:`x'._at] if nttt`t' == `x' /* but this gener */
		replace se   = _se[1.m2f:`x'._at] if nttt`t' == `x'
		}
		
		* create ci intervals
	gen ci_top = coef + 1.96*se
	gen ci_bottom = coef - 1.96*se

		
		* keep only
	keep time_to_treat coef se ci_*
	duplicates drop 
	sort time_to_treat

		* create a scatterplot of coefficients with confidence intervals
	keep if time_to_treat <= `t' & time_to_treat > = - `t'

	sum ci_top
	local top_range = r(max)
	sum ci_bottom
	local bottom_range = r(min)


	twoway (sc coef time_to_treat, connect(line)) ///
		(rcap ci_top ci_bottom time_to_treat)	///
		(function y = 0, range(time_to_treat)) ///
		(function y = 0, range(`bottom_range' `top_range') horiz), ///
		xtitle("Time to Treatment") caption("95% Confidence Intervals Shown") ///
		title("{bf: Event study difference-in-difference}") ///
		subtitle("{it:Male-to-female vs. male to male}") ///
		ytitle("Average marginal probability to win a public contract")
	graph export event_marginalprob`wmax'.png, replace
		
	restore
}




***********************************************************************
* 	PART 3: Event study triple DiD predicted probabilities
***********************************************************************	
	* only keep observations within the event window
*foreach t of num 10 25 50 {
	preserve 
	drop if nttt10<0
		
		* run the diff-in-diff regression around the event window 
	logit winner i.m2f##female_po##ib20.nttt10 if nttt10 <= 20 & nttt10 > 0, vce(robust)
	margins i.m2f##female_po##ib20.nttt10, post
	cd "$ppg_event"
	outreg2 using event_3D_predictedprob20, excel replace
	matrix list e(b)
		
		* create empty variables for coefficients, standard errors, & confidence intervals
local groups m2f m2m
local officials fpo mpo
foreach g of local groups {
	foreach o of local officials {
	gen coef_`g'`o' = .
	gen se_`g'`o' = .
		}
}

	* loop to list the coefficients for each process lag & leap
	forvalues x = 1(1)20 {
	
		replace coef_m2f_fpo = _b[1.m2f#1.female_po#`x'o.nttt10] if nttt10 == `x' 
		replace coef_m2f_mpo = _b[1.m2f#0.female_po#`x'o.nttt10] if nttt10 == `x'
		
		replace coef_m2m_fpo = _b[0.m2f#1.female_po#`x'o.nttt10] if nttt10 == `x' 
		replace coef_m2m_mpo = _b[0.m2f#0.female_po#`x'o.nttt10] if nttt10 == `x' 

		replace se_m2f_fpo   = _se[1.m2f#1.female_po#`x'o.nttt10] if nttt10 == `x'
		replace se_m2f_mpo   = _se[1.m2f#0.female_po#`x'o.nttt10] if nttt10 == `x'

		replace se_m2m_fpo   = _se[0.m2f#1.female_po#`x'o.nttt10] if nttt10 == `x'
		replace se_m2m_mpo   = _se[0.m2f#0.female_po#`x'o.nttt10] if nttt10 == `x'

	}
	
		* create ci intervals
	gen ci_top_m2f_fpo = coef_m2f_fpo + 1.96*se_m2f_fpo
	gen ci_bottom_m2f_fpo = coef_m2f_fpo - 1.96*se_m2f_fpo
	
	gen ci_top_m2f_mpo = coef_m2f_mpo + 1.96*se_m2f_mpo
	gen ci_bottom_m2f_mpo = coef_m2f_mpo - 1.96*se_m2f_mpo
	
	gen ci_top_m2m_fpo = coef_m2m_fpo + 1.96*se_m2m_fpo
	gen ci_bottom_m2m_fpo = coef_m2m_fpo - 1.96*se_m2m_fpo
	
	gen ci_top_m2m_mpo = coef_m2m_mpo + 1.96*se_m2m_mpo
	gen ci_bottom_m2m_mpo = coef_m2m_mpo - 1.96*se_m2m_mpo
		
		* keep only
	keep time_to_treat coef_* se_* ci_*
	duplicates drop 
	sort time_to_treat

	* create a scatterplot of coefficients with confidence intervals
	keep if time_to_treat <= 10 & time_to_treat > = - 10
	
local groups m2f m2m
local officials fpo mpo
foreach g of local groups {
	foreach o of local officials {
	sum ci_top_`g'`o'
	local top_range_`g'`o' = r(max)
	sum ci_bottom_`g'`o'
	local bottom_range_`g'`o' = r(min)
	}	
}
	
		* event study tripple DiD visualisation m2f vs. m2m under male PO
	twoway (sc coef_m2f_mpo time_to_treat, connect(line)) ///
		(sc coef_m2m_mpo time_to_treat, connect(line)) ///
		(rcap ci_top_m2f_mpo ci_bottom_m2f_mpo time_to_treat)	///
		(rcap ci_top_m2m_mpo ci_bottom_m2m_mpo time_to_treat)	///
		(function y = 0, range(`bottom_range_m2f_mpo' `top_range_m2f_mpo') horiz) ///
		(function y = 0, range(`bottom_range_m2m_mpo' `top_range_m2m_mpo') horiz), ///
		xtitle("Time to Treatment") caption("95% Confidence Intervals Shown") ///
		title("{bf: Under male procurement official}") ///
		ytitle("Predicted probability to win a public contract") ///
		caption("Sample size = 6959 procurement processes of firms with a single change in their representatives gender. 85% are m2m.", size(vsmall)) ///
		name(3D_malePO_10)
	graph export event_3D_mpo_predictedprob10.png, replace
	
		* event study tripple DiD visualisation m2f vs. m2m under female PO
	twoway (sc coef_m2f_fpo time_to_treat, connect(line)) ///
		(sc coef_m2m_fpo time_to_treat, connect(line)) ///
		(rcap ci_top_m2f_fpo ci_bottom_m2f_fpo time_to_treat)	///
		(rcap ci_top_m2m_fpo ci_bottom_m2m_fpo time_to_treat)	///
		(function y = 0, range(`bottom_range_m2f_fpo' `top_range_m2f_fpo') horiz) ///
		(function y = 0, range(`bottom_range_m2m_fpo' `top_range_m2m_fpo') horiz), ///
		xtitle("Time to Treatment") caption("95% Confidence Intervals Shown") ///
		title("{bf: Under female procurement official}") ///
		ytitle("Predicted probability to win a public contract") ///
		caption("Sample size = 6959 procurement processes of firms with a single change in their representatives gender. 85% are m2m.", size(vsmall)) ///
		name(3D_femalePO_10)
	graph export event_3D_fpo_predictedprob10.png, replace

	gr combine 3D_malePO_10 3D_femalePO_10, title("{bf: Event study triple difference-in-difference}" ///
		subtitle("{it:Male-to-female vs. male to male}"

	restore
*}


***********************************************************************
* 	PART : Learning
***********************************************************************	 
twoway (histogram firm_occurence if female_firm == 1 & firm_occurence < 1000, freq color(red%70)) ///
	(histogram firm_occurence if female_firm == 0 & firm_occurence < 1000, freq color(blue%30)), ///
	legend(order(1 "Female" 2 "Male" )) xtitle("number of times participated") ytitle("number of observations")

	* marginsplot to calculate a learning effect differential by gender
		* with firm & period fixed effects
cd "$ppg_learning"
preserve 
drop if never_change == 1
keep if firm_occurence <= 50 & firm_occurence >= 10
sum firm_occurence, d
logit winner i.female_firm##i.female_po i.firm_occurence i.firmid $process_controls, vce(robust)
margins female_firm, at(firm_occurence = (10(1)50)) post /* 700 ~ 75th percentile, 160 ~ median */
marginsplot, recast(line) noci title("Winning a public contract, Predictive probability") xtitle("nth bid") ytitle("Pr(Winning = 1)") plot1opts(lcolor(black)) plot2opts(lcolor(gs6) lpattern("--")) legend(on order(1 "female firm" 0 "male firm")) name(learning_gender1, replace)
graph export learning_gender1.png, replace
restore

		* without firm but only period fixed effects
			* only gender effect for all firms
preserve 
keep if firm_occurence <= 50 & firm_occurence >= 10 
sum firm_occurence, d
logit winner i.female_firm##i.female_po i.firm_occurence $firm_controls $process_controls, vce(robust)
margins female_firm, at(firm_occurence = (10(1)50)) post /* 700 ~ 75th percentile, 160 ~ median */
outreg2 using learning_tfe_all, excel replace
marginsplot, recast(line) noci title("Winning a public contract, Predictive probability") xtitle("nth bid") ytitle("Pr(Winning = 1)") plot1opts(lcolor(black)) plot2opts(lcolor(gs6) lpattern("--")) legend(on order(1 "female firm" 0 "male firm")) name(learning_gender2, replace)
graph export learning_tfe_all.png, replace
restore
			* only gender effect for all firms excluding firms with no change in ceo
preserve 
drop if never_change == 1
keep if firm_occurence <= 50 & firm_occurence >= 10 /* 21, 263 obs in regression */
sum firm_occurence, d
logit winner i.female_firm##i.female_po i.firm_occurence $firm_controls $process_controls, vce(robust)
margins female_firm, at(firm_occurence = (10(1)50)) post /* 700 ~ 75th percentile, 160 ~ median */
marginsplot, recast(line) noci title("Winning a public contract, Predictive probability") xtitle("nth bid") ytitle("Pr(Winning = 1)") plot1opts(lcolor(black)) plot2opts(lcolor(gs6) lpattern("--")) legend(on order(1 "female firm" 0 "male firm")) name(learning_gender2, replace)
graph export learning_gender2.png, replace
restore
			* only gender effect for all firms 
preserve 
keep if single_change == 1
keep if firm_occurence <= 50 & firm_occurence >= 10  
sum firm_occurence, d
logit winner i.female_firm##i.female_po i.firm_occurence $firm_controls $process_controls, vce(robust)
margins female_firm, at(firm_occurence = (10(1)50)) post /* 700 ~ 75th percentile, 160 ~ median */
marginsplot, recast(line) noci title("Winning a public contract, Predictive probability") xtitle("nth bid") ytitle("Pr(Winning = 1)") plot1opts(lcolor(black)) plot2opts(lcolor(gs6) lpattern("--")) legend(on order(1 "female firm" 0 "male firm")) name(learning_gender2, replace)
graph export learning_gender2.png, replace
restore
			
			* interaction effect between gender firm rep and gender PO
preserve 
drop if never_change == 1
keep if firm_occurence <= 50 & firm_occurence >= 10
sum firm_occurence, d
logit winner i.female_firm##i.female_po i.firm_occurence $firm_controls $process_controls, vce(robust)
margins female_firm, at(firm_occurence = (10(1)50)) post /* 700 ~ 75th percentile, 160 ~ median */
marginsplot, recast(line) noci title("Winning a public contract, Predictive probability") xtitle("nth bid") ytitle("Pr(Winning = 1)") plot1opts(lcolor(black)) plot2opts(lcolor(gs6) lpattern("--")) legend(on order(1 "female firm" 0 "male firm")) name(learning_gender2, replace)
graph export learning_gender2.png, replace
restore







**** Archive



	gen coef_m2f = .
	gen coef_m2m = .
	gen coef_m2f = .
	gen coef_m2m = .
	gen se_m2f = .
	gen se_m2m = .

	gen se_m2f = .
	gen se_m2m = .
