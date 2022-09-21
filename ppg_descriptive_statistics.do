***********************************************************************
* 			create descriptive statistics public procurement gender								  		  
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
*	Requires: 	  	sicop_final.dta; sicop_subprocess									  
***********************************************************************
* 	PART START: 	load data set		  			
***********************************************************************
use "${ppg_final}/sicop_subprocess", clear



***********************************************************************
* 	PART START: 	time series of procurement volume		  			
***********************************************************************
	* change to time series format
tsset date_adjudicacion
	
	* in general
	
	
	
	* female vs. male firms
	
	
	
***********************************************************************
* 	PART START: 	Plot dependent variables: (1) monto	  			
***********************************************************************
sum monto_crc, d
order clasificacion_objeto_des clasi_bien_serv, a(precio_crc)
br if monto_crc < 1000
graph box monto_crc
