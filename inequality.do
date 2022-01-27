# delimit;
cap log close;
set more off;
log using "\stataproject\educ_wagegap\log\inequality.log",replace;

/* US */
use "\stataproject\educ_wagegap\data\all_cps.dta", clear;
gen age_beduc1=agely*beduc1;
gen age2_beduc1=beduc1*(agely^2);

keep if female==0;
forvalues t=0/31 {;
local s=`t'+1975;
xi:reg lwage beduc2 beduc3 i.agely agely age2 age_beduc2 age_beduc3 age2_beduc2 age2_beduc3 if year==`s' ;
predict re if e(sample),residuals ;
if `t'==0 {;
gen resid=re;
};
if `t'>0 {;
replace resid=re if resid==.;
};
drop re;
};

sort year;

by year: egen us10=pctile(lwage),p(10);
by year: egen us50=pctile(lwage),p(50);
by year: egen us90=pctile(lwage),p(90);

by year: egen usres10=pctile(resid),p(10);
by year: egen usres90=pctile(resid),p(90);

collapse(mean) us10 us50 us90 usres10 usres90,by(year);
sort year;
merge year using "\stataproject\educ_wagegap\data\us_agg_wage.dta";
gen p9010=us90-us10;
gen p9050=us90-us50;
gen p5010=us50-us10;
gen educgap=rel_lwage;
gen res9010=usres90-usres10;

/* figure 2 US*/
graph twoway connected p9010 year,yaxis(1) ytitle("Log Hourly Wage Ratio") xtitle("Year")  
|| connected res9010 year  || connected p5010 year
|| connected p9050 year ||,legend(label(1 "Overall 90/10") 
label(2 "Residual 90/10") label(3 "Overall 50/10")label(4 "Overall 90/50"))
 scheme(s2mono);
graph save "\stataproject\educ_wagegap\out\us905010_gap.gph", replace;


keep year p9010 p9050 p5010 educgap;
gen us=1;
sort year us;
save "\stataproject\educ_wagegap\data\com_inequality.dta",replace;

/* Japan */
use "\stataproject\educ_wagegap\data\pctile.dta",clear;

keep if per_m==90 | per_m==50 | per_m==10;
keep year pcm_wage per_m;
reshape wide pcm_wage,i(year) j( per_m);

gen p9010=pcm_wage90-pcm_wage10;
gen p9050=pcm_wage90-pcm_wage50;
gen p5010=pcm_wage50-pcm_wage10;
keep year p9010 p9050 p5010 ;
gen us=0;
sort year;
save "\stataproject\educ_wagegap\data\jp_inequality.dta",replace;

use "\stataproject\educ_wagegap\data\jp_us_figure.dta",clear;
keep year jp_rel_wage;
rename jp_rel_wage educgap;
gen us=0;
sort year;
merge year using "\stataproject\educ_wagegap\data\jp_inequality.dta";
drop _merge;
sort year us;
merge year us using "\stataproject\educ_wagegap\data\com_inequality.dta";
sort _merge;
keep if year<=2006 & year>=1986;
save "\stataproject\educ_wagegap\data\com_inequality.dta",replace;

/* Regression */
reg p9010 us;
reg p9010 educgap us;
outreg2 using "\stataproject\educ_wagegap\out\inequality.txt",replace se 
nonotes noaster bdec(3);
reg p9050 us;
reg p9050 educgap us;
outreg2 using "\stataproject\educ_wagegap\out\inequality.txt",append se 
nonotes noaster bdec(3);
reg p5010 us;
reg p5010 educgap us;
outreg2 using "\stataproject\educ_wagegap\out\inequality.txt",append se 
nonotes noaster bdec(3);

log close;

