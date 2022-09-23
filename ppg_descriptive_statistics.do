***********************************************************************
* 			create descriptive statistics public procurement gender								  		  
***********************************************************************
*																	  
*	PURPOSE: create analysis, sub-process level data set
*			
*																	  
*	OUTLINE:														  
*	1)		collapse data set on firm level				          
*	2) 		save the data set					  									 
*																	  													      
*	Author:  	Florian Muench						    
*	ID variable: 				  					  
*	Requires: 	  	sicop_final.dta; sicop_subprocess									  
***********************************************************************
* 	PART START: 	load data set		  			
***********************************************************************
use "${ppg_final}/sicop_subprocess", clear



***********************************************************************
* 	PART 1: 	time series of procurement volume + procecesses		  			
***********************************************************************
	* What is the total amount that was allocated?
local currencies "crc usd"
foreach x of local currencies {
	egen total_procurement_amount_`x' = sum(monto_`x')
	order total_procurement_amount_`x', a(monto_`x')
	format total_procurement_amount_`x' %-25.3fc
 }

* Col: ~ 902 billion Costa Rican Colones
* USD: ~ 1.65 billion
 
	
	* How many processes/bids were there in total?
codebook numero_procedimiento 
/* 43, 693 procecesses, 774, 423 bids */

	* How many winners/products ordered?
codebook monto_crc if monto_crc != . 
/* 199,639 products/orders/winners
implies that every 
 */

	* From when to when goes the data?
sort date_publicacion /* December 2010, April 2019 --> 8 3/4 years */

	* create a seperate frame
frame copy default subtask, replace
frame change subtask

	* generate variable that can be used to visualize the number of processes per month
bysort numero_procedimiento: gen process_count = _n == 1, a(numero_procedimiento)



	* collape to monthly or annual procurement volume
* useful links: 					https://stats.oarc.ucla.edu/stata/faq/how-can-i-collapse-a-daily-time-series-to-a-monthly-time-series/
* https://www.ssc.wisc.edu/sscc/pubs/stata_dates.htm
* reminder: %td "number of days since Jan 1, 1960"
* help dcfcns
		* convert to date (instead of datetime variable)
gen da_adj = dofc(date_adjudicacion), a(date_adjudicacion)
format %td da_adj
		* convert date to monthly
gen da_adj_m = mofd(da_adj), a(da_adj)
format da_adj_m %tm
		
		* collapse to monthly amount, process data set
collapse (sum) monto_crc process_count (mean) n_competitors, by(da_adj_m)
lab var monto_crc "total procurement amount (in CRC)"
lab var n_competitors "number of bidders"
lab var process_count "number of processes"
lab var da_adj_m "months"

	* change to time series format
tsset da_adj_m
	
	* in general
tsline monto_crc if tin(2011m1,2018m1)
twoway (tsline monto_crc) (tsline process_count, yaxis(2))
twoway ///
	(tsline monto_crc, lcolor(black%75) lwidth(.5) ////
	ylabel(0(2)8, nogrid)) ///
	///
	(tsline n_competitors, yaxis(2) lcolor(gs10) lwidth(0.5) ///
	ylabel(0 5000000000 10000000000 20000000000 30000000000, nogrid)) ///
	///
	if tin(2011m1, 2018m12), ///
	legend(order (1 "amount" 2 "bidders") pos(6) rows(1)) ///
	tlabel(2011m1(12)2019m1, nogrid) ///
	xsize(2) ysize(1) ///
	name(time_series_amount_bidders, replace)
gr export "${ppg_descriptive_statistics}/time_series_amount_bidders.png", replace
	

	* drop frame
frame change default
frame drop subtask
	
***********************************************************************
* 	PART 2: 	Plot dependent variables: (1) monto	  			
***********************************************************************
sum monto_usd, d
/*
suggests that 99% are within ~ 110,000 USD &  1% = 0. 

Winsorizing amount at 1% and 99% seems reasonable to
	exlcude outliers or wrong data entries. It is hard/impossible
	to tell apart outliers and erronous data entries.

*/

order clasificacion_objeto_des clasi_bien_serv, a(precio_crc)
br if monto_crc < 1000
/* 
suggest very low values relate to cleaning products, office materials, food, which seems plausible

there are sometimes zero values, which one could consider dropping. It is unclear what these
zeros stand for (won but not executed? data errors?)
*/

graph box monto_usd
/*
suggest there is one big outlier contract worth ~ 30 million USD and a handful of contracts
> 10 million USD

*/
br if monto_usd > 10000000 & monto_usd < .
/*
eyeballing the data does not suggest any special pattern. object classification suggests
two of the five products were real estate, which can explain the high value. In the three
other cases, the high value is rather surprising given products are "computer equipment",
information and general services.
*/

kdensity monto_usd_w
/* outliers still to far off left */

kdensity monto_usd_wlog
* some small values become negative, now right skewed but 

twoway ///
	(kdensity monto_usd_wlog if genderfo == 1, lcolor(black%75) lpattern(solid)) ///
	(kdensity monto_usd_wlog if genderfo == 0, lcolor(gs10) lpattern(dash)), ///
	legend(order(1 "female firm" 2 "male firm") row(1) pos(6) size(medium)) ///
	xtitle("contract value (USD), winsorized and log-transformed", size(medium)) ///
	ytitle("density", size(medium)) ///
	ylabel(, nogrid) xlabel(, nogrid) ///
	name(monto_distribution, replace)
gr export "${ppg_descriptive_statistics}/monto_distribution.png", replace

	
***********************************************************************
* 	PART 3: 	Plot dependent variables: (2) points  			
***********************************************************************
	* create total points
*order calificacion?, last
*order calificacion10-calificacion14, a(calificacion9)
local c "calificacion"
egen total_points = rowtotal(`c'1 `c'2 `c'3 `c'4 `c'5 `c'6 `c'7 `c'8 `c'9 `c'10 `c'11 `c'12 `c'13 `c'14 ), missing /* missing --> if all MV, results in MV instead of zero*/
order total_points, b(calificacion1)

	* plot total points by gender 
		* all the firms
