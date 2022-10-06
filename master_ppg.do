***********************************************************************
* 			midline master do-file 									  
***********************************************************************
*																	  
*	PURPOSE: make all data work reproducible						  
* 	for all team members & outsiders								  
*																	  
*	OUTLINE: 	PART 1: Set standard settings & install packages	  
*				PART 2: Prepare dynamic folder paths & globals		  
*				PART 3: Run midline do-files                          
*																	  
*																	  
*	Author:  	Florian Muench						    
*	ID variable: process-level id = id ; firm level id = firmid	  					  
*	Requires: 	 SICOP_gender_new_workingversion 										  
*	Creates:  			                                  
***********************************************************************
* 	PART 1: 	Set standard settings & install packages			  
***********************************************************************

	* set standard settings
version 17
clear all
graph drop _all
scalar drop _all
set more off
set graphics on /* switch off to on to display graphs */
qui cap log c
set varabbrev off /* avoid wrong variable gets selected */

	* install packages
/*
*ssc install blindschemes, replace
*net install http://www.stata.com/users/kcrow/tab2docx
*ssc install betterbar 
*ssc install xtable
*ssc install coefplot
*ssc install outreg2
*net install grc1leg,from( http://www.stata.com/users/vwiggins/)
ssc install freqindex
ssc install matchit
ssc install winsor2, replace
net install fastreshape, from("https://raw.githubusercontent.com/mdroste/stata-fastreshape/master/")
	
*/

	* define graph scheme for visual outputs
set scheme plotplainblind

	* set seeds for replication
set seed 01092022
set sortseed 01092022 

***********************************************************************
* 	PART 2: 	Prepare dynamic folder paths & globals			  	  *
***********************************************************************

		* globals: dynamic folder paths

if "`c(username)'" == "ASUS" {
		global ppg_gdrive = "G:/Meine Ablage/Public Procurement and Gender"
}
else{
		global ppg_gdrive = "C:/Users/`c(username)'/Google Drive/Public Procurement and Gender"
}
		
if c(os) == "Windows" {
	global ppg_github = "C:/Users/`c(username)'/Documents/GitHub/public-procurement-gender"
	global ppg_backup = "C:/Users/`c(username)'/Documents/backup-public-procurement-gender"
}
else if c(os) == "MacOSX" {
	global ppg_gdrive = "Users/`c(username)'/Google Drive/Public Procurement and Gender"
	global ppg_github = "Users/`c(username)'/Documents/GitHub/public-procurement-gender"
	global ppg_backup = "Users/`c(username)'/Documents/backup-public-procurement-gender"
}
		
		* globals: dynamic sub-folder 
			* data
global ppg_data = "${ppg_gdrive}/Data/Yami_Flo"
global ppg_raw = "${ppg_data}/raw"
global ppg_intermediate "${ppg_data}/intermediate"
global ppg_final "${ppg_data}/final"
global ppg_gender_lists "${ppg_data}/files_for_gender_coding"
global ppg_product "${ppg_data}/product_categories"
global ppg_institutions "${ppg_data}/institutions"
			
			* outputs
global ppg_output = "${ppg_gdrive}/Output"
global ppg_figures = "${ppg_output}/figures"
global ppg_regression_tables = "${ppg_output}/regression-tables"
global ppg_descriptive_statistics = "${ppg_output}/descriptive-statistics"
				
			* within regression-tables
global ppg_learning = "${ppg_regression_tables}/learning effects"
global ppg_event = "${ppg_regression_tables}/event study did"
global ppg_pooled = "${ppg_regression_tables}/pooled multivariate regression"
global ppg_unconprob = "${ppg_regression_tables}/unconditional probabilities"
		

