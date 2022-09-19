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
* 	PART 0:  Import data
***********************************************************************
use "${ppg_intermediate}/sicop_replicable", clear

***********************************************************************
* 	PART 1:  Drop observations with missing bidder name
***********************************************************************
* note that in the 47,073 cases we also miss data for amount, points, evaluation criteria
	* which suggests that the processes were actually never completed
drop if nombre_proveedor == ""


***********************************************************************
* 	PART 2:  Make all string obs lower case & remove trailing spaces  			
***********************************************************************
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
replace `x'= stritrim(strtrim(lower(`x')))
}


***********************************************************************
* 	PART 3:  Code missing firm representative gender values	
***********************************************************************
* export Excel file with all the different values of female_firm per firm
/*
preserve
contract persona_encargada_proveedor genderfo
	* 382 missing values
cd "$ppg_intermediate"
export excel using missing_names if genderfo == ., replace firstrow(var)
restore
*/

preserve
	* import excel with missing names gender coded
	import excel using "${ppg_gender_lists}/missing_names_coded.xlsx", firstrow case(preserve) clear
	duplicates drop persona_encargada_proveedor, force
	rename female_firm genderfo
	lab var genderfo ""
	drop nombre_proveedor firmid
	format persona_encargada_proveedor %-50s
	save "${ppg_gender_lists}/missing_names_coded", replace
restore

merge m:1 persona_encargada_proveedor using "${ppg_gender_lists}/missing_names_coded", update replace
/*
   Result                           # of obs.
    -----------------------------------------
    not matched                       996,043
        from master                   996,043  (_merge==1)
        from using                          0  (_merge==2)

    matched                             5,244
        not updated                     2,486  (_merge==3)
        missing updated                 2,729  (_merge==4)
        nonmissing conflict                29  (_merge==5)
    -----------------------------------------
*/
drop _merge

	* make manual corrections for conflicting merge results
replace genderfo = 1 if persona_encargada_proveedor == "kenny granados hodgson"
replace genderfo = 0 if persona_encargada_proveedor == "luis gonzalez mora"


***********************************************************************
* 	PART 5: Correct misspelling of firm representatives
***********************************************************************	
	* correct non-sensical names
list persona_encargada_proveedor if regexm(persona_encargada_proveedor, "representante") == 1

local non_sensical_names `" "socios" "representante 1" "representante" "'
foreach name of local non_sensical_names {
	replace persona_encargada_proveedor = regexr(persona_encargada_proveedor, "`name'", "")
}
	* correct names that are numbers
replace persona_encargada_proveedor = regexr(persona_encargada_proveedor, "[0-9]+", "")

	* adjust gender as missing for wrong firm rep names
