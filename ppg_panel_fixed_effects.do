***********************************************************************
* 			ppg panel data analysis with one or two way fixed effects		
***********************************************************************
*																	  
*	PURPOSE: replace					  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		 Load, directory for export, declare panel			  				  
* 	2) 	     Estimate the coef, se & visualise them
*	3)   							  
*	4)  		  				  	  
*																	  															      
*	Author:  	Florian Muench						  
*	ID variable: 	process level id = id ; firm level id = firmid			  					  
*	Requires: 	  	sicop_did.dta							  
*	Creates:  		sicop_did.dta	                          
*	
***********************************************************************
* 	PART START: 	Load, directory for export, declare panel		  			
***********************************************************************
	* extend maximum variables and matsize to accomdate size of data
set maxvar 32767
set matsize 11000

use "${ppg_intermediate}/sicop_did", clear
	
	* set export folder for regression tables
cd "$ppg_regression_tables"

	* set panel data
xtset firmid firm_occurence, delta(1)
	/* requires capture drop due to some mistake */

***********************************************************************
* 	PART 3: estimate the coef, se & visualise them
***********************************************************************
	* attempt 1: replication with xtlogit
preserve 
sum firm_occurence, d
keep if firm_occurence <= 100 & firm_occurence >= 10
logit winner i.female_firm##i.female_po i.firm_occurence i.firmid $process_controls, vce(robust)
margins i.female_firm##i.female_po, post
estimates store predictedprob_mv_did, title("Predicted probabilities")
coefplot predictedprob_mv_did, drop(_cons) xline(0) ///
	xtitle("Predicted probability of winning") xlab(0.2(0.01)0.3) ///
	graphr(color(white)) bgcol(white) plotr(color(white)) ///
	title("{bf:Predicted probabilities of winning a public contract}") ///
	subtitle("Robustness check 3: Two-way fixed effects vs. pooled", size(vsmall)) ///
	note("N = 707,717", size(small))
gr export predicted_probabilities_mv_did.png, replace
restore
		
		* simple, pooled logit model
logit winner i.female_firm##i.female_po $firm_controls $process_controls, vce(robust)
		* logit model with one way occurence/time fixed effects
logit winner i.female_firm##i.female_po i.firm_occurence $firm_controls $process_controls, vce(robust)	
logit winner i.female_firm##i.female_po i.firm_occurence $firm_controls $process_controls if firm_occurence <= 100 & firm_occurence >= 10, vce(robust)	

		* logit model with one way firm fixed effects
logit winner i.female_firm##i.female_po i.firmid $firm_controls $process_controls, vce(robust)