***********************************************************************
* 	PART 3: 	Run data cleaning & preparation do-files			  	
***********************************************************************
/* --------------------------------------------------------------------
	PART 3.0: import
	Requires: SICOP_gender_new_workingversion or SiCOPgendernew
	Creates:  sicop_replicable
----------------------------------------------------------------------*/
if (1) do "${ppg_github}/ppg_import.do"
/* --------------------------------------------------------------------
	PART 3.1: merge
	Requires: sicop_replicable
	Creates:  listgenderfo.xlsx/dta, listgenderpo.xlsx/dta
----------------------------------------------------------------------*/		
if (1) do "${ppg_github}/ppg_merge.do"
/* --------------------------------------------------------------------
	PART 3.1: clean
	Requires: sicop_replicable
	Creates:  sicop_replicable
----------------------------------------------------------------------*/		
if (1) do "${ppg_github}/ppg_clean.do"
/* --------------------------------------------------------------------
	PART 3.2: correct
	Requires: sicop_replicable
	Creates:  sicop_replicable
----------------------------------------------------------------------*/		
if (1) do "${ppg_github}/ppg_correct.do"
/* --------------------------------------------------------------------
	PART 3.3: generate
	Requires: sicop_replicable
	Creates:  sicop_final
	Erases: sicop_replicable
----------------------------------------------------------------------*/		
if (1) do "${ppg_github}/ppg_generate.do"


***********************************************************************
* 	PART 5: 	Collapse into different level data sets  	
***********************************************************************
/* --------------------------------------------------------------------
	PART 5.1: Collapse - remove criteria level
	Requires: sicop_final
	Creates:  sicop_subprocess
----------------------------------------------------------------------*/		
if (1) do "${ppg_github}/ppg_collapse_subprocess.do"
/* --------------------------------------------------------------------
	PART 5.2: Collapse - remove sub-processes and linea
	Requires: sicop_subprocess
	Creates:  sicop_process
----------------------------------------------------------------------*/		
if (1) do "${ppg_github}/ppg_collapse_process.do"
/* --------------------------------------------------------------------
	PART 5.3: Create firm-level data set for descriptive statistics
	Requires: sicop_final_subprocess
	Creates:  sicop_firm
----------------------------------------------------------------------*/		
if (1) do "${ppg_github}/ppg_collapse_firm_level.do"


***********************************************************************
* 	PART 5: 	Run descriptive statistics do files		  	
***********************************************************************
/* --------------------------------------------------------------------
	PART 5.1.: general, bid-level descriptive statistics
	Requires: sicop_subprocess
----------------------------------------------------------------------*/		
if (1) do "${ppg_github}/ppg_descriptive_statistics.do" 
/* --------------------------------------------------------------------
	PART 5.2.: firm level statistics & balance table
	Requires: sicop_firm
----------------------------------------------------------------------*/
if (1) do "${ppg_github}/ppg_firm_level_statistics.do"


***********************************************************************
* 	PART 6: 	Multivariate Regression analysis		  	
***********************************************************************
/* --------------------------------------------------------------------
	PART 6.1.: multivariate regression analysis
	Requires: sicop_replicable
----------------------------------------------------------------------*/
if (0) do "${ppg_github}/ppg_multivariate_regression.do"


***********************************************************************
* 	PART 7: Event study difference-in-difference (EDID)		  	
***********************************************************************
/* --------------------------------------------------------------------
	PART 7.1.: generate EDID variables & identify "treatment" groups
	Requires: sicop_process
	Creates: sicop_process
----------------------------------------------------------------------*/
if (1) do "${ppg_github}/ppg_did_generate.do"
/* --------------------------------------------------------------------
	PART 7.2.: visualize behaviour around the event window (change in reps)
	Requires: sicop_process
----------------------------------------------------------------------*/
if (0) do "${ppg_github}/ppg_did_visualisations.do"
/* --------------------------------------------------------------------
	PART 7.3.: run Event study/ Dynamic DID regressions
	Requires: sicop_process
----------------------------------------------------------------------*/
if (0) do "${ppg_github}/ppg_did_regresssions.do"
/* --------------------------------------------------------------------
	PART 7.4.: run 2x2 and 2x3 DiD regressions (Y aggregated)
	Requires: sicop_process
----------------------------------------------------------------------*/
if (0) do "${ppg_github}/ppg_did_2x3.do"


/* --------------------------------------------------------------------
	PART 8: Panel one and two way fixed effects approach
	Requires: sicop_replicable
	Creates:  sicop_firm
----------------------------------------------------------------------*/
if (0) do "${ppg_github}/ppg_panel_fixed_effects.do"
