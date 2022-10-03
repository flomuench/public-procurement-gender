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
	

	* correct errors so that monto_crc is constant
egen help_id = group(sub_process_firm_id criteria_id)
order help_id, a(criteria_id)
replace monto_crc = 319819 if help_id == 111183
replace monto_crc = 814080 if help_id == 5823
replace monto_crc = 43964910 if sub_process_firm_id == 263551 & criteria_id == 1

replace monto_crc = 2788.05 if help_id == 395362 | help_id == 395361
replace monto_crc = 725628.899 if help_id == 523983 | help_id == 523984 | help_id == 523985
replace monto_crc = 15799 if help_id == 723396
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
replace monto_crc = 479700 if help_id == 5863
replace monto_crc = 39155250 if help_id == 487992 | help_id == 487993 | help_id == 487994
replace monto_crc = 725628.899 if help_id == 523981
replace monto_crc = 15915 if help_id == 723399
replace monto_crc = 869805 if help_id == 727756 | help_id == 727757
replace monto_crc = 7335355.5 if help_id == 727767
replace monto_crc = 204000 if help_id == 731397
replace monto_crc = 260000 if help_id == 731419
replace monto_crc = 228500 if help_id == 731423
replace monto_crc = 132000 if help_id == 731469
replace monto_crc = 410300 if help_id == 731515
replace monto_crc = 352200 if help_id == 757137
replace monto_crc = 2267300 if help_id == 757150
replace monto_crc = 1667200 if help_id == 757155
replace monto_crc = 228000 if help_id == 757179
replace monto_crc = 536796 if help_id == 770361
replace monto_crc = 48750 if help_id == 771009
replace monto_crc = 109000 if help_id == 771013
replace monto_crc = 60000 if help_id == 771018
replace monto_crc = 55000 if help_id == 771021
replace monto_crc = 790250.432 if help_id == 971973
replace monto_crc = 948536.267 if help_id == 971981
replace monto_crc = 80000 if help_id == 771026
replace monto_crc = 12000 if help_id == 771029
replace monto_crc = 12000 if help_id == 771029
replace monto_crc = 12000 if help_id == 771029

* 
replace monto_crc = 215140 if sub_process_firm_id == 4251 & criteria_id == 2
replace monto_crc = 814080 if sub_process_firm_id == 4270 & criteria_id == 2
replace monto_crc = 479700  if sub_process_firm_id == 4290 & criteria_id == 2

replace monto_crc = 173562573 if sub_process_firm_id == 100569 & criteria_id == 2

replace monto_crc = 43964910 if sub_process_firm_id == 263551  & criteria_id == 1
replace monto_crc = 39155250 if sub_process_firm_id == 413053  & criteria_id ==4
replace monto_crc = 39155250 if sub_process_firm_id == 413054  & criteria_id == 1
replace monto_crc = 725629 if sub_process_firm_id == 437497  & criteria_id == 2

replace monto_crc = 194900 if sub_process_firm_id == 599652  & criteria_id == 2
replace monto_crc = 204000 if sub_process_firm_id == 599663 & criteria_id == 1
replace monto_crc = 115800 if sub_process_firm_id == 599678 & criteria_id == 2
replace monto_crc = 410300 if sub_process_firm_id == 599722 & criteria_id == 1
replace monto_crc = 900000 if sub_process_firm_id == 599725 & criteria_id == 2


replace monto_crc = 381900 if sub_process_firm_id == 615035  & criteria_id == 1
replace monto_crc = 352200 if sub_process_firm_id == 615041 & criteria_id == 2

replace monto_crc = 707000 if sub_process_firm_id == 615056 & criteria_id == 1
replace monto_crc = 877800 if sub_process_firm_id == 615059  & criteria_id == 2
replace monto_crc = 1021977 if sub_process_firm_id == 622680 & criteria_id == 2

replace monto_crc = 536796 if sub_process_firm_id == 622686 & criteria_id == 1
replace monto_crc = 80000 if sub_process_firm_id == 623216  & criteria_id == 1
replace monto_crc = 6951976 if sub_process_firm_id == 712100 & criteria_id == 1
replace monto_crc = 6951976 if sub_process_firm_id == 712100 & criteria_id == 5

replace monto_crc = 331927 if sub_process_firm_id == 714058  & criteria_id == 4

replace monto_crc = 790250  if sub_process_firm_id == 764941 & criteria_id == 2
replace monto_crc = 948536 if sub_process_firm_id == 764945  & criteria_id == 2



*replace monto_crc = monto_crc[_n+1] if monto_crc == . & sub_process_firm_id == sub_process_firm_id & sub_process_id == sub_process_id



local wrong_values "395361 395362 395363 750420 750421 750422 773210 773211 773212 773240 773241 773242 790107 790108 790109 790110 790111 790112 790113 972123 972124 972125 972126 972139 972140 972141 972142 972167 972168 972169 972170 972179 972180 972181 972182 734813 734814 734815 773225 773226 773227 971997 971998 972005 972006"
foreach x of local wrong_values {
	replace monto_crc = . if help_id ==  `x'
}


	* drop all variables that were created based on monto_crc
drop help_id

	* reshape such that there is only one sub-process per firm, criteria in wide format
local reshape_vars1 "factor_evaluacion factor_evaluacion_cat calificacion"
reshape wide `reshape_vars1', i(sub_process_firm_id) j(criteria_id)




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