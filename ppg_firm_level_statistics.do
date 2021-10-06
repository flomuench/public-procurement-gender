***********************************************************************
* 			public procurement gender firm level statistics									  		  
***********************************************************************
*																	  
*	PURPOSE: analyze the effect of gender on success in public procure					  	  			
*			ment
*																	  
*	OUTLINE:														  
*	1)		collapse data set on firm level				          
*	2)   	generate balance table between female and male firms					  
*	3)  	sectoral distribution of firms						  									 
*																	  													      
*	Author:  	Florian Muench						    
*	ID variable: 				  					  
*	Requires: 	  	SICOP_gender_new_workingversion.dta									  
*	Creates:  ml_inter.dta			                                  
***********************************************************************
* 	PART START: 	Format string & numerical variables		  			
***********************************************************************
use "${ppg_data}/SICOP_gender_new_workingversion", clear


***********************************************************************
* 	PART 1: 	collapse data set on firm level		  			
***********************************************************************
collapse , by(id)

* firm level variables
	* firm size
	* age at registration
	* age first won
	* capital
	* firm origin
	* times participated
	* times won
	* average amount won
	* average price bidded
	* average quantity of a good
	
	
***********************************************************************
* 	PART 2: 	generate balance table between female and male firms	  			
***********************************************************************



***********************************************************************
* 	PART 3: 	sectoral distribution of firms	  			
***********************************************************************


***********************************************************************
* 	PART 4: 	geographical distribution of firms  			
***********************************************************************


***********************************************************************
* 	PART 5: 	contract type  			
***********************************************************************

***********************************************************************
* 	PART 6: 	institutions			
***********************************************************************


***********************************************************************
* 	PART END: 	Save firm level data set		  			
***********************************************************************
save "merlink_firm", replace
