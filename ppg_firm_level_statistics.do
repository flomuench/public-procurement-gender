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
	* complication: gender of the firm rep is not stable over time
		* solution: create an firm-gender specific id
egen fgid = group(firmid female_firm)
		* collapse the data on firm-gender level
collapse (firstnm) firm_size age_registro firm_international female_firm  ///
		(count) times_part=one times_won=winner    ///
		(mean) avg_price=monto_crc avg_quantity=cantidad avg_points=calificacion avg_comp=n_c ///
		, by(fgid)

* firm level variables
	* firm size = done
	* age at registration = done
	* age first won *
	* firm origin = d
	* times participated
	* times won
	* average amount won = done 
	* average price bidded = done
	* average quantity of a good = done
	* average number of competitors = done 
	* average points for offer = done
	
	
***********************************************************************
* 	PART 2: 	generate balance table between female and male firms	  			
***********************************************************************
order firm_size, last
tab firm_size, gen(firm_size)

order female_firm, last
cd "$ppg_figures"
iebaltab age_registro-firm_size5, grpvar(female_firm) save(baltab_female_male)  ///
			 vce(robust) replace pttest rowvarlabels balmiss(mean)


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
