***********************************************************************
* 			create sub-process level data set public procurement gender								  		  
***********************************************************************
*																	  
*	PURPOSE: create analysis, sub-process level data set
*			
*																	  
*	OUTLINE:														  
*	1)		collapse data set on firm level				          
*	2) 		save the data set					  									 
*																	  													      
*	Author:  	Florian Muench						    
*	ID variable: 				  					  
*	Requires: 	  	sicop_final.dta									  
*	Creates:  		sicop_final_subprocess.dta			                                  
***********************************************************************
* 	PART START: 	Format string & numerical variables		  			
***********************************************************************
use "${ppg_final}/sicop_final", clear


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
* 	PART 2: 	collapse data set on sub-process level	  			
***********************************************************************
	* create an id for each sub-process 
egen sub_process_id = group(numero_procedimiento partida linea)
egen sub_process_firm_id = group(numero_procedimiento partida linea cedula_proveedor)	
order sub_process_id sub_process_firm_id, b(numero_procedimiento)
/* example:
sub_process_id	sub_process_firm_id	numero_procedimiento	partida	linea	nombre_proveedor	cedula_proveedor	factor_evaluacion	calificacion
23	69	2011cd-000001-0001200001	1	1	mary cruz quiros fallas	111790304	precio	60
23	69	2011cd-000001-0001200001	1	1	mary cruz quiros fallas	111790304	garantía de producto	20
23	69	2011cd-000001-0001200001	1	1	mary cruz quiros fallas	111790304	experiencia	16

*/
	* reshape to remove firm-criteria level in sub-processes
frame copy default subtask, replace
frame change subtask

reshape wide factor_evaluacion calificacion, i(sub_process_id) j(sub_process_firm_id)


frame change default
frame drop subtask

	
	* concatenate evaluation criteria


	* remove duplicate process

	* collapse the data on sub-process level
collapse (firstnm) age_registro firm_international female_firm  ///
		firm_size1-firm_size5 firm_location1-firm_location7 ///
		(sum) times_part=one times_won=winner    ///
		avg_amount_won=monto_crc avg_price=precio avg_quantity=cantidad ///
		avg_points=calificacion, by(sub_process_id)

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
save "${ppg_final}/sicop_subprocess", replace