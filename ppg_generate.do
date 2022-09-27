***********************************************************************
* 			generate variables public procurement gender								  	  
***********************************************************************
*																	   
*	PURPOSE: Generate variables for analysis															
*																	  
*	OUTLINE:														  
*	1)				firm age		  						  
*	2)   			firm location	  		    
*	3)  			firm country of origin	  
*	4)  			firm size
*	5)  			firm occurence, calendar independent 			  
*	6)  
*	7)											  
*	8)												  
*																	  
*	Author:  	Florian Muench					          															      
*	ID variable: 	process level id = id ; firm level id = firmid
*	Requires:  	   								  
*	Creates:  			   						  
*																	  
***********************************************************************
* 	PART START:  Load data set		  			
***********************************************************************
use "${ppg_intermediate}/sicop_replicable", clear


***********************************************************************
* 	PART 0:  create id's
***********************************************************************
	* sub-processes
egen sub_process_id = group(numero_procedimiento partida linea)

	* sub-processes firm combinations
egen sub_process_firm_id = group(numero_procedimiento partida linea cedula_proveedor)
format sub_process_id sub_process_firm_id %-12.0fc

	* firm id
egen firm_id = group(cedula_proveedor)

order sub_process_id firm_id sub_process_firm_id, b(numero_procedimiento)

***********************************************************************
* 	PART 1: create Stata recognized date variables + generate age variables			
***********************************************************************
	* create Stata recognized time variables to create a running event variable
local fechas "publicacion adjudicacion registro"
foreach x of local fechas {
gen date_`x' = clock(fecha_`x', "DM20Yhms"), a(fecha_`x')
format date_`x' %tc
}
	* create year variables for the year of publication, 
		* execution of the bid & firm registration
local dates "publicacion adjudicacion registro"
foreach var of local dates {
	gen year_`var' = substr(fecha_`var', 7, 2), a(fecha_`var')
	destring year_`var', replace
	replace year_`var' = year_`var' + 2000
}

lab var year_registro "year when firm was registered"
lab var date_registro "date when firm was registered"

	* do the same for the year when the firm was founded (different format thus not in loop)
gen year_constitucion = substr(fecha_constitucion, -4, .), a(fecha_constitucion)
destring year_constitucion, replace
label var year_constitucion "year when firm was founded"

	* calculate the age variables 
		* firm age in 2019
gen age_constitucion = 2019 - year_constitucion
label var age_constitucion "firm age in 2019"

		* firm age at time of bid publication
gen age = year_publicacion - year_constitucion
label var age "firm age at time of bid publication"

		* firm age at registration
gen age_registro = year_registro - year_constitucion
label var age_registro "firm age when registered"


***********************************************************************
* 	PART 2:  generate country origin dummy
***********************************************************************
gen firm_international = (pais_domicilio != "crc"), a(pais_domicilio)
label var firm_international "international firm (= not from CR)"
label def international 0 "Costa Rican" 1 "International"
lab val firm_international international


***********************************************************************
* 	PART 3:  generate firm size dummy
***********************************************************************
		* firm size dummy
lab def fsize 1 "micro" 2 "pequeña" 3 "mediana" 4 "grande" 5 "no clasificado"
encode tipo_empresa, gen(firm_size) label(fsize)
lab var firm_size "micro, small, medium, large or unclassified firm"
drop tipo_empresa


***********************************************************************
* 	PART 4:  generate firm region location dummy
***********************************************************************
replace codigo_postal = " " if codigo_postal == "008"
gen cp = substr(codigo_postal, 1,1)
destring cp, replace
label define Region 1 "San José" 2 "Alajuela" 3 "Cartago" 4 "Heredia" 5 "Guanac." 6 "Punta." 7 "Limón", replace
label values cp Region
rename cp region
order region, a(firm_size)
rename region firm_location
lab var firm_location "firm location, region in Costa Rica"



