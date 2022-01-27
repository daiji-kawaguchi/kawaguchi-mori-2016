/* Supply Measure */
# delimit;
set more off;

* supply;
clear;
forvalues y=64/99 {;
clear;
use "\stataproject\educ_wagegap\data\cps_clean\mar`y'.dta",clear;
keep if agely>=25 & agely<=59;
gen beduc=1 if school<=2;
replace beduc=2 if school==3;
replace beduc=3 if school>=4;

preserve;
collapse(sum) hrslwk [pw=wgt_hrs],by(year agely beduc female);
keep year agely beduc female hrslwk;
if `y'>64 {;
append using  "\stataproject\educ_wagegap\data\re_supply.dta";
};
save "\stataproject\educ_wagegap\data\re_supply.dta",replace;
restore;

};

clear;
forvalues y=0/7 {;
clear;
use "\stataproject\educ_wagegap\data\cps_clean\mar0`y'.dta",clear;
keep if agely>=25 & agely<=59;
gen beduc=1 if school<=2;
replace beduc=2 if school==3;
replace beduc=3 if school>=4;

collapse(sum) hrslwk [pw=wgt_hrs],by(year agely beduc female);
keep year agely beduc female hrslwk;
append using  "\stataproject\educ_wagegap\data\re_supply.dta";
save "\stataproject\educ_wagegap\data\re_supply.dta",replace;

};



