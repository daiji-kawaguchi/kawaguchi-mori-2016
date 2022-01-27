#delimit ;
cap log close;
log using "\stataproject\educ_wagegap\log\figure_pc.log",replace;
clear;

use "\stataproject\educ_wagegap\data\C_pctile.dta";

//* Figure 1 *//
/* generate 50/10, 90/50 or 90/10 wage inequality */
keep if per_m==10 | per_m==50 | per_m==90;
sort year per_m;
by year: gen pmw_gap=pcm_wage[_n+1]-pcm_wage[_n];
*by year: gen pfw_gap=pcf_wage[_n+1]-pcf_wage[_n];

/* generate 90/10 wage inequality */
by year: gen pmw9010_gap=pcm_wage[_n+2]-pcm_wage[_n];
by year: gen pmr9010_gap=pcm_resid[_n+2]-pcm_resid[_n];
by year: gen pmw5010_gap=pcm_wage[_n+1]-pcm_wage[_n] if per_m==10;
by year: gen pmw9050_gap=pcm_wage[_n+1]-pcm_wage[_n] if per_m==50;

collapse(mean) pmw9010_gap pmr9010_gap pmw5010_gap pmw9050_gap,by(year);
sort year;
save "\stataproject\educ_wagegap\data\C_figure2.dta", replace;

/* figure 2 */
gen pmw9010_gap05=pmw9010_gap if year>=2005;
replace pmw9010_gap=. if year>=2005;
gen pmr9010_gap05=pmr9010_gap if year>=2005;
replace pmr9010_gap=. if year>=2005;
gen pmw5010_gap05=pmw5010_gap if year>=2005;
replace pmw5010_gap=. if year>=2005;
gen pmw9050_gap05=pmw9050_gap if year>=2005;
replace pmw9050_gap=. if year>=2005;

graph twoway connected pmw9010_gap year,yaxis(1) ytitle("Log Hourly Wage Ratio")  xtitle("Year")  mcolor(black) msymbol(0)
|| connected pmw9010_gap05 year,mcolor(black) msymbol(0)  || connected pmr9010_gap year, mcolor(gs8) msymbol(D)
|| connected pmr9010_gap05 year, mcolor(gs8) msymbol(D)  || connected pmw5010_gap year,mcolor(black) msymbol(T)
|| connected pmw5010_gap05 year ,mcolor(black) msymbol(T) || connected pmw9050_gap year, mcolor(gs8) msymbol(S)
|| connected pmw9050_gap05 year, mcolor(gs8) msymbol(S) ||,legend(label(1 "Overall 90/10") label(2 "")
label(3 "Residual 90/10") label(4 "") label(5 "Overall 50/10") label(6 "") label(7 "Overall 90/50") label(8 ""))
 scheme(s2mono);
graph save "\stataproject\educ_wagegap\out\C_905010_gap.gph", replace;
