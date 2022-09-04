***********************************************************************
* 			generate variables public procurement gender								  	  
***********************************************************************
*																	   
*	PURPOSE: Generate variables for analysis															
*																	  
*	OUTLINE:														  
*	1)				firm age		  						  
*	2)   			firm location	  		    
*	3)  			firm country of origin	  
*	4)  			firm size
*	5)  			firm occurence, calendar independent 			  
*	6)  
*	7)											  
*	8)												  
*																	  
*	Author:  	Florian Muench					          															      
*	ID variable: 	process level id = id ; firm level id = firmid
*	Requires:  	   								  
*	Creates:  			   						  
*																	  
***********************************************************************
* 	PART START:  Load data set		  			
***********************************************************************
use "${ppg_intermediate}/sicop_replicable", clear

***********************************************************************
* 	PART 0:  create Stata recognized date variables			
***********************************************************************
* browse id numero_procedimiento year fecha_publicacion fecha_adjudicacion partida linea nombre_proveedor firmid 

	* create Stata recognized time variables to create a running event variable
local fechas "publicacion adjudicacion registro"
foreach x of local fechas {
gen date_`x' = clock(fecha_`x', "DM20Yhms"), a(fecha_`x')
format date_`x' %tc
}

***********************************************************************
* 	PART 1:  generate age variables			
***********************************************************************
	* create year variables for the year of publication, 
		* execution of the bid & firm registration
local dates "publicacion adjudicacion registro"
foreach var of local dates {
	gen year_`var' = substr(fecha_`var', 7, 2), a(fecha_`var')
	destring year_`var', replace
	replace year_`var' = year_`var' + 2000
}

	* do the same for the year when the firm was founded (different format thus not in loop)
gen year_constitucion = substr(fecha_constitucion, -4, .), a(fecha_constitucion)
destring year_constitucion, replace
label var year_constitucion "year when firm was founded"

	* calculate the age variables 
		* firm age in 2019
gen age_constitucion = 2019 - year_constitucion
label var age_constitucion "firm age in 2019"

		* firm age at time of bid publication
gen age = year_publicacion - year_constitucion
label var age "firm age at time of bid publication"

		* firm age at registration
gen age_registro = year_registro - year_constitucion
label var age_registro "firm age when registered"


***********************************************************************
* 	PART 2:  generate location dummies		
***********************************************************************
tab firm_location, gen(firm_location)

***********************************************************************
* 	PART 3:  generate country origin dummy
***********************************************************************
gen firm_international = (pais_domicilio != "crc"), a(pais_domicilio)
label var firm_international "international firm (= not from CR)"
label def international 0 "Costa Rican" 1 "International"
lab val firm_international international

***********************************************************************
* 	PART 4:  generate firm size dummy
***********************************************************************
tab firm_size, gen(firm_size)


***********************************************************************
* 	PART 5: generate firm occurence variable			
***********************************************************************
sort firmid date_adjudicacion numero_procedimiento partida linea
by firmid: gen firm_occurence = _n, a(firmid)
format %5.0g firmid firm_occurence

***********************************************************************
* 	PART 5:  single, never, multiple changes in representative 
***********************************************************************
	* idea: only look at firms that have more than 1 distinct name
		* gen count number of representatives & dummy for single rep		
			* idea: count unique values of representative
by firmid persona_encargada_proveedor, sort: gen reps = _n == 1, a(persona_encargada_proveedor)
bysort firmid: replace reps = sum(reps)
bysort firmid: replace reps = reps[_N]
	
gen single_change = (reps == 2)
codebook firmid if single_change == 1
				* 860 firms, 40,470 processs
				
gen never_change = (reps == 1)
codebook firmid if never_change == 1
				* 7384 firms, 100,119 processes

gen multiple_change = (reps > 2 & reps <.)
codebook firmid if multiple_change == 1
				* 417 firms
				
***********************************************************************
* 	PART 6:  Verify via text matching if change in reps not wrongly assigned due to misspellings	  			
***********************************************************************

egen rep_id = group(persona_encargada_proveedor)

*egen firm_rep_id = group(firmid rep_id)
*bys firmid (rep_id): gen firm_rep_id = _n

*egen firm_rep_id = group(firmid rep_id)

*preserve 

contract firmid rep_id persona_encargada_proveedor
drop _freq
bysort firmid (persona_encargada_proveedor) : gen firm_rep_id = sum(persona_encargada_proveedor != persona_encargada_proveedor[_n-1])
drop rep_id
reshape wide persona_encargada_proveedor, i(firmid) j(firm_rep_id)

/*
local i = 2
forvalues x = 1(1)24 {
	matchit persona_encargada_proveedor`x' persona_encargada_proveedor`i', gen(score`x'`i')
	local ++i
	}
*/	
local i = 1
forvalues first  = 1(1)24 {
		local ++i
forvalues second = `i'(1)25 {
	matchit persona_encargada_proveedor`first' persona_encargada_proveedor`second', gen(score`first'`second')
	}
}

/*1 
23456
2
346789	

	* remove all 1 due to missing values
foreach x of varlist score12-score2425 {
	replace `x' = . if `x' == 1
}

	* create per firms maxscore
egen maxscore = rowmax(score12-score2425)

	* identify potential problematic cases
br persona_encargada_proveedor* if maxscore >= 0.9

	* check for cross-matches



restore

* left
local correct_names `" "minor ramirez marin" "maria gabriela duran solis" "jonathan mariÑo  g" "'

*right
local incorrect_names `" "minor ramirez mariz" "maria gabriela duran solis." "jonathan mariÑo g"'

local n : word count `correct_names'

forvalues i = 1/`n' {
	local a : word `i' of `correct_names'
	local b : word `i' of `incorrect_names'
	replace persona_encargada_proveedor = "`a'" if persona_encargada_proveedor == "`b'"
	
}

 



***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
save "${ppg_final}/sicop_final", replace
