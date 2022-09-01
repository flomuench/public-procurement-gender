***********************************************************************
* 			public procurement gender clean									  		  
***********************************************************************
*																	  
*	PURPOSE: clean administrative procurement data					  	  			
*																	  
*																	  
*	OUTLINE:														  
*	1)		Format string & numerical variables				          
*	2)   	Drop all text windows from the survey					  
*	3)  	Make all variables names lower case						  
*	4)  	Order the variables in the data set						  	  
*	5)  	Rename the variables									  
*	6)  	Label the variables										  
* 	7) 		Label variable values 								 
* 	8) 		Trim obversations										 
*																	  													      
*	Author:  	Florian Muench						    
*	ID variable: 	process-level id = id ; firm level id = firmid			  					  
*	Requires: 	  	SICOP_gender_new_workingversion.dta									  
*	Creates:  		codebook-variables, codebook-labels	                                  
***********************************************************************
* 	PART 1: 	Make all variables names lower case		  			
***********************************************************************
use "${ppg_raw}/SICOP_gender_new_workingversion", clear

rename TIPO tipo_s
rename *, lower

***********************************************************************
* 	PART 2: 	Drop variables		  			
***********************************************************************
drop firm_size firm_founded firm_registration firm_registro date_ca date_pu ///
	date_contract_published date_contract_allocated firm_age_registro ///
	firm_appearance

***********************************************************************
* 	PART 3: 	Format string & numerical variables		  			
***********************************************************************

ds, has(type string) 
local strvars "`r(varlist)'"
format %-15s `strvars'
format %-25s numero_procedimiento persona_encargada_proveedor
format %-5s partida
 
ds, has(type numeric) 
local numvars "`r(varlist)'"
format %20.0fc `numvars'
format %10.0g firmid id firmid year female_firm
format %5.0g linea genderfo ceochange ceof2m ceom2f winner cantidad

***********************************************************************
* 	PART 4: 	Order the variables in the data set		  			
***********************************************************************
 
***********************************************************************
* 	PART 5: 	Rename the variables		  			
***********************************************************************


***********************************************************************
* 	PART 6: 	Label the variables		  			
***********************************************************************
lab var female_firm "firm represented by a women = 1"
* label var q03 "continuer avec le questionnaire ou attendre PDG"

***********************************************************************
* 	PART 7: 	Label variables values	  			
***********************************************************************
		* label values of representatives gender
			* firm
lab def genderfirm 0 "male firm" 1 "female firm"
lab val female_firm genderfirm
			* procurement officer
lab def genderpo 0 "male officer" 1 "female officer"
lab val female_po genderpo

***********************************************************************
* 	PART 8: Removing trail and leading spaces in string values that will be converted into numeric values*	  			
***********************************************************************

*Triming string variable
/*foreach x of global numvar {
replace `x' = strtrim(`x')
}*/

***********************************************************************
* 	PART 9: sort the observations in the right of the process
***********************************************************************
sort numero_procedimiento partida linea

***********************************************************************
* 	PART 10: create a codebook
***********************************************************************
cd "$ppg_github"
export excel ppg_codebook_variables in 1/1, firstrow(variables) replace
export excel ppg_codebook_labels in 1/1, firstrow(varlabels) replace

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
cd "$ppg_intermediate"
save "sicop_replicable", replace