replace genderfo = . if persona_encargada_proveedor == ""
			
	* correction based on manuel identification in Excel firm_rep_combinations
{
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
replace persona_encargada_proveedor = "kattia selley gonzalez" if persona_encargada_proveedor == "kattia sellet gonzalez"
replace persona_encargada_proveedor = "pal selley gonzalez" if persona_encargada_proveedor == "eng.pal selley" | persona_encargada_proveedor == "pal z selley gonzalez"
replace persona_encargada_proveedor = "jose mariano alpizar arredondo" if persona_encargada_proveedor == "mariano alpizar arredondo"
replace persona_encargada_proveedor = "jessica maria fonseca ureÑa" if persona_encargada_proveedor == "jessica fonseca ureÑa"
replace persona_encargada_proveedor = "carlos abel corrales lopez" if persona_encargada_proveedor == "carlos abel corrales lópez"
replace persona_encargada_proveedor = "carlos rodrigo gomez rodriguez" if persona_encargada_proveedor == "carlos gomez rodriguez"
replace persona_encargada_proveedor = "carlos eduardo calvo alvarado" if persona_encargada_proveedor == "carlos calvo alvarado"
replace persona_encargada_proveedor = "roger alberto cubero cascante" if persona_encargada_proveedor == "roger cubero cascante"
replace persona_encargada_proveedor = "erika maria espinoza ramirez" if persona_encargada_proveedor == "erka maria espinoa ramirez"
replace persona_encargada_proveedor = "olger axel mejias valenciano" if persona_encargada_proveedor == "olger mejias valenciano"
replace persona_encargada_proveedor = "karla calderón barquero" if persona_encargada_proveedor == "karla calderon barquero"
replace persona_encargada_proveedor = "monica maría hernandez roa" if persona_encargada_proveedor == "monica maria hernandez roa"
replace persona_encargada_proveedor = "alejandrina gutiérrez ortega" if persona_encargada_proveedor == "alejandrina gutierrez ortega"
replace persona_encargada_proveedor = "luis carlos sojo quirós" if persona_encargada_proveedor == "luis carlos sojo quiros"
replace persona_encargada_proveedor = "kathia valverde aguilar" if persona_encargada_proveedor == "kattia valverde aguilar"
replace persona_encargada_proveedor = "giovanni valentin cavallini barquero" if persona_encargada_proveedor == "giovanni cavallini barquero"
replace persona_encargada_proveedor = "viviana allon zuñiga" if persona_encargada_proveedor == "viviana allon zuÑiga"
replace persona_encargada_proveedor = "lester saldaña r." if persona_encargada_proveedor == "lester saldaña"
replace persona_encargada_proveedor = "alvaro vinicio alfaro montero" if persona_encargada_proveedor == "alvaro alfaro montero"
replace persona_encargada_proveedor = "raquel madrigal ramirez" if persona_encargada_proveedor == "raquel madrigal ramírez"
replace persona_encargada_proveedor = "jorge luis caballero garcía" if persona_encargada_proveedor == "jorge luis caballero garcia"
replace persona_encargada_proveedor = "josé enrique quant rojas" if persona_encargada_proveedor == "jose enrique quant rojas"
replace persona_encargada_proveedor = "randy gordon cruickshank" if persona_encargada_proveedor == "randy anthony gordon cruickshank"
replace persona_encargada_proveedor = "grettel trejos avila" if persona_encargada_proveedor == "grethel trejos avila"
replace persona_encargada_proveedor = "marco solano zuñiga" if persona_encargada_proveedor == "marco solano zuÑiga"
replace persona_encargada_proveedor = "randall enrique fallas villalta" if persona_encargada_proveedor == "randall fallas villalta"
replace persona_encargada_proveedor = "minor alonso santana solano" if persona_encargada_proveedor == "minor santana solano"
replace persona_encargada_proveedor = "roberto jose suarez castro" if persona_encargada_proveedor == "roberto suarez castro"
replace persona_encargada_proveedor = "franscinie brenes gonzalez" if persona_encargada_proveedor == "franscinie brenes gonzÁlez"
replace persona_encargada_proveedor = "geovanna ventura quirós barrantes" if persona_encargada_proveedor == "geovanna quirós barrantes"
replace persona_encargada_proveedor = "marlon sanchez gonzalez" if persona_encargada_proveedor == "marlon hairo sanchez gonzalez"
replace persona_encargada_proveedor = "enid cordero quiros" if persona_encargada_proveedor == "enis cordero quiros"
replace persona_encargada_proveedor = "julio cardenas acosta" if persona_encargada_proveedor == "juliomcardenas acosta"
replace persona_encargada_proveedor = "mauricio muñoz vieto" if persona_encargada_proveedor == "mauricio muÑoz vieto"
replace persona_encargada_proveedor = "carlos calvo ureña" if persona_encargada_proveedor == "carlos calvo ureÑa"
replace persona_encargada_proveedor = "anthony fallas ureña" if persona_encargada_proveedor == "anthony fallas ureÑa"
replace persona_encargada_proveedor = "jorge arturo león rojas" if persona_encargada_proveedor == "jorge arturo leon rojas"
replace persona_encargada_proveedor = "julio cesar cardenas acosta" if persona_encargada_proveedor == "julio cardenas acosta"
replace persona_encargada_proveedor = "jonathan flores ramírez" if persona_encargada_proveedor == "jonathan flores ramirez"
replace persona_encargada_proveedor = "jorge valverde aguero" if persona_encargada_proveedor == "jorge hernan valverde aguero"
replace persona_encargada_proveedor = "alexis daniel sandoval cabezas" if persona_encargada_proveedor == "alexis sandoval cabezas"
replace persona_encargada_proveedor = "walter rolando solano pessoa" if persona_encargada_proveedor == "walter solano pessoa"
replace persona_encargada_proveedor = "oscar ignacio vergara muÑoz" if persona_encargada_proveedor == "oscar ignacio vergara mu¥oz"
replace persona_encargada_proveedor = "guillermo humberto vado caldera" if persona_encargada_proveedor == "guillermo vado caldera"
replace persona_encargada_proveedor = "cinthya rojas muñoz" if persona_encargada_proveedor == "cinthya rojas muÑoz"
replace persona_encargada_proveedor = "maria gabriela duran solis." if persona_encargada_proveedor == "gabriela duran solis"
replace persona_encargada_proveedor = "olga dinia quesada rojas" if persona_encargada_proveedor == "olga quesada rojas"
replace persona_encargada_proveedor = "deivy chinchilla mora" if persona_encargada_proveedor == "deivy josue chinchilla mora"
replace persona_encargada_proveedor = "constancio umana arroyo" if persona_encargada_proveedor == "constancio umaÑa arroyo"
replace persona_encargada_proveedor = "juan josé navarro zamora" if persona_encargada_proveedor == "juan jose navarro zamora"
replace persona_encargada_proveedor = "christian córdoba gamboa" if persona_encargada_proveedor == "christian cordoba gamboa"
replace persona_encargada_proveedor = "ricardo bonilla martín" if persona_encargada_proveedor == "ricardo bonilla martin"
replace persona_encargada_proveedor = "kenneth mena godínez" if persona_encargada_proveedor == "kenneth mena godinez"
replace persona_encargada_proveedor = "edier valverde ramÍrez" if persona_encargada_proveedor == "edier valverde ramirez"
replace persona_encargada_proveedor = "josé rafael salas molina" if persona_encargada_proveedor == "jose rafael salas molina"
replace persona_encargada_proveedor = "carlos castillo madrigal" if persona_encargada_proveedor == "carlos alberto castillo madrigal"
replace persona_encargada_proveedor = "renso andres solerti gonzalez" if persona_encargada_proveedor == "renso solerti gonzalez"
replace persona_encargada_proveedor = "alicia patricia murillo soto" if persona_encargada_proveedor == "alicia murillo soto"
replace persona_encargada_proveedor = "vanessa rocio monge paniagua" if persona_encargada_proveedor == "vanessa monge paniagua"
replace persona_encargada_proveedor = "benjamin pineda avila" if persona_encargada_proveedor == "benjamin pineda Ávila"
replace persona_encargada_proveedor = "william calderón rojas" if persona_encargada_proveedor == "william calderon rojas"
replace persona_encargada_proveedor = "miguel antonio hernandez mendez" if persona_encargada_proveedor == "miguel hernandez mendez"
replace persona_encargada_proveedor = "luis rolando durán jiménez" if persona_encargada_proveedor == "luis rolando durán jiméenz"
replace persona_encargada_proveedor = "rodolfo enrique herrera barrantes" if persona_encargada_proveedor == "rodolfo herrera barrantes"
replace persona_encargada_proveedor = "gabriela virginia bonilla cerdas" if persona_encargada_proveedor == "gabriela bonilla cerdas"
replace persona_encargada_proveedor = "ingrid maria flores sanchez" if persona_encargada_proveedor == "ingrid flores sanchez"
replace persona_encargada_proveedor = "olga maria cruz molina" if persona_encargada_proveedor == "olga cruz molina"
replace persona_encargada_proveedor = "eliecer jesus chacon villegas" if persona_encargada_proveedor == "eliecer chacon villegas"
replace persona_encargada_proveedor = "carlos zamora villalobos" if persona_encargada_proveedor == "carlos alberto zamora villalobos"
replace persona_encargada_proveedor = "gerardo froilan morales martinez" if persona_encargada_proveedor == "gerardo morales martinez"
replace persona_encargada_proveedor = "sergio antonio canossa jimenez" if persona_encargada_proveedor == "sergio canossa jimenez"
replace persona_encargada_proveedor = "gustavo adolfo porras cordero" if persona_encargada_proveedor == "gustavo porras cordero"
replace persona_encargada_proveedor = "mauricio vega salazar" if persona_encargada_proveedor == "mauricio antonio vega salazar"
replace persona_encargada_proveedor = "emy soraya jimenez martinez" if persona_encargada_proveedor == "emy jiménez martínez"
replace persona_encargada_proveedor = "luis ricardo mora díaz" if persona_encargada_proveedor == "luis ricardo mora diaz"
replace persona_encargada_proveedor = "gustavo adolfo mora solera" if persona_encargada_proveedor == "gustavo mora solera"
replace persona_encargada_proveedor = "manuel antonio valverde huertas" if persona_encargada_proveedor == "manuel valverde huertas"
replace persona_encargada_proveedor = "freddy gerardo hernandez chevez" if persona_encargada_proveedor == "freddy hernandez chevez"
replace persona_encargada_proveedor = "julio cesar azofeifa montero" if persona_encargada_proveedor == "julio azofeifa montero"
replace persona_encargada_proveedor = "adrian alberto herrera ramos" if persona_encargada_proveedor == "adrian herrera ramos"
replace persona_encargada_proveedor = "denis zuniga" if persona_encargada_proveedor == "denis arnaldo zuniga aplicano"
replace persona_encargada_proveedor = "rayford andres sanchez loria" if persona_encargada_proveedor == "rayford sanchez loria"
replace persona_encargada_proveedor = "randall jose moya gutierrez" if persona_encargada_proveedor == "randall j. moya gutierrez"
replace persona_encargada_proveedor = "sugey cascante rodríguez" if persona_encargada_proveedor == "sugey casacnte rodríguez"
replace persona_encargada_proveedor = "francisco javier saborio carro" if persona_encargada_proveedor == "francisco saborio carro"
replace persona_encargada_proveedor = "jorge estuardo menendez guardia" if persona_encargada_proveedor == "alicia murillo soto"
replace persona_encargada_proveedor = "vanessa rocio monge paniagua" if persona_encargada_proveedor == "vanessa monge paniagua"
replace persona_encargada_proveedor = "ileana maritza gutierrez badilla" if persona_encargada_proveedor == "ileana gutierrez badilla"
replace persona_encargada_proveedor = "andres gerardo benavides murillo" if persona_encargada_proveedor == "andres benavides murillo"
replace persona_encargada_proveedor = "miguel antonio hernandez mendez" if persona_encargada_proveedor == "miguel hernandez mendez"
replace persona_encargada_proveedor = "emilda pizarro méndez" if persona_encargada_proveedor == "emilda pizarro mendez"
replace persona_encargada_proveedor = "enrique somogyi pérez" if persona_encargada_proveedor == "enrique somogyi perez"
replace persona_encargada_proveedor = "pablo urizar cartín" if persona_encargada_proveedor == "pablo urizar cartin"
replace persona_encargada_proveedor = "jozabad aaron vargas mora" if persona_encargada_proveedor == "jozabad vargas mora"
replace persona_encargada_proveedor = "ricardo prudencio menendez mendez" if persona_encargada_proveedor == "ricardo menendez"
replace persona_encargada_proveedor = "carlos federico soto castro" if persona_encargada_proveedor == "federico soto castro"
replace persona_encargada_proveedor = "maria edith campos vasquez" if persona_encargada_proveedor == "maría edith campos vásquez"
replace persona_encargada_proveedor = "luis barboza castrillo" if persona_encargada_proveedor == "luis emilio barboza castrillo"
replace persona_encargada_proveedor = "allan manuel quiros mejias" if persona_encargada_proveedor == "allan quiros mejias"
replace persona_encargada_proveedor = "william valerio montero" if persona_encargada_proveedor == "william eduardo valerio montero"
replace persona_encargada_proveedor = "mauricio vega salazar" if persona_encargada_proveedor == "mauricio antonio vega salazar"
replace persona_encargada_proveedor = "edgar antonio meseguer armijo" if persona_encargada_proveedor == "edgar meseguer armijo"
replace persona_encargada_proveedor = "manuel enrique fernandez vaglio" if persona_encargada_proveedor == "manuel fernandez vaglio"
replace persona_encargada_proveedor = "hugo poltronieri trejos" if persona_encargada_proveedor == "hugo enrique poltronieri trejos"
replace persona_encargada_proveedor = "marvin gerardo rodriguez esquivel" if persona_encargada_proveedor == "marvin rodriguez esquivel"
replace persona_encargada_proveedor = "andres clarke holman" if persona_encargada_proveedor == "andres clarke h"
replace persona_encargada_proveedor = "mario francisco granados masis" if persona_encargada_proveedor == "mario granados masis"
replace persona_encargada_proveedor = "mario humberto garbanzo mendez" if persona_encargada_proveedor == "mario garbanzo mendez"
replace persona_encargada_proveedor = "roy sandino gonzález" if persona_encargada_proveedor == "roy sandino gonzalez"
replace persona_encargada_proveedor = "melvin antonio salas sanchez" if persona_encargada_proveedor == "melvin salas sanchez"
replace persona_encargada_proveedor = "carlos alberto rojas hernandez" if persona_encargada_proveedor == "carlos rojas hernandez"
replace persona_encargada_proveedor = "minor ramirez mariz" if persona_encargada_proveedor == "minor alexis ramirez marin"
replace persona_encargada_proveedor = "jorge mora flores" if persona_encargada_proveedor == "jorge emilio mora flores"
replace persona_encargada_proveedor = "silvia sequeria rojas" if persona_encargada_proveedor == "silvia sequeira rojas"
replace persona_encargada_proveedor = "doris carrillo lopez" if persona_encargada_proveedor == "doris patricia carrillo lopez"
replace persona_encargada_proveedor = "andrés mariano gurdian rivera" if persona_encargada_proveedor == "andrés mariano gurdian bond" | persona_encargada_proveedor == "andres mariano gurdian rivera"
replace persona_encargada_proveedor = "erlín gómez rodríguez" if persona_encargada_proveedor == "erlín gómezrpdríguez"
replace persona_encargada_proveedor = "dixie maria castro mena" if persona_encargada_proveedor == "dixie castro mena"
replace persona_encargada_proveedor = "irene vargas butz" if persona_encargada_proveedor == "irene maria vargas butz"
replace persona_encargada_proveedor = "gilberto eduardo chaves mesen" if persona_encargada_proveedor == "gilberto chaves mesen"
replace persona_encargada_proveedor = "rodolfo humberto jimenez granados" if persona_encargada_proveedor == "rodolfo jimenez granados"
replace persona_encargada_proveedor = "larry gabriela sevilla carvajal" if persona_encargada_proveedor == "gsbriela sevilla carvajal"
replace persona_encargada_proveedor = "jimmy jimenez huertas" if persona_encargada_proveedor == "jimmy antonio jimenez huertas"
replace persona_encargada_proveedor = "ricardo sosa herrera" if persona_encargada_proveedor == "ricardo manuel sosa herrera"
replace persona_encargada_proveedor = "luis matamoros gonzalez" if persona_encargada_proveedor == "luis eduardo matamoros gonzalez"
replace persona_encargada_proveedor = "ester molina figuls" if persona_encargada_proveedor == "estercita molina figuls"
replace persona_encargada_proveedor = "henry nunez morales" if persona_encargada_proveedor == "henry nuÑez morales"
replace persona_encargada_proveedor = "dahianna rodriguez moya" if persona_encargada_proveedor == "dahiana rodríguez moya"
replace persona_encargada_proveedor = "john jairo ortiz bedoya" if persona_encargada_proveedor == "jhon jairo ortiz bedoya"
replace persona_encargada_proveedor = "maureen mendoza sanchez" if persona_encargada_proveedor == "maureen patricia mendoza sanchez"
replace persona_encargada_proveedor = "christian campos monge" if persona_encargada_proveedor == "christian enrique campos monge"
replace persona_encargada_proveedor = "leonardo paniagua martinez" if persona_encargada_proveedor == "leonardo paniagua m"
replace persona_encargada_proveedor = "leonel alvarez moya" if persona_encargada_proveedor == "leonel alberto alvarez moya"
replace persona_encargada_proveedor = "jorge raul vazquez" if persona_encargada_proveedor == "jorge raul vazquez novoa"
replace persona_encargada_proveedor = "yuan chi li" if persona_encargada_proveedor == "yuan chih li"
replace persona_encargada_proveedor = "luis rodolfo bucknor masis" if persona_encargada_proveedor == "luis rodolfo ruchnor masis"
replace persona_encargada_proveedor = "melvin fernandez ramirez" if persona_encargada_proveedor == "melvin mauricio fernandez ramirez"
replace persona_encargada_proveedor = "rubén lezama ulate" if persona_encargada_proveedor == "ruben lezama ulate"
replace persona_encargada_proveedor = "allan navarro araya" if persona_encargada_proveedor == "allan francisco navarro araya"
replace persona_encargada_proveedor = "carla yenci cordero aguilar" if persona_encargada_proveedor == "karla cordero aguilar"
replace persona_encargada_proveedor = "ninotchka mora corrales" if persona_encargada_proveedor == "ninoskcha mora corrales"
replace persona_encargada_proveedor = "christhiam gomez monge" if persona_encargada_proveedor == "christhima gomez monge"
replace persona_encargada_proveedor = "pedro alexander naranjo solano" if persona_encargada_proveedor == "pedro naranjo solano"
replace persona_encargada_proveedor = "edgar alvarado ardón" if persona_encargada_proveedor == "edgar eduardo alvarado ardon"
replace persona_encargada_proveedor = "katherine viviana navarro castillo" if persona_encargada_proveedor == "katherine navarro castillo"
replace persona_encargada_proveedor = "pablo espinoza saenz" if persona_encargada_proveedor == "pablo javier espinoza saenz"
replace persona_encargada_proveedor = "lester jose sanchez robleto" if persona_encargada_proveedor == "lesther sanchez robleto"
replace persona_encargada_proveedor = "anthony cascante ramirez" if persona_encargada_proveedor == "anthony cascante"
replace persona_encargada_proveedor = "rolando diaz ruiz" if persona_encargada_proveedor == "rolando antonio diaz ruiz"
replace persona_encargada_proveedor = "hazel sibaja briceño" if persona_encargada_proveedor == "hazel dayana sibaja briceÑo"
replace persona_encargada_proveedor = "eloy vidal ortega" if persona_encargada_proveedor == "eloy alberto vidal ortega"
replace persona_encargada_proveedor = "alvaro fernando jirón garcía" if persona_encargada_proveedor == "alvaro fernando jiron garcia"
replace persona_encargada_proveedor = "ariana marcela solano martinez" if persona_encargada_proveedor == "ariana solano martínez"
replace persona_encargada_proveedor = "marisol munoz" if persona_encargada_proveedor == "marisol muÑoz" | persona_encargada_proveedor == "mariosol muÑo"
replace persona_encargada_proveedor = "rafael cañas" if persona_encargada_proveedor == "rafael eduardo caÑas ruiz"
replace persona_encargada_proveedor = "efrain cespedes" if persona_encargada_proveedor == "efrain cespedes alpizar"
replace persona_encargada_proveedor = "hector enrique chinchilla" if persona_encargada_proveedor == "hector chinchilla"
replace persona_encargada_proveedor = "katherine garro bolaños" if persona_encargada_proveedor == "katherin garro bolaÑos"
replace persona_encargada_proveedor = "jose joaquin sanabria aguilar" if persona_encargada_proveedor == "josé joaquín sanabria aguilar"
replace persona_encargada_proveedor = "linda lopez alezard" if persona_encargada_proveedor == "linda consuelo lopez alezard"
replace persona_encargada_proveedor = "edgar mauricio hernandez araya" if persona_encargada_proveedor == "edgar hernández araya"
replace persona_encargada_proveedor = "raul felipe angulo cruz" if persona_encargada_proveedor == "raul angulo cruz"
replace persona_encargada_proveedor = "adrian alonso rojas goÑi" if persona_encargada_proveedor == "adrian rojas goÑi"
replace persona_encargada_proveedor = "carlos eduardo calvo alvarado" if persona_encargada_proveedor == "lic. carlos calvo alvarado"
replace persona_encargada_proveedor = "jose eugenio raudes torres" if persona_encargada_proveedor == "jose raudes torres"
replace persona_encargada_proveedor = "manuel fallas solera" if persona_encargada_proveedor == "manuel eduardo fallas solera"
replace persona_encargada_proveedor = "chrstian montero alvarez" if persona_encargada_proveedor == "christian jesus montero alvarez"
replace persona_encargada_proveedor = "helmuth ajun murillo" if persona_encargada_proveedor == "helmuth santiago ajun murillo"
replace persona_encargada_proveedor = "graciela del carmen tuckler mejia" if persona_encargada_proveedor == "graciela tuckler mejia"
replace persona_encargada_proveedor = "jose steinkoler" if persona_encargada_proveedor == "jose steinkoler kasner"
replace persona_encargada_proveedor = "javier apestegui arias" if persona_encargada_proveedor == "francisco javier apestegui arias"
replace persona_encargada_proveedor = "alvaro orlando perez moya" if persona_encargada_proveedor == "alvaro perez moya"
replace persona_encargada_proveedor = "ricardo brenes" if persona_encargada_proveedor == "ricardo andres brenes brenes"
replace persona_encargada_proveedor = "jonathan mariÑo  g" if persona_encargada_proveedor == "jonathan mariÑo gonzalez"
replace persona_encargada_proveedor = "ronny torentes vega" if persona_encargada_proveedor == "ronny alberto torrentes vega"
replace persona_encargada_proveedor = "gerald zuÑiga sibaja" if persona_encargada_proveedor == "gerald mauricio zuÑiga sibaja"
replace persona_encargada_proveedor = "kathya bejarano v." if persona_encargada_proveedor == "kathya bejarano valerin"
replace persona_encargada_proveedor = "erick varela c" if persona_encargada_proveedor == "erick varela cabezas"
replace persona_encargada_proveedor = "carlos altamirano z." if persona_encargada_proveedor == "carlos omar altamirano zamora"
replace persona_encargada_proveedor = "adrian mauricio wilson somarribas" if persona_encargada_proveedor == "adrián wilson somarribas"
replace persona_encargada_proveedor = "jiefeng wu" if persona_encargada_proveedor == "jiefen wu"
replace persona_encargada_proveedor = "luis fernando leal arrieta" if persona_encargada_proveedor == "luis fernando leal"
replace persona_encargada_proveedor = "josé pablo quesada chavarría" if persona_encargada_proveedor == "jose pablo quesada chavarria"
replace persona_encargada_proveedor = "josé miguel díaz miranda" if persona_encargada_proveedor == "jose miguel diaz miranda"
replace persona_encargada_proveedor = "andré navarrete alvarez" if persona_encargada_proveedor == "andre mauricio navarrete alvarez"
replace persona_encargada_proveedor = "erick umaña romero" if persona_encargada_proveedor == "erick ricardo umaÑa romero"
replace persona_encargada_proveedor = "andre ruiz campos" if persona_encargada_proveedor == "andre maritza ruiz campos"
replace persona_encargada_proveedor = "jimmy enrique ramos corea" if persona_encargada_proveedor == "jimmy ramos corea"
replace persona_encargada_proveedor = "andrew mark irwin" if persona_encargada_proveedor == "andrew mark irwin tickton"
replace persona_encargada_proveedor = "elban jose ramirez peraza" if persona_encargada_proveedor == "elban josé ramírez peraza"
replace persona_encargada_proveedor = "oscar efraín gómez gamboa" if persona_encargada_proveedor == "oscar efrain gomez gamboa"
replace persona_encargada_proveedor = "jorge villalobos rodríguez" if persona_encargada_proveedor == "jorge diego villalobos rodriguez"
replace persona_encargada_proveedor = "maria edith campos vasquez" if persona_encargada_proveedor == "maría edith campos vásquez"
replace persona_encargada_proveedor = "luis barboza castrillo" if persona_encargada_proveedor == "luis emilio barboza castrillo"
replace persona_encargada_proveedor = "laura sibaja rodriguez" if persona_encargada_proveedor == "laura sibaja r"
replace persona_encargada_proveedor = "kembly aguilar" if persona_encargada_proveedor == "kembly aguilar chaves"
replace persona_encargada_proveedor = "jason francisco chaves arroyo" if persona_encargada_proveedor == "jason chaves arroyo"
replace persona_encargada_proveedor = "jimmy alexander mora espinoza" if persona_encargada_proveedor == "jimmy mora espinoza"
replace persona_encargada_proveedor = "andres quintana" if persona_encargada_proveedor == "andres jesus quintana espino"
replace persona_encargada_proveedor = "angélica vargas rodríguez" if persona_encargada_proveedor == "angelica vargas rodriguez"
replace persona_encargada_proveedor = "cristian zuÑiga picado" if persona_encargada_proveedor == "cristian zúñiga picado"
replace persona_encargada_proveedor = "andrés mariano gurdian rivera" if persona_encargada_proveedor == "andres mariano gurdian rivera"
replace persona_encargada_proveedor = "andrés mariano gurdian rivera" if persona_encargada_proveedor == "andrés mariano gurdian bond"
replace persona_encargada_proveedor = "katia golcher barguil" if persona_encargada_proveedor == "katiagÓlcher barguil"
replace persona_encargada_proveedor = "marco vargas zuñiga" if persona_encargada_proveedor == "marco antonio vargas zuÑiga"
replace persona_encargada_proveedor = "xenia rojas martinez" if persona_encargada_proveedor == "xenia rojas m"
replace persona_encargada_proveedor = "guisselle camacho méndez" if persona_encargada_proveedor == "guiselle maria camacho mendez"
replace persona_encargada_proveedor = "sileny maria viales hernandez" if persona_encargada_proveedor == "licda. sileny viales hernandez"
replace persona_encargada_proveedor = "jose alberto mora azuola" if persona_encargada_proveedor == "jose alberto azuola quesada"
replace persona_encargada_proveedor = "martín gonzález romero" if persona_encargada_proveedor == "martin gonzalez romero"
replace persona_encargada_proveedor = "jazmin lobo vega" if persona_encargada_proveedor == "jazmin de jesus lobo vega"
replace persona_encargada_proveedor = "hazel sibaja briceño" if persona_encargada_proveedor == "hazel dayana sibaja briceÑo"
replace persona_encargada_proveedor = "rolando diaz ruiz" if persona_encargada_proveedor == "rolando antonio diaz ruiz"
replace persona_encargada_proveedor = "christian muñoz calvo" if persona_encargada_proveedor == "christian mauricio muÑoz calvo"
replace persona_encargada_proveedor = "luis rizo vega" if persona_encargada_proveedor == "luis adolfo rizo vega"
replace persona_encargada_proveedor = "luis rizo vega" if persona_encargada_proveedor == "luis rizo"
replace persona_encargada_proveedor = "werner toebe elter" if persona_encargada_proveedor == "werner tobe"
replace persona_encargada_proveedor = "ronald fernández astúa" if persona_encargada_proveedor == "ronald alberto fernandez astua"
replace persona_encargada_proveedor = "raúl quesada rodriguez" if persona_encargada_proveedor == "raul esteban quesada rodriguez"
replace persona_encargada_proveedor = "francisco javier garro arbaiza" if persona_encargada_proveedor == "francisco garro a"
replace persona_encargada_proveedor = "gerardo vargas loría" if persona_encargada_proveedor == "gerardo alberto vargas loria"
replace persona_encargada_proveedor = "natalia de los angeles campos rojas" if persona_encargada_proveedor == "natalia campos rojas"
replace persona_encargada_proveedor = "ligia rodríguez soto" if persona_encargada_proveedor == "ligia maria rodriguez soto"
replace persona_encargada_proveedor = "francisco masis" if persona_encargada_proveedor == "francisco jose masis vargas"
replace persona_encargada_proveedor = "andrés ramírez campos" if persona_encargada_proveedor == "andrees ramirez campos"
replace persona_encargada_proveedor = "martin zuñiga brenes" if persona_encargada_proveedor == "martin alfredo zuÑiga brenes"
replace persona_encargada_proveedor = "jose lopez chaves" if persona_encargada_proveedor == "jose lopez cahes"
replace persona_encargada_proveedor = "luis carlos miranda izquierdo" if persona_encargada_proveedor == "luis carlosmiranda"
replace persona_encargada_proveedor = "handerson bolivar" if persona_encargada_proveedor == "handerson bolivar restrepo"
replace persona_encargada_proveedor = "daniel gamboa núñez" if persona_encargada_proveedor == "daniel gamboa nuÑez"
replace persona_encargada_proveedor = "ricardo umaña gómez" if persona_encargada_proveedor == "ricardo umaÑa gomez"
replace persona_encargada_proveedor = "gerardo vinicio cheves alvarez" if persona_encargada_proveedor == "gerardo vinicio chevez zamora"
replace persona_encargada_proveedor = "kattia selley gonzalez" if persona_encargada_proveedor == "kattia sellet gonzalez"
replace persona_encargada_proveedor = "kattia selley gonzalez" if persona_encargada_proveedor == "eng.pal selley"
replace persona_encargada_proveedor = "kattia selley gonzalez" if persona_encargada_proveedor == "pal z selley gonzalez"
replace persona_encargada_proveedor = "bryan carvajal prado" if persona_encargada_proveedor == "brayner carvajal prado"
replace persona_encargada_proveedor = "paola elena guevara aguilar" if persona_encargada_proveedor == "paola guevarara"
replace persona_encargada_proveedor = "katherine vanessa gonzalez calderon" if persona_encargada_proveedor == "katherine gonzález calderón"
replace persona_encargada_proveedor = "victor otarola salazar" if persona_encargada_proveedor == "victor rolando otarola alfaro"
replace persona_encargada_proveedor = "mario enrique garcia vindas" if persona_encargada_proveedor == "mario garcía vindas"
replace persona_encargada_proveedor = "marco vignoli" if persona_encargada_proveedor == "marco vignoli chessler"
replace persona_encargada_proveedor = "maria araya rojas" if persona_encargada_proveedor == "maria de los angeles araya rojas"
replace persona_encargada_proveedor = "edgar mauricio hernandez araya" if persona_encargada_proveedor == "edgar hernández araya"
replace persona_encargada_proveedor = "espitia barrantes doris" if persona_encargada_proveedor == "espitia barrientos doris maría"
replace persona_encargada_proveedor = "olga nuñez ortiz" if persona_encargada_proveedor == "olga victoria nuÑez ortiz"
replace persona_encargada_proveedor = "jorge brenes gonzález" if persona_encargada_proveedor == "jorge eduardo brenes gonzalez"
replace persona_encargada_proveedor = "gabriel lizama oliger" if persona_encargada_proveedor == "gabrie lizama"
replace persona_encargada_proveedor = "tania robles cascante" if persona_encargada_proveedor == "tania robles"
replace persona_encargada_proveedor = "tania robles cascante" if persona_encargada_proveedor == "tania robles"
replace persona_encargada_proveedor = "carlos marín villegas" if persona_encargada_proveedor == "carlos francisco marin villegas"
replace persona_encargada_proveedor = "edgardo wagner" if persona_encargada_proveedor == "edgardo alberto wagner zamora"
replace persona_encargada_proveedor = "roy quesada leiton" if persona_encargada_proveedor == "roger arturo quesada leiton"
replace persona_encargada_proveedor = "jeannette ferencz" if persona_encargada_proveedor == "jeannette patricia ferencz mainemer"
replace persona_encargada_proveedor = "crhistian ureÑa gomez" if persona_encargada_proveedor == "christian eliecer ureÑa gomez"
replace persona_encargada_proveedor = "roy enrique cantillano gonzalez" if persona_encargada_proveedor == "roy cantillano g"
replace persona_encargada_proveedor = "ibis mendoza" if persona_encargada_proveedor == "ibis efren mendoza salgado"
replace persona_encargada_proveedor = "esteban gerardo mora arias" if persona_encargada_proveedor == "esteban mora a"
replace persona_encargada_proveedor = "karla alfaro sánchez" if persona_encargada_proveedor == "karla vanessa alfaro sanchez"
replace persona_encargada_proveedor = "marco aguilar" if persona_encargada_proveedor == "marco vinicio aguilar castro"
replace persona_encargada_proveedor = "ronald fernández astúa" if persona_encargada_proveedor == "ronald alberto fernandez astua"
replace persona_encargada_proveedor = "werner toebe elter" if persona_encargada_proveedor == "werner tobe"
replace persona_encargada_proveedor = "quintin olivier rodriguez quesada" if persona_encargada_proveedor == "quintín rodríguez quesada"
replace persona_encargada_proveedor = "ronald mora" if persona_encargada_proveedor == "ronald leonardo mora ramirez"
replace persona_encargada_proveedor = "mauricio chacón chacón" if persona_encargada_proveedor == "mauricio chacon chacon"
replace persona_encargada_proveedor = "mauricio chacón chacón" if persona_encargada_proveedor == "mauricio chacon chacon"
replace persona_encargada_proveedor = "esteban oviedo blanco" if persona_encargada_proveedor == "edgar oviedo blanco"
replace persona_encargada_proveedor = "jose israel granados madrigal" if persona_encargada_proveedor == "josé esteban granados madrigal"
replace persona_encargada_proveedor = "alvise barnabo" if persona_encargada_proveedor == "alvise ruggero gabriele barnabo"
replace persona_encargada_proveedor = "maureen patricia mendoza sanchez" if persona_encargada_proveedor == "maureen mendez sanchez"
replace persona_encargada_proveedor = "javier bonilla" if persona_encargada_proveedor == "javier alonso bonilla delgado"
replace persona_encargada_proveedor = "carlos moreno" if persona_encargada_proveedor == "carlos f moreno hernandez"
replace persona_encargada_proveedor = "arturo monge" if persona_encargada_proveedor == "jorge arturo monge salazar"
replace persona_encargada_proveedor = "nikolay gandev" if persona_encargada_proveedor == "nikolay dobrev gandev georgieva"
replace persona_encargada_proveedor = "ricardo amador cespedes" if persona_encargada_proveedor == "ricardo amador leon"
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
}

