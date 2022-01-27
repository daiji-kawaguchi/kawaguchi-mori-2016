#delimit ;
cap log close;
log using "\stataproject\educ_wagegap\log\figure_pc.log",replace;
clear;

use "\stataproject\educ_wagegap\data\pctile.dta";

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
save "\stataproject\educ_wagegap\data\figure2.dta", replace;

/* figure 2 */
graph twoway connected pmw9010_gap year,yaxis(1) ytitle("Log Hourly Wage Ratio")  xtitle("Year")
|| connected pmr9010_gap year  || connected pmw5010_gap year
|| connected pmw9050_gap year ||,legend(label(1 "Overall 90/10") 
label(2 "Residual 90/10") label(3 "Overall 50/10")label(4 "Overall 90/50"))
 scheme(s2mono);
graph save "\stataproject\educ_wagegap\out\905010_gap.gph", replace;
