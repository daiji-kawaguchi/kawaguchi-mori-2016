# delimit;
clear;
*clear matrix;
cap log close;
log using E:\stataproject\educ_wagegap\log\decomposition.log,replace;
set mem 2000m;
set more off;

use "E:\stataproject\educ_wagegap\data\rocho_wage.dta", clear;
drop  month district  mar rel n15 
nu15_03 nu15_46 nu15_79 nu15_1012 nu15_1314;
drop if hour<35;

/* drop in school & generate education index before 2001 */
keep if educ_stat==2 | year>=2002;
replace educ=educ_year if year<=2001;
replace educ=educ-1 if year<=2001 & educ>=2;

/* drop in school & generate education index after 2002 */
drop if educ<=3 & year>=2002;
drop if educ==7 | educ==.;
replace educ=educ-3 if year>=2002;
label drop educ;

/* drop female worker */
drop if sex==2;

/* drop some college worker */
drop if educ==2;
 
/* drop young and old ages */
keep if age>=25 & age<=59;

/* keep working status = main worker */
keep if empstat==1;

/* translate wage to real wage using CPI */
preserve;
clear;
insheet using "E:\stataproject\educ_wagegap\data\CPI.csv";
gen deflator=cpi/100;
sort year;
save "E:\stataproject\educ_wagegap\data\CPI.dta",replace;
restore;

sort year;
merge year using "E:\stataproject\educ_wagegap\data\CPI.dta";
drop _merge;
gen rwage=deflator*wage;

/* define cohort */
gen cohort=1925+birth_year if birth_nengo==3;
replace cohort=1911+birth_year if birth_nengo==2;
replace cohort=1867+birth_year if birth_nengo==1;
replace cohort=1988+birth_year if birth_nengo==4;
replace cohort=birth_year if birth_nengo==5 | birth_nengo==0;
replace cohort=cohort-1 if birth_month<=3;

keep if cohort>=1928 & cohort<=1982;

/* mean by cohort & year */
collapse(mean) rwage,by(cohort year educ);
reshape wide rwage,i(cohort year) j(educ);
sort  year cohort;
gen rel_lwage=log(rwage3/rwage1);
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

twoway connected  d2 age, xtitle(Age) ytitle("") xlabel(25 (5) 60) scheme(s2mono);
graph save E:\stataproject\educ_wagegap\out\age_effect.gph, replace;
restore;

matrix c=J(55,2,.);
forvalues i=1/55 {;
local s=`i'+1927;
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

twoway connected  c2 cohort,xtitle(Birth Year) ytitle("") scheme(s2mono);
graph save E:\stataproject\educ_wagegap\out\cohort_effect.gph, replace;
restore;

matrix y=J(23,2,.);
forvalues i=1/23 {;
local s=`i'+1985;
matrix y[`i', 1] =`s';
if `s'==1986 {;
matrix y[`i', 2] =0;
}; 
if `s'>=1987 {;
matrix y[`i', 2] =_b[_Iyear_`s'];
};
};

preserve;
svmat double y;
keep y1 y2;
drop if y1==.;
rename y1 year;
sort year;

twoway connected  y2 year,xtitle(Year) ytitle("") scheme(s2mono);
graph save E:\stataproject\educ_wagegap\out\year_effect.gph, replace;
restore;