***********************************************************************
* 	PART 6:  Code missing gender for procurement officials	  			
***********************************************************************
/*
preserve
keep if female_po == .
contract nombre_comprador female_po
cd "$ppg_intermediate"
export excel missing_po_gender, firstrow(var) replace
import excel missing_po_gender_coded, clear firstrow
save "missing_po_gender_coded", replace
restore

merge m:1 nombre_comprador using missing_po_gender_coded, update
drop _merge
*/

preserve
	* import excel with missing names gender coded
	import excel using "${ppg_gender_lists}/missing_po_gender_coded.xlsx", firstrow case(preserve) clear
	rename female_po genderpo
	lab var genderpo ""
	isid nombre_comprador
	save "${ppg_gender_lists}/missing_po_gender_coded", replace
restore

merge m:1 nombre_comprador using "${ppg_gender_lists}/missing_po_gender_coded", update replace
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                       987,416
        from master                   987,416  (_merge==1)
        from using                          0  (_merge==2)

    Matched                            13,512
        not updated                         0  (_merge==3)
        missing updated                13,512  (_merge==4)
        nonmissing conflict                 0  (_merge==5)
    -----------------------------------------
*/

drop _merge


***********************************************************************
* 	PART 7:  Correct & clean product classification code	  			
***********************************************************************
* import product classification descriptions
preserve
	import excel using "${ppg_product}/codigos_unidad_compra_adjusted.xlsx", firstrow clear
	replace clasificacion_objeto = subinstr(clasificacion_objeto, ".", "",2)
	destring clasificacion_objeto, replace
	drop if clasificacion_objeto == .
	codebook clasificacion_objeto
	save "${ppg_product}/product", replace
