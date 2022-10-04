***********************************************************************
* 						ppg triple DiD	
***********************************************************************
*																	  
*	PURPOSE: Conduct 2x3 triple DiD using aggregate Y-variables					  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		 Load, directory for export, declare panel			  				  
* 	2) 	     Estimate the coef, se & visualise them
*	3)   							  
*	4)  		  				  	  
*																	  															      
*	Author:  	Florian Muench						  
*	ID variable: 	firm_id/cedula_proveedor = firm id ; process id = 
*	Requires: 	  	sicop_process.dta							  
*	
***********************************************************************
* 	PART START: 	Load & declare panel		  			
***********************************************************************
use "${ppg_intermediate}/sicop_process", clear