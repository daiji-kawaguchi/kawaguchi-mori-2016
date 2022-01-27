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
/*
* Men & Female ;
gen w0= p* rel_hour;
sort year agegroup beduc;
by year agegroup beduG: egen w1=sum(rel_hour);
by year agegroup beduG: egen w2=sum(w0);
gen w=w2/w1;
replace p=w;
drop if female==1;
drop w w0 w1 w2;
*/
drop if beduc==2 | beduc>=4;
reshape wide p rel_hour,i(year agegroup) j(beduc);
gen rel_lwage= p3- p1;
save "\stataproject\educ_wagegap\data\us_relwage_groups.dta",replace;

gen h_p0=rel_hour1*p1;
gen c_p0=rel_hour3*p3;
sort year agegroup ;
by year  :egen h_p1=sum(h_p0);
by year  :egen h_p2=sum(rel_hour1);
by year  :egen c_p1=sum(c_p0);
by year  :egen c_p2=sum(rel_hour3);
gen h_p=h_p1/h_p2;
gen c_p=c_p1/c_p2;
collapse(mean) h_p c_p,by(year);
sort year;
save "\stataproject\educ_wagegap\data\us_agg_wage.dta",replace;

sort year;
merge year using "\stataproject\educ_wagegap\data\cps_all_relsupply.dta";
drop  _merge;
gen us_rel_lwage=c_p-h_p;
rename rel_lsupply us_rel_lsupply;
sort year;
merge year using "\stataproject\educ_wagegap\data\C_jp_us_figure.dta";
keep if year>=1986 ;

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
gen jp_rel_wage05=jp_rel_wage if year>=2005;
replace jp_rel_wage=. if year>=2005;
gen jp_rel_supply05=jp_rel_supply if year>=2005;
replace jp_rel_supply=. if year>=2005;

twoway connected jp_rel_wage year,yaxis(1) msymbol(0) mcolor(black) yscale(range(.22 .34)) 
ylabel(.22 (.02) .34) ytitle("Relative Wage", axis(1)) xtitle("Year") 
|| connected jp_rel_wage05 year,yaxis(1) msymbol(0) mcolor(black)
|| connected jp_rel_supply year,yaxis(2) msymbol(D) mcolor(gs8) ytitle("Relative Supply", axis(2))
|| connected jp_rel_supply05 year,yaxis(2) msymbol(D) mcolor(gs8)
||, legend(label (1 "Japan Wage") label(2 "") label(3 "Japan Supply") label(4 "")) scheme(s2manual) 
;
*/;
graph save Graph "\stataproject\educ_wagegap\out\C_jp_us_figure.gph",replace;