restore

* prepare main data set for merger
replace clasificacion_objeto = subinstr(clasificacion_objeto, ".", "",2)
destring clasificacion_objeto, replace

* merge
merge m:1 clasificacion_objeto using "${ppg_product}/product", update replace
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         3,012
        from master                     2,858  (_merge==1)
        from using                        154  (_merge==2)

    Matched                           998,070
        not updated                   998,070  (_merge==3)
        missing updated                     0  (_merge==4)
        nonmissing conflict                 0  (_merge==5)
    -----------------------------------------
*/
drop if _merge == 2
drop _merge

* clean product classification description variable
format %-50s clasificacion_objeto_des
replace clasificacion_objeto_des= stritrim(strtrim(lower(clasificacion_objeto_des)))

* lab variables
lab var clasificacion_objeto_des "product description"

***********************************************************************
* 	PART 8:  Categorisation of institutions	  			
***********************************************************************
preserve
	import excel using "${ppg_institutions}/List_of_institutions_mit_dummy.xlsx", firstrow case(lower) clear
	isid institucion
	replace institucion= stritrim(strtrim(lower(institucion)))
	format institucion %-75s
	lab var institucion ""
	save "${ppg_institutions}/institutions", replace
restore

* merge corrections for merger
		* correct accent
replace institucion = subinstr(institucion, "é", "e",.)
replace institucion = subinstr(institucion, "ó", "o",.)
replace institucion = subinstr(institucion, "Ó", "o",.)
replace institucion = subinstr(institucion, "í", "i",.)
replace institucion = subinstr(institucion, "á", "a",.)
replace institucion = subinstr(institucion, "Á", "a",.)
replace institucion = subinstr(institucion, "ú", "u",.)

		* correct wrong spellings
