***********************************************************************
* 			public procurement gender difference-in-difference, event		
***********************************************************************
*																	  
*	PURPOSE: replace					  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Define non-response categories 			  				  
* 	2) 		Encode categorical variables
*	3)   	Replace string with numeric values						  
*	4)  	Convert string to numerical variables	  				  	  
*																	  															      
*	Author:  	Florian Muench						  
*	ID variable: 	process level id = id ; firm level id = firmid			  					  
*	Requires: 	  								  
*	Creates:  			                          
*																	  
***********************************************************************
* 	PART 1:  create a calendar independent firm occurence 			
***********************************************************************
use "${ppg_intermediate}/sicop_replicable", clear

* browse id numero_procedimiento year fecha_publicacion fecha_adjudicacion partida linea nombre_proveedor firmid 

	* create State recognized time variables to create a running event variable
local fechas "publicacion adjudicacion registro"
foreach x of local fechas {
gen date_`x' = clock(fecha_`x', "DM20Yhms"), a(fecha_`x')
format date_`x' %tc
drop fecha_`x'
}


	* idea/problem: remove same process-firmid-winner combinations because one process (with same procurement officer)
			* can have manifold subprocesses, which would all be perceived as different processes before-after change in gender of rep.
				* can different firms win subprocesses in one big process? 
					* this process illustrates that different companies can win different subprocesses (partidas, lineas) within one procurement process
					* this implies also same firm can be a winner and looser in the same process, hence per firm max. 2 observations per process
*browse if numero_procedimiento == "2011cd-000001-0001200001"

		* identify same-process-firmid-winner combinations
		* remove same process-firmid-winner combinations 
sort numero_procedimiento firmid winner
quietly by numero_procedimiento firmid winner:  gen dup = cond(_N==1,0,_n)
order dup, b(post)
			* eyeballing the data
* browse if numero_procedimiento == "2011cd-000001-0001200001"
* browse if numero_procedimiento == "2011cd-000001-0001200001" & dup <= 1
			* last line suggests that dup = 0 & dup = 1 select per firm one loosing and one winning bid
			* also checked and inclusion of procurement officer firm name did not change the number of observations in dup 0 and 1

drop if dup > 1 & dup < .
	* 580,878 of 774, 391 obs dropped...

		* generate firm occurence variable
sort firmid date_adjudicacion numero_procedimiento partida linea
by firmid: gen firm_occurence = _n, a(firmid)
format %5.0g firmid firm_occurence
	
***********************************************************************
* 	PART 2:  identify the different treatment groups 			
***********************************************************************	
	
********* PART 2.1.: try to identify firms that changed the representative
		* in analysis drop all firms that have not changed their representative
		* as change in rep could indicate firm performs less well before, hence
		* effect observed after rep change would reflect change from low to high performing
		* individual rather than change in gender

		* generate dummy for firms that changed the representative (person change)
			* idea: 
gen repchange1 = . 
bysort firmid: replace repchange = 1 if persona_encargada_proveedor[_n] != persona_encargada_proveedor[_n-1]
bysort firmid: replace repchange = 0 if persona_encargada_proveedor[_n] == persona_encargada_proveedor[_n-1]

egen repchange2 = sum(repchange1), by(firmid)
by firmid: gen repchange = (repchange2 > 1 & repchange2 < .)
order repchange*, a(ceochange)
		* how many firms never change rep?
codebook firmid if repchange == 0

		* generate dummy for firms that changed representative
			* idea: count unique values of representative
by firmid persona_encargada_proveedor, sort: gen reps = _n == 1, a(persona_encargada_proveedor)
bysort firmid: replace reps = sum(reps)
bysort firmid: replace reps = reps[_N]
	
gen single_change = (reps == 2)
codebook firmid if single_change == 1
				* 858 firms, 40,470 processs
gen never_change = (reps == 1)
codebook firmid if never_change == 1
				* 7387 firms, 100,119 processes
				
gen multiple_change = (reps > 2 & reps <.)
codebook firmid if multiple_change == 1


/* gen compare = (repchange == ceochange) --> suggests same in 75% but different in 25%*/

		* generate dummy for firms that had always only female (male) representatives
			* idea: minimum (maximum) value of female_firm is 1 (0)
