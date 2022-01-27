#delimit ;
*cd G:;
cap log close;
*log using "\stataproject\educ_wagegap\log\supply_and_wage.log",replace;
clear;
set mem 2000m;
set more off;

/* weight for allocation of some college to college and high school categories */
use "\stataproject\educ_wagegap\data\re_price.dta",replace;
xi: reg lwage agely age2 age3 age4 beduc2 beduc3 female midwest northeast south
 i.year [pw=wgt_wks];

gen b_high=_b[_cons];
gen b_some=_b[beduc2];
gen b_college=_b[beduc3];

gen some_to_cl=b_some/b_college;
gen some_to_h=1-some_to_cl;

collapse(mean)  some_to_cl  some_to_h,by(year);
sort year;
save "\stataproject\educ_wagegap\data\weight_somedrop.dta",replace; 

/***************************
Construct supply measure 
****************************/

use "\stataproject\educ_wagegap\data\re_supply.dta",clear;
drop if female==1;
gen supply=hrslwk;
sort year;
merge year using "\stataproject\educ_wagegap\data\weight_somedrop.dta";
drop _merge;
recode agely (25/29=1) (30/39=2) (40/49=3) (50/59=4),gen(agegroup4);
collapse(sum) supply (mean) some_to_cl some_to_h,by(year beduc agegroup4);

reshape wide supply,i(year agegroup4) j(beduc);
gen h_supply= supply1+ supply2*some_to_h;
gen c_supply=some_to_cl* supply2+ supply3;

keep  agegroup4 year c_supply h_supply ;
save "\stataproject\educ_wagegap\data\cps_supply_agegroup4.dta",replace;

collapse(sum)  c_supply h_supply ,by(year);
gen rel_lsupply=log( c_supply)-log( h_supply);
save "\stataproject\educ_wagegap\data\cps_overall_supply.dta",replace;
keep rel_lsupply year;
sort year;
save "\stataproject\educ_wagegap\data\cps_all_relsupply.dta",replace;

/**************************
Construct wage measure 
**************************/
use \stataproject\educ_wagegap\data\re_mcps.dta,clear;
* Men Only *;
drop if female==1;
drop if beduc==2 | beduc>=4;
sort year agegroup;
by year agegroup: egen all_hour=total(rel_hour);
by year: egen all_year_hour=total(rel_hour);
replace rel_hour=all_hour/all_year_hour;
drop all_year_hour all_hour;
reshape wide p ,i(year agegroup) j(beduc);
gen rel_lwage= p3- p1;
save "\stataproject\educ_wagegap\data\us_relwage_groups.dta",replace;
preserve;
keep year agegroup rel_hour;
sort year agegroup;
rename agegroup agegroup4;
rename rel_hour us_hour;
save "\stataproject\educ_wagegap\data\us_simweight.dta",replace;
restore;

replace rel_lwage=rel_lwage*rel_hour;

collapse(sum) rel_lwage,by(year);
sort year;
save "\stataproject\educ_wagegap\data\us_agg_wage.dta",replace;

sort year;
merge year using "\stataproject\educ_wagegap\data\cps_all_relsupply.dta";
drop  _merge;
gen us_rel_lwage=rel_lwage;
rename rel_lsupply us_rel_lsupply;
sort year;
merge year using "\stataproject\educ_wagegap\data\jp_us_figure.dta";
keep if year>=1986 & year<=2006;

* Fulltime *;
/*
twoway connected jp_rel_wage year,yaxis(1) ytitle("Relative Wage", axis(1)) xtitle("Year") 
|| connected us_rel_lwage year,yaxis(1) 
|| connected jp_rel_supply year,yaxis(2) ytitle("Relative Supply", axis(2))
|| connected us_rel_lsupply year,yaxis(2)
||, legend(label (1 "Japan Wage") label(2 "US Wage") label(3 "Japan Supply") 
label(4 "US Supply"))  scheme(s2mono)
text(.35 1986 "0.35",place(s)) text(.28 2005.5 "0.29",place(s))
text(.42 1986 "0.43",place(s)) text(.68 2005.5 "0.65",place(s))
text(.22 1986 "-1.19",place(n)) text(.54 2005.5 "-0.47",place(s))
text(.6 1986 "-0.39",place(n)) text(.7 2005.5 "-0.17",place(n));
*/
*All workers;
twoway connected jp_rel_wage year,yaxis(1) ytitle("Relative Wage", axis(1)) xtitle("Year") 
|| connected us_rel_lwage year,yaxis(1) 
|| connected jp_rel_supply year,yaxis(2) ytitle("Relative Supply", axis(2))
|| connected us_rel_lsupply year,yaxis(2)
||, legend(label (1 "Japan Wage") label(2 "US Wage") label(3 "Japan Supply") 
label(4 "US Supply"))  scheme(s2mono)
text(.32 1986 "-1.24",place(n)) text(.35 2005.5 "0.34",place(n))
text(.44 1986 "0.47",place(n)) text(.70 2005.5 "0.70",place(n))
text(.38 1986 "0.35",place(n)) text(.56 2005.5 "-0.56",place(n))
text(.62 1986 "-0.37",place(n)) text(.68 2005.5 "-0.14",place(s));
*/;
graph save Graph "\stataproject\educ_wagegap\out\jp_us_figure.gph",replace;
/*
twoway connected jp_rel_wage year,yaxis(1) ytitle("Relative Wage", axis(1)) xtitle("Year") 
|| connected jp_rel_supply year,yaxis(2) ytitle("Relative Supply", axis(2))
||, legend(label (1 "Japan Wage") label(2 "Japan Supply"))  scheme(s2mono)
yscale(range(.22 (.02) .34));
