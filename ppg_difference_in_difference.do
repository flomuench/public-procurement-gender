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

/* gen compare = (repchange == ceochange) --> suggests same in 75% but different in 25%*/

		* generate dummy for firms that had always only female (male) representatives
			* idea: minimum (maximum) value of female_firm is 1 (0)
tempvar `fonly'
egen fonly = min(female_firm), by(firmid)
gen female_always = (`fonly' = 1 & `fonly' != .)

tempvar `monly'
egen monly = max(female_firm), by(firmid)
gen female_always = (`monly' = 0 & `monly' != .) 

		* generate dummy for firms that never changed person 
gen female_always_same person = (female_always == 1 & repchange == 0)
gen male_always_same person = (male_always == 1 & repchange == 0)

		* ALWAYS - & NEVER TAKERS
gen f2f = (female_always == 1 & repchange == 1)
lab var f2f "rep-change female to female"
gen m2m = (male_always == 1 & repchange == 1)
lab var m2m "rep-change male to male"

********* PART 2.2.: identify firms that changed the gender of representative several times
		* create a var that counts / = 1 each time gender of rep changes
tempvar gender_change_count
gen `gender_change_count' = . 
bysort firmid (firm_occurrence): replace `gender_change_count' = 1 if female_firm[_n] != female_firm[_n-1] if n>1 & repchange == 1

		* create a var that sums for each firm the number of 
egen gender_change_sum = sum(`gender_change_count'), by(firmid)

		* create a dummy for a single gender in gender of rep
gen gender_change_single = (gender_change_sum == 1 & gender_change_sum < .)

		* create dummy for multiples changes in gender of rep
gen gender_change_multiple = (gender_change_sum > 1 & gender_change_sum < .)
		
********* PART 2.3.: identify firms that changed rep but only among women (men)
gen f2m = .
	* idea: if single change & first observation is female it must change f2m
replace f2m = 1 if gender_change_single == 1 & female_firm[1] == 1
	* define the counterfactual
		* option 1:
		* option 2:
replace f2m = 0 if f2f == 1

 identify firm that changed their representatives gender
* option 1: use ceof2m ceom2f
gen repgenderchange = .
replace repgenderchange = 0 if repchange == 0
replace repgenderchange = 0 if repchange == 1 & ceom2f == 0 & ceof2m == 0
replace repgenderchange = 1 if repchange == 1 & ceom2f == 1 | ceof2m == 1
tab repgenderchange, missing

drop repchange1 repchange2

gen treated = .
replace treated = 1 if repgenderchange == 1 
replace treated = 0 if 


gen treated_female = .
replace treated_male = 1 if ceom2f == 1 & repgenderchange == 1 & repchange == 1
replace treated_male = 0 if ceom2f == 0 & repgenderchange == 0 & repchange == 1
replace treated_male = . if ceof2m == 1 /* take out those that change in opposite direction to avoid cancelling out of effect */

gen treated_male = . 
replace treated_male = 1 if ceof2m == 1 & repgenderchange == 1 & repchange == 1
replace treated_male = 0 if ceof2m == 0 & repgenderchange == 0 & repchange == 1
replace treated_male = . if ceom2f == 1 /* take out those that change in opposite direction to avoid cancelling out of effect */
	