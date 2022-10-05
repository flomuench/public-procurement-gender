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


***********************************************************************
* 	PART 1: 	Collapse pre-post taking into account 20 bids around the event window	  			
***********************************************************************
frame copy default two_by_two_m2f, replace
frame change two_by_two_m2f
keep if inrange(time_to_treat, -20, 20)
local sumvars "bids_won=bid_won monto_usd_wlog total_points times_bid=one"
local firstnmvars "m2f firm_international firm_size firm_location age"
collapse (sum) `sumvars' (firstnm) `firstnmvars', by(cedula_proveedor post)

***********************************************************************
* 	PART 2: Adjust variables 	
***********************************************************************
	* bids won
gen bid_efficiency = bids_won/times_bid

	* points
gen points_efficiency = total_points/times_bid

	* amount
gen amount_efficiency = monto_usd_wlog/times_bid

	* won dummy
gen won = (bids_won > 0)

***********************************************************************
* 	PART 3:  DiD 2x2
***********************************************************************
	* won
reg won i.m2f##i.post, vce(cluster cedula_proveedor)
	
	* times bid
reg times_bid i.m2f##i.post, vce(cluster cedula_proveedor)

	* times won
reg bids_won i.m2f##i.post, vce(cluster cedula_proveedor)

	* amount
reg monto_usd_wlog i.m2f##i.post, vce(cluster cedula_proveedor)
	
	* bid_efficiency
reg bid_efficiency i.m2f##i.post, vce(cluster cedula_proveedor)
	
	* points_efficiency
reg points_efficiency i.m2f##i.post, vce(cluster cedula_proveedor)

	* amount efficiency
reg amount_efficiency i.m2f##i.post, vce(cluster cedula_proveedor)

