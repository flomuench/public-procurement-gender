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
* 	PART 2: 	collapse data set on sub-process level	  			
***********************************************************************
	* create an id for each sub-process 
egen sub_process_id = group(numero_procedimiento partida linea)
egen sub_process_firm_id = group(numero_procedimiento partida linea cedula_proveedor)
format sub_process_id sub_process_firm_id %-12.0fc

order sub_process_id sub_process_firm_id, b(numero_procedimiento)
sort sub_process_firm_id
/* example:
sub_process_id	sub_process_firm_id	numero_procedimiento	partida	linea	nombre_proveedor	cedula_proveedor	factor_evaluacion	calificacion
23	69	2011cd-000001-0001200001	1	1	mary cruz quiros fallas	111790304	precio	60
23	69	2011cd-000001-0001200001	1	1	mary cruz quiros fallas	111790304	garantía de producto	20
23	69	2011cd-000001-0001200001	1	1	mary cruz quiros fallas	111790304	experiencia	16

*/

	* create a "j" variable that counts each criteria within sub-process
bysort sub_process_firm_id (factor_evaluacion) : gen criteria_id = sum(factor_evaluacion != factor_evaluacion[_n-1]), a(sub_process_firm_id)
	
/* first code to see which observations obstruct reshaping 
reshape wide factor_evaluacion calificacion, i(sub_process_firm_id) j(criteria_id)
log using "${ppg_final}/reshape_problems", replace text
reshape error
log close
*/

	* correct errors so that monto_crc is constant
egen help_id = group(sub_process_firm_id criteria_id)
order help_id, a(criteria_id)
replace monto_crc = 319819 if help_id == 111183
replace monto_crc = 814080 if help_id == 5823
replace monto_crc = 43964910 if help_id == 291983
replace monto_crc = 2788.05 if help_id == 395362 | help_id == 395361
replace monto_crc = 725628.899 if help_id == 523983 | help_id == 523984 | help_id == 523985
replace monto_crc = 15799 if help_id == 723395
replace monto_crc = 15915 if help_id == 723400
replace monto_crc = 51288 if help_id == 723847
replace monto_crc = 7335355.5 if help_id == 727768 | help_id == 727769
replace monto_crc = 194900 if help_id == 731374
replace monto_crc = 228500 if help_id == 731422
replace monto_crc = 132000 if help_id == 731468
replace monto_crc = 3138000 if help_id == 744848 | help_id == 744850
replace monto_crc = 381900 if help_id == 757126
replace monto_crc = 243600 if help_id == 757131
replace monto_crc = 2267300 if help_id == 757149
replace monto_crc = 1667200 if help_id == 757156
replace monto_crc = 12844000 if help_id == 757161
replace monto_crc = 707000 if help_id == 757168
replace monto_crc = 877800 if help_id == 757174
replace monto_crc = 228000 if help_id == 757180
replace monto_crc = 48750 if help_id == 771010
replace monto_crc = 109000 if help_id == 771014
replace monto_crc = 55000 if help_id == 771022
replace monto_crc = 12000 if help_id == 771030
replace monto_crc = 6951976 if help_id == 899565 | help_id == 899566 | help_id == 899567
replace monto_crc = 331927.357 if help_id == 902345 | help_id == 902346 | help_id == 902347
replace monto_crc = 869805 if help_id == 727754 | help_id == 727755
replace monto_crc = 12000 if help_id == 771029

local wrong_values "750420 750421 750422 773210 773211 773212 773240 773241 773242 790107 790108 790109 790110 790111 790112 790113 972123 972124 972125 972126 972139 972140 972141 972142 972167 972168 972169 972170 972179 972180 972181 972182"
foreach x of local wrong_values {
	replace monto_crc = . if help_id ==  `x'
}

drop help_id

	* reshape such that there is only one sub-process per firm, criteria in wide format
reshape wide factor_evaluacion factor_evaluacion_cat calificacion, i(sub_process_firm_id) j(criteria_id)



***********************************************************************
* 	PART 3: 	order the data set	  			
***********************************************************************	
order factor_evaluacion1-factor_evaluacion_cat14, last
sort numero_procedimiento partida linea -calificacion1

	
	
***********************************************************************
* 	PART END: 	Save firm level data set		  			
***********************************************************************
save "${ppg_final}/sicop_subprocess", replace