***********************************************************************
* 			public procurement gender bid level descriptive statistics		
***********************************************************************
*																	  
*	PURPOSE: replace					  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Create frequency table of gender firm vs. procurement official 			  				  
* 	2) 		
*	3)   							  
*	4)  		  				  	  
*																	  															      
*	Author:  	Florian Muench						  
*	ID variable: 	process level id = id ; firm level id = firmid			  					  
*	Requires: 	  								  
*	Creates:  			                          
*																	  
***********************************************************************
* 	PART 1: Create frequency table of gender firm vs. procurement official		
***********************************************************************
use "${ppg_intermediate}/sicop_replicable", clear

xtable (female_firm) (female_po), contents(count freq) filename(frequency_gender_firm_procurementofficial) replace
tabstat
*tab2xl female_firm female_po using frequency_gender_firm_procurementofficial, replace percentage row(1) col(1)
