***********************************************************************
* 			ppg Dynamic DiD event study regressions + coefplot		
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
*	ID variable: 	firm_id/cedula_proveedor = firm id ; process id = 
*	Requires: 	  	sicop_process.dta							  
*	
***********************************************************************
* 	PART 1: Load bid-unit panel data & make necessary adjustments	  			
***********************************************************************
use "${ppg_final}/sicop_process", clear
	
	* set export folder for regression tables
*cd "$ppg_regression_tables"

	* set panel data
	* declare panel
order firm_id, a(cedula_proveedor)
xtset firm_id time_to_treat, delta(1)

	
	* define window size & shift factor
/* notes: 
	* problem: stata does not allow negative factors
	* solution: shift time to treat variable by a certain factor to make it all positive
	* shift factor should correspond to event window width, which needs to be determined arbitrarily
*/

	* define max. event window and shift factor
gen nttt = time_to_treat + 50 if time_to_treat != .


	* replace missing values for control variables
nmissing tipo_s year institucion_tipo firm_size age firm_location cum_bids_won if m2f != .
		* age missing for 265
		* firm_location missing for 79
	* replace firm age with median age
gen age_adj = age
sum age if m2f != . | f2m != ., d
replace age_adj = r(p50) if age == .

	* gen a dummy for firm having missing values for control variables
gen missing_data = (age == .) | (firm_location == 8)

	* define X control variables
local process_controls "i.tipo_s i.year i.institucion_tipo"
local firm_controls "i.firm_size c.age_adj i.firm_location c.cum_bids_won"
	

***********************************************************************
* 	PART 1.1: Event study/Dynamic DiD: 
***********************************************************************	
	* m2f defined for 22,000 bids

	* estimate the DiD
		* 1: bid won
			* large event window: 0 = 50, change at 50, window (0-100), N = 12,756 observations
reg bid_won i.m2f i.nttt i.m2f#ib50.nttt `process_controls' `firm_controls' if inrange(nttt, 0, 100), vce(cluster cedula_proveedor)			
			
			* small event window: 0 = 50, change at 50; window (40-60), N = 5629 observations
reg bid_won i.m2f i.nttt i.m2f#ib50.nttt `process_controls' `firm_controls' if inrange(nttt, 40, 60), vce(cluster cedula_proveedor)

preserve 
keep if nttt > 0
logit bid_won i.m2f i.nttt i.m2f#ib50.nttt `process_controls' `firm_controls' if inrange(nttt, 40, 60), vce(cluster cedula_proveedor)
restore


		* 2: amount won
			* large event window: 0 = 50, change at 50, window (0-100), N = 12,756 observations
reg monto_crc_wlog i.m2f i.nttt i.m2f#ib50.nttt `process_controls' `firm_controls' if inrange(nttt, 0, 100), vce(cluster cedula_proveedor)			
			
			* small event window: 0 = 50, change at 50; window (40-60), N = 5629 observations
reg monto_crc_wlog i.m2f i.nttt i.m2f#ib50.nttt `process_controls' `firm_controls' if inrange(nttt, 40, 60), vce(cluster cedula_proveedor)


		* points won
			* large event window: 0 = 50, change at 50, window (0-100), N = 12,756 observations
reg total_points i.m2f i.nttt i.m2f#ib50.nttt `process_controls' `firm_controls' if inrange(nttt, 0, 100), vce(cluster cedula_proveedor)			
			
			* small event window: 0 = 50, change at 50; window (40-60), N = 5629 observations
reg total_points i.m2f i.nttt i.m2f#ib50.nttt `process_controls' `firm_controls' if inrange(nttt, 40, 60), vce(cluster cedula_proveedor)


***********************************************************************
* 	PART 1.2: Event study/Dynamic DiD: interacted with PO gender
***********************************************************************
local process_controls "i.tipo_s i.year i.institucion_tipo"
local firm_controls "i.firm_size c.age_adj i.firm_location c.cum_bids_won i.missing_data"

		* 1: bid won
			* large event window: 0 = 50, change at 50, window (0-100), N = 12,756 observations
reg bid_won i.m2f##ib50.nttt##i.genderpo  `process_controls' `firm_controls' if inrange(nttt, 0, 100), vce(cluster cedula_proveedor)			
			
			* small event window: 0 = 50, change at 50; window (40-60), N = 5629 observations
