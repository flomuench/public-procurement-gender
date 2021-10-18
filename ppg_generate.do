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

	* create State recognized time variables to create a running event variable
local fechas "publicacion adjudicacion registro"
foreach x of local fechas {
gen date_`x' = clock(fecha_`x', "DM20Yhms"), a(fecha_`x')
format date_`x' %tc
drop fecha_`x'
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
* 	Save the changes made to the data		  			
***********************************************************************

save "sicop_replicable", replace
