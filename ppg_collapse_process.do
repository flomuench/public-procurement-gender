***********************************************************************
* 			create sub-process level data set public procurement gender								  		  
***********************************************************************
*																	  
*	PURPOSE: create analysis, process-level data set
*			
*																	  
*	OUTLINE:														  
*	1)		reshape data set on process level				          
*	2) 		save the data set					  									 
*																	  													      
*	Author:  	Florian Muench						    
*	ID variable: 				  					  
*	Requires: 	  	sicop_subprocess.dta									  
*	Creates:  		sicop_process.dta			                                  
***********************************************************************
* 	PART START: 	Format string & numerical variables		  			
***********************************************************************
use "${ppg_final}/sicop_subprocess", clear






***********************************************************************
* 	PART END: 	Save firm level data set		  			
***********************************************************************
save "${ppg_final}/sicop_process", replace
