# delimit;
clear;
*clear matrix;
cap log close;
log using E:\stataproject\educ_wagegap\log\cps_decomposition.log,replace;
set mem 2000m;
set more off;

use "E:\stataproject\educ_wagegap\data\all_cps.dta", clear;

/* drop female worker */
drop if female==1;

/* drop some college worker */
keep if beduc==1 | beduc==3;
 
/* drop young and old ages */
keep if agely>=25 & agely<=59;

/* define cohort */
gen cohort=year-agely;

*keep if cohort>=1928 & cohort<=1982;

/* mean by cohort & year */
collapse(mean) lwage [pweight=wgt_wks],by(cohort year beduc);
reshape wide lwage,i(cohort year) j(beduc);
sort  year cohort;
gen rel_lwage=lwage3-lwage1;
gen age=year-cohort;
gen age2=age^2;
gen age3=age^3;
gen age4=age^4;

matrix d=J(35,2,.);
xi: reg rel_lwage age age2 age3 age4 i.cohort i.year;
forvalues i=1/35 {;
local s=`i'+24;
matrix d[`i', 1] =`s';
matrix d[`i', 2] =`s'*_b[age]+`s'^2*_b[age2]+`s'^3*_b[age3]+`s'^4*_b[age4]
-(25*_b[age]+25^2*_b[age2]+25^3*_b[age3]+25^4*_b[age4]);
};

preserve;
svmat double d;
keep d1 d2;
drop if d1==.;
rename d1 age;
sort age;

twoway connected  d2 age, xtitle(Age) ytitle("") xlabel(25 (5) 60)  scheme(s2mono);
graph save E:\stataproject\educ_wagegap\out\cps_age_effect.gph, replace;
restore;

matrix c=J(78,2,.);
forvalues i=1/78 {;
local s=`i'+1903;
matrix c[`i', 1] =`s'; 
if `i'==1 {;
matrix c[`i', 2] =0;
};
if `i'>1 {;
matrix c[`i', 2] =_b[_Icohort_`s'];
};
};

preserve;
svmat double c;
keep c1 c2;
drop if c1==.;
rename c1 cohort;
sort cohort;

twoway connected  c2 cohort,xtitle(Birth Year) ytitle("")  scheme(s2mono);
graph save E:\stataproject\educ_wagegap\out\cps_cohort_effect.gph, replace;
restore;

matrix y=J(44,2,.);
forvalues i=1/44 {;
local s=`i'+1962;
matrix y[`i', 1] =`s';
if `s'==1963 {;
matrix y[`i', 2] =0;
}; 
if `s'>=1964 {;
matrix y[`i', 2] =_b[_Iyear_`s'];
};
};

preserve;
svmat double y;
keep y1 y2;
drop if y1==.;
rename y1 year;
sort year;

twoway connected  y2 year,xtitle(Year) ytitle("")  scheme(s2mono);
graph save E:\stataproject\educ_wagegap\out\cps_year_effect.gph, replace;
restore;

