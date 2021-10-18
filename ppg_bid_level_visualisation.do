***********************************************************************
* 			ppg_bid_level_statistics		
***********************************************************************
*																	  
*	PURPOSE: replace					  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		 			  				  
* 	2) 		
*	3)   							  
*	4)  		  				  	  
*																	  															      
*	Author:  	Florian Muench						  
*	ID variable: 	process level id = id ; firm level id = firmid			  					  
*	Requires: 	  								  
*	Creates:  			                          
*																	  
***********************************************************************
* 	PART 1:  create bar chart of female male ratio per product group			
***********************************************************************
use "${ppg_intermediate}/sicop_replicable", clear
cd "$figures"

		* data set on product level (female male ratio for firm on product level created before)
collapse (firstnm) ratio_fmf c_o_DESCRIPCION, by(c_o)
		
		* create a variable to order the bars of the ratio by descending order
sort ratio_fmf
gen rank = _n

		* create a scalar to visualise lower and upper half of products in one graph
sum ratio_fmf, d
scalar med_fmf = r(p50)

		* lower the names of the product categories for better readability
replace c_o_DESCRIPCION = lower(c_o_DESCRIPCION)

		* create the graph
graph hbar (min) ratio_fmf if ratio_fmf <= med_fmf, ///
	over(c_o_DESCRIPCION, label(labsize(tiny)) sort(rank)) ///
		blabel(bar, format(%-9.2f) size(tiny)) ///
		ytitle("Ratio of female to male firms") ///
		name(female_male_ratio_product_lower)
graph hbar (min) ratio_fmf if ratio_fmf > med_fmf & ratio_fmf!=., ///
	over(c_o_DESCRIPCION, label(labsize(tiny)) sort(rank)) ///
		blabel(bar, format(%-9.2f) size(tiny)) ///
		ytitle("Ratio of female to male firms") ///
		name(female_male_ratio_product_upper)
graph combine female_male_ratio_product_lower female_male_ratio_product_upper, ///
	title("Ratio of female to male firms by procurement product") ///
	subtitle("Below median (left) and above median (right)")
		* export the graph
graph export female_male_ratio_product.png, replace

***********************************************************************
* 	PART 2:  create bar chart of total females (left) and total males (right) per product group			
***********************************************************************


***********************************************************************
* 	PART 3:  visualise how many lags and leaps before treatment (change in reps gender)
***********************************************************************
	cd "$ppg_figures"
histogram time_to_treat, title("{bf:Lags and leaps around gender change of firm representative}") ///
	subtitle("{it:Process-level}") ///
	xtitle("Number of bids") xlabel(#10) ///
	note("Bin width = ", size(small))
	
histogram time_to_treat if time_to_treat <= 50 & time_to_treat > = - 50, frequency ///
	width(5) ///
	title("{bf:Lags and leaps around gender change of firm representative}") ///
	subtitle("{it:Process-level}") ///
	xtitle("Time to treatment") xlabel(#10) ///
	note("Bin width = 5", size(small)) ///
	ylabel(0(500)4000) ytitle("Total number of procurement processes")
graph export lags_leaps_around_gender_change_process_level.png, replace

histogram time_to_treat if time_to_treat <= 50 & time_to_treat > = - 50 & f2m!= ., frequency ///
	width(1) ///
	title("{bf:Lags and leaps around gender change of firm representative}") ///
	subtitle("{it:Process-level}") ///
	xtitle("Time to treatment") xlabel(#10) ///
	note("Bin width = 1. N = 8165 processes.", size(small)) ///
	ylabel(0(10)200) ytitle("Total number of procurement processes")
graph export lags_leaps_around_gender_change_process_level_sample.png, replace
	
twoway  (histogram time_to_treat if time_to_treat <= 50 & time_to_treat > = - 50 & f2m == 1, width(1) frequency color(maroon%30)) ///
		(histogram time_to_treat if time_to_treat <= 50 & time_to_treat > = - 50 & f2m == 0, width(1) frequency color(navy%30)), ///
			legend(order(1 "Female to male" 2 "Female to female")) ///
			title("{bf:Lags and leaps around gender change of firm representative}") ///
			subtitle("{it:Process-level by treatment and control group}") ///
			xtitle("Time to treatment") xlabel(#10) ///
			note("Bin width = 1. N = 8165 processes out of which 2,385 female-to-male & female-to-female 5,780.", size(vsmall)) ///
			ylabel(0(10)100) ytitle("Total number of procurement processes")
graph export lags_leaps_around_gender_change_process_level_f2m.png, replace
	
twoway  (histogram time_to_treat if time_to_treat <= 50 & time_to_treat > = - 50 & m2f == 1, width(1) frequency color(maroon%30)) ///
		(histogram time_to_treat if time_to_treat <= 50 & time_to_treat > = - 50 & m2f == 0, width(1) frequency color(navy%30)), ///
			legend(order(1 "Male to female" 2 "Male to male")) ///
			title("{bf:Lags and leaps around gender change of firm representative}") ///
			subtitle("{it:Process-level by treatment and control group}") ///
			xtitle("Time to treatment") xlabel(#10) ///
			note("Bin width = 1. N = 39,876 processes out of which 1,761 male-to-female & 38,115 male-to-male.", size(vsmall)) ///
			ylabel(0(50)500) ytitle("Total number of procurement processes")
graph export lags_leaps_around_gender_change_process_level_m2f.png, replace
