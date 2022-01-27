# delimit;
set more off;
use "\stataproject\educ_wagegap\data\us_relwage_groups.dta",clear;
rename rel_lwage rel_age_wage;
rename  p3 clwage;
rename  p1 hlwage;
rename agegroup agegroup4;
sort year agegroup4;
drop female rel_hour;
save "\stataproject\educ_wagegap\data\cps_regress_by_age.dta",replace;

use "\stataproject\educ_wagegap\data\cps_supply_agegroup4.dta",clear;
gen rel_age_supply=log(c_supply)-log(h_supply);
rename c_supply csupply;
rename h_supply hsupply;
sort year agegroup4;
merge year agegroup4 using "\stataproject\educ_wagegap\data\cps_regress_by_age.dta";
tab _merge;
drop _merge;

preserve;
use "\stataproject\educ_wagegap\data\cps_overall_supply.dta",replace;
gen rel_all_supply=log(c_supply)-log(h_supply);
sort year;
save "\stataproject\educ_wagegap\data\cps_regress_all_age.dta",replace;
restore;

sort year;
merge year using "\stataproject\educ_wagegap\data\cps_regress_all_age.dta";
tab _merge;
drop _merge;

preserve; 
use "\stataproject\educ_wagegap\data\cps_weight.dta",clear;
sort year agegroup4;
save "\stataproject\educ_wagegap\data\cps_weight.dta",replace;
restore;

sort year agegroup4;
merge year agegroup4 using "\stataproject\educ_wagegap\data\cps_weight.dta";
tab _merge;
keep if _merge==3;
drop _merge;

sort year agegroup4;
merge year agegroup4 using "\stataproject\educ_wagegap\data\cps_pop_share.dta";
tab _merge;
drop _merge;

preserve;
clear;
insheet using "\stataproject\educ_wagegap\data\minimumwage.csv";
drop japan;
rename us minimumwage;
sort year;
save  "\stataproject\educ_wagegap\data\minimumwage.dta",replace;
restore;

sort year;
merge year using "\stataproject\educ_wagegap\data\minimumwage.dta";
gen lmin=log(minimumwage);
tab _merge;
drop _merge;

sort agegroup4;
gen trend=year-1962;

save "\stataproject\educ_wagegap\data\usregress.dta",replace;

/* 1st step */
keep if year>=1963 & year<=2006;
xi: reg  rel_age_wage rel_age_supply i.agegroup4 i.year [aw=weight];
outreg2 using "\stataproject\educ_wagegap\out\cps_1st_stage.txt"
,replace se nonotes noaster bdec(3);

/* calculate sigma and eta */;
gen sigma_a=-(1/_b[rel_age_supply]);
gen rho=1-(1/sigma_a);

///* regression eq.(9), (10) *///;

/* regression eq.(9): collage */
/* calculate dep. var. */;
xi i.year i.agegroup4,noomit prefix(_D);
gen dep_9=clwage+(1/sigma_a)*log(csupply);

/* regression (9) */;
reg  dep_9  _Dyear_1975-_Dyear_2005 _Dagegroup4_1-_Dagegroup4_4  [aw=weight];
outreg2 using "\stataproject\educ_wagegap\out\cps_reg_910.txt",replace se nonotes noaster bdec(3);

/* calculate alpha */;
gen alpha=exp(_b[_Dagegroup4_1]) if agegroup4==1;
forvalues i=2/4{;
replace alpha=exp(_b[_Dagegroup4_`i']) if agegroup4==`i';
};

/* regression (10) */;
/* calculate dep. var. */;
gen dep_10=hlwage+(1/sigma_a)*log(hsupply);

/* regression (10) */;
reg  dep_10  _Dyear_1975-_Dyear_2005 _Dagegroup4_1-_Dagegroup4_4  [aw=weight];
outreg2 using "\stataproject\educ_wagegap\out\cps_reg_910.txt",append se nonotes noaster bdec(3);

/* calculate beta */;
gen beta=exp(_b[_Dagegroup4_1]) if agegroup4==1;
forvalues i=2/4{;
replace beta=exp(_b[_Dagegroup4_`i']) if agegroup4==`i';
};

///* regression eq.(7) *///;

/* calculate high/collage aggregate labour input  */;

gen alpha_collage=alpha*(csupply^rho);
gen beta_high=beta*(hsupply^rho);

/* sum up alpha_collage & beta_collage by year */;
sort year;
by year: egen collage_sum=total(alpha_collage);
by year: egen high_sum=total(beta_high);

/* generate aggregate data  */;
gen agg_collage=collage_sum^(1/rho);
gen agg_high=high_sum^(1/rho);

/* generate (own supply - aggregate supply) */;
gen lagg_ch=log(agg_collage/ agg_high);
gen hdif_sup= rel_age_supply -lagg_ch;



/* regression eq.(7) */;

reg rel_age_wage trend hdif_sup lagg_ch _Dagegroup4_2-_Dagegroup4_4  [aw=weight];
outreg2 using "\stataproject\educ_wagegap\out\cps_reg_7.xls",replace se 
nonotes noaster bdec(3) keep(trend hdif_sup lagg_ch);

reg rel_age_wage trend hdif_sup lagg_ch lmin _Dagegroup4_2-_Dagegroup4_4  [aw=weight];
outreg2 using "\stataproject\educ_wagegap\out\cps_reg_7.xls",append se 
nonotes noaster bdec(3) keep(trend hdif_sup lagg_ch lmin);

/* preserve coefficients */
gen us_trend=_b[trend];
gen us_own=_b[hdif_sup];
gen us_agg=_b[lagg_ch];
gen us_age2=_b[_Dagegroup4_2];
gen us_age3=_b[_Dagegroup4_3];
gen us_age4=_b[_Dagegroup4_4];
gen us_con=_b[_cons];
rename alpha us_alpha;
rename beta us_beta;
rename rho us_rho;

/* IV */;
ivreg2 rel_age_wage trend (hdif_sup lagg_ch = dif_pop dif_all_pop) _Dagegroup4_2-_Dagegroup4_4  [aw=weight],first;
outreg2 using "\stataproject\educ_wagegap\out\cps_reg_7.xls",append se 
nonotes noaster bdec(3) keep(trend hdif_sup lagg_ch);

gen us_weight=(csupply+hsupply)/(c_supply+h_supply);

rename hdif_sup us_age_supply;
rename lagg_ch us_all_supply;
rename csupply us_csupply;
rename hsupply us_hsupply;
rename rel_age_supply us_rel_age_supply;

rename rel_age_wage us_wage;


keep us_trend us_own us_agg us_age2 us_age3 us_age4 us_con year agegroup4 
us_age_supply us_all_supply us_wage us_weight trend  us_alpha us_beta us_rho
us_csupply us_hsupply us_rel_age_supply;
sort year agegroup4;
save "\stataproject\educ_wagegap\data\us_simulate.dta",replace;