twoway ///
	(kdensity total_points if genderfo == 1, lcolor(black%75) lpattern(solid)) ///
	(kdensity total_points if genderfo == 0, lcolor(gs10) lpattern(dash)), ///
	legend(order(1 "female firm" 2 "male firm") row(1) pos(6) size(medium)) ///
	subtitle("sample = all bidders", size(medium)) ///
	xtitle("points for bid", size(medium)) ///
	ytitle("density", size(medium)) ///
	ylabel(, nogrid) xlabel(, nogrid) ///
	name(points_distribution_all, replace)
gr export "${ppg_descriptive_statistics}/points_distribution_all.png", replace

		* winners only
twoway ///
	(kdensity total_points if genderfo == 1, lcolor(black%75) lpattern(solid)) ///
	(kdensity total_points if genderfo == 0, lcolor(gs10) lpattern(dash)) ///
	if monto_crc < . & monto_crc > 0, ///
	legend(order(1 "female firm" 2 "male firm") row(1) pos(6) size(medium)) ///
	subtitle("sample = bid winners", size(medium)) ///
	xtitle("points for bid", size(medium)) ///
	ytitle("density", size(medium)) ///
	ylabel(, nogrid) xlabel(, nogrid) ///
	name(points_distribution_winners, replace)
gr export "${ppg_descriptive_statistics}/points_distribution_winners.png", replace

***********************************************************************
* 	PART 4: 	Plot dependent variables: (3) probability of winning	  			
***********************************************************************
* option 1: dummy --> but gives only prob relative to other firm
* option 2: 
	* 1: estimate prob of winning for each company, and predict probability
			* problem 1: what if all 1 or 0?
			* problem 2: some companies have changes in rep. Better to do it
				* by company-gender?
	* 2: kdensity then takes 

/*
logit bid_won, vce(cluster cedula_proveedor)
predict probability_bid_won, xb
lab var probability_bid_won "unconditiional linear prediction firm bid won"

twoway ///
	(kdensity probability_bid_won if genderfo == 1, lcolor(black%75) lpattern(solid)) ///
	(kdensity probability_bid_won if genderfo == 0, lcolor(gs10) lpattern(dash)) ///
	if monto_crc < . & monto_crc > 0, ///
	legend(order(1 "female firm" 2 "male firm") row(1) pos(6) size(medium)) ///
	subtitle("sample = bid winners", size(medium)) ///
	xtitle("probability bid won, unconditional linear prediction", size(medium)) ///
	ytitle("density", size(medium)) ///
	ylabel(, nogrid) xlabel(, nogrid) ///
	name(bid_won_pdistribution, replace)
gr export "${ppg_descriptive_statistics}/bid_won_pdistribution.png", replace
*/


***********************************************************************
* 	PART 5: 	Plot independent variables: (1) gender procurement officer
***********************************************************************
* bids decided for by women vs. men
graph bar (percent) monto_usd one, over(genderpo, lab(labs(medium))) asyvars stack ///
	blabel(bar, format(%10.2fc) position(center)) ///
	ytitle("percent", size(medium)) ///
	ylabel(, nogrid) /// 
	legend(order(1 "Contract value" 2 "Bids") pos(6) rows(1) size(medium)) ///
	name(bids_amount_gender, replace)
gr export "${ppg_descriptive_statistics}/bids_amount_gender.png", replace

	
	 
* absolute number of women vs. men procurement officers
	* create a seperate frame
frame copy default subtask, replace
frame change subtask

drop _freq

contract nombre_comprador genderpo
rename _freq bids_managed
gsort genderpo -bids_managed

