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
* 	PART 1: 	Format string & numerical variables		  			
***********************************************************************
use "${ppg_raw}/SICOP_gender_new_workingversion", clear

ds, has(type string) 
local strvars "`r(varlist)'"
format %15s `strvars'
format %25s numero_procedimiento


*Lower all string observations of string variables*
foreach x of local strvars {
replace `x'= lower(`x')
}
 
ds, has(type numeric) 
local numvars "`r(varlist)'"
format %15.0fc `numvars'
format %9.0g id firmid

***********************************************************************
* 	PART 2: 	Drop variables		  			
***********************************************************************
drop tipo_empresa firm_founded firm_registration firm_registro

***********************************************************************
* 	PART 3: 	Make all variables names lower case		  			
***********************************************************************
rename TIPO tipo_s
rename *, lower

***********************************************************************
* 	PART 4: 	Order the variables in the data set		  			
***********************************************************************

***********************************************************************
* 	PART 5: 	Rename the variables		  			
***********************************************************************


***********************************************************************
* 	PART 6: 	Label the variables		  			
***********************************************************************

* label var q03 "continuer avec le questionnaire ou attendre PDG"

***********************************************************************
* 	PART 7: 	Label variables values	  			
***********************************************************************

*lab def mlran 1 "standards section" 2 "conformity section" 3 "metrology section"
*lab val midline_rand mlran

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
cd "$ppg_intermediate"

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************

save "sicop_replicable", replace