replace institucion = "ministerio de gobernacion y policia" if institucion == "ministerio gobernacion y policia"

		* correct institution names
local correct_names `" "bn sociedad administradora de fondos de inversion sociedad anonima" "comision nacional de prestamos para educacion" "laboratorio costarricense de metrologia" "municipalidad de palmares" "sistema de emergencias 911" "teatro nacional" "'
		* incorrect institution names
local incorrect_names `" "b n sociedad administradora de fondos de inversion sociedad anonima" "comisión nacional de préstamos para educación" "laboratorio costarricense de metrologia (lacomet)" "municipalidad de palmares." "sistema de emergencias 9-1-1" "teatro nacional de costa rica" "'

local n : word count `correct_names'
forvalues i = 1/`n' {
	local a : word `i' of `correct_names'
	local b : word `i' of `incorrect_names'
	replace institucion = "`a'" if institucion == "`b'"
}
* merge
merge m:1 institucion using "${ppg_institutions}/institutions", update replace
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                        60,707
        from master                    60,512  (_merge==1)
        from using                        195  (_merge==2)

    Matched                           940,416
        not updated                   940,416  (_merge==3)
        missing updated                     0  (_merge==4)
        nonmissing conflict                 0  (_merge==5)
    -----------------------------------------
*/
drop if _merge == 2
drop _merge

	* instutions 5 = empresas publicas
