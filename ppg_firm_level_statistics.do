***********************************************************************
* 			public procurement gender firm level statistics									  		  
***********************************************************************
*																	  
*	PURPOSE: analyze the effect of gender on success in public procure					  	  			
*			ment
*																	  
*	OUTLINE:														  
*	1)   	generate balance table between female and male firms					  
*	2)  	sectoral distribution of firms						  									 
*																	  													      
*	Author:  	Florian Muench						    
*	ID variable: 				  					  
*	Requires: 	  	SICOP_gender_new_workingversion.dta									  
*	Creates:  ml_inter.dta			                                  
***********************************************************************
* 	PART START: 	Format string & numerical variables		  			
***********************************************************************
use "${ppg_intermediate}/sicop_firm", clear
	
	
***********************************************************************
* 	PART 2: 	generate balance table between female and male firms	  			
***********************************************************************
order firm_size, last
tab firm_size, gen(firm_size)

order female_firm, last
cd "$ppg_figures"
iebaltab firm_size-avg_comp, grpvar(female_firm) save(baltab_female_male) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)


		

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



