***********************************************************************
* 			public procurement gender multivariate regression		
***********************************************************************
*																	  
*	PURPOSE: replace					  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Table of logit coefficients & predicted probabilities 			  				  
* 	2) 		Coefficient plot of predicted probabilities of main specification
	  				  	  
*																	  															      
*	Author:  	Florian Muench						  
*	ID variable: 	process level id = id ; firm level id = firmid			  					  
*	Requires: 	  								  
*	Creates:  			                          
*																	  
***********************************************************************
* 	PART 1:  Effect of gender firm representative on wining public contract 			
***********************************************************************
use "${ppg_intermediate}/sicop_replicable", clear
cd "$ppg_regression_tables"
	
	* table discrimination logit coefficients
logit winner i.female_firm, vce(robust)
outreg2 using discrimination_coefficients, excel replace
logit winner i.female_firm $process_controls $firm_controls, vce(robust)
local outreg "outreg2 using discrimination_coefficients, excel append"
logit winner i.female_firm##i.female_po $process_controls $firm_controls, vce(robust)
`outreg'
logit winner i.female_firm##i.female_po $process_controls $firm_controls, vce(cluster numero_procedimiento)
`outreg'

	* table discriminiation predicted probabilities
			* c(1) average
logit winner i.female_firm, vce(robust)
margins i.female_firm, post
outreg2 using discrimination_predictedprob, excel replace
			* c(2) effect of female firm dummy
logit winner i.female_firm $process_controls $firm_controls, vce(robust)
margins , post
local outreg "outreg2 using discrimination_predictedprob, excel append"
`outreg'
			* c(3) effect of firm-procurement officer gender interaction
logit winner i.female_firm##i.female_po $process_controls $firm_controls, vce(robust)
margins i.female_firm##i.female_po, post
local outreg "outreg2 using discrimination_predictedprob, excel append"
`outreg'
			* c(4) = c(3) but clustered standard errors
logit winner i.female_firm##i.female_po $process_controls $firm_controls, vce(cluster numero_procedimiento)
margins i.female_firm##i.female_po, post
local outreg "outreg2 using discrimination_predictedprob, excel append"
`outreg'


			* coefficient plot
logit winner i.female_firm##i.female_po $process_controls $firm_controls, vce(robust)
margins i.female_firm##i.female_po, post
estimates store predictedprob, title("Predicted probabilities")
coefplot predictedprob, drop(_cons) xline(0) ///
	xtitle("Predicted probability of winning") xlab(0.2(0.01)0.3) ///
	graphr(color(white)) bgcol(white) plotr(color(white)) ///
	title("{bf:Predicted probabilities of winning a public contract}") ///
	subtitle("Do procurement officer discriminates in their allocation decision?", size(small)) ///
	note("N = 707,717", size(small))
gr export predicted_probabilities.png, replace



***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
