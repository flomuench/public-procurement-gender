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
