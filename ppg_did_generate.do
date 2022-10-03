***********************************************************************
* 			ppg did identify & generate different treatment groups							  	  
***********************************************************************
*																	   
*	PURPOSE: Identify the treatment and control group firms in the data															
*			& generate dummy variables indicating treatment status
*	OUTLINE:														  
*	1)				identify the different treatment groups		  						  
*	2)   			dummy for change in representative 	"repchange"	  		    
*	3)  			single, never, multiple changes in representative	  
*	4)  			Female & male only representatives
*	5)  			(Fe)-male & same person 			  
*	6)  			Always- & Nevertakers (same gender, single change)
*	7)				Switchers, single & multiple changes in gender							  
*	8)				Compliers & defiers	
*   9) 				Create a time to treat variable for control group								  
*	10) 			Create a time to treat variable for treatment group	
* 																				  
*	Author:  	Florian Muench					          															      
*	ID variable: 	firm id = cedula_proveedor; process id = numero_procedimiento
*	Requires:  	   	sicop_process.dta							  
*	Creates:  		sicop_process.dta	   						  
*																	  
***********************************************************************
* 	PART START:  Load data set		  			
***********************************************************************
use "${ppg_final}/sicop_process", clear


***********************************************************************
* 	PART 0:  create firm occurence running variable
***********************************************************************	
	* change order to panel structure: firm id first variable
order cedula_proveedor nombre_proveedor persona_encargada_proveedor numero_procedimiento date_publicacion date_adjudicacion monto_crc
	
	* stable sort such that remains always in same order
sort cedula_proveedor date_publicacion numero_procedimiento, stable

	* create firm occurence count
by cedula_proveedor: gen firm_occurence = _n, a(cedula_proveedor)
format %-5.0g firm_occurence


	* create time difference between two contracts
			* calculation/difference btw. two dates are calculates in miliseconds
				* adding hours function provides diffence in hours rather than miliseconds
				* dividing by 24 provides the difference in days
by cedula_proveedor: gen hours_dif = hours(date_publicacion - date_publicacion[_n-1]), a(date_publicacion)
gen days_dif = hours_dif/24, a(date_publicacion)
drop hours_dif

	* how much time between publication and adjucation?
gen days_pub_adj = clockdiff(date_publicacion, date_adjudicacion, "day"), a(date_adjudicacion)


***********************************************************************
* 	PART 1:  identify the different treatment groups 			
***********************************************************************	
	********* PART 1.1.: identify firms that changed the representative
		* in analysis drop all firms that have not changed their representative
		* as change in rep could indicate firm performs less well before, hence
		* effect observed after rep change would reflect change from low to high performing
		* individual rather than change in gender
	
***********************************************************************
* 	PART 2: dummy for change in representative 	"repchange"		
***********************************************************************
gen repchange1 = ., a(persona_encargada_proveedor)
bysort cedula_proveedor: replace repchange1 = 1 if persona_encargada_proveedor[_n] != persona_encargada_proveedor[_n-1]
bysort cedula_proveedor: replace repchange1 = 0 if persona_encargada_proveedor[_n] == persona_encargada_proveedor[_n-1]

egen repchange2 = sum(repchange1), by(cedula_proveedor)
bysort cedula_proveedor: gen repchange = (repchange2 > 1 & repchange2 < .)
order repchange*, a(persona_encargada_proveedor)

lab var repchange "firm changed rep"
		
		* how many firms never change rep?
codebook cedula_proveedor if repchange == 0 /* 7595; 1069 switched their rep. */

drop repchange?

***********************************************************************
* 	PART 3: single, never, multiple changes in representative 			
***********************************************************************
			* idea: count unique values of representative
by cedula_proveedor persona_encargada_proveedor, sort: gen reps = _n == 1, a(repchange)
bysort cedula_proveedor: replace reps = sum(reps)
bysort cedula_proveedor: replace reps = reps[_N]

lab var reps "number of reps per firm"
	
gen single_change = (reps == 2), a(reps)
codebook cedula_proveedor if single_change == 1
lab var single_change "firm changed rep once"
				* 721 firms, 39,911 processs

gen never_change = (reps == 1), a(repchange)
codebook cedula_proveedor if never_change == 1
				* 7595 firms, 101,542 processes
lab var single_change "firm never changed rep"

				
gen multiple_change = (reps > 2 & reps <.), a(single_change)
codebook cedula_proveedor if multiple_change == 1
				* 348 firms, 40,298 processes
lab var single_change "firm switched multiple reps"

