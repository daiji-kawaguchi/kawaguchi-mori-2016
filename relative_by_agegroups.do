# delimit;
cap log close;
log using "\stataproject\educ_wagegap\log\figure4.log",replace;

clear;
use "\stataproject\educ_wagegap\data\rlwage_4age.dta", clear;
drop if educ==2;
sort year educ agegroup4;
save "\stataproject\educ_wagegap\data\relative_by_age.dta",replace;

clear;
use "\stataproject\educ_wagegap\data\by_age_supply.dta",clear;
sort year educ agegroup4;
merge year educ agegroup4 using "\stataproject\educ_wagegap\data\relative_by_age.dta";
drop _merge wei_hour;

reshape wide pwage supply,i(year agegroup4) j(educ); 

gen rel_lwage=pwage3-pwage1;
gen rel_lsupply=log(supply3)-log(supply1);

twoway connected rel_lwage year if agegroup4==1 || 
connected rel_lwage year if agegroup4==2 ||
connected rel_lwage year if agegroup4==3 ||
connected rel_lwage year if agegroup4==4 ||
||,xtitle(Year) ytitle("") legend(label (1 "Age, 25-29") label(2 "Age, 30-39") 
label(3 "Age, 40-49") label(4 "Age, 50-59")) scheme(s2mono);
graph save Graph "\stataproject\educ_wagegap\out\relwage_by_age.gph",replace;

twoway connected rel_lsupply year if agegroup4==1 || 
connected rel_lsupply year if agegroup4==2 ||
connected rel_lsupply year if agegroup4==3 ||
connected rel_lsupply year if agegroup4==4 ||
||,xtitle(Year) ytitle("") legend(label (1 "Age, 25-29") label(2 "Age, 30-39") 
label(3 "Age, 40-49") label(4 "Age, 50-59")) scheme(s2mono);
graph save Graph "\stataproject\educ_wagegap\out\relsupply_by_age.gph",replace;

clear;
use "\stataproject\educ_wagegap\data\overall_supply.dta", clear;
sort year educ ;
by year:gen rel_supply=log(supply[_n])-log(supply[_n-1]);
drop if rel_supply==.;
drop educ supply;
sort year;
save "\stataproject\educ_wagegap\data\figure4.dta",replace;

clear;
use "\stataproject\educ_wagegap\data\rlwage_4age.dta", clear;
drop if educ==2;
sort year agegroup4 educ;
by year agegroup4 : gen rel_wage=pwage[_n]-pwage[_n-1];
drop if rel_wage==.;
gen wei_wage=rel_wage*wei_hour;
sort year;
by year:egen rel_wage2=total(wei_wage);
collapse(mean) rel_wage2,by (year);
rename rel_wage2 rel_wage;
sort year;
merge year using "\stataproject\educ_wagegap\data\figure4.dta";
drop _merge ;

twoway connected rel_wage year,yaxis(1) ytitle("Relative Wage", axis(1))
|| connected rel_supply year,yaxis(2) ytitle("Relative Supply", axis(2))
||, legend(label (1 "Wage") label(2 "Supply")) scheme(s2mono);
graph save Graph "\stataproject\educ_wagegap\out\rel_wage_supply.gph",replace;

rename rel_wage jp_rel_wage;
rename rel_supply jp_rel_supply;
sort year;
save "\stataproject\educ_wagegap\data\jp_us_figure.dta",replace;