reg bid_won i.m2f##ib50.nttt##i.genderpo `process_controls' `firm_controls' if inrange(nttt, 40, 60), vce(cluster cedula_proveedor)


		* 2: amount won
			* large event window: 0 = 50, change at 50, window (0-100), N = 12,756 observations
reg monto_crc_wlog i.m2f##ib50.nttt##i.genderpo `process_controls' `firm_controls' if inrange(nttt, 0, 100), vce(cluster cedula_proveedor)			
			
			* small event window: 0 = 50, change at 50; window (40-60), N = 5629 observations
reg monto_crc_wlog i.m2f##ib50.nttt##i.genderpo `process_controls' `firm_controls' if inrange(nttt, 40, 60), vce(cluster cedula_proveedor)


		* points won
			* large event window: 0 = 50, change at 50, window (0-100), N = 12,756 observations
reg total_points i.m2f##ib50.nttt##i.genderpo `process_controls' `firm_controls' if inrange(nttt, 0, 100), vce(cluster cedula_proveedor)			
			
			* small event window: 0 = 50, change at 50; window (40-60), N = 5629 observations
reg total_points i.m2f##ib50.nttt##i.genderpo `process_controls' `firm_controls' if inrange(nttt, 40, 60), vce(cluster cedula_proveedor)

***********************************************************************
* 	PART 1.3: Triple DiD
***********************************************************************
		


		
		
		
		
***********************************************************************
* 	PART 2: Load two-month panel data & make necessary adjustments	  			
***********************************************************************		
	* declare panel
order firm_id two_month_to_treat
xtset firm_id two_month_to_treat

	
	* define window size & shift factor
/* notes: 
	* problem: stata does not allow negative factors
	* solution: shift time to treat variable by a certain factor to make it all positive
	* shift factor should correspond to event window width, which needs to be determined arbitrarily
*/

	* define max. event window and shift factor
gen nttt = time_to_treat + 50 if time_to_treat != .


	* gen cumulative bids won prior to bid
bysort firm_id (two_month_to_treat): gen cum_bids_won = sum(bids_won), a(bids_won)
lab var cum_bids_won "cumulative bids won"


	* define X control variables		
local process_controls1 "i.process_type2 i.process_type3 i.process_type4 i.process_type5 i.process_type6" 
local process_controls2 "i.year i.institution_type2 i.institution_type3 i.institution_type4 i.institution_type5"
local firm_controls "i.firm_size c.age_adj i.firm_location c.cum_bids_won" // add i.missing_data	
		
***********************************************************************
* 	PART 2.1: Event study/Dynamic DiD: 
***********************************************************************	
	* estimate the DiD
		* 1: bid won
			* large event window: 0 = 40, change at 41, window (34-46 = 1 year), N = ? observations
reg bids_won i.m2f i.two_month_to_treat i.m2f#ib40.two_month_to_treat `firm_controls' if inrange(two_month_to_treat, 34, 46), vce(cluster firm_id)			
			
			* small event window: 0 = 50, change at 50; window (40-60), N = 5629 observations
reg bids_won i.m2f i.two_month_to_treat i.m2f#ib50.two_month_to_treat `process_controls' `firm_controls' if inrange(two_month_to_treat, 40, 60), vce(cluster firm_id)

preserve 
keep if two_month_to_treat > 0
logit bids_won i.m2f i.two_month_to_treat i.m2f#ib50.two_month_to_treat `process_controls' `firm_controls' if inrange(two_month_to_treat, 40, 60), vce(cluster firm_id)
restore


		* 2: amount won
			* large event window: 0 = 50, change at 50, window (0-100), N = 12,756 observations
reg monto_crc_wlog i.m2f i.two_month_to_treat i.m2f#ib50.two_month_to_treat `process_controls' `firm_controls' if inrange(two_month_to_treat, 0, 100), vce(cluster firm_id)			
			
			* small event window: 0 = 50, change at 50; window (40-60), N = 5629 observations
reg monto_crc_wlog i.m2f i.two_month_to_treat i.m2f#ib50.two_month_to_treat `process_controls' `firm_controls' if inrange(two_month_to_treat, 40, 60), vce(cluster firm_id)


		* points won
			* large event window: 0 = 50, change at 50, window (0-100), N = 12,756 observations
