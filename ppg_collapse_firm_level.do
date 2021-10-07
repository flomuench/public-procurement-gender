***********************************************************************
* 			create firm level data set public procurement gender								  		  
***********************************************************************
*																	  
*	PURPOSE: analyze the effect of gender on success in public procure					  	  			
*			ment
*																	  
*	OUTLINE:														  
*	1)		collapse data set on firm level				          
*	2) 		save the data set					  									 
*																	  													      
*	Author:  	Florian Muench						    
*	ID variable: 				  					  
*	Requires: 	  	SICOP_gender_new_workingversion.dta									  
*	Creates:  ml_inter.dta			                                  
***********************************************************************
* 	PART START: 	Format string & numerical variables		  			
***********************************************************************
use "${ppg_intermediate}/sicop_replicable", clear


***********************************************************************
* 	PART 1: 	save all the variables labels 	  			
***********************************************************************
foreach v of var * {
	local l`v' : variable label `v'
	 if `"`l`v''"' == "" {
		local l`v' "`v'"
 	}
 }

***********************************************************************
* 	PART 2: 	collapse data set on firm level		  			
***********************************************************************
	* complication: gender of the firm rep is not stable over time
		* solution: create an firm-gender specific id
egen fgid = group(firmid female_firm)			
				/* control whether id has been correctly created by eye-balling the data
		sort firmid fgid
		browse fgid firmid nombre_proveedor genderfo female_firm persona_encargada_proveedor if ceof2m == 1
				*/

		* collapse the data on firm-gender level
collapse (firstnm) age_registro firm_international female_firm  ///
		firm_size1-firm_size5 firm_location1-firm_location7 ///
		(sum) times_part=one times_won=winner    ///
		(mean) avg_amount_won=monto_crc avg_price=precio avg_quantity=cantidad ///
		avg_points=calificacion avg_comp=n_c ///
		, by(fgid)

***********************************************************************
* 	PART 3: 	label the variables in the new firm level data set	  			
***********************************************************************	
 lab var fgid "firm-gender level id"
 foreach v of var * {
	label var `v' `"`l`v''"'
 }
label var times_won "total bids won"
label var times_part "total bids"
label var avg_amount_won "mean allocated amount"
label var avg_price "mean bid price"
label var avg_quantity "mean quantity bid"
label var avg_points "mean bid score"
label var avg_comp "mean competitors in bid"

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
* 	PART END: 	Save firm level data set		  			
***********************************************************************
save "sicop_firm", replace
