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
replace f2m = 1 if gender_change_single == 1 & female_firm[1] == 1
	* define the counterfactual
		* option 1 (selected option): compare to female to female change
		* option 2: compare to multiple changes
replace f2m = 0 if f2f == 1
lab var f2m "f2m vs. f2f for single gender change"
codebook firmid if f2m == 1
			* 197 firms, 17, 881 bids

gen m2f = .
	* idea: if single change & first observation is female it must change f2m
replace m2f = 1 if gender_change_single == 1 & female_firm[0] == 1
	* define the counterfactual
		* option 1 (selected option): compare to male to male change
		* option 2: compare to multiple changes
replace m2f = 0 if m2m == 1
lab var m2f "m2f vs. m2m for single gender change"
codebook firmid if f2m == 1
			* 197 firms, 17, 881 bids


* event --> first time change occurred t = 1
	* event before change --> t = 0
	* 
	