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
* 	5) 		number of representatives & dummy for single rep 				  	  
*	6) 		correct misspelled names
* 	7) 		correct missing gender codings																  															      
*	Author:  	Florian Muench						  
*	ID variable: 	process level id = id ; firm level id = firmid			  					  
*	Requires: 	  								  
*	Creates:  			                          
*																	  
***********************************************************************
* 	PART 1:  Make all string obs lower case & remove trailing spaces  			
***********************************************************************
use "${ppg_intermediate}/sicop_replicable", clear
	
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
replace `x'= strutrun(strtrim(lower(`x')))
}

***********************************************************************
* 	PART 2:  Encode categorical variables		  			
***********************************************************************
		* firm size dummy
lab def fsize 1 "micro" 2 "pequeña" 3 "mediana" 4 "grande" 5 "no clasificado"
encode tipo_empresa, gen(firm_size) label(fsize)
lab var firm_size "micro, small, medium, large or unclassified firm"


***********************************************************************
* 	PART 3:  Replace string with numeric values		  			
***********************************************************************
	* q391: ventes en export 
*replace q391_corrige = "254000000" if id == "f247"
replace female_firm = 0 if firmid == 7 & persona_encargada_proveedor == "luis gonzalez mora"
replace genderfo = 0 if firmid == 7 & persona_encargada_proveedor == "luis gonzalez mora"

***********************************************************************
* 	PART 4:  Code missing gender values	
***********************************************************************
* export Excel file with all the different values of female_firm per firm
/*
preserve
contract firmid nombre_proveedor persona_encargada_proveedor female_firm
format %40s nombre_proveedor persona_encargada_proveedor
sort firmid female_firm persona_encargada_proveedor
	* 382 missing values
cd "$ppg_intermediate"
export excel using missing_names if female_firm == ., replace firstrow(var)
	* import excel with missing names gender coded
import excel using missing_names_coded, clear firstrow
tempfile missings_coded
save "`missings_coded'"
restore
*/

* merge m:1 firmid persona_encargada_proveedor using missings_coded, replace update



***********************************************************************
* 	PART 5:  Correct spelling of firm representatives
***********************************************************************
	* redo some basic cleaning
		* sort & format
sort firmid persona_encargada_proveedor
format %30s nombre_proveedor persona_encargada_proveedor

		* gen variable to check whether less unique values of firm representation
bysort persona_encargada_proveedor: gen oldn = _N
codebook oldn
			* suggest 692 rep names
		* lower, remove trailing blanks
