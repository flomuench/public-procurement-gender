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

	* corrections for merger
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

		* label  institution
lab var institucion_tipo "public contracting institution, category" 
lab def instutions 1 "central government" 2 "independent institutions" 3 "municipalities" 4 "semi-independent institutions" 5 "state-owned enterprises"
lab val institucion_tipo institutions

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
* 	PART 9:  Test whether administrative firm is a unique
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
* 	PART 10:  harmonize spelling of evaluation factors
***********************************************************************
/* identify different overarching evaluation categories
frame copy default subtask, replace
frame change subtask

drop _freq
contract factor_evaluacion
format %-75s factor_evaluacion
gsort -_freq

*frame change default
*frame drop subtask
*/
		* remove special symbols (from all string variables)
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
	replace `x' = subinstr(`x', "é", "e",.)
	replace `x' = subinstr(`x', "ó", "o",.)
	replace `x' = subinstr(`x', "Ó", "o",.)
	replace `x' = subinstr(`x', "Í", "i",.)
	replace `x' = subinstr(`x', "í", "i",.)
	replace `x' = subinstr(`x', "á", "a",.)
	replace `x' = subinstr(`x', "Á", "a",.)
	replace `x' = subinstr(`x', "Ú", "u",.)
	replace `x' = subinstr(`x', "ú", "u",.)
	replace `x' = subinstr(`x', "Ñ", "n",.)
	replace `x' = subinstr(`x', "ñ", "n",.)
	replace `x' = subinstr(`x', "ü", "u",.)
	replace `x' = subinstr(`x', "É", "u",.)
}
*duplicates drop factor_evaluacion, force

	* create new categorical with evaluation criteria
gen factor_evaluacion_cat = ""
format %-25s factor_evaluacion_cat

	* correct different spellings of 
		* price
			* use regexp to create dummy
gen category = regexm(factor_evaluacion, "precio|costo"), a(factor_evaluacion)
replace factor_evaluacion_cat = "price" if category == 1


local price_spellings `" "precio el menor" "menor precio" "precio mínimo" "precio menor gana" "precio mantenimiento preventivo" "descuento por monto de venta" "facturacion de equipos" "precio para el servicio tecnico" "monto de la partida presupuestaria asignada a la linea" "costo de los materiales" "'
foreach x of local price_spellings { 
	replace factor_evaluacion_cat = "price" if factor_evaluacion == "x" 
}

drop category

		* experience
			* use regexp to create dummy
gen category = regexm(factor_evaluacion, "experiencia|antiguedad|antecedente|constancia|mercado|cantidad|facturacion|descuento|proyectos|contratos"), a(factor_evaluacion)
replace factor_evaluacion_cat = "experience" if category == 1

			* manual replacements
local experience_spellings `" "experiencia adicional" "experiencia adicional (proyectos)" "experiencia del oferente" "años de experiencia de la empresa" "experiencia de la empresa" "experiencia de la empresa en la prestacion de servicios afines" "experiencia adicional (años)" "antiguedad de la empresa" "experiencia adicional del oferente (proyectos)" "experiencia empresa labores similares" "experiencia profesional" "experiencia del fabricante" "experiencia profesional labores similares" "experiencia en distribucion de la marca del equipo ofertado" "cantidad de contratos similares" "experencia" "experiencia de la empresa u oferente" "experiencia en anos" "experiencia anos en el mercado" "experiencia cartas trabajos similares (2ptos x carta)" "experiencia de la empresa en trabajos similares" "experiencia del profesional" "experiencia de la empresa en ventas" "presencia en el mercado" "experiencia documentada de la empresa atinente al objeto contractual" "certificacion de experiencia" "experiencia adicional del profesional responsable (proyectos)" "experiencia del oferente adicional a la minima" "portafolio de proyectos realizados" "cantidad de proyectos realizados por la empresa en trabajos similares (obra)"  "experencia" "'
foreach x of local experience_spellings { 
	replace factor_evaluacion_cat = "experience" if factor_evaluacion == "x" 
}
drop category

		* delivery time
