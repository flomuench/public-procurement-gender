***********************************************************************
* 			public procurement gender - merge							  		  
***********************************************************************
*																	  
*	PURPOSE: merge main data set with lists of coded gender of procurement		  	  			
*			officials and firms representatives												  
*																	  
*	OUTLINE:														  
*	1)		Import, save, and merge with list of firm representatives				          
*	2)		Import, save, and merge with list of procurement representatives				          
*																	  													      
*	Author:  	Florian Muench						    
*	ID variable: 	no id yet; five levels: process, subprocess, product line, firm, evaluation criteria			  					  
*	Requires: 	  	SICOP_gender_new_workingversion.dta or SICOPgendernew
*	Creates:  		sicop_replicable                                  
***********************************************************************
* 	PART 1: 	Import, save, and merge firm reps
***********************************************************************
use "${ppg_intermediate}/sicop_replicable", clear

	* import + save list of firm reps
preserve
	import delimited using "${ppg_gender_lists}/listgenderfo", varn(1) case(preserve) clear
	save "${ppg_gender_lists}/listgenderfo", replace
restore

	* merge list on main data
merge m:1 PERSONA_ENCARGADA_PROVEEDOR using "${ppg_gender_lists}/listgenderfo"
_drop merge


***********************************************************************
* 	PART 2: 	Import, save, and merge firm reps
***********************************************************************
	* import + save list of firm reps
preserve
	import excel using "${ppg_gender_lists}/listgenderpo", firstrow clear
	save "${ppg_gender_lists}/listgenderpo", replace
restore

	* merge list on main data
merge m:1 PERSONA_ENCARGADA_PROVEEDOR using "${ppg_gender_lists}/listgenderpo"
_drop merge



***********************************************************************
* 	PART 3: 	save as raw data 
***********************************************************************
save "${ppg_intermediate}/sicop_replicable", replace