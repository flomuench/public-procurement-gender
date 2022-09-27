***********************************************************************
* 			public procurement gender firm level statistics									  		  
***********************************************************************
*																	  
*	PURPOSE: analyze the effect of gender on success in public procure					  	  			
*			ment
*																	  
*	OUTLINE:														  
*	1)   	generate balance table between female and male firms					  
*	2)  	sectoral distribution of firms						  									 
*																	  													      
*	Author:  	Florian Muench						    
*	ID variable: 				  					  
*	Requires: 	  	SICOP_gender_new_workingversion.dta									  
*	Creates:  ml_inter.dta			                                  
***********************************************************************
* 	PART START: 	Format string & numerical variables		  			
***********************************************************************
use "${ppg_intermediate}/sicop_firm", clear
	
sort genderfo0
***********************************************************************
* 	PART 1: 	create variables for visualisation 			
***********************************************************************	
	* create dummy for firms with all gender reps
gen all_gender = 0
replace all_gender = 1 if genderfo0 != .
* 561 companies that have both female and male reps
	
	* create win/participated ratio	 
gen success_ratio = times_won/times_part
lab var success_ratio "times bid won in times participated" 
	
***********************************************************************
* 	PART 2: 	generate balance table between female and male firms	  			
***********************************************************************
order female_firm, last
cd "$ppg_figures"
iebaltab age_registro-success_ratio, grpvar(female_firm) save(baltab_female_male) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
			 
kdensity success_ratio if female_firm == 1, ///
	addplot(kdensity success_ratio if female_firm == 0)
	
tw ///
	(kdensity success_ratio if female_firm == 1, lp(dash) lc(maroon)) ///
	(kdensity success_ratio if female_firm == 0, lp(dash) lc(navy)) ///
	, ///
	legend(order(0 "{bf: Gender firm representative:}" ///
	1 "Female (N=2435)" ///
                     2 "Male firms (N=6465)") ///
               c(1) pos(11) ring(0)) ///
	xtitle("Success_ratio") ///
	ytitle("Density") ///
	title("Density distribution of sucess ratios in winning a public contract") ///
	subtitle("Female vs. Male represented firms in Costa Rica") ///
	graphregion(color(white)) ylab(,angle(0) nogrid notick) xscale(noline) yscale(noline) yline(0 , lc(black))
graph export success_ratio_distribution.png, replace
***********************************************************************
* 	PART 3: 	sectoral distribution of firms	  			
***********************************************************************


***********************************************************************
* 	PART 4: 	geographical distribution of firms  			
***********************************************************************


***********************************************************************
* 	PART 5: 	contract type  			
***********************************************************************

***********************************************************************
* 	PART 6: 	institutions			
***********************************************************************



