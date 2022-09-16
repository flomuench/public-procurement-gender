***********************************************************************
* 			public procurement gender - import								  		  
***********************************************************************
*																	  
*	PURPOSE: import the main data set and saves in raw folder		  	  			
*																	  
*																	  
*	OUTLINE:														  
*	1)		Format string & numerical variables				          
*	2)   	Drop all text windows from the survey					  									 
*																	  													      
*	Author:  	Florian Muench						    
*	ID variable: 	no id yet; five levels: process, subprocess, product line, firm, evaluation criteria			  					  
*	Requires: 	  	SICOP_gender_new_workingversion.dta or SICOPgendernew
*	Creates:  		sicop_replicable                                  
***********************************************************************
* 	PART 1: 	Import raw data 
***********************************************************************
* three level version (700.000+ observations)
*use "${ppg_raw}/SICOP_gender_new_workingversion", clear

* four level version (1 million + observations)
use "${ppg_raw}/SICOPgendernew", clear

***********************************************************************
* 	PART 2: 	save as raw data 
***********************************************************************
save "${ppg_intermediate}/sicop_replicable", replace