graph bar (count) , over(genderpo) ///
	blabel(bar, format(%10.0fc) position(outside))


* how many bids per procurement officers, bottom and top?
twoway ///
	(histogram bids_managed if genderpo == 0, fcolor(black)) ///
	(histogram bids_managed if genderpo == 1, fcolor(gs10%50)), ///
	legend(title("Procurement officers") order(1 "Female" 2 "Male") pos(6) rows(1) size(medium)) ///
	ytitle("density") ///
	xtitle("bids managed")
	name(bids_po_gender, replace)
	
	* get the average
sum bids_managed if genderpo == 1, d /* 838, SD 1900. One can divide by 4 to get number of processes. */
local fpoavg = r(mean)
sum bids_managed if genderpo == 0 /* 1085, SD 3206. One can divide by 4 to get number of processes. */
local mpoavg = r(mean)

	* list the top 15 for each gender
gsort genderpo -bids_managed
graph hbar (asis) bids_managed in 1/15, over(nombre_comprador, sort(1)) ///
	ytitle("bids managed") ///
	subtitle("top 15 male procurement officers") ///
	ylabel(0(10000)40000, nogrid) ///
	yline(`mpoavg') ///
	name(top15malepo, replace)
	
gsort -genderpo -bids_managed
	
graph hbar (asis) bids_managed in 1/15, over(nombre_comprador, sort(1)) ///
	ytitle("bids managed") ///
	subtitle("top 15 female procurement officers") ///
	ylabel(0(10000)40000, nogrid) ///
	yline(`fpoavg') ///
	name(top15femalepo, replace)
	
gr combine top15femalepo top15malepo, name(top15po, replace)
gr export "${ppg_descriptive_statistics}/top15po.png", replace
	


* PO-FR combinations, per bids
graph bar (sum) combi1 combi2 combi3 combi4, asyvars ///
	blabel(bar, format(%10.0fc) position(outside)) ///
	ylabel(, nogrid) ///
	legend(title("Procurement officer - Firm representative gender combinations:", justification(left)) ///
	order(1 "female-female" 2 "female-male" 3 "male-female" 4 "male-male") pos(6) /// 
	rows(1) size(medium)) ///
	ytitle("bids", size(medium)) ///
	name(gender_combis, replace)
gr export "${ppg_descriptive_statistics}/gender_combis.png", replace


***********************************************************************
* 	PART 7: 	Plot independent variables: (2) main institutions
***********************************************************************
* most frequent institutions
* gender distribution across institutions? Do we care? Idk. Products likely more important.

***********************************************************************
* 	PART 8: 	Plot independent variables: (3) main products
***********************************************************************
* main products
	* put into one table
table clasificacion_objeto_des genderfo, statistic(frequency) ///
		statistic(percent, across(clasificacion_objeto_des)) ///
		sformat("%s%%" percent)
		
	* one-way tabulation by gender
table clasificacion_objeto_des if genderfo == 1, ///
	statistic(frequency) statistic(percent)
		
		
	* create a variable containing the absolute frequencies of each category
bysort clasificacion_objeto_des : gen product_freq = _N, a(clasificacion_objeto_des)

	* get an idea of absolute frequencies
tab clasificacion_objeto_des
tab clasificacion_objeto_des genderfo
tab clasificacion_objeto_des if genderfo == 1, sort

	* calculate a rank to select top products only
bysort 

	* visualise top 20 products
		* female firms
replace clasificacion_objeto_des = "productos de construccion" if clasificacion_objeto_des == "otros materiales y productos de uso en la construccion y mantenimiento"
replace clasificacion_objeto_des = "productos electricos" if clasificacion_objeto_des == "materiales y productos electricos, telefonicos y de computo"
replace clasificacion_objeto_des = "materiales medico" if clasificacion_objeto_des == "utiles y materiales medico, hospitalario y de investigacion"
graph hbar (percent) one if product_freq >= 3931 & product_freq < . & genderfo == 1, ///
	over(clasificacion_objeto_des, sort(1)) ///
	ylabel(, nogrid) ///
	ytitle("percent of bids of female-represented firms")
	
	
		* male firms
graph hbar (percent) one if product_freq >= 7700 & product_freq < . & genderfo == 0, ///
	over(clasificacion_objeto_des, sort(1)) ///
		ylabel(, nogrid) ///
	ytitle("percent of bids of male-represented firms") ///
	

	* firmrep
		* create a seperate frame
frame copy default subtask1, replace
frame change subtask1

		* contract to select only 

		* change frame
frame change default
frame copy default subtask2, replace
frame change subtask2


	* Procurement officers



	* drop frames
frame drop subtask?


***********************************************************************
* 	PART 9: 	Plot independent variables: (5) contract allocation process
***********************************************************************
* participation of female vs. male firms by contract allocation type

***********************************************************************
* 	PART 10: 	Plot independent variables: (2) gender firm representatives
***********************************************************************