local institutions5 `" "compaÑÍa nacional de fuerza y luz sociedad anonima" "junta administrativa imprenta nacional" "fideicomiso 872 ms-ctams-bncr" "fideicomiso de titularizacion inmobiliario ice - bcr" "fideicomiso fonatt jadgme - bcr" "fideicomiso fondo especial de migracion jadgme - bcr" "fideicomiso fondo social migratorio jadgme - bcr" "fideicomiso inmobiliario ccss bcr dos mil diecisiete" "ins inversiones sociedad administradora de fondos de inversion sociedad anonima"  "ins valores puesto de bolsa sociedad anonima" "operadora de planes de pensiones complementarias del banco popular y de desarrollo comunal sociedad" "patronato de construcciones, instalaciones y adquisicion de bienes" "radiografica costarricense sociedad anonima" "superintendencia de telecomunicaciones" "banco bac san jose sociedad anonima" "'
foreach institution of local institutions5 {
	replace institucion_tipo = 5 if institucion == "`institution'"
}


* institutions 4 otro (comitees, funds, junta, councils)
local institutions4 `" "comité cantonal de deportes y recreación de belén" "comité cantonal de deportes y recreación de san josé"  "direccion nacional de cen-cinai" "junta administrativa de la dirección general de migración y extranjería" "comision nacional de investigacion en salud" "comision nacional de vacunacion y epidemiologia" "consejo tecnico de aviacion civil" "direccion nacional de cen-cinai" "bcr pension operadora de planes de pensiones complementarias sociedad anonima" "junta administrativa del colegio tecnico profesional de ulloa - heredia" "consejo nacional para investigaciones cientificas y tecnologicas"   "'

foreach institution of local institutions4 {
	replace institucion_tipo = 4 if institucion == "`institution'"
}


	* instutions 3 = municipalidades
