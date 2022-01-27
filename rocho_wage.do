#delimit ;
cap log close;
log using \stataproject\educ_wagegap\log\rocho_wage.log, replace;

clear;
set mem 2000m;
set more off;

forvalues t=0/6 {;
local s=`t'+1989;
clear;
use "\stataproject\data\wagecensus1989-2008\data\wcm`s'.dta";
gen a_income9=(salary+oversalary)*12+ bonus;

* for 1989-1995 *;
preserve;
recode a_income9 (0=1) (1/9999=2) (10000/19999=3) (20000/29999=4) (30000/39999=5) (40000/49999=6)
(50000/69999=7) (70000/99999=8) (100000/149999=9) (150000/max=0),gen(inc);
collapse(mean) year a_income9 [pweight=weight],by(inc);
if `t'>=1 {;
append using "\stataproject\educ_wagegap\data\mean_income9.dta";
};
sort year inc;
save "\stataproject\educ_wagegap\data\mean_income9.dta",replace;
restore;

/* there are no data of wagecensus from 1986-1988. So wage data from 1986-1988 are
calculated using wagecensus 1989 */;
if `t'==0 {;
drop year ;
recode a_income9 (0/9999=1) (10000/19999=2) (20000/29999=3) (30000/39999=4) (40000/49999=5) (50000/69999=6)
(70000/99999=7) (100000/149999=8) (150000/max=9),gen(inc);
rename a_income9 a_income89;
collapse(mean) a_income89 [pweight=weight],by(inc);
sort inc;
save "\stataproject\educ_wagegap\data\mean_income9_89.dta",replace;
};

};

forvalues t=0/12 {;
local s=`t'+1996;
clear;
use "\stataproject\data\wagecensus1989-2008\data\wcm`s'.dta", clear;
gen a_income12=(salary+oversalary)*12 + bonus;
recode a_income12 (0=1) (1/4999=2) (5000/9999=3) (10000/14999=4) (15000/19999=5) (20000/29999=6)
(30000/39999=7) (40000/49999=8) (50000/69999=9) (70000/99999=10) (100000/149999=11) (150000/max=12), gen(inc);
collapse(mean) year a_income12 [pweight=weight],by(inc);
if `t'>=1 {;
append using "\stataproject\educ_wagegap\data\mean_income12.dta";
};
sort year inc;
save "\stataproject\educ_wagegap\data\mean_income12.dta",replace;
};

clear;
use "\stataproject\data\rocho\lfssp_1986_2008.dta";
sort year inc;
merge year inc using "\stataproject\educ_wagegap\data\mean_income9.dta";
drop _merge;
sort year inc;
merge year inc using "\stataproject\educ_wagegap\data\mean_income12.dta";
drop _merge;
sort inc;
merge inc using "\stataproject\educ_wagegap\data\mean_income9_89.dta";
drop _merge;

gen a_income=a_income9 if year<=1995 & year>=1989;
replace a_income=a_income12 if year>=1996;
replace a_income=a_income89 if year<=1988;
drop a_income12 a_income9 a_income89;

gen a_hour=hour*50;
gen wage=a_income*100/a_hour;
gen lwage=log(wage);
sort year;
by year : tabstat a_income;
save "\stataproject\educ_wagegap\data\rocho_wage.dta",replace;



log close;