***********************************************************************
* 	PART 4: Female & male only representatives 			
***********************************************************************		
	* generate dummy for firms that had always only female (male) representatives
			* idea: minimum (maximum) value of genderfo is 1 (0)
tempvar fonly
egen `fonly' = min(genderfo), by(cedula_proveedor)
gen female_always = (`fonly' == 1)
replace female_always = . if `fonly' == .
					* how many firms are female-always? 1983 firms, 30,334 bids
codebook cedula_proveedor if female_always == 1
lab var female_always "firm always had a female rep"

tempvar monly
egen `monly' = max(genderfo), by(cedula_proveedor)
gen male_always = (`monly' == 0)
replace male_always = . if `monly' == .
					* how many firms are male-always? 5926
codebook cedula_proveedor if male_always == 1
lab var male_always "firm always had a male rep"


***********************************************************************
* 	PART 5: (Fe)-male & same person 			
***********************************************************************
		* generate dummy for firms that never changed person 
gen female_always_same_person = (female_always == 1 & repchange == 0), a(never_change)
codebook cedula_proveedor if female_always_same_person == 1
			* how many female firms never change rep: 1910
			
gen male_always_same_person = (male_always == 1 & repchange == 0), a(female_always_same_person)
replace male_always_same_person = . if repchange == 1
codebook cedula_proveedor if male_always_same_person == 1
			* how many male firms never change rep: 5680

***********************************************************************
* 	PART 6: Always- & Nevertakers (same gender, single change)			
***********************************************************************
	* always takers
gen f2f = ., a(single_change)
replace f2f = 1 if single_change == 1 & female_always == 1
lab var f2f "rep-change female to female"
codebook cedula_proveedor if f2f == 1
		* 64 firms, 3379 processes
		
		
	* never takers
gen m2m = . 
replace m2m = 1 if single_change == 1 & male_always == 1
lab var m2m "rep-change male to male"
codebook cedula_proveedor if m2m == 1
	* 355 firms, 18,837 processes

***********************************************************************
* 	PART 7: Switchers, single & multiple changes in gender		
***********************************************************************

********* PART 2.2.: identify firms that changed the gender of representative several times

		* create a var that counts / = 1 each time gender of rep changes
tempvar gender_change_count
gen `gender_change_count' = . , a()
bysort cedula_proveedor (firm_occurence): replace `gender_change_count' = 1 if genderfo[_n] != genderfo[_n-1] & _n>1 & repchange == 1

		* create a var that sums for each firm the number of 
egen gender_change_sum = sum(`gender_change_count'), by(cedula_proveedor)

		* create a dummy for a single gender in gender of rep
gen gender_change_single = (gender_change_sum == 1 & gender_change_sum < .)
codebook cedula_proveedor if gender_change_single == 1
			* 206 firms, 18,111 bids
		* create dummy for multiples changes in gender of rep
gen gender_change_multiple = (gender_change_sum > 1 & gender_change_sum < .)
codebook cedula_proveedor if gender_change_multiple == 1
			* 384 firms, 209,079 bids
			
			
***********************************************************************
* 	PART 8: Compliers & defiers			
***********************************************************************
	* single change from female to male
gen f2m = .
		* idea: if single change & first observation is female it must change f2m
bysort cedula_proveedor (firm_occurence): replace f2m = 1 if gender_change_single == 1 & genderfo[1] == 1
		* define the counterfactual
			* option 1 (selected option): compare to female to female change
			* option 2: compare to multiple changes
replace f2m = 0 if f2f == 1
lab var f2m "f2m vs. f2f for single gender change"
codebook cedula_proveedor if f2m == 1
order f2m, a(persona_encargada_proveedor)
			* 79 firms, 2414 processes

	* single change from male to female
gen m2f = .
		* idea: if single change & first observation is female it must change f2m
bysort cedula_proveedor (firm_occurence): replace m2f = 1 if gender_change_single == 1 & genderfo[1] == 0
		* define the counterfactual
			* option 1 (selected option): compare to male to male change
			* option 2: compare to multiple changes
replace m2f = 0 if m2m == 1
lab var m2f "m2f vs. m2m for single gender change"
codebook cedula_proveedor if m2f == 1
order m2f, a(f2m)
			* 92 firms, 1764 processes
			
			
label def compliers 1 "m2f" 0 "m2m"
label values m2f compliers
label def defiers 1 "f2m" 0 "f2f"
label values f2m defiers

***********************************************************************
* 	PART 9:  Create a time to treat variable for control group	
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
sort cedula_proveedor firm_occurence
egen `tag' = tag(cedula_proveedor persona_encargada_proveedor)
order `tag', a(persona_encargada_proveedor)
			* next, try to get the value_before first occurence of second firm rep
egen `value' = max(firm_occurence) if `tag' == 1, by(cedula_proveedor)
*order value, a(tag)
			* -1 to get the value_before the last (max) value 
gen `control_value_before1' = `value' - 1
*order control_value_before1, a(value)
			* create a tempvar that has value_before as value for all obs of cedula_proveedor
egen `control_value_before2' = max(`control_value_before1'), by(cedula_proveedor)
*order control_value_before, a(control_value_before1)

/*		
sort cedula_proveedor firm_occurence
egen control_value_before1 = max(firm_occurence) if persona_encargada_proveedor[_n] == persona_encargada_proveedor[_n-1] & f2f == 1 | m2m == 1, by(cedula_proveedor)
egen control_value_before2  = max(control_value_before1), by(cedula_proveedor)
order control_value_before*, a(firm_occurence)*/

*browse if f2f == 1 | m2m == 1

***********************************************************************
* 	PART 10:  Create a time to treat variable for treatment group
***********************************************************************	
* idea: firm_occurence but centred at 0 (or -1) period before change
	* 1: get the value one period before the change occurs:
		* idea: 
			* m2f --> max occurence for genderfo == 0
			* f2m --> max occurence for genderfo == 1
egen `treat_value_before1' = max(firm_occurence) if genderfo==0 & m2f == 1 | genderfo == 1 & f2m == 1, by(cedula_proveedor)
egen `treat_value_before2' = max(`treat_value_before1'), by(cedula_proveedor)


gen `value_before' = .
replace `value_before' = `control_value_before2' if m2m == 1 | f2f == 1
replace `value_before' = `treat_value_before2' if f2m == 1 | m2f == 1

	* 2: replace values of time_to_treat var:
		* idea:
			* post = 1: replace time_to_treat = firm_occurrence - value_before
			* post = 0: replace time_to_treat = value_before - firm_occurence
	


***********************************************************************
* 	PART 3:  Create a time to treat and normalised time to treat variable			
***********************************************************************	
	* generate time to treat variable
gen time_to_treat = .
bysort cedula_proveedor (firm_occurence): replace time_to_treat = firm_occurence - `value_before'
order time_to_treat, a(firm_occurence)
format %5.0g time_to_treat

	* normalise time to treat such that all values are positive
foreach t of num 10 25 50 {
gen nttt`t' = time_to_treat + `t', a(time_to_treat)
lab var nttt`t' "normalised time to treatment, +/- `t' window"
}



