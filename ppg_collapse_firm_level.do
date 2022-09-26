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
*	Requires: 	  	sicop_subprocess.dta									  
*	Creates:  sicop_process.dta (firm-process or firm-bid-level)			                                  
***********************************************************************
* 	PART START: 	Load data set on subprocess level	  			
***********************************************************************
use "${ppg_final}/sicop_subprocess", clear



***********************************************************************
* 	PART 1: 	reshape from sub_sub_process to sub_process level 			
***********************************************************************
* objective: transform process-partida-linea-firm to process-partida-firm from long to wide format

		* sort data
sort sub_process_firm_id
	
		* identify variables that vary on linea-level
/*
vary: cantidad, precio, monto*, clasificacion_objeto, factor_evaluacion, calificacion
*/
/* example:line 1-8
*/
order sub_process_firm_id sub_process_id numero_procedimiento partida linea nombre_proveedor cedula_proveedor monto_crc cantidad precio_crc clasificacion_objeto clasifi_hacienda clasificacion_objeto_des clasi_bien_serv
format %-4.0g sub_process_firm_id sub_process_id partida linea

		* try fixing linea and partida in one go
foreach x of var partida linea {
	gen `x'1 = string(`x'), a(`x')
}
gen sub_process = partida1 + linea1, a(linea1)
drop partida1 linea1
destring sub_process, replace
		
		* drop vars that are not constant & not needed
drop sub_process_firm_id sub_process_id partida linea _freq firstfomerge secondfomerge mergegpo date_adjudicacion fecha_adjudicacion year_adjudicacion
		/* attention: date_adjudicacion is missing for 11,047 bids
		we use date_publication instead, which is never missing &
		constant across subprocesses */

		* 6 companies with a total of 424 bids have missing rep name --> drop
codebook cedula_proveedor if persona_encargada_proveedor == ""
drop if persona_encargada_proveedor == ""
		
		* create i for reshape
*egen id_reshape = group(numero_procedimiento cedula_proveedor persona_encargada_proveedor genderfo)
*order id_reshape, b(numero_procedimiento)

		* put variables to reshape into locals
local factor_evaluacion "factor_evaluacion1 factor_evaluacion2 factor_evaluacion3 factor_evaluacion4 factor_evaluacion5 factor_evaluacion6 factor_evaluacion7 factor_evaluacion8 factor_evaluacion9 factor_evaluacion10 factor_evaluacion11 factor_evaluacion12 factor_evaluacion13 factor_evaluacion14"

local factor_evaluacion_cat "factor_evaluacion_cat1 factor_evaluacion_cat2 factor_evaluacion_cat3 factor_evaluacion_cat4 factor_evaluacion_cat5 factor_evaluacion_cat6 factor_evaluacion_cat7 factor_evaluacion_cat8 factor_evaluacion_cat9 factor_evaluacion_cat10 factor_evaluacion_cat11 factor_evaluacion_cat12 factor_evaluacion_cat13 factor_evaluacion_cat14"

local calificacion "calificacion1 calificacion2 calificacion3 calificacion4 calificacion5 calificacion6 calificacion7 calificacion8 calificacion9 calificacion10 calificacion11 calificacion12 calificacion13 calificacion14"

local reshape_vars "monto_crc cantidad precio_crc clasificacion_objeto clasifi_hacienda clasificacion_objeto_des clasi_bien_serv sector `factor_evaluacion' `factor_evaluacion_cat'  `calificacion'"

reshape wide `reshape_vars', i(numero_procedimiento cedula_proveedor persona_encargada_proveedor) j(sub_process)

		* option: first linea, then partida
*reshape wide vars, i(numero_procedimiento partida firm) j(linea)

log using "${ppg_final}/reshape_error", text replace
reshape error
log close

* remain not constant: fecha_adjudicacion (4408), date_adjudicacion (3590), year_adjudicacion (855); count for date_adjudicacion remains constant even after having dropped other two & re-running on different computer

/*
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
save "${ppg_final}/sicop_firm", replace
