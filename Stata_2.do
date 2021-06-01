*Henok Fasil Telila
* Research paper

* Install necessary programs 
ssc install asrol // rolling window statistics 
ssc install asreg // rolling window and group regressions 
ssc install asgen // weighted average 
ssc install asdoc // sending output to MS Word 
net install asid, from(http://FinTechProfessor.com) replace 
ssc install astile // qaurtile groups / portfolios creation 
 
//*------------------------------------------------------------------------------
//                 				 DIRECTORIES
//=============================================================================*/

* Change to following directory 

cd "C:\Users\Asus2\Section_3_Persistence\Persistent_regresssion_result"

/*------------------------------------------------------------------------------
* 							Part 1 - Alphas
*=============================================================================*/

use  "inputdata\persist_data", clear
gen mofd = mofd( mond)
format mofd %tm

foreach v of varlist c1_low-c6_spread   {
	
	preserve
    
	* Convert return to 100 ppt

	
	
	* rolling alphs using a 24 months window

	asreg `v' x1a x2a x3a x4a x7a, window(mofd 24) min(24)
	
	tsset mofd
	
	keep mofd _*
	
	drop in 1/23
	cd outputdata
	export delimited using "`v'_Carhart_Part1.csv", replace
	cd ..

	
	restore
	

}




* Model 2 - Fama and French
use  "inputdata\persist_data", clear
gen mofd = mofd( mond)
format mofd %tm

foreach v of varlist c1_low-c6_spread   {
	preserve
    
	* Convert return to 100 ppt

	
	* rolling alphs using a 24 months window

	asreg `v' x1a x2b x3a x4a x5a x6a  x7a, window(mofd 24) min(24)
	
	label var _b_cons "`v' alpha of Fama"
	
	keep mofd _*
	
	drop in 1/23
	cd outputdata/Part2
	export delimited using "`v'_Fama_Part2.csv", replace
	cd ..
	cd ..
restore
}


* Models 3

use  "inputdata\persist_data", clear
gen mofd = mofd( mond)
format mofd %tm

foreach v of varlist c1_low-c6_spread   {
    preserve
	* Convert return to 100 ppt

	
	
	* rolling alphs using a 24 months window

	asreg `v' z1a z2a z3a z4a z7a, window(mofd 24) min(24)
	
	keep mofd _*
	
	drop in 1/23
	cd outputdata/Part3
	export delimited using "`v'_Carhart_Part3.csv", replace
	cd ..
	cd ..
	
	restore


}


* Model 4

use  "inputdata\persist_data", clear
gen mofd = mofd( mond)
format mofd %tm

foreach v of varlist c1_low-c6_spread   {
    preserve
	* Convert return to 100 ppt

	
	* rolling alphs using a 24 months window

	asreg `v' z1a z2b z3a z4a z5a z6a z7a, window(mofd 24) min(24)
	
	keep mofd _*
	
	drop in 1/23
	cd outputdata/Part4
	export delimited using "`v'_Fama_Part4.csv", replace
	cd ..
	cd ..
	
	restore

}

* Regression Results
use  "inputdata\persist_data", clear
gen mofd = mofd( mond)
format mofd %tm


loc fundtype c1 c2 c3 c4 c5 c6

foreach f of local fundtype {

qui sum `f'_high
loc mean : di %9.3f = `r(mean)'
loc sd : di %9.3f = `r(sd)'
		  

asdoc reg `f'_high x1a x2a x3a x4a x7a, nest title(Fund Group `f') ///
	      save(results\Part1\Fund Group `f') replace cnames(high) /// 
		  add(mean, `mean', sd, `sd') robust

	  
		  
	loc scale medium low spread
	loc index 1 
	

foreach v of varlist   `f'_medium `f'_low `f'_spread {
    
    loc fund : word `index' of `scale'
	
	qui sum `v'
	loc mean : di %9.3f = `r(mean)'
	loc sd : di %9.3f = `r(sd)'
	
	asdoc reg `v' x1a x2a x3a x4a x7a, nest title(Fund Group `f') ///
	      save(results\Part1\Fund Group `f') cnames(`fund') ///
		  add(mean, `mean', sd, `sd') robust
		  
	loc `++index'
}
}




















 * Model 2
 
 asdoc reg f1a x1a x2b x3a x4a x5a x6a  x7a, nest title(Table 1: Fama and French Regressions) ///
	      save(results\Table2  Fama and French  Regressions) replace

foreach v of varlist   f1b f2a f2b f3a f3b {
    
	
	* rolling alphs using a 24 months window

	asdoc reg `v' x1a x2b x3a x4a x5a x6a  x7a, nest title(Table 1: Fama and French Regressions) ///
	      save(results\Table2  Fama and French  Regressions)
}

* Model 3
	replace f4a = f4a * 100

	asdoc reg f4a z1a z2a z3a z4a z7a, nest title(Table 3: Carhart Regressions) ///
	      save(results\Table3 Carhart Regressions_z) replace

foreach v of varlist  f4b-f6b {
		replace `v' = `v' * 100


	asdoc reg `v' z1a z2a z3a z4a z7a, nest title(Table 3: Carhart Regressions) ///
	      save(results\Table3 Carhart Regressions_z)
}

* Model 4
asdoc reg f4a z1a z2b z3a z4a z5a z6a z7a, nest title(Table 4: Fama and French Regressions) ///
	      save(results\Table4  Fama and French  Regressions)  replace

foreach v of varlist  f4b-f6b {

	asdoc reg `v' z1a z2b z3a z4a z5a z6a z7a, nest title(Table 4: Fama and French Regressions) ///
	      save(results\Table4  Fama and French  Regressions) 
}



*********************** End of Part 1 ***************************************

