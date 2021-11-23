***********************************************************************
* 			ppg diff-in-diff collapse & correct							  	  
***********************************************************************
*																	   
*	PURPOSE: Create panel data set for event study diff-in-diff analysis
* 	implies panel id: firm ; time: number of occurence
*																	  
*	OUTLINE:														  
*	1)	 collapse on firm-process level by removing bid-level duplicates		  						  
*	2)   create firm level number of occurence variable			  		    										  
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
* 	PART 1:  collapse on firm-process level by removing bid-level duplicates		  			
***********************************************************************
/* idea/problem: remove same process-firmid-winner combinations because 
one process (with same procurement officer) can have manifold subprocesses, 
which would all be perceived as different processes before-after change 
in gender of rep.
	
	Can different firms win subprocesses in one big process? 
		* this process illustrates that different companies can win 
		different subprocesses (partidas, lineas) within one procurement process
		* this implies also same firm can be a winner and looser in the same process, 
		hence per firm max. 2 observations per process */
		
* browse if numero_procedimiento == "2011cd-000001-0001200001"
* browse if numero_procedimiento == "2011cd-000001-0001200001" & dup <= 1

			* last line suggests that dup = 0 & dup = 1 select per firm one loosing and one winning bid
			* also checked and inclusion of procurement officer firm name did not change the number of observations in dup 0 and 1
			
			
	* identify & remove same-process-firmid-winner combinations
sort numero_procedimiento firmid winner
quietly by numero_procedimiento firmid winner:  gen dup = cond(_N==1,0,_n)
order dup, b(post)
drop if dup > 1 & dup < .
	* 580,878 of 774, 391 obs dropped...
	
***********************************************************************
* 	PART 2:  	create firm level number of occurence variable	  			
***********************************************************************
sort firmid date_adjudicacion numero_procedimiento partida linea
by firmid: gen firm_occurence = _n, a(firmid)
format %5.0g firmid firm_occurence

***********************************************************************
* 	Save new as sicop did 			
***********************************************************************
cd "$ppg_intermediate"
save "sicop_did", replace	
