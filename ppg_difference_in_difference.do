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

	* create State recognized time variables to create a running event variable
local fechas "publicacion adjudicacion registro"
foreach x of local fechas {
gen date_`x' = clock(fecha_`x', "DM20Yhms"), a(fecha_`x')
format date_`x' %tc
drop fecha_`x'
}

sort firmid date_adjudicacion
bysort firmid : gen occurrence = _n, a(firmid)

	* mask: "DMY"
	
	* try to identify firms that changed the representative
gen repchange1 = . 
bysort firmid: replace repchange = 1 if persona_encargada_proveedor[_n] != persona_encargada_proveedor[_n-1]
bysort firmid: replace repchange = 0 if persona_encargada_proveedor[_n] == persona_encargada_proveedor[_n-1]

egen repchange2 = sum(repchange1), by(firmid)
by firmid: gen repchange = (repchange2 > 1)
order repchange*, a(ceochange)

/* gen compare = (repchange == ceochange) --> suggests same in 75% but different in 25%*/

	* identify firm that changed their representatives gender
* option 1: use ceof2m ceom2f
gen repgenderchange = .
replace repgenderchange = 0 if repchange == 0
replace repgenderchange = 0 if repchange == 1 & ceom2f == 0 & ceof2m == 0
replace repgenderchange = 1 if repchange == 1 & ceom2f == 1 | ceof2m == 1
tab repgenderchange, missing

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
	