***********************************************************************
* 	PART 5:  generate sector dummy
***********************************************************************
gen co = string(clasificacion_objeto)
replace co = substr(co,1,3)
destring co, replace
gen sector = .

replace sector = 1 if co == 101 
replace sector = 2 if co == 102
replace sector = 3 if co == 103
replace sector = 4 if co == 104
replace sector = 5 if co == 105
replace sector = 6 if co == 106
replace sector = 7 if co == 109 | co == 100 | co == 107 | co == 199
replace sector = 8 if co == 108
replace sector = 9 if co == 201

replace sector = 10 if co == 202
replace sector = 11 if co == 203 | co == 200
replace sector = 12 if co == 204
replace sector = 13 if co == 205
replace sector = 14 if co == 299

replace sector = 15 if co == 500 | co == 501
replace sector = 16 if co == 502
replace sector = 17 if co == 503
replace sector = 18 if co == 599
replace sector = 19 if co == 602 | co == 607
replace sector = 20 if co == 0 | co == 103 

drop co

label var sector " "
label define sectorcategories 1 "rent" ///
	2 "basic public services" ///
	3 "publicity & transaction services" ///
	4 "management & support services" ///
	5 "travel & transport services" ///
	6 "financial services" ///
	7 "miscallaneous services" ///
	8 "maintenance & repair" ///
	9 "chemical products" ///
	10 "agricultural products & food" ///
	11 "raw and construction materials" ///
	12 "tools & equipment" ///
	13 "materials for production" ///
	14 "utensiles & other materials" /*(paper, cleaning products, wood, medical devices*/ /// 
	15 "durable goods" /*(machines, electronics, furniture etc.) */  ///
	16 "construction" ///
	17 "preexisting property" ///
	18 "nontangible property" ///
	19 "transfers" ///
	20 "salaries" 
	 
label values sector sectorcategories
tab sector, missing

***********************************************************************
* 	PART 6:  Factor variable auction or contract allocation type
***********************************************************************
local varstocode "tipo_s institucion clasi_bien_serv mejora_precio"
foreach x of local varstocode {
	encode `x', gen(`x'1)
	drop `x'
	rename `x'1 `x'
}

***********************************************************************
* 	PART 7:  Number of competitors
***********************************************************************
gen one = 1
egen n_competitors = sum(one), by(sub_process_id)
order n_competitors, a(cedula_proveedor)
lab var n_competitors "number of other bidding firms"


***********************************************************************
* 	PART 7:  gen variable with US dollar instead of Costa Rican Colones amount
***********************************************************************
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
	lab var monto_usd "contract value, USD"
	lab var precio_usd "bid price, USD"
	
***********************************************************************
* 	PART 8:  winsorized + log-transform amount values to account for outliers --> see also ppg_descriptive_statistics
***********************************************************************
		* winsorize
	local currencies "usd crc"
	foreach cur of local currencies {
		winsor2 `var'_`cur', suffix(_w) cuts(1 99)
		format %-15.3fc `var'_`cur'_w
		order `var'_`cur'_w, a(`var'_`cur')
		lab var `var'_`cur'_w "winsorized amount in `cur'"

	}
}

	* log-transform
local currencies "usd crc"
foreach cur of local currencies {
	gen monto_`cur'_wlog = log(monto_`cur'_w), a(monto_`cur'_w)
	format %-15.3fc monto_`cur'_wlog
	lab var monto_`cur'_w "winsorized log of amount in `cur'"
}


***********************************************************************
* 	PART 9: gen dependent variable: dummy bid won  
***********************************************************************
gen bid_won = 0, a(monto_crc)
replace bid_won = 1 if monto_crc != .
lab var bid_won "firm won bid"

***********************************************************************
* 	PART 10: gen dummy for bid-level procurement officer-firm representative gender combinations
***********************************************************************
gen gender_combi = . 
	replace gender_combi = 1 if genderpo == 1 & genderfo == 1
	replace gender_combi = 2 if genderpo == 1 & genderfo == 0
	replace gender_combi = 3 if genderpo == 0 & genderfo == 1
	replace gender_combi = 4 if genderpo == 0 & genderfo == 0
