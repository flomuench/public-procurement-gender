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
* 	PART 1:  create a calendar independent event variable 			
***********************************************************************
use "${ppg_intermediate}/sicop_replicable", clear

sort firmid firm_appearance
browse id numero_procedimiento year fecha_publicacion fecha_adjudicacion partida linea nombre_proveedor firmid 

sort firmid date_adjudicacion numero_procedimiento partida linea
by firmid: gen firm_occurence = _n, a(firmid)

	* create State recognized time variables to create a running event variable
local fechas "publicacion adjudicacion registro"
foreach x of local fechas {
gen date_`x' = clock(fecha_`x', "DM20Yhms"), a(fecha_`x')
format date_`x' %tc
drop fecha_`x'
}

order date_adjudicacion, a(linea)

sort firmid date_adjudicacion
bysort firmid : gen occurrence = _n, a(firmid)

	* mask: "DMY"
	
	
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
gen f2f = (female_always == 1 & repchange == 1)
lab var f2f "rep-change female to female"
codebook firmid if f2f == 1
	* 125 firms, 19,379 bids
gen m2m = (male_always == 1 & repchange == 1)
lab var m2m "rep-change male to male"
codebook firmid if m2m == 1
	* 618 firms, 171,277 bids

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
			* 77 firms, 10,461 bids

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

			* 91 firms, 6,673 bids

***********************************************************************
* 	PART 3:  Create post variable			
***********************************************************************	
	* treatment group
* idea: exploit the new m2f & f2m variables to create post variable for the treatment group
	* for m2f firm, post = 1 if female_firm == 1
	* for f2m firms, post = 1 if female_firm == 0
gen post = .
	*
replace post = 1 if m2f == 1 & female_firm == 1
replace post = 0 if m2f == 1 & female_firm == 0
	*
replace post = 1 if f2m == 1 & female_firm == 0
replace post = 0 if f2m == 1 & female_firm == 1
order post, a(m2f)
format %5.0g post

***********************************************************************
* 	PART 3:  Create a placebo treatment for the firms that did never change CEO			
***********************************************************************
* idea: see _difference-in-difference line 28 - 46


***********************************************************************
* 	PART 4:  Create a time to treat variable for control group	
***********************************************************************
* f2f, m2m identify firms with one single same gender change
	* task: need to identify switching point
	* idea: identify max occurence before switch
order f2f m2m, a(m2f)
tempvar treat_value_before1 control_value_before1 treat_value_before2 control_value_before2 value_before
sort firmid firm_occurence
egen `control_value_before1' = max(firm_occurence) if persona_encargada_proveedor[_n] == persona_encargada_proveedor[_n-1] & f2f == 1 | m2m == 1, by(firmid)
egen `control_value_before2'  = max(`control_value_before1'), by(firmid)

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

* to browse firms in treatment and control group: browse if gender_change_single == 1

***********************************************************************
* 	PART 6:  Create scatterplot of coefficient	
***********************************************************************	
	* set panel data
	
	* estimate coefficients & se
		* 
		* problem: stata does not allow negative factors
			* solution: shift time to treat variable by a certain factor to make it all positive
				* problem: time_to_treat varies by firm
					* solution: determine event window of interest
						* problem: for firms that bidded for big processes, small window will refer
							* to the same processes
* can different firms win subprocesses in one big process? 
duplicates tag numero_procedimiento firmid winner, gen(process_same_firm_outcome)

gen tag_same_process_diff_winner = .
bysort firmid (firm_occurence): replace tag_same_process_diff_winner = 1 if numero_procedimiento[_n] == numero_procedimiento[_n-1] & process_same_firm_outcome == 0
							
egen shift_factor = min(firm_occurence) if gender_change_single == 1, by(firmid)
gen shifted_ttt = time_to_treat + r(min)


logit winner i.f2m##ib.post , vce(robust)

preserve
keep if time_to_treat <= 5 & time_to_treat >= -5
tw ///
	(kdensity winner if m2f == 1, lp(dash) lc(maroon) bwidth(.5)) ///
	(kdensity winner if f2m == 1, lp(dash) lc(navy) bwidth(.5)) 
restore