gen category = regexm(factor_evaluacion, "plazo|tiempo|entraga"), a(factor_evaluacion)
replace factor_evaluacion_cat = "delivery time" if category == 1

		* manual replacements
local time_spellings `" "tiempo de entrega" "tiempo de entrega (en semanas)" "plazo" "plazo de entrega (formula)" "tiempo" "plazo de entrega (dias habiles)" "plazo entrega" "menor plazo de entrega" "'
foreach x of local time_spellings { 
	replace factor_evaluacion_cat = "delivery time" if factor_evaluacion == "x" 
}
drop category

		* Warranty
gen category = regexm(factor_evaluacion, "garantia"), a(factor_evaluacion)
replace factor_evaluacion_cat = "warranty" if category == 1		
		
local warranty_spellings `" "garantia" "garantia adicional" "garantia de producto" "garantia adicional para los equipos" "'
foreach x of local warranty_spellings { 
	replace factor_evaluacion_cat = "warranty" if factor_evaluacion == "x" 
}
drop category

		* Certification
gen category = regexm(factor_evaluacion, "certificacion|norma|certificado|iso"), a(factor_evaluacion)
replace factor_evaluacion_cat = "certification" if category == 1	

local certification_spellings `" "certificacion o plan de manejo" "certificacion iso 14001" "certificaciones" "certificado iso 50001" "oferente o producto que posea certificacion vigente iso 14000, para alguno de los procesos internos de la empresa o que la empresa mediante acta notarial certifique que la misma desarrolla campañas de proteccion del medio ambiente" "oferente o producto que posea certificacion vigente de alguna de las familias iso 9000, para alguno de los procesos internos de la empresa." "norma iso 9001" "norma iso 14001" "certificaciones ambientales" "certificacion de calidad" "norma iso 13485" "proyectos ejecutados" "contratos adjudicados" "'
foreach x of local certification_spellings { 
	replace factor_evaluacion_cat = "certification" if factor_evaluacion == "x" 
}
drop category

		* Local contributions, installments
gen category = regexm(factor_evaluacion, "cotizacion|cotizar"), a(factor_evaluacion)
replace factor_evaluacion_cat = "domestic contributive payments" if category == 1
local contributable_spellings `" "cotizacion en moneda nacional de costa rica" "cotizacion en moneda nacional"   "'
foreach x of local contributable_spellings { 
	replace factor_evaluacion_cat = "domestic contributive payments" if factor_evaluacion == "x" 
}
drop category

		* environmental criteria
gen category = regexm(factor_evaluacion, "ambiente|ambiental|sustentable|residuos|reciclaje|contaminacion|desechos|eco-eficiencia|consumo energetico|solar"), a(factor_evaluacion)
replace factor_evaluacion_cat = "environmental criteria" if category == 1

