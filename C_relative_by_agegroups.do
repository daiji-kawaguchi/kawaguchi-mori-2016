# delimit;
cap log close;
log using "\stataproject\educ_wagegap\log\figure4.log",replace;

clear;
use "\stataproject\educ_wagegap\data\C_rlwage_4age.dta", clear;
drop if educ==2;
sort year educ agegroup4;
save "\stataproject\educ_wagegap\data\C_relative_by_age.dta",replace;

clear;
use "\stataproject\educ_wagegap\data\C_by_age_supply.dta",clear;
sort year educ agegroup4;
merge year educ agegroup4 using "\stataproject\educ_wagegap\data\C_relative_by_age.dta";
drop _merge hour;

reshape wide pwage supply,i(year agegroup4) j(educ); 

gen rel_lwage=pwage3-pwage1;
gen rel_lsupply=log(supply3)-log(supply1);

preserve;
gen rel_lwage05=rel_lwage if year>=2005;
replace rel_lwage=. if year>=2005;
gen rel_lsupply05=rel_lsupply if year>=2005;
replace rel_lsupply=. if year>=2005;

twoway connected rel_lwage year if agegroup4==1, mcolor(black) msymbol(0)|| 
connected rel_lwage05 year if agegroup4==1 , mcolor(black) msymbol(0)||
connected rel_lwage year if agegroup4==2 , mcolor(gs8) msymbol(D)||
connected rel_lwage05 year if agegroup4==2 , mcolor(gs8) msymbol(D)||
connected rel_lwage year if agegroup4==3 , mcolor(black) msymbol(S)||
connected rel_lwage05 year if agegroup4==3 , mcolor(black) msymbol(S)||
connected rel_lwage year if agegroup4==4 , mcolor(gs8) msymbol(T)||
connected rel_lwage05 year if agegroup4==4 , mcolor(gs8) msymbol(T)||
||,xtitle(Year) ytitle("") legend(label (1 "Age, 25-29") label(2 "")
label(3 "Age, 30-39") label(4 "") label(5 "Age, 40-49") 
label(6 "") label(7 "Age, 50-59") label(8 "")) scheme(s2mono);
graph save Graph "\stataproject\educ_wagegap\out\C_relwage_by_age.gph",replace;

twoway connected rel_lsupply year if agegroup4==1, mcolor(black) msymbol(0)|| 
connected rel_lsupply05 year if agegroup4==1 , mcolor(black) msymbol(0)||
connected rel_lsupply year if agegroup4==2 , mcolor(gs8) msymbol(D)||
connected rel_lsupply05 year if agegroup4==2 , mcolor(gs8) msymbol(D)||
connected rel_lsupply year if agegroup4==3 , mcolor(black) msymbol(S)||
connected rel_lsupply05 year if agegroup4==3 , mcolor(black) msymbol(S)||
connected rel_lsupply year if agegroup4==4 , mcolor(gs8) msymbol(T)||
connected rel_lsupply05 year if agegroup4==4 , mcolor(gs8) msymbol(T)||
||,xtitle(Year) ytitle("") legend(label (1 "Age, 25-29") label(2 "")
label(3 "Age, 30-39") label(4 "") label(5 "Age, 40-49") 
label(6 "") label(7 "Age, 50-59") label(8 "")) scheme(s2mono);
graph save Graph "\stataproject\educ_wagegap\out\C_relsupply_by_age.gph",replace;
restore;

clear;
use "\stataproject\educ_wagegap\data\C_overall_supply.dta", clear;
sort year educ;
by year:gen rel_supply=log(supply[_n])-log(supply[_n-1]);
drop if rel_supply==.;
drop educ supply;
sort year;
save "\stataproject\educ_wagegap\data\C_figure4.dta",replace;

clear;
use "\stataproject\educ_wagegap\data\C_rlwage_4age.dta", clear;
drop if educ==2;
collapse(mean)  pwage [iw=hour],by(year educ );
sort year educ;
by year: gen rel_wage=pwage[_n]-pwage[_n-1];
drop if rel_wage==.;
merge year using "\stataproject\educ_wagegap\data\C_figure4.dta";
drop _merge educ;

twoway connected rel_wage year,yaxis(1) ytitle("Relative Wage", axis(1))
|| connected rel_supply year,yaxis(2) ytitle("Relative Supply", axis(2))
||, legend(label (1 "Wage") label(2 "Supply")) scheme(s2mono);
graph save Graph "\stataproject\educ_wagegap\out\C_rel_wage_supply.gph",replace;

rename rel_wage jp_rel_wage;
rename rel_supply jp_rel_supply;
sort year;
save "\stataproject\educ_wagegap\data\C_jp_us_figure.dta",replace;


