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
version 15
clear all
graph drop _all
scalar drop _all
set more off
set graphics on /* switch off to on to display graphs */
capture program drop zscore /* drops the program programname */
qui cap log c

	* install packages
*ssc install blindschemes, replace
*net install http://www.stata.com/users/kcrow/tab2docx
*ssc install betterbar 

	* define graph scheme for visual outputs
set scheme plotplain

***********************************************************************
* 	PART 2: 	Prepare dynamic folder paths & globals			  	  *
***********************************************************************

		* globals: dynamic folder paths
if c(os) == "Windows" {
	global ppg_gdrive = "C:/Users/`c(username)'/Google Drive/Public Procurement and Gender"
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
			* outputs
global ppg_output = "${ppg_gdrive}/Output"
global ppg_figures = "${ppg_output}/figures"
global ppg_regression_tables = "${ppg_output}/regression-tables"
global ppg_descriptive_statistics = "${ppg_output}/descriptive-statistics"
	
		* global for numerical variables*
*global numvar ml_prix q393 q392 q391


		* globals for other reponses categories
*global not_know    = "77777777777777777"



***********************************************************************
* 	PART 3: 	Run data cleaning & preparation do-files			  	
***********************************************************************
/* --------------------------------------------------------------------
	PART 3.1: clean
	Requires: SICOP_gender_new_workingversion
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
	Creates:  sicop_replicable
----------------------------------------------------------------------*/		
if (1) do "${ppg_github}/ppg_generate.do"

***********************************************************************
* 	PART 4: 	Run descriptive statistics do files		  	
***********************************************************************

/* --------------------------------------------------------------------
	PART 4.1.: firm level statistics & balance table
	Requires: sicop_replicable
	Creates:  sicop_firm
----------------------------------------------------------------------*/		
if (1) do "${ppg_github}/ppg_collapse_firm_level.do" 
/* can be switched off to 0 after first run */

/* --------------------------------------------------------------------
	PART 4.2.: firm level statistics & balance table
	Requires: sicop_firm
	Creates:  sicop_firm
----------------------------------------------------------------------*/

if (0) do "${ppg_github}/ppg_firm_level_statistics.do"
