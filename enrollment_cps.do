# delimit;
clear;
*cd E:;
cap log close;
log using "\stataproject\educ_wagegap\log\enrollment_cps.log",replace;

*clear matrix;
set mem 2000m;
set more off;

use "\stataproject\educ_wagegap\data\all_cps.dta", clear;

keep if agely>=25 & agely<=59;
gen birth_year=year-agely;

/* generate college graduate dummy */
gen college=1 if beduc==3;
replace college=0 if beduc<3;

matrix d=J(66,2,.);
xi: reg college i.birth_year [pweight=wgt_wks];
forvalues i=1/66 {;
local s=`i'+1915;
matrix d[`i', 1] =`s';
if `s'==1916 {;
matrix d[`i', 2] =_b[_cons];
}; 
if `s'>=1917 {;
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

preserve;
clear;
insheet using "\stataproject\educ_wagegap\data\cohort_size_cps.csv";
replace num_birth=num_birth/1000000;
sort birth_year;
save "\stataproject\educ_wagegap\data\cohort_size_cps.dta",replace;
restore;

merge birth_year using "\stataproject\educ_wagegap\data\cohort_size_cps.dta";
tab _merge;

gen c_rate=d2*100;
sort birth_year;
save "\stataproject\educ_wagegap\data\enrollment_cps.dta",replace;

twoway connected c_rate birth_year if birth_year<=1981  ,yaxis(1) ytitle("Rate (%)", axis(1))||
connected num_birth birth_year if birth_year<=1981, yaxis(2) 
ytitle("Number of Births (million)", axis(2)) ||, xtitle(Birth Year) 
legend(label(1 "Graduate Rate") label(2 "Number of Births")) scheme(s2mono);
graph save "\stataproject\educ_wagegap\out\enroll_cps.gph", replace;



