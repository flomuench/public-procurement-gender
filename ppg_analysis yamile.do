
***********************************************************************
* 			public procurement gender firm level statistics									  		  
***********************************************************************
*																	  
*	PURPOSE: analyze the effect of gender on success in public procure					  	  			
*			ment
*																	  
*	OUTLINE:														  
*	1)   	Percentage of female applicants per public contract 					  
*	2)  	Chance of a female represented firms winning a public contract
*   3)		Cross-tables for sectors, genderfo, win and score
					  									 
*																	  													      
*	Author:  	Yamile Vargas					    
*	ID variable: 				  					  
*	Requires: 	  	SICOP_gender_new_workingversion.dta									  
*	Creates:  	
*
cd "/Users/yamivargas/Google Drive/Public Procurement and Gender/Data/Yami_Flo/"
use "SICOP_gender_new_workingversion.dta", clear	                                  
***********************************************************************
* 	PART 1: 	Percentage of female represented applicants per public contract 			
***********************************************************************

bys id: egen sum_female = sum(genderfo)
bys id: gen sum_id = _N
bys id: gen perc_female = sum_female / sum_id

***********************************************************************
* 	PART 2: 	Chance of female represented firms winning a public contract - Score			
***********************************************************************

* By generating the variable score, it is possible to find out the success chances 
* of a female represented firm winning a public contract represented through an female-win-score
bys id: gen score = win * (1/perc_female) if genderfo == 1 & win == 1

* Generate variable only_female to find groups where only females have applied
gen only_female = 0
bys id: replace only_female = 1 if sum_id == sum_female

* Check score 
tab score if only_female == 0
su score, detail //=> highest 5% score >=5

* Check branches with high score - above 5
tab c_o_DESCRIPCION if score >= 5 & score != .
tab sector if score >= 5 & score != .

*It is possible to see that the top five sectors where women have frequently a high score are: raw construction materials, tools and equipments, utensiles and other materiales, durable goods and chemical products

***********************************************************************
* 	PART 3: 	Cross-tables for sectors, genderfo, win and score			
***********************************************************************

* Simple overview of frequencies by sector
tab sector genderfo, row

* Overview of Sector with sum of wins by gender and mean female-win-score
table sector genderfo, contents(sum win mean score)

* Overview of Sector with sum of applied female represented firms by female-win-score (with detailed sub categories)
table c_o_DESCRIPCION genderfo, contents(mean score)

* Collapse of all data by sector in order to see mean female-win-score by sector
* and thus see means/medians etc.
collapse (mean) score, by(sector)
summarize score, detail

*As a result it is possible to observe that the top 5 sectors with the highest mean female-win-score are:  raw and construction materials, chemical products, materials for production, construction, travel & transport services