local environmental_spellings `" "criterio sustentable" "reconocimiento ambiental y social" "lista de iniciativa para reduccion de la contaminacion" "plan de manejo de residuos" "gestion ambiental del fabricante" "gestion ambiental" "plan de gestion integral de residuos (de conformidad con ley para la gestion integral de residuos n° 8839)" "proteccion al medio ambiente" "criterio ambiental" "contribucion ambiental" "factores sustentables_ambientales" "plan de manejo de residuos solidos" "sellos ambientales" "producto biodegradable, no contaminante o de facil asimilacion por el planeta" "factores sustentables_sociales" "certificaciones ambientales y de calidad" "cumplimiento de manejo de reciclaje y tratamiento de desechos electronicos" "desempeno ambiental" "refrigerantes naturales"   "'
foreach x of local environmental_spellings { 
	replace factor_evaluacion_cat = "environmental criteria" if factor_evaluacion == "x" 
}
drop category

		* skilled staff 
gen category = regexm(factor_evaluacion, "personal|academico|academica|cantidad de tecnicos certificados"), a(factor_evaluacion)
replace factor_evaluacion_cat = "quality" if category == 1
drop category

		* social criteria
gen category = regexm(factor_evaluacion, "discapacidad|social|personal mayor de 50|pyme|accesibilidad|seguridad|salud|sostenibilidad|producto verde"), a(factor_evaluacion)
replace factor_evaluacion_cat = "social criteria" if category == 1
drop category

		* recommendation
gen category = regexm(factor_evaluacion, "referencia|recomendacion"), a(factor_evaluacion)
replace factor_evaluacion_cat = "recommendation" if category == 1
drop category


		* location
gen category = regexm(factor_evaluacion, "distancia|ubicacion"), a(factor_evaluacion)
replace factor_evaluacion_cat = "geographically close" if category == 1
drop category

		* national production
gen category = regexm(factor_evaluacion, "proveedor local|fabricacion nacional|marca pais"), a(factor_evaluacion)
replace factor_evaluacion_cat = "national or local production" if category == 1
drop category
	

		* product quality
gen category = regexm(factor_evaluacion, "calidad"), a(factor_evaluacion)
replace factor_evaluacion_cat = "quality" if category == 1
drop category


		* site visits
gen category = regexm(factor_evaluacion, "visita"), a(factor_evaluacion)
replace factor_evaluacion_cat = "quality" if category == 1
drop category

		* financial situation of suppliers
gen category = regexm(factor_evaluacion, "financiera|situacion del proveedor"), a(factor_evaluacion)
replace factor_evaluacion_cat = "quality" if category == 1
drop category

		* maintement
gen category = regexm(factor_evaluacion, "mantimiento|sustitucion|taller propio"), a(factor_evaluacion)
replace factor_evaluacion_cat = "quality" if category == 1
drop category
		
		* otros
replace factor_evaluacion_cat = "other" if factor_evaluacion_cat == ""

tab factor_evaluacion_cat /*2% are in other category, implying 98% covered in the 12 formed categories*/

***********************************************************************
* 	PART 11:  remove duplicates
***********************************************************************
	* search for duplicates
duplicates report numero_procedimiento partida linea cedula_proveedor factor_evaluacion
duplicates tag numero_procedimiento partida linea cedula_proveedor factor_evaluacion, gen(suspicion)
br if suspicion > 0 /* eyeballing suggests that these are real duplicates */


	* remove duplicates
duplicates drop numero_procedimiento partida linea cedula_proveedor factor_evaluacion, force
*(13,895 observations deleted)
sort numero_procedimiento partida linea cedula_proveedor factor_evaluacion
duplicates report numero_procedimiento partida linea cedula_proveedor factor_evaluacion
drop suspicion


***********************************************************************
* 	PART 12:  Verify via text matching if change in reps not wrongly assigned due to misspellings	  			
***********************************************************************
* note: this code only needs to be executed when running the do-file for the first time
* this code creates a list of all the firms (one firm per row) and all their representatives (one column per rep)
* it then combines all potential within firm repname-repname combinations for their similarity to identify incorrect
* spellings based on string similarity >= 0.9

/* only needs to be executed once: 
frame copy default subtask, replace
frame change subtask

	* create id for repname-firm
egen rep_id = group(cedula_proveedor persona_encargada_proveedor)

	* prepare for contracting
drop _freq
contract cedula_proveedor rep_id persona_encargada_proveedor
drop _freq

	* within firm, create a count variable, 1, 2,3 for each rep
bysort cedula_proveedor (persona_encargada_proveedor) : gen firm_rep_id = sum(persona_encargada_proveedor != persona_encargada_proveedor[_n-1])
order cedula_proveedor persona_encargada_proveedor rep_id firm_rep_id
drop rep_id
reshape wide persona_encargada_proveedor, i(cedula_proveedor) j(firm_rep_id)

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
br cedula_proveedor persona_encargada_proveedor* if maxscore >= 0.6

frame change default
*/

* drop remaining inconsistent spellings
local p "persona_encargada_proveedor"
replace `p' = "jonathan marino" if `p' == "jonathan marino  g"
replace `p' = "adrian esteban fernandez castro" if `p' == "adrian fernandez castro"
replace `p' = "maria auxiliadora alfaro ortega" if `p' == "auxiliadora alfaro ortega"
replace `p' = "maikol gomez trejos" if `p' == "maykol gomez trejos"
replace `p' = "maikol gomez trejos" if `p' == "maykolgomez trejos"
replace `p' = "jorge guillen ruiz" if `p' == "jorge guillen"
replace `p' = "carlos alejandro ubico duran" if `p' == "carlos ubico duran"
replace `p' = "hernan antonio hernandez zamora" if `p' == "hernan a. hernandez zamora"
replace `p' = "ana lucia gonzalez garcia" if `p' == "ana lucia gonzalez"
replace `p' = "maureen patricia mendoza sanchez" if `p' == "maureen mendoza sanchez"
replace `p' = "willy alberto jimenez sanchez" if `p' == "willy jimenez sanchez"
replace `p' = "richard francisco mesen vasquez" if `p' == "richard mesen vasquez"
replace `p' = "celia maria perezcabello soza" if `p' == ""
replace `p' = "javier alonso garro sanchez" if `p' == "javier garro"
replace `p' = "javier alonso garro sanchez" if `p' == "javier garro sanchez"
replace `p' = "jorge estuardo menendez guardia" if `p' == "jorge menendez guardia"
replace `p' = "alvaro enrique pantoja viquez" if `p' == "alvaro pantoja viquez"
replace `p' = "freddy gerardo estrada luna" if `p' == "freddy estrada luna"
replace `p' = "nelson salvador zuniga chaverri" if `p' == "nelson zuniga chaverri"
replace `p' = "andres gerardo viquez viquez" if `p' == "andres viquez viquez"
replace `p' = "rafael angel rojas escalante" if `p' == "rafael rojas"
replace `p' = "nimrod ezuz" if `p' == "nirmod ezuz"
replace `p' = "enrique alberto bogantes fernandez" if `p' == "enrique bogantes"
replace `p' = "jorge guillermo lizano seas" if `p' == "jorge lizano"
replace `p' = "carla maria cartin de san roman" if `p' == "carla cartin"
replace `p' = "alfredo gerardo wesson acuna" if `p' == "alfredo wesson"
replace `p' = "giovanni antonio carrion ballestero" if `p' == "geovanny carrion ballestero"
replace `p' = "rodrigo barrantes villarevia" if `p' == "rodrigo barrantes"
replace `p' = "richard alonso rodriguez mora" if `p' == "richard rodriguez"
replace `p' = "jose alejandro munoz sequeira" if `p' == "alejandro munoz"
replace `p' = "rolando jose paiz gonzalez" if `p' == "rolando paiz"
replace `p' = "nelson norlui mattie d jesus" if `p' == "nelson mattie"
replace `p' = "mario guillermo chi ruano" if `p' == "mario chi"

