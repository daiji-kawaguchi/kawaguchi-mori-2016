cd F: 

*****************
***** Japan *****
*****************

/* assign the value for the range of income using BSWS & generate the hourly wage */
*do "\stataproject\educ_wagegap\do\rocho_wage.do"

/* collapse LFS to construct relative wage and relative supply */
do "\stataproject\educ_wagegap\do\collapse_rocho.do"

/* create emprate & IV */
do "\stataproject\educ_wagegap\do\emprate.do"

/* Figure 1 : Change of Wage Distribution */
do "\stataproject\educ_wagegap\do\change_905010.do"

/* Figure 2 - 4: Relative Supply & Wage */
do "\stataproject\educ_wagegap\do\relative_by_agegroups.do"

/* Figure 5 : enrollment ratio */
do "\stataproject\educ_wagegap\do\enrollment.do"

/* Figure 6 : decomposition */
*do "\stataproject\educ_wagegap\do\decomposition.do"

/* Regression */
do "\stataproject\educ_wagegap\do\regression_by_age.do"


*****************
***** U.S. ******
*****************

/* Cleaning the March CPS data  */
do "\stataproject\educ_wagegap\do\re_march7699.do"
do "\stataproject\educ_wagegap\do\re_march0007.do"
do "\stataproject\educ_wagegap\do\re_supply.do"

/* Construct supply and wage measure */
do "\stataproject\educ_wagegap\do\supply_and_wage.do"

/* Figure of relative supply and wage */
do "\stataproject\educ_wagegap\do\figure_supply_wage.do"

/* Figure of enrollment ratio */
do "\stataproject\educ_wagegap\do\enrollment_cps.do"

/* Figure of decomposition */
*do "\stataproject\educ_wagegap\do\cps_decomposition.do"

/* Regression */
do "\stataproject\educ_wagegap\do\reg_cps.do"


******************
*** Simulation ***
******************

/* bootstrap */
do "\stataproject\educ_wagegap\do\japan_bootstrap.do"
do "\stataproject\educ_wagegap\do\japan_boot_estimate.do"
do "\stataproject\educ_wagegap\do\us_bootstrap.do"
do "\stataproject\educ_wagegap\do\us_boot_estimate.do"

do "\stataproject\educ_wagegap\do\simulate.do"

* Comparative inequality & Figure 3 (change of the wage distribution in U.S) *
do "\stataproject\educ_wagegap\do\inequality.do"

******************************
***** Japan (Wage Census)*****
******************************

/* collapse LFS to construct relative wage and relative supply */
do "\stataproject\educ_wagegap\do\collapse_census.do"

/* Figure 1 : Change of Wage Distribution */
do "\stataproject\educ_wagegap\do\C_change_905010.do"

/* Figure 2 - 4: Relative Supply & Wage */
do "\stataproject\educ_wagegap\do\C_relative_by_agegroups.do"

/* Regression */
do "\stataproject\educ_wagegap\do\C_regression_by_age.do"

/* Figure: supply and wage of Japan & US*/
do "\stataproject\educ_wagegap\do\C_supply_and_wage.do"

/* Difference of the number of PC users between CL and HS */ 
do "\stataproject\educ_wagegap\do\pc_use.do"

