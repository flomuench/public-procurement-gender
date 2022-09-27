***********************************************************************
* 			create firm level data set public procurement gender								  		  
***********************************************************************
*																	  
*	PURPOSE: analyze the effect of gender on success in public procure					  	  			
*			ment
*																	  
*	OUTLINE:														  
*	1)		collapse data set on firm level				          
*	2) 		save the data set					  									 
*																	  													      
*	Author:  	Florian Muench						    
*	ID variable: 				  					  
*	Requires: 	  	sicop_subprocess.dta									  
*	Creates:  sicop_process.dta (firm-process or firm-bid-level)			                                  
***********************************************************************
* 	PART START: 	Load data set on subprocess level	  			
***********************************************************************
use "${ppg_final}/sicop_subprocess", clear


***********************************************************************
* 	PART 1: 	save all the variables labels 	  			
***********************************************************************
foreach v of var * {
	local l`v' : variable label `v'
	 if `"`l`v''"' == "" {
		local l`v' "`v'"
 	}
 }
 

***********************************************************************
* 	PART: gen - to be removed once sub-process-collapse file fixed 	  			
***********************************************************************
	* create firm id
	* firm id
egen firm_id = group(cedula_proveedor)
order firm_id, a(cedula_proveedor)

	* gen count variable for times participated
gen one = 1

	* drop if persona_encargada_proveedor is missing
drop if persona_encargada_proveedor == ""

	* create total points
local c "calificacion"
egen total_points = rowtotal(`c'1 `c'2 `c'3 `c'4 `c'5 `c'6 `c'7 `c'8 `c'9 `c'10 `c'11 `c'12 `c'13 `c'14 ), missing /* missing --> if all MV, results in MV instead of zero*/
order total_points, b(calificacion1)

lab var total_points "bid evaluation, 0-100 points"

	
	* number of competitors
egen n_competitors = sum(one), by(sub_process_id)
order n_competitors, a(cedula_proveedor)
lab var n_competitors "number of other bidding firms"

	* create usd amounts
* 	PART 7:  gen variable with US dollar instead of Costa Rican Colones amount
		* write a loop for both price and actual procurement value
local amounts "monto precio"
foreach var of local amounts {
		* create empty variable that will hold US dollar amounts
	gen `var'_usd = ., a(`var'_crc)
			* put all years into local
	local year `" "2010" "2011" "2012" "2013" "2014" "2015" "2016" "2017" "2018" "2019" "'
			* put exchange rates for specific year into local
	local exchange_rate `" "525" "505" "502" "499" "538" "534" "544" "567" "576" "587"  "'

			* loop over each year and replace US amount 
	local n : word count `year'
	forvalues i = 1/`n' {
		local a : word `i' of `year'
		local b : word `i' of `exchange_rate'
		replace `var'_usd = `var'_crc/ `b' if year == `a'
	}

	format `var'_usd %-15.3fc
	
* 	PART 8:  winsorized + log-transform amount values to account for outliers --> see also ppg_descriptive_statistics
		* winsorize
	local currencies "usd crc"
	foreach cur of local currencies {
		winsor2 `var'_`cur', suffix(_w) cuts(1 99)
		format %-15.3fc `var'_`cur'_w
		order `var'_`cur'_w, a(`var'_`cur')
		lab var `var'_`cur'_w "winsorized amount in `cur'"

	}
}

	lab var monto_usd "contract value, USD"
	lab var precio_usd "bid price, USD"

	* log-transform
local currencies "usd crc"
foreach cur of local currencies {
	gen monto_`cur'_wlog = log(monto_`cur'_w), a(monto_`cur'_w)
	format %-15.3fc monto_`cur'_wlog
	lab var monto_`cur'_w "winsorized log of amount in `cur'"
}

* 	PART 9: gen dependent variable: dummy bid won  
gen bid_won = 0, a(monto_crc)
replace bid_won = 1 if monto_crc != .
lab var bid_won "firm won bid"

 

***********************************************************************
* 	PART 2: 	collapse data set on firm level		  			
***********************************************************************
	* complication: gender of the firm rep is not stable over time
		* solution: create an firm-gender specific id
egen fgid = group(firm_id genderfo)			
				/* control whether id has been correctly created by eye-balling the data
		sort firmid fgid
		browse fgid firmid nombre_proveedor genderfo female_firm persona_encargada_proveedor if ceof2m == 1
				*/
local keepvars "nombre_proveedor cedula_proveedor persona_encargada_proveedor age_registro age_constitucion firm_international genderfo firm_size firm_location"
local sumvars "times_part=one times_won=bid_won total_amount=monto_usd"		
local meanvars "avg_price=precio_usd avg_quantity=cantidad avg_points=total_points avg_comp=n_competitors"
				
		* collapse the data on firm-gender level
collapse (firstnm) `keepvars' (sum) `sumvars' (mean) `meanvars', by(fgid)
sort nombre_proveedor persona_encargada_proveedor genderfo

drop fgid
***********************************************************************
* 	PART 3: 	label the variables in the new firm level data set	  			
***********************************************************************	
 foreach v of var * {
	label var `v' `"`l`v''"'
 }
 
label var times_won "total bids won"
label var times_part "total bids"
label var total_amount "total amount won, USD"
label var avg_price "mean bid price, USD"
label var avg_quantity "mean quantity bid"
label var avg_points "mean bid score"
label var avg_comp "mean competitors in bid"

* firm level variables
	* firm size = done
	* age at registration = done
	* age first won *
	* firm origin = d
	* times participated
	* times won
	* average amount won = done 
	* average price bidded = done
	* average quantity of a good = done
	* average number of competitors = done 
	* average points for offer = done
	
***********************************************************************
* 	PART 4: reshape to one line per firm (due to firms with severals reps)
***********************************************************************
/*
	* get an idea how many firms have several reps
duplicates list cedula_proveedor
duplicates report 
duplicates tag cedula_proveedor, gen(several_reps)
			/* suggests 8664 - 8099 = 565 firms have female & male reps  */
			
	* create j for reshape
sort cedula_proveedor persona_encargada_proveedor genderfo
by cedula_proveedor: gen rep_id = _n == 1, a(persona_encargada_proveedor)
br if several_reps > 0

	*
drop fgid nombre_proveedor
local stubvars "persona_encargada_proveedor genderfo times_part times_won total_amount avg_comp avg_points avg_price avg_quantity"
reshape wide `stubvars', i(cedula_proveedor) j(rep_id)

	* order
order cedula_proveedor persona_encargada_proveedor0 genderfo0 persona_encargada_proveedor1 genderfo1 times_part? times_won? total_amount? avg_comp? avg_points? avg_price? avg_quantity?
br if several_reps > 0

	* verify one single obs per firm
isid cedula_proveedor
	
*/
	
***********************************************************************
* 	PART END: 	Save firm level data set		  			
***********************************************************************
save "${ppg_final}/sicop_firm", replace
