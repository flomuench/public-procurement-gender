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
* useful links: 					https://stats.oarc.ucla.edu/stata/faq/how-can-i-collapse-a-daily-time-series-to-a-monthly-time-series/
* https://www.ssc.wisc.edu/sscc/pubs/stata_dates.htm
* reminder: %td "number of days since Jan 1, 1960"
* help dcfcns
		* convert to date (instead of datetime variable)
gen da_adj = dofc(date_adjudicacion), a(date_adjudicacion)
format %td da_adj
		* convert date to monthly
gen da_adj_m = mofd(da_adj), a(da_adj)
format da_adj_m %tm
		
		* collapse to monthly amount, process data set
collapse (sum) monto_crc process_count (mean) n_competitors, by(da_adj_m)
lab var monto_crc "total procurement amount (in CRC)"
lab var n_competitors "number of bidders"
lab var process_count "number of processes"
lab var da_adj_m "months"

	* change to time series format
tsset da_adj_m
	
	* in general
tsline monto_crc if tin(2011m1,2018m1)
twoway (tsline monto_crc) (tsline process_count, yaxis(2))
twoway ///
	(tsline monto_crc, lcolor(black)) ///
	(lfit monto_crc da_adj_m, lcolor(black)) ///
	(tsline n_competitors, yaxis(2), lcolor(blue)) ///
	(lfit monto_crc da_adj_m, lcolor(blue)) ///
	if tin(2011m1, 2018m1), ///
	legend(order (1 "amount" 2 "bidders") pos(6) rows(1)) ///
	tlabel(2011m1(12)2018m1)
	
	
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
