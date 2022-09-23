***********************************************************************
* 			public procurement gender clean									  		  
***********************************************************************
*																	  
*	PURPOSE: clean administrative procurement data					  	  			
*																	  
*																	  
*	OUTLINE:														  
*	1)		Format string & numerical variables				          
*	2)   	Drop all text windows from the survey					  
*	3)  	Make all variables names lower case						  
*	4)  	Order the variables in the data set						  	  
*	5)  	Rename the variables									  
*	6)  	Label the variables										  
* 	7) 		Label variable values 								 
* 	8) 		Trim obversations										 
*																	  													      
*	Author:  	Florian Muench						    
*	ID variable: 	process-level id = id ; firm level id = firmid			  					  
*	Requires: 	  	SICOP_gender_new_workingversion.dta									  
*	Creates:  		codebook-variables, codebook-labels	                                  
***********************************************************************
* 	PART 1: 	Make all variables names lower case		  			
***********************************************************************
use "${ppg_intermediate}/sicop_replicable", clear

rename TIPO tipo_s
rename *, lower

***********************************************************************
* 	PART 2: 	Drop variables		  			
***********************************************************************
drop cartel_no secuencia codigo_clasificacion

***********************************************************************
* 	PART 3: 	Format string & numerical variables		  			
***********************************************************************

ds, has(type string) 
local strvars "`r(varlist)'"
format %-15s `strvars'
format %-25s numero_procedimiento persona_encargada_proveedor nombre_proveedor nombre_comprador
format %-50s nombre_proveedor
format %-35s persona_encargada_proveedor nombre_comprador institucion
foreach x of varlist partida ano {
	destring `x', replace
}
format %-5.0g partida linea calificacion cantidad
format %-15.3fc monto_crc precio_crc
 
ds, has(type numeric) 
local numvars "`r(varlist)'"
format %20.0fc `numvars'


***********************************************************************
* 	PART 4: 	Order the variables in the data set		  			
***********************************************************************
order numero_procedimiento partida linea nombre_proveedor cedula_proveedor factor_evaluacion calificacion institucion monto_crc cantidad precio_crc
 
***********************************************************************
* 	PART 5: 	Rename the variables		  			
***********************************************************************
rename ano year


***********************************************************************
* 	PART 6: 	Label the variables		  			
***********************************************************************
lab var year "year procurement process took place"
lab var numero_procedimiento "admin process number"
lab var partida "admin. sub-process" 
lab var linea "admin. product line" 
lab var tipo_s "admin. process of contract allocation" 
lab var monto_crc "contract value" 
lab var institucion "public contracting institution" 
lab var institucion_tipo "public contracting institution, category" 
lab var nombre_comprador "name of procurement officer" 
lab var nombre_proveedor "name of bidder" 
lab var persona_encargada_proveedor "name of firm representative"
lab var clasificacion_objeto "UN procurement product classification code" 
lab var clasifi_hacienda "Ministry of Finance product classification code" 
lab var clasi_bien_serv "product type" 
lab var cedula_proveedor "firm id"
lab var fecha_constitucion "date when firm was formally created"
lab var fecha_registro "date when firms was registered in e-procurement system"
lab var fecha_publicacion "date when procurement contract was published"
lab var precio_crc "unit price in Costa Rican Colon"
lab var pais_domicilio "firm country of origin"
lab var mejora_precio "process where firms could submit improved price"
lab var codigo_postal "firm HQ postal code" 
lab var fecha_adjudicacion "date of contract allocation" 
lab var factor_evaluacion "contract evaluation criteria" 
lab var cantidad "units of product" 
lab var calificacion "points received for bid" 
lab var bid_area "region were bidding was allowed"

***********************************************************************
* 	PART 7: 	Label variables values	  			
***********************************************************************
		* label values of representatives gender
			* firm
lab def genderfirm 0 "male rep" 1 "female rep"
lab val genderfo genderfirm

			* procurement officer
lab def genderofficer 0 "male officer" 1 "female officer"
lab val genderpo genderofficer

		* institution
lab def instutions 1 "central government" 2 "independent institutions" 3 "municipalities" 4 "semi-independent institutions" 5 "state-owned enterprises"
lab val institucion_tipo institutions


***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
save "${ppg_intermediate}/sicop_replicable", replace