reg total_points i.m2f i.two_month_to_treat i.m2f#ib50.two_month_to_treat `process_controls' `firm_controls' if inrange(two_month_to_treat, 0, 100), vce(cluster firm_id)			
			
			* small event window: 0 = 50, change at 50; window (40-60), N = 5629 observations
reg total_points i.m2f i.two_month_to_treat i.m2f#ib50.two_month_to_treat `process_controls' `firm_controls' if inrange(two_month_to_treat, 40, 60), vce(cluster firm_id)
		
		
		
* old code: 
		
***********************************************************************
* 	PART 1: Event study DiD predicted probabilities of winning public contract
***********************************************************************	
	* define window size & shift factor
foreach t of num 10 25 50 {
gen nttt`t' = time_to_treat + `t'
lab var nttt`t' "normalised time to treatment, +/- `t' window"
}

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
* 	PART : Event study DiD marginal probabilities at nttt of winning public contract
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
* 	PART 3: Event study triple DiD predicted probabilities of winning public contract
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
	gen coef_`g'_`o' = .
	gen se_`g'_`o' = .
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
	sum ci_top_`g'_`o'
	local top_range_`g'_`o' = r(max)
	sum ci_bottom_`g'_`o'
	local bottom_range_`g'_`o' = r(min)
	}	
}
	
		* event study tripple DiD visualisation m2f vs. m2m under male PO
	twoway (sc coef_m2f_mpo time_to_treat, connect(line) lcolor(blue%50) lpattern(solid) legend(off)) ///
		(sc coef_m2m_mpo time_to_treat, connect(line) lcolor(red%50) lpattern(dash) legend(off)) ///
		(rcap ci_top_m2f_mpo ci_bottom_m2f_mpo time_to_treat, legend(off))	///
		(rcap ci_top_m2m_mpo ci_bottom_m2m_mpo time_to_treat, legend(off))	///
		(function y = 0, range(`bottom_range_m2f_mpo' `top_range_m2f_mpo') horiz) ///
		(function y = 0, range(`bottom_range_m2m_mpo' `top_range_m2m_mpo') horiz), ///
		xtitle("Time to Treatment") caption("95% Confidence Intervals Shown") ///
		title("{bf: Under male procurement official}") ///
		ytitle("Predicted probability to win a public contract", size(small)) ///
		name(D3_malePO_10, replace)
	graph export event_3D_mpo_predictedprob10.png, replace
	
		* event study tripple DiD visualisation m2f vs. m2m under female PO
	twoway (sc coef_m2f_fpo time_to_treat, connect(line) lcolor(blue%50) lpattern(solid)) ///
		(sc coef_m2m_fpo time_to_treat, connect(line) lcolor(red%50) lpattern(dash)) ///
		(rcap ci_top_m2f_fpo ci_bottom_m2f_fpo time_to_treat, legend(off))	///
		(rcap ci_top_m2m_fpo ci_bottom_m2m_fpo time_to_treat, legend(off))	///
		(function y = 0, range(`bottom_range_m2f_fpo' `top_range_m2f_fpo') horiz) ///
		(function y = 0, range(`bottom_range_m2m_fpo' `top_range_m2m_fpo') horiz), ///
		xtitle("Time to Treatment") caption("95% Confidence Intervals Shown") ///
		title("{bf: Under female procurement official}") ///
		ytitle("Predicted probability to win a public contract", size(small)) ///
		legend(order(1 "Male to female" 2 "Male to male")) ///
		name(D3_femalePO_10, replace)
	graph export event_3D_fpo_predictedprob10.png, replace

	grc1leg D3_malePO_10 D3_femalePO_10, title("{bf: Event study triple difference-in-difference}") ///
		subtitle("{it:Male-to-female vs. male to male}") ///
		legendfrom(D3_femalePO_10) ///
		ycommon xcommon ///
		note("Sample size = 6959 procurement processes of firms with a single change in their representatives gender. 85% are m2m.", size(vsmall))
		
	gr export event_D3_pp10.png, replace
	restore
*}

***********************************************************************
* 	PART 4: Event study triple DiD AMOUNT WON IN BID
***********************************************************************	
	* only keep observations within the event window
*foreach t of num 10 25 50 {
	preserve 
	drop if nttt10<0
		
		* run the diff-in-diff regression around the event window 
	regress monto_crc i.m2f##female_po##ib20.nttt10 if nttt10 <= 20 & nttt10 > 0, vce(robust)
	cd "$ppg_event"
	outreg2 using event_3D_amount10, excel replace
	matrix list e(b)
		
		* create empty variables for coefficients, standard errors, & confidence intervals
local groups m2f m2m
local officials fpo mpo
foreach g of local groups {
	foreach o of local officials {
	gen coef_`g'_`o' = .
	gen se_`g'_`o' = .
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
	sum ci_top_`g'_`o'
	local top_range_`g'_`o' = r(max)
	sum ci_bottom_`g'_`o'
	local bottom_range_`g'_`o' = r(min)
	}	
}
	
		* event study tripple DiD visualisation m2f vs. m2m under male PO
	twoway (sc coef_m2f_mpo time_to_treat, connect(line) lcolor(blue%50) lpattern(solid) legend(off)) ///
		(sc coef_m2m_mpo time_to_treat, connect(line) lcolor(red%50) lpattern(dash) legend(off)) ///
		(rcap ci_top_m2f_mpo ci_bottom_m2f_mpo time_to_treat, legend(off))	///
		(rcap ci_top_m2m_mpo ci_bottom_m2m_mpo time_to_treat, legend(off))	///
		(function y = 0, range(`bottom_range_m2f_mpo' `top_range_m2f_mpo') horiz) ///
		(function y = 0, range(`bottom_range_m2m_mpo' `top_range_m2m_mpo') horiz), ///
		xtitle("Time to Treatment") caption("95% Confidence Intervals Shown") ///
		title("{bf: Under male procurement official}") ///
		ytitle("Predicted probability to win a public contract", size(small)) ///
		name(D3_malePO_10, replace)
	graph export event_3D_mpo_predictedprob10.png, replace
	
		* event study tripple DiD visualisation m2f vs. m2m under female PO
	twoway (sc coef_m2f_fpo time_to_treat, connect(line) lcolor(blue%50) lpattern(solid)) ///
		(sc coef_m2m_fpo time_to_treat, connect(line) lcolor(red%50) lpattern(dash)) ///
		(rcap ci_top_m2f_fpo ci_bottom_m2f_fpo time_to_treat, legend(off))	///
		(rcap ci_top_m2m_fpo ci_bottom_m2m_fpo time_to_treat, legend(off))	///
		(function y = 0, range(`bottom_range_m2f_fpo' `top_range_m2f_fpo') horiz) ///
		(function y = 0, range(`bottom_range_m2m_fpo' `top_range_m2m_fpo') horiz), ///
		xtitle("Time to Treatment") caption("95% Confidence Intervals Shown") ///
		title("{bf: Under female procurement official}") ///
		ytitle("Predicted probability to win a public contract", size(small)) ///
		legend(order(1 "Male to female" 2 "Male to male")) ///
		name(D3_femalePO_10, replace)
	graph export event_3D_fpo_predictedprob10.png, replace

	grc1leg D3_malePO_10 D3_femalePO_10, title("{bf: Event study triple difference-in-difference}") ///
		subtitle("{it:Male-to-female vs. male to male}") ///
		legendfrom(D3_femalePO_10) ///
		ycommon xcommon ///
		note("Sample size = 6959 procurement processes of firms with a single change in their representatives gender. 85% are m2m.", size(vsmall))
		
	gr export event_D3_pp10.png, replace
	restore







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
	/*gr combine D3_malePO_10 D3_femalePO_10, title("{bf: Event study triple difference-in-difference}") ///
		subtitle("{it:Male-to-female vs. male to male}") ///
		note("Sample size = 6959 procurement processes of firms with a single change in their representatives gender. 85% are m2m.", size(vsmall)) 


	gen coef_m2f = .
	gen coef_m2m = .
	gen coef_m2f = .
	gen coef_m2m = .
	gen se_m2f = .
	gen se_m2m = .

	gen se_m2f = .
	gen se_m2m = .

	
	
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

*/