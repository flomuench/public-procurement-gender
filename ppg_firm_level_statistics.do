***********************************************************************
* 			public procurement gender firm level statistics									  		  
***********************************************************************
*																	  
*	PURPOSE: create firm-level descriptive statistics & balance table
*																	  
*	OUTLINE:														  
*	1)   	generate balance table between female and male firms					  
*	2)  	sectoral distribution of firms						  									 
*																	  													      
*	Author:  	Florian Muench						    
*	ID variable: 				  					  
*	Requires: sicop_firm
*	Creates:  -			                                  
***********************************************************************
* 	PART START: 	load data set
***********************************************************************
use "${ppg_final}/sicop_firm", clear
	
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
	
foreach x of var times_part times_won total_amount {
	gen `x'_log = log(`x')
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
	(kdensity times_won_log if genderfo == 1 & gender == 1, lw(0.6) lc(black) lp(1))  ///
	(kdensity times_won_log if genderfo == 0 & gender == 0, lw(0.6) lc(gs10) lp(1))  ///
	(kdensity times_won_log if genderfo == 1 & gender == 2, lw(0.3) lc(black) lp(-))  ///
	(kdensity times_won_log if genderfo == 0 & gender == 2, lw(0.3) lc(gs10) lp(-)), ///
	legend(order(1 "female firm" 2 "male firm" 3 "mixed, female rep." 4 "mixed, male rep.") row(2) pos(6) size(medium)) ///
	xtitle("times firm won, log-transformed", size(medium)) ///
	ytitle("density", size(medium)) ///
	ylabel(, nogrid) xlabel(, nogrid) ///
	name(firm_won_gender, replace)
gr export "${ppg_descriptive_statistics}/firm_won_gender.png", replace


	* amout won
twoway ///
	(kdensity total_amount_log if genderfo == 1 & gender == 1, lw(0.6) lc(black) lp(1))  ///
	(kdensity total_amount_log if genderfo == 0 & gender == 0, lw(0.6) lc(gs10) lp(1))  ///
	(kdensity total_amount_log if genderfo == 1 & gender == 2, lw(0.3) lc(black) lp(-))  ///
	(kdensity total_amount_log if genderfo == 0 & gender == 2, lw(0.3) lc(gs10) lp(-)), ///
	legend(order(1 "female firm" 2 "male firm" 3 "mixed, female rep." 4 "mixed, male rep.") row(2) pos(6) size(medium)) ///
	xtitle("total amount won, log-transformed, USD", size(medium)) ///
	ytitle("density", size(medium)) ///
	ylabel(, nogrid) xlabel(, nogrid) ///
	name(firm_amount_gender, replace)
gr export "${ppg_descriptive_statistics}/firm_amount_gender.png", replace

	
	* efficiency
twoway ///
	(kdensity success_ratio if genderfo == 1 & gender == 1, lw(0.6) lc(black) lp(1))  ///
	(kdensity success_ratio if genderfo == 0 & gender == 0, lw(0.6) lc(gs10) lp(1))  ///
	(kdensity success_ratio if genderfo == 1 & gender == 2, lw(0.3) lc(black) lp(-))  ///
	(kdensity success_ratio if genderfo == 0 & gender == 2, lw(0.3) lc(gs10) lp(-)), ///
	legend(order(1 "female firm" 2 "male firm" 3 "mixed, female rep." 4 "mixed, male rep.") row(2) pos(6) size(medium)) ///
	xtitle("times won / times participated", size(medium)) ///
	ytitle("density", size(medium)) ///
	ylabel(, nogrid) xlabel(, nogrid) ///
	name(firm_successratio_gender, replace)
gr export "${ppg_descriptive_statistics}/firm_successratio_gender.png", replace

	* efficiency but restricted > 1 participation
twoway ///
	(kdensity success_ratio if genderfo == 1 & gender == 1 & times_part > 1, lw(0.6) lc(black) lp(1))  ///
	(kdensity success_ratio if genderfo == 0 & gender == 0 & times_part > 1, lw(0.6) lc(gs10) lp(1))  ///
	(kdensity success_ratio if genderfo == 1 & gender == 2 & times_part > 1, lw(0.3) lc(black) lp(-))  ///
	(kdensity success_ratio if genderfo == 0 & gender == 2 & times_part > 1, lw(0.3) lc(gs10) lp(-)), ///
	legend(order(1 "female firm" 2 "male firm" 3 "mixed, female rep." 4 "mixed, male rep.") row(2) pos(6) size(medium)) ///
	xtitle("times won / times participated", size(medium)) ///
	ytitle("density", size(medium)) ///
	ylabel(, nogrid) xlabel(, nogrid) ///
	name(firm_successratio_gender, replace)
gr export "${ppg_descriptive_statistics}/firm_successratio_gender2.png", replace
	
***********************************************************************
* 	PART 3: DV: points won
***********************************************************************
	* points
twoway ///
	(kdensity avg_points if genderfo == 1 & gender == 1, lw(0.6) lc(black) lp(1))  ///
	(kdensity avg_points if genderfo == 0 & gender == 0, lw(0.6) lc(gs10) lp(1))  ///
	(kdensity avg_points if genderfo == 1 & gender == 2, lw(0.3) lc(black) lp(-))  ///
	(kdensity avg_points if genderfo == 0 & gender == 2, lw(0.3) lc(gs10) lp(-)), ///
	legend(order(1 "female firm" 2 "male firm" 3 "mixed, female rep." 4 "mixed, male rep.") row(2) pos(6) size(medium)) ///
	xtitle("average bid evaluation, 0-100 points", size(medium)) ///
	ytitle("density", size(medium)) ///
	ylabel(, nogrid) xlabel(, nogrid) ///
	name(firm_points_gender, replace)
gr export "${ppg_descriptive_statistics}/firm_points_gender1.png", replace

	* points but restricted to firms with > 2 participations 
		* concern: 100 avg points per bid easier to reach if just one bid
twoway ///
	(kdensity avg_points if genderfo == 1 & gender == 1 & times_part > 2, lw(0.6) lc(black) lp(1))  ///
	(kdensity avg_points if genderfo == 0 & gender == 0 & times_part > 2, lw(0.6) lc(gs10) lp(1))  ///
	(kdensity avg_points if genderfo == 1 & gender == 2 & times_part > 2, lw(0.3) lc(black) lp(-))  ///
	(kdensity avg_points if genderfo == 0 & gender == 2 & times_part > 2, lw(0.3) lc(gs10) lp(-)), ///
	legend(order(1 "female firm" 2 "male firm" 3 "mixed, female rep." 4 "mixed, male rep.") row(2) pos(6) size(medium)) ///
	xtitle("average bid evaluation, 0-100 points", size(medium)) ///
	ytitle("density", size(medium)) ///
	ylabel(, nogrid) xlabel(, nogrid) ///
	name(firm_points_gender, replace)
gr export "${ppg_descriptive_statistics}/firm_points_gender2.png", replace

	
	
***********************************************************************
* 	PART 3: 	balance table female vs. male	  			
***********************************************************************
tab firm_size, gen(firm_size)
lab var firm_size1 "medium firm"
lab var firm_size2 "large firm"
lab var firm_size3 "size unclassified"
lab var firm_size4 "micro firm"
lab var firm_size5 "small firm"

tab firm_location, gen(firm_location)
lab var firm_location1 "San José"
lab var firm_location2 "Alajuela"
lab var firm_location3 "Cartago"
lab var firm_location4 "Heredia"
lab var firm_location5 "Guanac."
lab var firm_location6 "Punta."
lab var firm_location7 "Limón"

lab def genders 1 "female" 0 "male"
lab val genderfo genders

	* 1: Consider only female or male; firms with mixed reps are counted in each category
local balvars "times_part times_won success_ratio total_amount avg_points avg_comp age_registro age_constitucion firm_international firm_size? firm_location?"
		* Excel
iebaltab `balvars', grpvar(genderfo) replace ///
		save("${ppg_descriptive_statistics}/baltab_firm_gender") ///
		vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
		format(%12.2fc)
			 
		* Tex
iebaltab `balvars', grpvar(genderfo) replace ///
		savetex("${ppg_descriptive_statistics}/baltab_firm_gender") ///
		vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
		format(%12.2fc)
		
	* 2: distinguish four categories: male only, female only, mixed either male or female
gen gender4 = .
	replace gender4 = 1 if gender == 0
	replace gender4 = 2 if gender == 1
	replace gender4 = 3 if gender == 2 & genderfo == 0 /* mixed, under male rep */
	replace gender4 = 4 if gender == 2 & genderfo == 1 /* mixed, under female rep */
lab def gender_four 1 "male only" 2 "femaly only" 3 "mixed, under male" 4 "mixed, under female"
lab val gender4 gender_four

local balvars "times_part times_won success_ratio total_amount avg_points avg_comp age_registro age_constitucion firm_international firm_size? firm_location?"

		* Excel
iebaltab `balvars', grpvar(gender4) replace ///
		save("${ppg_descriptive_statistics}/baltab_firm_gender4") ///
		vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
		format(%12.2fc)
			 
		* Tex
iebaltab `balvars', grpvar(gender4) replace ///
		savetex("${ppg_descriptive_statistics}/baltab_firm_gender4") ///
		vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
		format(%12.2fc)
			 
***********************************************************************
* 	PART 3: 	sectoral distribution of firms	  			
***********************************************************************


***********************************************************************
* 	PART 4: 	geographical distribution of firms  			
***********************************************************************
graph bar firm_location?, over(genderfo)

***********************************************************************
* 	PART 5: 	contract type  			
***********************************************************************

***********************************************************************
* 	PART 6: 	institutions			
***********************************************************************



