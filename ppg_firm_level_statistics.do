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
	
*sort genderfo0
***********************************************************************
* 	PART 1: 	create variables for visualisation 			
***********************************************************************	
	* create a gender dummy (0 = male only, 1 female only, 2 = both)
gen gender = ., a(genderfo)

			* get an idea how many firms have several reps
duplicates list cedula_proveedor
duplicates report 
* 561 companies that have both female and male reps
duplicates tag cedula_proveedor, gen(several_reps)
*br if several_reps > 0

replace gender = 2 if several_reps > 0
replace gender = 1 if several_reps < 1 & genderfo == 1
replace gender = 0 if several_reps < 1 & genderfo == 0

lab def gendered 0 "male only firm" 1 "female only firm" 2 "mixed firm"
lab val gender gendered
	
	
	* create win/participated ratio	 
gen success_ratio = times_won/times_part
lab var success_ratio "times won over times participated" 

***********************************************************************
* 	PART 2: DV: 	times participated, won, efficiency 			
***********************************************************************
sum times_part, d


twoway ///
	(kdensity times_part if genderfo == 1) ///
	(kdensity times_part if genderfo == 0)
	
foreach x of varl times_part times_won {
	gen `x'_log = log(`x')
	gen `x'_log  = log(`x')
}

	* times participated
twoway ///
	(kdensity times_part_log if genderfo == 1 & gender == 1, lw(0.6) lc(black) lp(1))  ///
	(kdensity times_part_log if genderfo == 0 & gender == 0, lw(0.6) lc(gs10) lp(1))  ///
	(kdensity times_part_log if genderfo == 1 & gender == 2, lw(0.3) lc(black) lp(-))  ///
	(kdensity times_part_log if genderfo == 0 & gender == 2, lw(0.3) lc(gs10) lp(-)), ///
	legend(order(1 "female firm" 2 "male firm" 3 "mixed, female rep." 4 "mixed, male rep.") row(2) pos(6) size(medium)) ///
	xtitle("times firm participated, log-transformed", size(medium)) ///
	ytitle("density", size(medium)) ///
	ylabel(, nogrid) xlabel(, nogrid) ///
	name(firm_part_gender, replace)
gr export "${ppg_descriptive_statistics}/firm_part_gender.png", replace
	
	* times won
twoway ///
	(kdensity times_part_log0) ///
	(kdensity times_part_log1), ///
	legend(order(1 "female firm" 2 "male firm") row(1) pos(6) size(medium)) ///
	xtitle("times firm won, log-transformed", size(medium)) ///
	ytitle("density", size(medium)) ///
	ylabel(, nogrid) xlabel(, nogrid) ///
	name(firm_won_gender, replace)
	
	
	* efficiency
twoway ///
	(kdensity success_ratio if genderfo == 1) ///
	(kdensity success_ratio if genderfo == 0), ///
	legend(order(1 "male firm" 2 "female firm") row(1) pos(6) size(medium)) ///
	xtitle("times won/times participated", size(medium)) ///
	ytitle("density", size(medium)) ///
	ylabel(, nogrid) xlabel(, nogrid) ///
	name(firm_efficiency_gender, replace)
	
***********************************************************************
* 	PART 3: DV: points won
***********************************************************************
	
***********************************************************************
* 	PART 3: 	balance table female vs. male	  			
***********************************************************************
	* 1: firms with single gender
local balvars ""
iebaltab `balvars' if all_gender == 0, grpvar() save(baltab_female_male) replace ///
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