***********************************************************************
* 	PART 13: Correct gender of ambiguous first names	  			
***********************************************************************
/*
frame create firmdata
frame change firmdata
use "${ppg_final}/sicop_firm", clear
duplicates tag persona_encargada_proveedor, gen(same_name)
duplicates tag persona_encargada_proveedor genderfo,gen(same_name_gender)
br if same_name != same_name_gender
*/

replace genderfo = 0 if persona_encargada_proveedor == "milagros macias pino"
replace genderfo = 0 if persona_encargada_proveedor == "andrea ruiz hidalgo"
replace genderfo = 1  if persona_encargada_proveedor == "cindy angulo monge"
replace genderfo = 1 if persona_encargada_proveedor == "goldy ponchner geller"
replace genderfo = 1 if persona_encargada_proveedor == "arie befeler israelsky"
replace genderfo = 1 if persona_encargada_proveedor == "doris carrillo lopez"
replace genderfo = 0 if persona_encargada_proveedor == "edwin castro rodriguez"
replace genderfo = 0 if persona_encargada_proveedor == "gabriel lizama oliger"


replace genderfo = 0 if persona_encargada_proveedor == "jose mariano alpizar arredondo"
replace genderfo = 1 if persona_encargada_proveedor == "karol serrano soto"
replace genderfo = 1 if persona_encargada_proveedor == "maria de los angeles naranjo vega"
replace genderfo = 1 if persona_encargada_proveedor == "marisol castillo villalobos"
replace genderfo = 0 if persona_encargada_proveedor == "norman herrera portugues"
replace genderfo = 0 if persona_encargada_proveedor == "paulo alberto dodero aguilar"
replace genderfo = 0 if persona_encargada_proveedor == "rocio segura jimenez"
replace genderfo = 0 if persona_encargada_proveedor == "simone castellani"
replace genderfo = 0 if persona_encargada_proveedor == "yanori alfaro alvarez"

