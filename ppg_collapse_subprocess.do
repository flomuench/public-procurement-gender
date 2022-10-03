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
* 	PART START: 	Load data set		
***********************************************************************
use "${ppg_final}/sicop_final", clear

***********************************************************************
* 	PART 2: 	collapse data set on sub-process level	  			
***********************************************************************
frame copy default subprocess, replace
frame change subprocess

sort sub_process_firm_id
* browse id numero_procedimiento year fecha_publicacion fecha_adjudicacion partida linea nombre_proveedor firmid 
/* 
Problem: 

1: each product has one or several evaluation criteria, 
for example "price", "experience", "product warranty", which implies each firm is listed several times per product (within a process)

2: what is more, firms can win single products and loose others within
the same process, which implies that the amount won varies by product


example:
sub_process_id	sub_process_firm_id	numero_procedimiento	partida	linea	nombre_proveedor	cedula_proveedor	factor_evaluacion	calificacion
23	69	2011cd-000001-0001200001	1	1	mary cruz quiros fallas	111790304	precio	60
23	69	2011cd-000001-0001200001	1	1	mary cruz quiros fallas	111790304	garantía de producto	20
23	69	2011cd-000001-0001200001	1	1	mary cruz quiros fallas	111790304	experiencia	16

*/

	* create a "j" variable that counts each criteria within sub-process
bysort sub_process_firm_id (factor_evaluacion) : gen criteria_id = sum(factor_evaluacion != factor_evaluacion[_n-1]), a(sub_process_firm_id)
	

	* reshape such that there is only one sub-process per firm, criteria in wide format
local reshape_vars "factor_evaluacion factor_evaluacion_cat calificacion"
reshape wide `reshape_vars', i(sub_process_firm_id) j(criteria_id)


log using "${ppg_final}/collapse_reshape_error", replace text
reshape error
log close

***********************************************************************
* 	PART 3: 	order the data set	  			
***********************************************************************	
order factor_evaluacion1-factor_evaluacion_cat14, last
sort numero_procedimiento partida linea -calificacion1


***********************************************************************
* 	PART 4: 	create total points variable	  			
***********************************************************************	
*order calificacion?, last
*order calificacion10-calificacion14, a(calificacion9)
local c "calificacion"
egen total_points = rowtotal(`c'1 `c'2 `c'3 `c'4 `c'5 `c'6 `c'7 `c'8 `c'9 `c'10 `c'11 `c'12 `c'13 `c'14 ), missing /* missing --> if all MV, results in MV instead of zero*/
order total_points, b(calificacion1)

lab var total_points "bid evaluation, 0-100 points"
	
	
***********************************************************************
* 	PART END: 	Save firm level data set		  			
***********************************************************************
save "${ppg_final}/sicop_subprocess", replace