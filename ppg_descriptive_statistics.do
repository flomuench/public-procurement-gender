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
* 	PART START: 	time series of procurement volume + procecesses		  			
***********************************************************************
	* create a seperate frame
frame copy default subtask, replace
frame change subtask

	* generate variable that can be used to visualize the number of processes per month
bysort numero_procedimiento: gen process_count = _n == 1, a(numero_procedimiento)



	* collape to monthly or annual procurement volume
* useful link: https://stats.oarc.ucla.edu/stata/faq/how-can-i-collapse-a-daily-time-series-to-a-monthly-time-series/
* help dcfcns
		* monthly
gen dm_adj = mofd(date_adjudicacion), a(date_adjudicacion)
format dm_adj %tm
collapse (sum) monto_crc process_count (mean) n_competitors, by(dm_adj)

	* change to time series format
tsset date_adjudicacion
	
	* in general
	
	
	
	* female vs. male firms
	

	* drop frame
frame change default
frame drop subtask
	
***********************************************************************
* 	PART START: 	Plot dependent variables: (1) monto	  			
***********************************************************************
sum monto_crc, d
order clasificacion_objeto_des clasi_bien_serv, a(precio_crc)
br if monto_crc < 1000
graph box monto_crc