lab def combis 1 "PO female - FR female" 2 "PO female - FR male" 3 "PO male - FR female" 4 "PO male - FR male"
lab val gender_combi combis
tab gender_combi, gen(combi)

/*
***********************************************************************
* 	PART 5: generate firm occurence variable			
***********************************************************************
sort cedula_proveedor date_adjudicacion numero_procedimiento partida linea
by cedula_proveedor: gen firm_occurence = _n, a(firmid)
format %5.0g firmid firm_occurence

***********************************************************************
* 	PART 5:  single, never, multiple changes in representative 
***********************************************************************
	* idea: only look at firms that have more than 1 distinct name
		* gen count number of representatives & dummy for single rep		
			* idea: count unique values of representative
by firmid persona_encargada_proveedor, sort: gen reps = _n == 1, a(persona_encargada_proveedor)
bysort firmid: replace reps = sum(reps)
bysort firmid: replace reps = reps[_N]
	
gen single_change = (reps == 2)
codebook firmid if single_change == 1
				* 860 firms, 40,470 processs
				
gen never_change = (reps == 1)
codebook firmid if never_change == 1
				* 7384 firms, 100,119 processes

gen multiple_change = (reps > 2 & reps <.)
codebook firmid if multiple_change == 1
				* 417 firms
				
***********************************************************************
* 	PART 6:  Verify via text matching if change in reps not wrongly assigned due to misspellings	  			
***********************************************************************
egen rep_id = group(persona_encargada_proveedor)


* note: this code only needs to be executed when running the do-file for the first time
* this code creates a list of all the firms (one firm per row) and all their representatives (one column per rep)
* it then combines all potential within firm repname-repname combinations for their similarity to identify incorrect
* spellings based on string similarity >= 0.9
/*
preserve 

contract firmid rep_id persona_encargada_proveedor
drop _freq
bysort firmid (persona_encargada_proveedor) : gen firm_rep_id = sum(persona_encargada_proveedor != persona_encargada_proveedor[_n-1])
drop rep_id
reshape wide persona_encargada_proveedor, i(firmid) j(firm_rep_id)

/*
local i = 2
forvalues x = 1(1)24 {
	matchit persona_encargada_proveedor`x' persona_encargada_proveedor`i', gen(score`x'`i')
	local ++i
	}
*/	
local i = 1
forvalues first  = 1(1)24 {
		local ++i
forvalues second = `i'(1)25 {
	matchit persona_encargada_proveedor`first' persona_encargada_proveedor`second', gen(score`first'`second')
	}
}


/*
1 
23456
2
346789	
*/

	* remove all 1 due to missing values
foreach x of varlist score12-score2425 {
	replace `x' = . if `x' == 1
}

	* create per firms maxscore
egen maxscore = rowmax(score12-score2425)

	* identify potential problematic cases
br persona_encargada_proveedor* if maxscore >= 0.9

restore
*/

* drop remaining inconsistent spellings
* left
local correct_names `" "minor ramirez marin" "maria gabriela duran solis" "jonathan mariÑo  g" "genaro camacho elizondo" "auxiliadora alfaro ortega" "'

*right
local incorrect_names `" "minor ramirez mariz" "maria gabriela duran solis." "jonathan mariÑo g" "jenaro camacho elizondo" " "maria auxiliadora alfaro ortega" "'

local n : word count `correct_names'

forvalues i = 1/`n' {
	local a : word `i' of `correct_names'
	local b : word `i' of `incorrect_names'
	replace persona_encargada_proveedor = "`a'" if persona_encargada_proveedor == "`b'"
	
}

*/

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
save "${ppg_final}/sicop_final", replace
erase "${ppg_intermediate}/sicop_replicable.dta" /* erase intermediate file to save storage space */

