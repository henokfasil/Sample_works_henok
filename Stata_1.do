*------------------------------------------------------------------------------
*HENOK FASIL TELILA, paper, Jan 2018

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

cd "C:\Users\Asus2\1st_Paper_Final_Files\Section_1_2_Alpha_estimates"
/*------------------------------------------------------------------------------
* 							Part 1 - Alphas
*=============================================================================*/

use  "inputdata\Part_1_Tekola", clear

drop mofd

gen mofd = mofd(date(date, "DMY"))
format mofd %tm

save "outputdata\Data1", replace

use "outputdata\Data1", clear


foreach v of varlist  f1a f1b f2a f2b f3a f3b {
	
	preserve
    
	* Convert return to 100 ppt

	replace `v' = `v' * 100
	
	
	* rolling alphs using a 24 months window

	asreg `v' x1a x2a x3a x4a x7a, window(mofd 24) min(24)
	
	tsset mofd
	
	label var _b_cons "`v' alpha of Carhart"
	
	label var mofd "Dates"

	tsline _b_cons
	cd results

	graph export `v'.png, as(png) name("Graph") replace
	cd ..
	
	keep mofd _*
	
	drop in 1/23
	cd outputdata
	export delimited using "`v'_Carhart.csv", replace
	cd ..

	
	restore
	

}




* Model 2 - Fama and French
use "outputdata\Data1", clear

foreach v of varlist  f1a f1b f2a f2b f3a f3b {
	preserve
    
	* Convert return to 100 ppt

	replace `v' = `v' * 100
	
	* rolling alphs using a 24 months window

	asreg `v' x1a x2b x3a x4a x5a x6a  x7a, window(mofd 24) min(24)
	
	label var _b_cons "`v' alpha of Fama"
	
	keep mofd _*
	
	drop in 1/23
	cd outputdata
	export delimited using "`v'_Fama.csv", replace
	cd ..
restore
}


* Models 3

use "outputdata\Data1", clear

foreach v of varlist  f4a-f6b {
    preserve
	* Convert return to 100 ppt

	replace `v' = `v' * 100
	
	
	* rolling alphs using a 24 months window

	asreg `v' z1a z2a z3a z4a z7a, window(mofd 24) min(24)
	
	label var _b_cons "`v' alpha of Carhart_z"
	keep mofd _*
	
	drop in 1/23
	cd outputdata
	export delimited using "`v'_Carhart_z.csv", replace
	cd ..

	
	restore


}


* Model 4

use "outputdata\Data1", clear

foreach v of varlist  f4a-f6b {
    preserve
	* Convert return to 100 ppt

	replace `v' = `v' * 100
	
	* rolling alphs using a 24 months window

	asreg `v' z1a z2b z3a z4a z5a z6a z7a, window(mofd 24) min(24)
	
	label var _b_cons "`v' alpha of Fama_Z"
	keep mofd _*
	
	drop in 1/23
	cd outputdata
	export delimited using "`v'_Fama_z.csv", replace
	cd ..

	
	restore

}

* Regression Results
use "outputdata\Data1", clear

asdoc reg f1a x1a x2a x3a x4a x7a, nest title(Table 1: Carhart Regressions) ///
	      save(results\Table1 Carhart Regressions) replace robust

foreach v of varlist   f1b f2a f2b f3a f3b {
	

	replace `v' = `v' * 100
	

	asdoc reg `v' x1a x2a x3a x4a x7a, nest title(Table 1: Carhart Regressions) ///
	      save(results\Table1 Carhart Regressions) robust
}


 * Model 2
 
 asdoc reg f1a x1a x2b x3a x4a x5a x6a  x7a, nest title(Table 1: Fama and French Regressions) ///
	      save(results\Table2  Fama and French  Regressions) replace robust

foreach v of varlist   f1b f2a f2b f3a f3b {
    
	
	* rolling alphs using a 24 months window

	asdoc reg `v' x1a x2b x3a x4a x5a x6a  x7a, nest title(Table 1: Fama and French Regressions) ///
	      save(results\Table2  Fama and French  Regressions) robust
}

* Model 3
	replace f4a = f4a * 100

	asdoc reg f4a z1a z2a z3a z4a z7a, nest title(Table 3: Carhart Regressions) ///
	      save(results\Table3 Carhart Regressions_z) replace robust

foreach v of varlist  f4b-f6b {
		replace `v' = `v' * 100


	asdoc reg `v' z1a z2a z3a z4a z7a, nest title(Table 3: Carhart Regressions) ///
	      save(results\Table3 Carhart Regressions_z) robust
}

* Model 4
asdoc reg f4a z1a z2b z3a z4a z5a z6a z7a, nest title(Table 4: Fama and French Regressions) ///
	      save(results\Table4  Fama and French  Regressions)  replace robust

foreach v of varlist  f4b-f6b {

	asdoc reg `v' z1a z2b z3a z4a z5a z6a z7a, nest title(Table 4: Fama and French Regressions) ///
	      save(results\Table4  Fama and French  Regressions)  robust
}



*********************** End of Part 1 ***************************************

