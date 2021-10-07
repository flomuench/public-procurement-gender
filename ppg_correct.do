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
*																	  															      
*	Author:  	Florian Muench						  
*	ID variable: 	process level id = id ; firm level id = firmid			  					  
*	Requires: 	  								  
*	Creates:  			                          
*																	  
***********************************************************************
* 	PART 1:  Define non-response categories  			
***********************************************************************
use "${ppg_data}/SICOP_gender_new_workingversion", clear
	


***********************************************************************
* 	PART 2:  Encode categorical variables		  			
***********************************************************************
/*	* enumerator name
label def enq 1 "Faten" 2 "Lina" 3 "Azziz" 4 "Sarah"
encode midline_enqueteur, gen(ml_enqueteur) label(enq) 
drop midline_enqueteur
rename ml_enqueteur midline_enqueteur
*/


***********************************************************************
* 	PART 3:  Replace string with numeric values		  			
***********************************************************************
	* q391: ventes en export 
*replace q391_corrige = "254000000" if id == "f247"


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
