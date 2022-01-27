# delimit;
clear;
*cd E:;
cap log close;
log using "\stataproject\educ_wagegap\log\enrollment.log",replace;

*clear matrix;
set mem 2000m;
set more off;

use "\stataproject\educ_wagegap\data\rocho_wage.dta", clear;
drop  month district mar rel n15 
nu15_03 nu15_46 nu15_79 nu15_1012 nu15_1314;

gen birth_year2=1925+birth_year if birth_nengo==3;
replace birth_year2=1911+birth_year if birth_nengo==2;
replace birth_year2=1867+birth_year if birth_nengo==1;
replace birth_year2=1988+birth_year if birth_nengo==4;
replace birth_year2=birth_year if birth_nengo==5 | birth_nengo==0;
replace birth_year=birth_year2;
replace birth_year=birth_year-1 if birth_month<=3;
drop birth_year2 birth_month birth_nengo;

keep if age>=25 & age<=59;
keep if sex==1;

/* drop in school & generate education index before 2001 */
keep if educ_stat==2 | year>=2002;
replace educ=educ_year if year<=2001;
replace educ=educ-1 if year<=2001 & educ>=2;

/* drop in school & generate education index after 2002 */
drop if educ<=3 & year>=2002;
drop if educ==7 | educ==.;
replace educ=educ-3 if year>=2002;
label drop educ;
drop if educ==.;


/* generate college graduate dummy */
gen college=1 if educ==3;
replace college=0 if educ<3;

matrix d=J(57,2,.);
xi: reg college i.birth_year;
forvalues i=1/57 {;
local s=`i'+1926;
matrix d[`i', 1] =`s';
if `s'==1927 {;
matrix d[`i', 2] =_b[_cons];
}; 
if `s'>=1928 {;
matrix d[`i', 2] =_b[_cons]+_b[_Ibirth_yea_`s'];
};
};

svmat double d;
label variable d1 "Birth Year";
label variable d2 "College Graduate Ratio";
keep d1 d2;
drop if d1==.;
rename d1 birth_year;
sort birth_year;
save \stataproject\educ_wagegap\data\enrollment.dta,replace;

clear;
insheet using \stataproject\educ_wagegap\data\cohort_size.csv;
replace num_birth=num_birth/1000000;
drop if birth_year<1927;
sort birth_year;
save \stataproject\educ_wagegap\data\cohort_size.dta,replace;

clear;
insheet using \stataproject\educ_wagegap\data\enrollment.csv;
gen birth_year=year-19;
sort birth_year;
merge birth_year using \stataproject\educ_wagegap\data\enrollment.dta;
drop _merge;
sort birth_year;
merge birth_year using \stataproject\educ_wagegap\data\cohort_size.dta;
tab _merge;
gen c_rate=d2*100;



*# delimit;
sort birth_year;

twoway connected enrollment birth_year if birth_year<=1983 ,yaxis(1) ytitle("Rate (%)", axis(1))|| 
connected c_rate birth_year if birth_year<=1983, yaxis(1)
|| connected num_birth birth_year if birth_year<=1983, yaxis(2) 
ytitle("Number of Births (million)", axis(2)) ||, xtitle(Birth Year)  legend(label(1 "Advancement Rate") 
label(2 "Graduate Rate") label(3 "Number of Male Births")) scheme(s2mono);
graph save \stataproject\educ_wagegap\out\enroll.gph, replace;

