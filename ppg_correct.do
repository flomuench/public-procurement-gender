***********************************************************************
* 			public procurement gender corrections		
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
* 	PART 1:  Make all string obs lower case & remove trailing spaces  			
***********************************************************************
use "${ppg_intermediate}/sicop_replicable", clear
	
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
replace `x'= strtrim(lower(`x'))
}

***********************************************************************
* 	PART 2:  Encode categorical variables		  			
***********************************************************************
		* firm size dummy
lab def fsize 1 "micro" 2 "pequeña" 3 "mediana" 4 "grande" 5 "no clasificado"
encode tipo_empresa, gen(firm_size) label(fsize)
lab var firm_size "micro, small, medium, large or unclassified firm"


***********************************************************************
* 	PART 3:  Replace string with numeric values		  			
***********************************************************************
	* q391: ventes en export 
*replace q391_corrige = "254000000" if id == "f247"
replace female_firm = 0 if firmid == 7 & persona_encargada_proveedor == "luis gonzalez mora"
replace genderfo = 0 if firmid == 7 & persona_encargada_proveedor == "luis gonzalez mora"


***********************************************************************
* 	PART 4:  Code missing gender values	 + correct spelling
***********************************************************************
	* export Excel file with all the different values of female_firm per firm
preserve
contract firmid nombre_proveedor persona_encargada_proveedor female_firm
format %40s nombre_proveedor persona_encargada_proveedor
sort firmid female_firm persona_encargada_proveedor
	* 382 missing values
cd "$ppg_intermediate"
export excel using missing_names if female_firm == ., replace firstrow(var)
	* import excel with missing names gender coded
import excel using missing_names_coded, clear firstrow
tempfile missings_coded
save "`missings_coded'"
restore
merge m:1 firmid persona_encargada_proveedor using `missings_coded', replace update

	* try to identify/match names with small spelling differences
drop _freq
ssc install strgroup, replace
contract firmid nombre_proveedor persona_encargada_proveedor
		
		* option 1 strgroup
bysort firmid: strgroup persona_encargada_proveedor, generate(rep) threshold(.7) first
 
		* option 2 cross
contract firmid nombre_proveedor persona_encargada_proveedor
gen id = _n
preserve
rename persona_encargada_proveedor persona_encargada_proveedor2
tempfile persona_encargada_proveedor2
save `persona_encargada_proveedor2'
restore
merge 1:1 id using `persona_encargada_proveedor2'
*drop if persona_encargada_proveedor2>=persona_encargada_proveedor
matchit persona_encargada_proveedor persona_encargada_proveedor2
list if similscore>0.8, clean

	* option 3 same as 2 but use levenstein instead
contract firmid nombre_proveedor persona_encargada_proveedor
tempfile data
save `data'
*TURN TIMER ON
timer on 1
*BREAK IT UP INTO TENTHS AND CROSS
forval i=1/11{
keep if inrange(_n,`i'000-999,`i'000)
rename persona_encargada_proveedor persona_encargada_proveedor2
tempfile ds`i'
save `ds`i''
use `data', clear
}

forval i=1/11{
cross using `ds`i''
tempfile cds`i'
save `cds`i''
use `data', clear
}

*APPEND DATA SETS
use `cds1', clear
forval i=2/11{
append using `cds`i''
}
*TURN OFF TIMER
timer off 1
drop if persona_encargada_proveedor2>=persona_encargada_proveedor
matchit persona_encargada_proveedor persona_encargada_proveedor2
list if similscore>0.5, clean	
	
***********************************************************************
* 	PART 4:  Convert string to numerical variables	  			
***********************************************************************
/*foreach x of global numvarc {
destring `x', replace
format `x' %25.0fc
}
*/

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************

save "sicop_replicable", replace