***********************************************************************
* 	PART 14: Correct amount values
***********************************************************************
* in most cases, there is one single amount, at least for one product within a process
	* however, in some cases,
	
	* create variables to help identify problematic obs for reshaping
		* obs not constant within process-sub-process-product-firm combinations
egen sub_process_firm_id = group(numero_procedimiento partida linea cedula_proveedor)
bysort sub_process_firm_id (factor_evaluacion) : gen criteria_id = sum(factor_evaluacion != factor_evaluacion[_n-1]), a(sub_process_firm_id)
egen help_id = group(sub_process_firm_id criteria_id)
order help_id, a(criteria_id)

{
replace monto_crc = 319819 if help_id == 111183
replace monto_crc = 814080 if help_id == 5823
replace monto_crc = 43964910 if sub_process_firm_id == 263551 & criteria_id == 1

replace monto_crc = 2788.05 if help_id == 395362 | help_id == 395361
replace monto_crc = 725628.899 if help_id == 523983 | help_id == 523984 | help_id == 523985
replace monto_crc = 15799 if help_id == 723396
replace monto_crc = 15915 if help_id == 723400
replace monto_crc = 51288 if help_id == 723847
replace monto_crc = 7335355.5 if help_id == 727768 | help_id == 727769
replace monto_crc = 194900 if help_id == 731374
replace monto_crc = 228500 if help_id == 731422
replace monto_crc = 132000 if help_id == 731468
replace monto_crc = 3138000 if help_id == 744848 | help_id == 744850
replace monto_crc = 381900 if help_id == 757126
replace monto_crc = 243600 if help_id == 757131
replace monto_crc = 2267300 if help_id == 757149
replace monto_crc = 1667200 if help_id == 757156
replace monto_crc = 12844000 if help_id == 757161
replace monto_crc = 707000 if help_id == 757168
replace monto_crc = 877800 if help_id == 757174
replace monto_crc = 228000 if help_id == 757180
replace monto_crc = 48750 if help_id == 771010
replace monto_crc = 109000 if help_id == 771014
replace monto_crc = 55000 if help_id == 771022
replace monto_crc = 12000 if help_id == 771030
replace monto_crc = 6951976 if help_id == 899565 | help_id == 899566 | help_id == 899567
replace monto_crc = 331927.357 if help_id == 902345 | help_id == 902346 | help_id == 902347
replace monto_crc = 869805 if help_id == 727754 | help_id == 727755
replace monto_crc = 12000 if help_id == 771029
replace monto_crc = 479700 if help_id == 5863
replace monto_crc = 725628.899 if help_id == 523981
replace monto_crc = 15915 if help_id == 723399
replace monto_crc = 869805 if help_id == 727756 | help_id == 727757
replace monto_crc = 7335355.5 if help_id == 727767
replace monto_crc = 204000 if help_id == 731397
replace monto_crc = 260000 if help_id == 731419
replace monto_crc = 228500 if help_id == 731423
replace monto_crc = 132000 if help_id == 731469
replace monto_crc = 410300 if help_id == 731515
replace monto_crc = 352200 if help_id == 757137
replace monto_crc = 2267300 if help_id == 757150
replace monto_crc = 1667200 if help_id == 757155
replace monto_crc = 228000 if help_id == 757179
replace monto_crc = 536796 if help_id == 770361
replace monto_crc = 48750 if help_id == 771009
replace monto_crc = 109000 if help_id == 771013
replace monto_crc = 60000 if help_id == 771018
replace monto_crc = 55000 if help_id == 771021
replace monto_crc = 790250.432 if help_id == 971973
replace monto_crc = 948536.267 if help_id == 971981
replace monto_crc = 80000 if help_id == 771026
replace monto_crc = 12000 if help_id == 771029
replace monto_crc = 12000 if help_id == 771029
replace monto_crc = 12000 if help_id == 771029

* 
replace monto_crc = 215140 if sub_process_firm_id == 4251 & criteria_id == 2
replace monto_crc = 814080 if sub_process_firm_id == 4270 & criteria_id == 2
replace monto_crc = 479700  if sub_process_firm_id == 4290 & criteria_id == 2

replace monto_crc = 173562573.11 if sub_process_firm_id == 100569 & criteria_id == 2

replace monto_crc = 43964910 if sub_process_firm_id == 263551  & criteria_id == 1

replace monto_crc = 39155250 if sub_process_firm_id == 413053  & criteria_id == 1
replace monto_crc = 39155250 if sub_process_firm_id == 413053  & criteria_id == 2
replace monto_crc = 39155250 if sub_process_firm_id == 413053  & criteria_id == 3
replace monto_crc = 39155250 if sub_process_firm_id == 413053  & criteria_id == 4


replace monto_crc = 39155250 if sub_process_firm_id == 413054  & criteria_id == 1
replace monto_crc = 39155250 if sub_process_firm_id == 413054  & criteria_id == 2
replace monto_crc = 39155250 if sub_process_firm_id == 413054  & criteria_id == 3
replace monto_crc = 39155250 if sub_process_firm_id == 413054  & criteria_id == 4

replace monto_crc = 725628.899 if sub_process_firm_id == 437497  & criteria_id == 2

replace monto_crc = 194900 if sub_process_firm_id == 599652  & criteria_id == 2
replace monto_crc = 204000 if sub_process_firm_id == 599663 & criteria_id == 1
replace monto_crc = 115800 if sub_process_firm_id == 599678 & criteria_id == 1
replace monto_crc = 410300 if sub_process_firm_id == 599722 & criteria_id == 1
replace monto_crc = 900000 if sub_process_firm_id == 599725 & criteria_id == 2


replace monto_crc = 381900 if sub_process_firm_id == 615035  & criteria_id == 1
replace monto_crc = 352200 if sub_process_firm_id == 615041 & criteria_id == 2

replace monto_crc = 707000 if sub_process_firm_id == 615056 & criteria_id == 1
replace monto_crc = 877800 if sub_process_firm_id == 615059  & criteria_id == 1
replace monto_crc = 1021977 if sub_process_firm_id == 622680 & criteria_id == 2

replace monto_crc = 536796 if sub_process_firm_id == 622686 & criteria_id == 1
replace monto_crc = 80000 if sub_process_firm_id == 623216  & criteria_id == 1
replace monto_crc = 6951976 if sub_process_firm_id == 712100 & criteria_id == 1
replace monto_crc = 6951976 if sub_process_firm_id == 712100 & criteria_id == 5

replace monto_crc = 331927.357 if sub_process_firm_id == 714058  & criteria_id == 4

replace monto_crc = 790250.432  if sub_process_firm_id == 764941 & criteria_id == 2
replace monto_crc = 948536.267 if sub_process_firm_id == 764945  & criteria_id == 2
}

local wrong_values "395361 395362 395363 750420 750421 750422 773210 773211 773212 773240 773241 773242 790107 790108 790109 790110 790111 790112 790113 972123 972124 972125 972126 972139 972140 972141 972142 972167 972168 972169 972170 972179 972180 972181 972182 734813 734814 734815 773225 773226 773227 971997 971998 972005 972006"
foreach x of local wrong_values {
	replace monto_crc = . if help_id ==  `x'
}



drop help_id criteria_id sub_process_firm_id

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
save "${ppg_intermediate}/sicop_replicable", replace