local institutions3 `" "municipalidad de jimenez de cartago" "municipalidad del canton de flores"  "'
foreach institution of local institutions3 {
	replace institucion_tipo = 3 if institucion == "`institution'"
}


	* institutions 2 = autonomas

local institutions2 `" "instituto costarricense de pesca y acuicultura"  "instituto nacional de seguros" "instituto tecnologico de costa rica" "instituto de desarrollo profesional uladislao gÁmez solano" "instituto del café de costa rica" "instituto nacional de innovacion y transferencia en tecnologia agropecuaria" "instituto nacional de estadistica y censos" "instituto costarricense de investigacion y enseÑanza en nutricion y salud" "museo arte y diseÑo contemporaneo" "'

foreach institution of local institutions2 {
	replace institucion_tipo = 2 if institucion == "`institution'"
}

	* instutions 1 = gobierno central
local institutions1 `" "contraloría general de la republica" "defensoría de los habitantes de la república" "operadora de pensiones complementarias y de capitalizacion laboral de la c.c.s.s."  "'
foreach institution of local institutions1 {
	replace institucion_tipo = 1 if institucion == "`institution'"
}




* drop if not institution but some special contract payment
drop if institucion == "contrato fideicomiso inmobiliario poder judicial 2015" | institucion == "contrato fideicomiso inmobiliario tribunal registral administrativo bcr 2014" | institucion == "fideicomiso inmobiliario ccss bcr dos mil diecisiete"

* give the data a frame names
/*
frame copy default subtask, replace
frame change subtask
drop _freq
contract institucion if institucion_tipo == .

frame change default
frame drop subtask
*/


***********************************************************************
* 	PART 0:  Test whether administrative firm is a unique
***********************************************************************
	* firm id
frame copy default subtask, replace
frame change subtask
drop _freq
contract cedula_proveedor nombre_proveedor
duplicates list cedula_proveedor
* result: 0 observations are duplicates
frame change default
frame drop subtask



***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
save "${ppg_intermediate}/sicop_replicable", replace