local person persona_encargada_proveedor
replace `person' = stritrim(strtrim(lower(`person')))
tempvar newn
bysort `person': gen `newn' = _N
codebook `newn'
			* still 692 firm reps despite 2944 changes

	
	* export rep-firm combinations to identify obs that need to be changed
/*
preserve
	
	* drop the firms with juste one representative over whole time period
drop if never_change == 1
			* 360,812 obs deleted		
	* only keep one line per firm-representative pair as other data too big
contract firmid persona_encargada_proveedor
codebook firmid
codebook persona_encargada_proveedor
format %-40s persona_encargada_proveedor
duplicates tag firmid, gen(dupfirm)
drop if dupfirm == 0
		* 8661 firms remain, 10193 representatives

	* gen new id that is unique for firm-rep combi
gen id_firmrep = _n
cd "$ppg_intermediate"	

	* code for matchit
gen persona_encargada_proveedor1 = persona_encargada_proveedor[_n-1]
matchit persona_encargada_proveedor persona_encargada_proveedor1
*browse if similscore > 0.7
export excel firm_rep_combinations, replace firstrow(var)

restore
*/
codebook persona_encargada_proveedor 
			* suggest 10187 uniques values

	* correction based on manuel identification in Excel firm_rep_combinations
{
local person persona_encargada_proveedor
replace persona_encargada_proveedor = "victor cordero centeno" if persona_encargada_proveedor == "victor cordero centeo"
replace persona_encargada_proveedor = "wilder hererra galvez" if persona_encargada_proveedor == "wilder herrera galvez"
replace persona_encargada_proveedor = "allan villallobos cambronero" if persona_encargada_proveedor == "allan villalobos cambronero"
replace persona_encargada_proveedor = "liliana peÑa ovares" if persona_encargada_proveedor == "lilliana peÑa ovares"
replace persona_encargada_proveedor = "sussy soto mendez" if persona_encargada_proveedor == "susy soto mendez"
replace persona_encargada_proveedor = "rafael alberto gutierrez de piñeres rivera" if persona_encargada_proveedor == "rafael alberto gutierrez de piÑeres rivera"
replace persona_encargada_proveedor = "norman herrera portugues" if persona_encargada_proveedor == "norman herrera portuguez"
replace persona_encargada_proveedor = "emmanuel francisco barrantes avendaño" if persona_encargada_proveedor == "emmanuel francisco barrantes avendaÑo"
replace persona_encargada_proveedor = "jorge eduardo vásquez aguilar" if persona_encargada_proveedor == "jorge eduardo vásqiuez aguilar"
replace persona_encargada_proveedor = "erick koberg herrera" if persona_encargada_proveedor == "eric koberg herrera"
replace persona_encargada_proveedor = "michaelmauricio ledezma martnez" if persona_encargada_proveedor == "michaelmauricio ledezma nartnez"
replace persona_encargada_proveedor = "jose gregorio logiurato margiotta" if persona_encargada_proveedor == "jose gregorio logivrato margiotta"
replace persona_encargada_proveedor = "fernando ant.vega guillén" if persona_encargada_proveedor == "fernando ant. vega guillén"
replace persona_encargada_proveedor = "angel antonio godinez prado" if persona_encargada_proveedor == "angelantonio godinez prado"
replace persona_encargada_proveedor = "katherine wachsman canales" if persona_encargada_proveedor == "katherin wachsman canales"
replace persona_encargada_proveedor = "alfredo gallegos jimenez" if persona_encargada_proveedor == "alfredo gallegos jimrenez"
replace persona_encargada_proveedor = "yanori alfaro alvarez" if persona_encargada_proveedor == "yaunori alfaro alvarez"
drop if firmid == 4983 /* only numbers for names */
replace persona_encargada_proveedor = "henry matarrita alvarez" if persona_encargada_proveedor == "henry matarrita avarez"
replace persona_encargada_proveedor = "liliana varela salazar" if persona_encargada_proveedor == "liliana maria varela salazar"
replace persona_encargada_proveedor = "yorleny cambronero cubero" if persona_encargada_proveedor == "yorleni cambronero cubero"
replace persona_encargada_proveedor = "jose hernan acuña cervantes" if persona_encargada_proveedor == "jose hernan acuÑa cervantes"
replace persona_encargada_proveedor = "jose mariano alpizar arredondo" if persona_encargada_proveedor == "mariano alpizar arredondo"
replace persona_encargada_proveedor = "wolfgang sancho aviles" if persona_encargada_proveedor == "wolfang sancho aviles"
replace persona_encargada_proveedor = "abel adolfo herrera portuquez" if persona_encargada_proveedor == "abel adolfo herrera portuguez"
replace persona_encargada_proveedor = "carlos rodrigo gomez rodriguez" if persona_encargada_proveedor == "carlos gomez rodriguez"
replace persona_encargada_proveedor = "eladio bolaños villanea" if persona_encargada_proveedor == "eladio bolaÑos villanea"
replace persona_encargada_proveedor = "gerardo antonio umaña rojas" if persona_encargada_proveedor == "gerardo antonio umaÑa rojas"
replace persona_encargada_proveedor = "mauricio soto montero" if persona_encargada_proveedor == "mauricio soto monero"
replace persona_encargada_proveedor = "gustavo adolfo esquivel quirós" if persona_encargada_proveedor == "gustavo adolfo esquivel quiros"
replace persona_encargada_proveedor = "marjorie sibaja barrantes" if persona_encargada_proveedor == "marjorie subaja barrantes"
replace persona_encargada_proveedor = "josé emil de la rocha valverde" if persona_encargada_proveedor == "jose emil de la rocha valverde"
replace persona_encargada_proveedor = "ana del carmen vasquez peña" if persona_encargada_proveedor == "ana del carmen vasquez peÑa"
replace persona_encargada_proveedor = "victor hugo rodriguez varela" if persona_encargada_proveedor == "victgr hugo rodriguez varela"
replace persona_encargada_proveedor = "henry mauricio umaÑa perez" if persona_encargada_proveedor == "henry mauricio umaÑa p"
replace persona_encargada_proveedor = "rafael angel villalobos cascante" if persona_encargada_proveedor == "rafael villalobos cascante"
replace persona_encargada_proveedor = "luis andrés artavia salazar" if persona_encargada_proveedor == "luis andres artavia salazar"
replace persona_encargada_proveedor = "ana maría aguilar padilla" if persona_encargada_proveedor == "ana maria aguilar padilla"
replace persona_encargada_proveedor = "geovanni varela dijeres" if persona_encargada_proveedor == "giovanni varela dijeres"
replace persona_encargada_proveedor = "olivero guillermo miller perez" if persona_encargada_proveedor == "guillermo miller perez"
replace persona_encargada_proveedor = "maría giovana ortegon angel" if persona_encargada_proveedor == "maria giovana ortegon angel"
replace persona_encargada_proveedor = "carlos altamirano" if persona_encargada_proveedor == "carlos altamirano z."
replace persona_encargada_proveedor = "olga rivera monge" if persona_encargada_proveedor == "olga maria rivera monge"
replace persona_encargada_proveedor = "césar andrey quesada ortega" if persona_encargada_proveedor == "cesar andrey quesada ortega"
replace persona_encargada_proveedor = "mariano miranda perez" if persona_encargada_proveedor == "mariano mirando perez"
replace persona_encargada_proveedor = "carlos gerardo garcia araya" if persona_encargada_proveedor == "carlos garcia araya"
replace persona_encargada_proveedor = "samuel bermudez ureña" if persona_encargada_proveedor == "samuel bermudez ureÑa"
replace persona_encargada_proveedor = "jennifer gonzales amador" if persona_encargada_proveedor == "jennifer gonzalez amador"

}

replace persona_encargada_proveedor = "rafael cañas" if persona_encargada_proveedor == "rafael eduardo caÑas ruiz"
replace persona_encargada_proveedor = "efrain cespedes" if persona_encargada_proveedor == "efrain cespedes alpizar"

* still to code
replace persona_encargada_proveedor = "kattia selley gonzalez" if persona_encargada_proveedor == "kattia sellet gonzalez"
replace persona_encargada_proveedor = "jose hernan acuña cervantes" if persona_encargada_proveedor == "jose hernan acuÑa cervantes"
replace persona_encargada_proveedor = "jose mariano alpizar arredondo" if persona_encargada_proveedor == "mariano alpizar arredondo"
replace persona_encargada_proveedor = "wolfgang sancho aviles" if persona_encargada_proveedor == "wolfang sancho aviles"
replace persona_encargada_proveedor = "abel adolfo herrera portuquez" if persona_encargada_proveedor == "abel adolfo herrera portuguez"
replace persona_encargada_proveedor = "carlos rodrigo gomez rodriguez" if persona_encargada_proveedor == "carlos gomez rodriguez"
replace persona_encargada_proveedor = "eladio bolaños villanea" if persona_encargada_proveedor == "eladio bolaÑos villanea"
replace persona_encargada_proveedor = "gerardo antonio umaña rojas" if persona_encargada_proveedor == "gerardo antonio umaÑa rojas"
replace persona_encargada_proveedor = "mauricio soto montero" if persona_encargada_proveedor == "mauricio soto monero"
replace persona_encargada_proveedor = "gustavo adolfo esquivel quirós" if persona_encargada_proveedor == "gustavo adolfo esquivel quiros"
replace persona_encargada_proveedor = "marjorie sibaja barrantes" if persona_encargada_proveedor == "marjorie subaja barrantes"
replace persona_encargada_proveedor = "josé emil de la rocha valverde" if persona_encargada_proveedor == "jose emil de la rocha valverde"
replace persona_encargada_proveedor = "ana del carmen vasquez peña" if persona_encargada_proveedor == "ana del carmen vasquez peÑa"
replace persona_encargada_proveedor = "victor hugo rodriguez varela" if persona_encargada_proveedor == "victgr hugo rodriguez varela"
replace persona_encargada_proveedor = "henry mauricio umaÑa perez" if persona_encargada_proveedor == "henry mauricio umaÑa p"
replace persona_encargada_proveedor = "rafael angel villalobos cascante" if persona_encargada_proveedor == "rafael villalobos cascante"
replace persona_encargada_proveedor = "luis andrés artavia salazar" if persona_encargada_proveedor == "luis andres artavia salazar"
replace persona_encargada_proveedor = "ana maría aguilar padilla" if persona_encargada_proveedor == "ana maria aguilar padilla"
replace persona_encargada_proveedor = "geovanni varela dijeres" if persona_encargada_proveedor == "giovanni varela dijeres"
replace persona_encargada_proveedor = "olivero guillermo miller perez" if persona_encargada_proveedor == "guillermo miller perez"
replace persona_encargada_proveedor = "maría giovana ortegon angel" if persona_encargada_proveedor == "maria giovana ortegon angel"
replace persona_encargada_proveedor = "carlos altamirano" if persona_encargada_proveedor == "carlos altamirano z."
replace persona_encargada_proveedor = "olga rivera monge" if persona_encargada_proveedor == "olga maria rivera monge"
replace persona_encargada_proveedor = "césar andrey quesada ortega" if persona_encargada_proveedor == "cesar andrey quesada ortega"
replace persona_encargada_proveedor = "mariano miranda perez" if persona_encargada_proveedor == "mariano mirando perez"
replace persona_encargada_proveedor = "carlos gerardo garcia araya" if persona_encargada_proveedor == "carlos garcia araya"
replace persona_encargada_proveedor = "samuel bermudez ureña" if persona_encargada_proveedor == "samuel bermudez ureÑa"
replace persona_encargada_proveedor = "jennifer gonzales amador" if persona_encargada_proveedor == "jennifer gonzalez amador"

* to see the different representative names per firm (sometimes better to use "tab" if firm has many representatives)
codebook persona_encargada_proveedor if firmid == 4746

tempvar newn
bysort `person': gen `newn' = _N
codebook `newn'
	
***** deep clean the remaining strings
		* eyeball the data
			/* 
examples of misspellings:
		* case type 1: parts of the name forgotten
firmid = 40 natalia de los angeles campos rojas vs natalia campos rojas
firmid = 137 jeannette patricia ferencz mainemer vs. jeannette ferencz
firmid = 210 manuel antonio valverde huertas vs manuel valverde huertas
firmid = 230 erika maria espinoza ramirez vs erka maria espinoa ramirez
firmid = 276 nikolay dobrev gandev georgieva vs nikolay gandev
firmid = 289 brayner carvajal prado vs bryan carvajal prado
firmid = 400 esteban
firmid = 467 alvaro
firmid = 486 alicia
firmid = 573
firmid = 625
...
firmid = 8587 walter
firmid = 8628 katherine
firmid = 8660 denis + adrian

		* case type 2: special characters
firmid = 400 cesar andrey quesada ortega vs. césar andrey quesada ortega
firmid = 480 eladio bolaÑos villanea vs. eladio bolaños villanea
firmid = 581
			
			*/

	

***********************************************************************
* 	PART 4:  Convert string to numerical variables	  			
***********************************************************************
/*foreach x of global numvarc {
destring `x', replace
format `x' %25.0fc
}
*/

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************

save "sicop_replicable", replace