***********************************************************************
* 	PART 3:  Create post variable			
***********************************************************************	
	* treatment group
* idea: exploit the new m2f & f2m variables to create post variable for the treatment group
	* for m2f firm, post = 1 if genderfo == 1
	* for f2m firms, post = 1 if genderfo == 0
foreach t of num 10 25 50 {
gen post`t' = .
	* m2f
replace post`t' = 1 if m2f == 1 & nttt`t' > 0
replace post`t' = 0 if m2f == 1 & nttt`t' < 0
	* f2m
replace post`t' = 1 if f2m == 1 & nttt`t' > 0
replace post`t' = 0 if f2m == 1 & nttt`t' < 0
	* m2m
replace post`t' = 1 if m2m == 1 & nttt`t' > 0
replace post`t' = 0 if m2m == 1 & nttt`t' < 0

order post`t', a(m2f)
format %5.0g post`t'
}

gen post = ., a(time_to_treat)
	replace post = 1 if m2f == 1 & time_to_treat > 0  	/* m2f */
	replace post = 0 if m2f == 1 & time_to_treat <= 0	/* m2f */
	
	replace post = 1 if m2f == 0 & time_to_treat > 0	/* m2f */
	replace post = 0 if m2f == 0 & time_to_treat <= 0	/* m2f */

	replace post = 1 if f2m == 1 & time_to_treat > 0  	
	replace post = 0 if f2m == 1 & time_to_treat <= 0	
	
	replace post = 1 if f2m == 0 & time_to_treat > 0	
	replace post = 0 if f2m == 0 & time_to_treat <= 0

label def ab 1 "after" 0 "before"
label values post* ab

***********************************************************************
* 	Save new as sicop did 			
***********************************************************************
drop `value_before' `treat_value_before1' `control_value_before1' `control_value_before2' `treat_value_before2' `gender_change_count' `fonly' `monly'

*save "${ppg_final}/sicop_process", replace





* archive



***********************************************************************
* 	PART 3:  Create a placebo treatment for the firms that did never change CEO			
***********************************************************************
* idea: see _difference-in-difference line 28 - 46

