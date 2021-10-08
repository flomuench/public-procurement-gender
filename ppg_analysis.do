***********************************************************************
* 			public procurement gender corrections		
***********************************************************************
*																	  
*	PURPOSE: replace					  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Define non-response categories 			  				  
* 	2) 		Encode categorical variables
*	3)   	Replace string with numeric values						  
*	4)  	Convert string to numerical variables	  				  	  
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
	
	* table discrimination_correlation
outreg2 using discrimination_correlation, excel replace
logit winner i.female_firm, vce(robust)
outreg2 using discrimination_correlation, excel replace
logit winner i.female_firm $process_controls $firm_controls, vce(robust)
local outreg "outreg2 using discrimination_correlation, excel append"
logit winner i.female_firm##i.female_po $process_controls $firm_controls, vce(robust)
`outreg'
logit winner i.female_firm##i.female_po $process_controls $firm_controls, vce(cluster numero_procedimiento)
`outreg'

	* predicted probabilities of winning a public contract
logit winner i.female_firm##i.female_po $process_controls $firm_controls, vce(robust)
margins i.female_firm##i.female_po, post
estimates store predictedprob, title("Predicted probabilities")
			* Excel table
*outreg2 predictedprob using "predictedprob", excel replace
			* coefficient plot
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
