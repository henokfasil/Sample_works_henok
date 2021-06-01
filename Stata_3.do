* Henok
* Research paper

* Install necessary programs 
ssc install asrol // rolling window statistics 
ssc install asreg // rolling window and group regressions 
ssc install asgen // weighted average 
ssc install asdoc // sending output to MS Word 
net install asid, from(http://FinTechProfessor.com) replace 
ssc install astile // qaurtile groups / portfolios creation 
 
//*------------------------------------------------------------------------------
//                  DIRECTORIES
//=============================================================================*/
* inputdata\        for all source data files
* outputdata\       for all data file generated during the process
* results\          for all output tables
* literature\       for all related literature 
* ------------------------------------------------------------------------------


* Change to following directory 

cd "C:\Users\Asus2\Persistence\Persistent_regresssion_result"
/*------------------------------------------------------------------------------
* 							For fund type C1
*=============================================================================*/

* Load the data set
import excel "inputdata\fund_group_return.xlsx", sheet("c1") firstrow case(lower) clear

* Reshape data to long format
reshape long x, i(fund_c1) j(year) str

* Rename variables
ren x ret

* Create monthly date in the following steps
split year, p("_")
destring year1, gen(m)

drop year

destring year2, gen(year)

gen mofd = ym(year, m)

format mofd %tm

* Remove uncessary variables
drop year1 m year2

order fund_c1 mofd

save "outputdata\Part2_data", replace

use "outputdata\Part2_data", clear

* Past 12 months performance for each fund_c1
bys fund_c1 : asrol ret, stat(product) add(1) gen(cumret12) window(mofd 12)

* Create 3 groups based on last 12 months performance
bys year : astile groups = cumret12, nq(3)

* Find average returns for each group
bys groups mofd: egen rpi = mean(ret)
drop if groups == .

* Reduce data to a portfolio level
bys groups mofd: keep if _n == _N
keep groups mofd rpi

* Reshape the data to winde
reshape wide rpi , j(groups) i(mofd)
ren rpi1 c1_low
ren rpi3 c1_high
rename rpi2 c2_medium 

gen c1_spread = c1_high - c1_low

save "outputdata\c1", replace


/*------------------------------------------------------------------------------
* 							For fund type C
*=============================================================================*/

* Load the data set
import excel "inputdata\fund_group_return.xlsx", sheet("c2") firstrow case(lower) clear

* Reshape data to long format
reshape long x, i(fund_c2) j(year) str

* Rename variables
ren x ret

* Create monthly date in the following steps
split year, p("_")
destring year1, gen(m)

drop year

destring year2, gen(year)

gen mofd = ym(year, m)

format mofd %tm

* Remove uncessary variables
drop year1 m year2

order fund_c2 mofd



* Past 12 months performance for each fund_c1
bys fund_c2 : asrol ret, stat(product) add(1) gen(cumret12) window(mofd 12)

* Create 3 groups based on last 12 months performance
bys year : astile groups = cumret12, nq(3)

* Find average returns for each group
bys groups mofd: egen rpi = mean(ret)
drop if groups == .

* Reduce data to a portfolio level
bys groups mofd: keep if _n == _N
keep groups mofd rpi

* Reshape the data to winde
reshape wide rpi , j(groups) i(mofd)
ren rpi1 c2_low
ren rpi3 c2_high
rename rpi2 c2_medium 

gen c2_spread = c2_high - c2_low

save "outputdata\c2", replace


/*------------------------------------------------------------------------------
* 							For fund type c3
*=============================================================================*/

* Load the data set
import excel "inputdata\fund_group_return.xlsx", sheet("c3") firstrow case(lower) clear

* Reshape data to long format
reshape long x, i(fund_c3) j(year) str

* Rename variables
ren x ret

* Create monthly date in the following steps
split year, p("_")
destring year1, gen(m)

drop year

destring year2, gen(year)

gen mofd = ym(year, m)

format mofd %tm

* Remove uncessary variables
drop year1 m year2

order fund_c3 mofd



* Past 12 months performance for each fund_c1
bys fund_c3 : asrol ret, stat(product) add(1) gen(cumret12) window(mofd 12)

* Create 3 groups based on last 12 months performance
bys year : astile groups = cumret12, nq(3)

* Find average returns for each group
bys groups mofd: egen rpi = mean(ret)
drop if groups == .

* Reduce data to a portfolio level
bys groups mofd: keep if _n == _N
keep groups mofd rpi

* Reshape the data to winde
reshape wide rpi , j(groups) i(mofd)
ren rpi1 c3_low
ren rpi3 c3_high
rename rpi2 c3_medium 

gen c3_spread = c3_high - c3_low

save "outputdata\c3", replace

/*------------------------------------------------------------------------------
* 							For fund type c4
*=============================================================================*/

* Load the data set
import excel "inputdata\fund_group_return.xlsx", sheet("c4") firstrow case(lower) clear

* Reshape data to long format
reshape long x, i(fund_c4) j(year) str

* Rename variables
ren x ret

* Create monthly date in the following steps
split year, p("_")
destring year1, gen(m)

drop year

destring year2, gen(year)

gen mofd = ym(year, m)

format mofd %tm

* Remove uncessary variables
drop year1 m year2

order fund_c4 mofd



* Past 12 months performance for each fund_c1
bys fund_c4 : asrol ret, stat(product) add(1) gen(cumret12) window(mofd 12)

* Create 3 groups based on last 12 months performance
bys year : astile groups = cumret12, nq(3)

* Find average returns for each group
bys groups mofd: egen rpi = mean(ret)
drop if groups == .

* Reduce data to a portfolio level
bys groups mofd: keep if _n == _N
keep groups mofd rpi

* Reshape the data to winde
reshape wide rpi , j(groups) i(mofd)
ren rpi1 c4_low
ren rpi3 c4_high
rename rpi2 c4_medium 

gen c4_spread = c4_high - c4_low

save "outputdata\c4", replace


/*------------------------------------------------------------------------------
* 							For fund type c5
*=============================================================================*/

* Load the data set
import excel "inputdata\fund_group_return.xlsx", sheet("c5") firstrow case(lower) clear

* Reshape data to long format
reshape long x, i(fund_c5) j(year) str

* Rename variables
ren x ret

* Create monthly date in the following steps
split year, p("_")
destring year1, gen(m)

drop year

destring year2, gen(year)

gen mofd = ym(year, m)

format mofd %tm

* Remove uncessary variables
drop year1 m year2

order fund_c5 mofd



* Past 12 months performance for each fund_c1
bys fund_c5 : asrol ret, stat(product) add(1) gen(cumret12) window(mofd 12)

* Create 3 groups based on last 12 months performance
bys year : astile groups = cumret12, nq(3)

* Find average returns for each group
bys groups mofd: egen rpi = mean(ret)
drop if groups == .

* Reduce data to a portfolio level
bys groups mofd: keep if _n == _N
keep groups mofd rpi

* Reshape the data to winde
reshape wide rpi , j(groups) i(mofd)
ren rpi1 c5_low
ren rpi3 c5_high
rename rpi2 c5_medium 

gen c5_spread = c5_high - c5_low

save "outputdata\c5", replace


/*------------------------------------------------------------------------------
* 							For fund type c6
*=============================================================================*/

* Load the data set
import excel "inputdata\fund_group_return.xlsx", sheet("c6") firstrow case(lower) clear

* Reshape data to long format
reshape long x, i(fund_c6) j(year) str

* Rename variables
ren x ret

* Create monthly date in the following steps
split year, p("_")
destring year1, gen(m)

drop year

destring year2, gen(year)

gen mofd = ym(year, m)

format mofd %tm

* Remove uncessary variables
drop year1 m year2

order fund_c6 mofd



* Past 12 months performance for each fund_c1
bys fund_c6 : asrol ret, stat(product) add(1) gen(cumret12) window(mofd 12)

* Create 3 groups based on last 12 months performance
bys year : astile groups = cumret12, nq(3)

* Find average returns for each group
bys groups mofd: egen rpi = mean(ret)
drop if groups == .

* Reduce data to a portfolio level
bys groups mofd: keep if _n == _N
keep groups mofd rpi

* Reshape the data to winde
reshape wide rpi , j(groups) i(mofd)
ren rpi1 c6_low
ren rpi3 c6_high
rename rpi2 c6_medium 

gen c6_spread = c6_high - c6_low

save "outputdata\c6", replace

