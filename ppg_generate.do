***********************************************************************
* 			generate variables public procurement gender								  	  
***********************************************************************
*																	   
*	PURPOSE: Generate variables for analysis															
*																	  
*	OUTLINE:														  
*	1)				generate age variables		  						  
*	2)   						  		    
*	3)  					  		  
*	4)  				  				  
*	5)  					  			  
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
* 	PART START:  Gen treatment status variable		  			
***********************************************************************
use "${ppg_intermediate}/sicop_replicable", clear

***********************************************************************
* 	PART 0:  create a process id			
***********************************************************************
egen process_id = group(numero_procedimient partida linea)
order process_id, a(linea)

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
* 	Save the changes made to the data		  			
***********************************************************************

save "sicop_replicable", replace
