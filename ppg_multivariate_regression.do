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
* 	PART 1:  Average probability of winning a public contract 			
***********************************************************************
use "${ppg_intermediate}/sicop_replicable", clear
cd "$ppg_unconprob"

	* for all firms 
logit winner, vce(robust)
margins, post
outreg2 using unconditional_probabilities, excel replace

		/* 25% */
		
	* for male & female firms
logit winner i.female_firm, vce(robust)
margins i.female_firm, post
outreg2 using unconditional_probabilities, excel append

		/* 26.8% female firm, 23.3% male firm */
		
	* for male & female firms that never changed ceo
logit winner i.female_firm if never_change == 1, vce(robust)
margins i.female_firm, post
outreg2 using unconditional_probabilities, excel append


																	  
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



		* Robustness checks
			* Additional controls
				* product level controls
logit winner i.female_firm##i.female_po $firm_controls i.c_o i.tipo ratio_firmfmf year i.institution_type number_competitors, vce(robust)
/* the following variables would be omitted because of colinearity ratio_firmpo_fm, sectors */
margins i.female_firm##i.female_po, post
estimates store predictedprob_r1, title("Predicted probabilities")
coefplot predictedprob_r1, drop(_cons) xline(0) ///
	xtitle("Predicted probability of winning") xlab(0.2(0.01)0.3) ///
	graphr(color(white)) bgcol(white) plotr(color(white)) ///
	title("{bf:Predicted probabilities of winning a public contract}") ///
	subtitle("Robustness check 1: product vs. sector controls", size(small)) ///
	note("N = 702,708. Ratio of f2m firm vs. procurement officials due to colinearity as calculated on product level.", size(vsmall))
gr export predicted_probabilities_r1.png, replace

				* Female vs. male CEO prevalence per product group
logit winner i.female_firm##i.female_po $firm_controls i.tipo ratio_fmf year i.institution_type number_competitors i.sector, vce(robust)
margins i.female_firm##i.female_po, post
estimates store predictedprob_r2, title("Predicted probabilities")
coefplot predictedprob_r2, drop(_cons) xline(0) ///
	xtitle("Predicted probability of winning") xlab(0.2(0.01)0.3) ///
	graphr(color(white)) bgcol(white) plotr(color(white)) ///
	title("{bf:Predicted probabilities of winning a public contract}") ///
	subtitle("Robustness check 2: control for gender ratio on firm rather than also procurement official level", size(vsmall)) ///
	note("N = 707,717", size(small))
gr export predicted_probabilities_r2.png, replace


***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