tempvar fonly
egen `fonly' = min(female_firm), by(firmid)
gen female_always = (`fonly' == 1)
replace female_always = . if `fonly' == .
					* how many firms are female-always? 1896
codebook firmid if female_always == 1

tempvar monly
egen `monly' = max(female_firm), by(firmid)
gen male_always = (`monly' == 0)
replace male_always = . if `monly' == .
					* how many firms are male-always? 5926
codebook firmid if male_always == 1

		* generate dummy for firms that never changed person 
gen female_always_same_person = (female_always == 1 & repchange == 0)
codebook firmid if female_always_same_person == 1
			* how many female firms never change rep: 1771
gen male_always_same_person = (male_always == 1 & repchange == 0)
replace male_always_same_person = . if repchange == 1
codebook firmid if male_always_same_person == 1
			* how many male firms never change rep: 5308

		* ALWAYS - & NEVER TAKERS
*gen f2f = (female_always == 1 & repchange == 1)
				* idea: 
					* option 1: single_change == 1 & female_always == 1
*browse if single_change == 1 & female_always == 1
gen f2f = . 
replace f2f = 1 if single_change == 1 & female_always == 1
lab var f2f "rep-change female to female"
codebook firmid if f2f == 1
	* 110 firms, 4503 processes
gen m2m = . 
replace m2m = 1 if single_change == 1 & male_always == 1
lab var m2m "rep-change male to male"
codebook firmid if m2m == 1
	* 487 firms, 22,983 processes

********* PART 2.2.: identify firms that changed the gender of representative several times

		* create a var that counts / = 1 each time gender of rep changes
tempvar gender_change_count
gen `gender_change_count' = . 
bysort firmid (firm_occurence): replace `gender_change_count' = 1 if female_firm[_n] != female_firm[_n-1] & _n>1 & repchange == 1

		* create a var that sums for each firm the number of 
egen gender_change_sum = sum(`gender_change_count'), by(firmid)

		* create a dummy for a single gender in gender of rep
gen gender_change_single = (gender_change_sum == 1 & gender_change_sum < .)
codebook firmid if gender_change_single == 1
			* 206 firms, 18,111 bids
		* create dummy for multiples changes in gender of rep
gen gender_change_multiple = (gender_change_sum > 1 & gender_change_sum < .)
codebook firmid if gender_change_multiple == 1
			* 384 firms, 209,079 bids

********* PART 2.3.: identify firms that changed rep but only among women (men)
gen f2m = .
	* idea: if single change & first observation is female it must change f2m
bysort firmid (firm_occurence): replace f2m = 1 if gender_change_single == 1 & female_firm[1] == 1
	* define the counterfactual
		* option 1 (selected option): compare to female to female change
		* option 2: compare to multiple changes
replace f2m = 0 if f2f == 1
lab var f2m "f2m vs. f2f for single gender change"
codebook firmid if f2m == 1
order f2m, a(persona_encargada_proveedor)
			* 79 firms, 2414 processes

gen m2f = .
	* idea: if single change & first observation is female it must change f2m
bysort firmid (firm_occurence): replace m2f = 1 if gender_change_single == 1 & female_firm[1] == 0
	* define the counterfactual
		* option 1 (selected option): compare to male to male change
		* option 2: compare to multiple changes
replace m2f = 0 if m2m == 1
lab var m2f "m2f vs. m2m for single gender change"
codebook firmid if m2f == 1
order m2f, a(f2m)
			* 92 firms, 1764 processes

***********************************************************************
* 	PART 3:  Create post variable			
***********************************************************************	
	* treatment group
* idea: exploit the new m2f & f2m variables to create post variable for the treatment group
	* for m2f firm, post = 1 if female_firm == 1
	* for f2m firms, post = 1 if female_firm == 0
/* gen post = .
	*
replace post = 1 if m2f == 1 & female_firm == 1
replace post = 0 if m2f == 1 & female_firm == 0
	*
replace post = 1 if f2m == 1 & female_firm == 0
replace post = 0 if f2m == 1 & female_firm == 1
order post, a(m2f)
format %5.0g post
*/

***********************************************************************
* 	PART 3:  Create a placebo treatment for the firms that did never change CEO			
***********************************************************************
* idea: see _difference-in-difference line 28 - 46


***********************************************************************
* 	PART 4:  Create a time to treat variable for control group	
***********************************************************************
* problem:
	* Stata does not seem to get along well with the strings saved in persona_encargada_proveedor
		* (1) data actually shows there are several changes in representative although reps variable suggests there were only 2 representatives
		* (2) code using persona_...[_n] != or == [n_1] does not work well as Stata struggles to make a difference
	* idea/approach: try to create a numeric variable for each distinct value of a firm-repname pair
		* objective: identify the process (its value/value of the process before) to create time_to_treat variable
order f2f m2m, a(m2f)
tempvar treat_value_before1 control_value_before1 treat_value_before2 control_value_before2 value_before tag value
			
			* use egen tag() to create a dummy that = 1 for the first occurence of each distinct value of persona_encagarda_proveedor for each firm
sort firmid firm_occurence
egen `tag' = tag(firmid persona_encargada_proveedor)
order `tag', a(persona_encargada_proveedor)
			* next, try to get the value_before first occurence of second firm rep
egen `value' = max(firm_occurence) if `tag' == 1, by(firmid)
*order value, a(tag)
			* -1 to get the value_before the last (max) value 
gen `control_value_before1' = `value' - 1
*order control_value_before1, a(value)
			* create a tempvar that has value_before as value for all obs of firmid
egen `control_value_before2' = max(`control_value_before1'), by(firmid)
*order control_value_before, a(control_value_before1)

/*		
sort firmid firm_occurence
egen control_value_before1 = max(firm_occurence) if persona_encargada_proveedor[_n] == persona_encargada_proveedor[_n-1] & f2f == 1 | m2m == 1, by(firmid)
egen control_value_before2  = max(control_value_before1), by(firmid)
order control_value_before*, a(firm_occurence)*/

*browse if f2f == 1 | m2m == 1
***********************************************************************
* 	PART 5:  Create a time to treat variable for treatment group
***********************************************************************	
* idea: firm_occurence but centred at 0 (or -1) period before change
	* 1: get the value one period before the change occurs:
		* idea: 
			* m2f --> max occurence for female_firm == 0
			* f2m --> max occurence for female_firm == 1
egen `treat_value_before1' = max(firm_occurence) if female_firm==0 & m2f == 1 | female_firm == 1 & f2m == 1, by(firmid)
egen `treat_value_before2' = max(`treat_value_before1'), by(firmid)


gen `value_before' = .
replace `value_before' = `control_value_before2' if m2m == 1 | f2f == 1
replace `value_before' = `treat_value_before2' if f2m == 1 | m2f == 1

	* 2: replace values of time_to_treat var:
		* idea:
			* post = 1: replace time_to_treat = firm_occurrence - value_before
			* post = 0: replace time_to_treat = value_before - firm_occurence
	
	* generate time to treat variable
gen time_to_treat = .
bysort firmid (firm_occurence): replace time_to_treat = firm_occurence - `value_before'
order time_to_treat, a(firm_occurence)
format %5.0g time_to_treat
/* 
	* visualise how many lags and leaps before treatment (change in reps gender)
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
	
*/
* to browse firms in treatment and control group: browse if gender_change_single == 1

***********************************************************************
* 	PART 6:  Create scatterplot of coefficient	
***********************************************************************	
	* set export folder for regression tables
cd "$ppg_regression_tables"
	* set panel data
	
	* estimate coefficients & se
		* problem: stata does not allow negative factors
			* solution: shift time to treat variable by a certain factor to make it all positive
				* shift factor should correspond to event window width, which needs to be determined arbitrarily
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
graph export lags_leaps_around_gender_change_process_level_m2f_50.png, replace
			
twoway  (histogram nttt10 if nttt10 <= 20 & nttt10 > = 0 & m2f == 1, width(1) frequency color(maroon%30)) ///
		(histogram nttt10 if nttt10 <= 20 & nttt10 > = 0 & m2f == 0, width(1) frequency color(navy%30)), ///
			xline(20) ///
			legend(order(1 "Male to female" 2 "Male to male")) ///
			title("{bf:Lags and leaps around gender change of firm representative}") ///
			subtitle("{it:Process-level by treatment and control group}") ///
			xtitle("Time to treatment") xlabel(#10) ///
			ylabel(0(50)500) ytitle("Total number of procurement processes")
graph export lags_leaps_around_gender_change_process_level_m2f_10.png, replace

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

