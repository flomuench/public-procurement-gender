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
* 	PART START: 	Load data set on subprocess level	  			
***********************************************************************
use "${ppg_final}/sicop_subprocess", clear
frame copy default process, replace
frame change process

***********************************************************************
* 	PART 1: 	prepare the data set 			
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
order sub_process_firm_id sub_process_id numero_procedimiento partida linea nombre_proveedor cedula_proveedor monto_crc cantidad precio_crc clasificacion_objeto clasificacion_objeto_des clasi_bien_serv
format %-4.0g sub_process_firm_id sub_process_id partida linea

	
***********************************************************************
* 	PART 2: concatenate product & product specific variables, such as evaluation criteria & 
***********************************************************************
/* useful links: https://www.statalist.org/forums/forum/general-stata-discussion/general/1364952-concatenating-strings-when-collapsing-data
https://www.statalist.org/forums/forum/general-stata-discussion/general/1293924-concatenating-columns-within-group
https://www.statalist.org/forums/forum/general-stata-discussion/general/1295254-vertical-concat-of-string-observations
https://www.statalist.org/forums/forum/general-stata-discussion/general/1462508-combining-strings-by-groups
*/
	* put all evaluation criteria into one variables
local factvars "factor_evaluacion1 factor_evaluacion2 factor_evaluacion3 factor_evaluacion4 factor_evaluacion5  factor_evaluacion6 factor_evaluacion7 factor_evaluacion8 factor_evaluacion9 factor_evaluacion10 factor_evaluacion11 factor_evaluacion12 factor_evaluacion13 factor_evaluacion14"
egen factors_evaluacion = concat(`factvars'), punc(" ")
format factors_evaluacion %-50s
replace factors_evaluacion = strtrim(factors_evaluacion)


	* drop product specific variables with no essential information for analysis
drop factor_evaluacion* calificacion* clasi_bien_serv sector


	* concatenate (create constant value for variables in each line, use firstnm in collapse afterwards)
tostring clasificacion_objeto, replace
local loopvars "factors_evaluacion clasificacion_objeto clasificacion_objeto_des"
local id "numero_procedimiento cedula_proveedor persona_encargada_proveedor"
foreach var of local loopvars {
	sort `id' , stable
	by `id': gen agg_`var' = `var' if _n == 1 
	by `id': replace agg_`var' = agg_`var'[_n-1] + " " + `var' if _n > 1
	by `id': replace agg_`var' = agg_`var'[_N]
}


***********************************************************************
* 	PART 3: collapse data from sub_sub_process to process level 			
***********************************************************************
/* 
useful link: https://twitter.com/toddrjones/status/1566095691885301762
*/
sort numero_procedimiento partida linea date_publicacion date_adjudicacion cedula_proveedor
		
		* create locals with variables for collapsing
local byvars "numero_procedimiento cedula_proveedor persona_encargada_proveedor"
local sumvars "monto* precio* total_points"
ds `byvars' `sumvars' partida linea, not 
local keepvars `r(varlist)'

		* collapse data on process-firm-firmrep level
collapse (sum) `sumvars' (firstnm) `keepvars', by(`byvars')

		* sort data by process-firm-firm-firmrep
sort `byvars'


***********************************************************************
* 	PART END: 	Save firm level data set		  			
***********************************************************************
save "${ppg_final}/sicop_process", replace




/* Archive
* example code for concatenation
by listing_id month, sort: gen combined_comments = comments if _n == 1

by listing_id month: replace combined_comments = combined_comments[_n-1] ///
    + ", " + comments if _n > 1 & !missing(comments)
	
by listing_id month: keep if _n == _N

sort block, stable
by block : gen var2 = var1 if _n == 1
by block : replace var2 = var2[_n-1] + var1 if _n > 1


sort id, stable
by id : gen alltext = text[1]
by id : replace alltext = alltext[_n-1] + " " + text if _n > 1
by id : replace alltext = alltext[_N]

* reshaping not possible as > 5000 variables, computer broke down

***********************************************************************
* 	PART 2: reshape from sub_sub_process to sub_process level 			
***********************************************************************
		* create a new subpcrocess variables that contains both subprocess and product line: linea and partida in one go
foreach x of var partida linea {
	gen `x'1 = string(`x'), a(`x')
}
gen sub_process = partida1 + linea1, a(linea1)
drop partida1 linea1
destring sub_process, replace
		
		* drop vars that are not constant & not needed
drop sub_process_firm_id sub_process_id partida linea _freq firstfomerge secondfomerge mergegpo 
drop date_adjudicacion fecha_adjudicacion year_adjudicacion 
drop factor_evaluacion_cat? clasifi_hacienda 

		/* attention: 
1) date_adjudicacion is missing for 11,047 bids 
we use date_publication instead, which is never missing &
constant across subprocesses 
2) limited to three evaluation criteria and the received points for each to limit number max var as > 5000 otherwise
*/

		* create i for reshape
*egen id_reshape = group(numero_procedimiento cedula_proveedor persona_encargada_proveedor genderfo)
*order id_reshape, b(numero_procedimiento)


		* conduct reshape by year as dataset too large
forvalues year = 2010/2018 {
			* create frame per year
	frame copy default subtask`year', replace
	frame change subtask`year'
	keep if year == `year'

			* put variables to reshape into locals
	local factor_evaluacion "factor_evaluacion1 factor_evaluacion2 factor_evaluacion3"

	local calificacion "calificacion1 calificacion2 calificacion3"

	local reshape_vars "monto_crc cantidad precio_crc clasificacion_objeto clasificacion_objeto_des clasi_bien_serv sector `factor_evaluacion'  `calificacion'"

			* conduct the reshape
	reshape wide `reshape_vars', i(numero_procedimiento cedula_proveedor persona_encargada_proveedor) j(sub_process)

			* save reshaped temporary file

	save "${ppg_final}/reshape`year'",replace
  
	* change back to default frame
	frame change default
  
   }
   
   * append all the different 
use "${ppg_final}/reshape2010", clear
forvalues year = 2011/2018 {
	append using "${ppg_final}/reshape`year'"
	save "${ppg_final}/sicop_process.dta", replace
	erase "${ppg_final}/reshape`year"
 }

erase "${ppg_final}/reshape2010"


		* option: first linea, then partida
*reshape wide vars, i(numero_procedimiento partida firm) j(linea)

log using "${ppg_final}/reshape_error", text replace
reshape error
log close

* remain not constant: fecha_adjudicacion (4408), date_adjudicacion (3590), year_adjudicacion (855); count for date_adjudicacion remains constant even after having dropped other two & re-running on different computer
