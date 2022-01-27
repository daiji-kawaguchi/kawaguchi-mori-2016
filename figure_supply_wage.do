# delimit;

/**************
Relative Supply 
***************/
use "\stataproject\educ_wagegap\data\cps_supply_agegroup4.dta",clear;
gen rel_supply=log(c_supply)-log(h_supply);
keep if year>=1963;
twoway connected rel_supply year if agegroup4==1 ||connected rel_supply year if  agegroup4==2
|| connected rel_supply year if agegroup4==3|| connected rel_supply year if  agegroup4==4
||,xtitle(Year) ytitle("") legend(label (1 "Age, 25-29") label(2 "Age, 30-39") 
label(3 "Age, 40-49") label(4 "Age, 50-59")) scheme(s2mono) ;
graph save "\stataproject\educ_wagegap\out\cps_relsupply.gph",replace;

keep year agegroup4 rel_supply;
sort year agegroup4;
save "\stataproject\educ_wagegap\data\cps_relsupply.dta",replace;

/*************
Relative Wage
*************/
use "\stataproject\educ_wagegap\data\us_relwage_groups.dta";

twoway connected rel_lwage year if agegroup==1 ||connected rel_lwage year if  agegroup==2
|| connected rel_lwage year if agegroup==3|| connected rel_lwage year if  agegroup==4
||,xtitle(Year) ytitle("") legend(label (1 "Age, 25-29") label(2 "Age, 30-39") 
label(3 "Age, 40-49") label(4 "Age, 50-59")) scheme(s2mono);
graph save "\stataproject\educ_wagegap\out\cps_relwage.gph",replace;

