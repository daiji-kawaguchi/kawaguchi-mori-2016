# delimit;
set more off;
cap log close;
*log using "\stataproject\educ_wagegap\log\regress_japan.log",replace;

/* Create Dataset */ 
use "\stataproject\educ_wagegap\data\rlwage_4age.dta", clear;
drop if  educ==2;
drop wei_hour;
reshape wide pwage,i(year agegroup4) j(educ);
rename pwage1 hlwage;
rename pwage3 clwage;
gen rel_age_wage=clwage-hlwage;
sort year agegroup4;
save "\stataproject\educ_wagegap\data\regress_by_age.dta",replace;

use "\stataproject\educ_wagegap\data\by_age_supply.dta", clear;
gen lsupply=log(supply);
reshape wide supply lsupply ,i(year agegroup4) j(educ);
rename lsupply1 hlsupply;
rename lsupply3 clsupply;
rename supply1 hsupply;
rename supply3 csupply;
gen rel_age_supply=clsupply-hlsupply;
sort year agegroup4;
merge year agegroup4 using "\stataproject\educ_wagegap\data\regress_by_age.dta";
tab _merge;
drop _merge;

preserve;
use "\stataproject\educ_wagegap\data\overall_supply.dta",clear;
gen lsupply=log(supply);
reshape wide supply lsupply  ,i(year) j(educ);
rename supply1 all_hsupply;
rename supply3 all_csupply;
rename lsupply1 all_hlsupply;
rename lsupply3 all_clsupply;
gen rel_all_supply=all_clsupply-all_hlsupply;
sort year;
save "\stataproject\educ_wagegap\data\regress_all_age.dta",replace;
restore;

sort year;
merge year using "\stataproject\educ_wagegap\data\regress_all_age.dta";
tab _merge;
drop _merge;

preserve; 
use "\stataproject\educ_wagegap\data\weight_for_regress.dta",clear;
sort year;
save "\stataproject\educ_wagegap\data\weight_for_regress.dta",replace;
restore;

sort year;
merge year using "\stataproject\educ_wagegap\data\weight_for_regress.dta";
tab _merge;
drop _merge;

sort year agegroup4;
merge year agegroup4 using "\stataproject\educ_wagegap\data\pop_share.dta";
tab _merge;
drop _merge;

preserve;
clear;
insheet using "\stataproject\educ_wagegap\data\minimumwage.csv";
drop us;
rename japan minimumwage;
sort year;
save  "\stataproject\educ_wagegap\data\minimumwage.dta",replace;
restore;

sort year;
merge year using "\stataproject\educ_wagegap\data\minimumwage.dta";
gen lmin=log(minimumwage)
tab _merge;
drop _merge;

sort agegroup4;
gen trend=year-1985;
gen dif_own_all= rel_age_supply- rel_all_supply;


save "\stataproject\educ_wagegap\data\japanregress.dta",replace;

//* Regression Analysis based on C&L(2001) *//

/* 1st step */
xi: reg  rel_age_wage rel_age_supply i.agegroup4 i.year [aweight=weight];
outreg2 using "\stataproject\educ_wagegap\out\1st_stage.txt"
,replace se nonotes noaster bdec(3);

/* calculate sigma and eta */;
gen sigma_a=-(1/_b[rel_age_supply]);
gen rho=1-1/ sigma_a;

///* regression eq.(9), (10) *///;

/* regression eq.(9): collage */
/* calculate dep. var. */;
xi i.year i.agegroup4,noomit prefix(_D);
gen dep_9=clwage+(1/sigma_a)*log(csupply);

/* regression (9) */;
reg  dep_9  _Dyear_1986-_Dyear_2008 _Dagegroup4_1-_Dagegroup4_4 [aweight=weight];
outreg2 using "\stataproject\educ_wagegap\out\reg_910.txt",replace se nonotes noaster bdec(2);

/* calculate alpha */;
gen alpha=exp(_b[_Dagegroup4_1]) if agegroup4==1;
forvalues i=2/4{;
replace alpha=exp(_b[_Dagegroup4_`i']) if agegroup4==`i';
};

/* regression (10) */;
/* calculate dep. var. */;
gen dep_10=hlwage+(1/sigma_a)*log(hsupply);

/* regression (10) */;
reg  dep_10  _Dyear_1986-_Dyear_2008 _Dagegroup4_1-_Dagegroup4_4 [aweight=weight];
outreg2 using "\stataproject\educ_wagegap\out\reg_910.txt",append se nonotes noaster bdec(2);

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
gen trend2=trend^2;
gen trend_us=trend*0.013*0.724796912;
gen DV2=rel_age_wage-trend_us;


/* second stage; eq.(7) */;
reg rel_age_wage trend  hdif_sup lagg_ch _Dagegroup4_2-_Dagegroup4_4  [aweight=weight];
outreg2 using "\stataproject\educ_wagegap\out\reg_7.xls",replace se 
nonotes noaster bdec(3) keep(trend hdif_sup lagg_ch);

reg rel_age_wage trend  hdif_sup lagg_ch lmin _Dagegroup4_2-_Dagegroup4_4  [aweight=weight];
outreg2 using "\stataproject\educ_wagegap\out\reg_7.xls",append se 
nonotes noaster bdec(3) keep(trend hdif_sup lagg_ch lmin);

reg rel_age_wage trend  hdif_sup lagg_ch _Dagegroup4_2-_Dagegroup4_4  [aweight=weight];

gen jp_trend=_b[trend];
gen jp_own=_b[hdif_sup];
gen jp_agg=_b[lagg_ch];
gen jp_age2=_b[_Dagegroup4_2];
gen jp_age3=_b[_Dagegroup4_3];
gen jp_age4=_b[_Dagegroup4_4];
gen jp_con=_b[_cons];

/*IV */;
ivreg2 rel_age_wage trend  (hdif_sup lagg_ch = dif_pop dif_all_pop) _Dagegroup4_2-_Dagegroup4_4
  [aweight=weight],first;
outreg2 using "\stataproject\educ_wagegap\out\reg_7.xls",append se  
nonotes noaster bdec(3) keep(trend hdif_sup lagg_ch);

/* Using US trend estimates 
DV2=rel_age_wage-trend*0.016*0.724796912 */;
reg DV2  hdif_sup lagg_ch _Dagegroup4_2-_Dagegroup4_4  [aweight=weight];
outreg2 using "\stataproject\educ_wagegap\out\reg_7.xls",append se 
nonotes noaster bdec(3) keep(trend hdif_sup lagg_ch);

predict fv_dv2;
gen fv_relwage=fv_dv2+trend*0.013*0.724796912;

corr rel_age_wage fv_relwage [aweight=weight];
di r(rho)^2;

gen jp2_own=_b[hdif_sup];
gen jp2_agg=_b[lagg_ch];
gen jp2_age2=_b[_Dagegroup4_2];
gen jp2_age3=_b[_Dagegroup4_3];
gen jp2_age4=_b[_Dagegroup4_4];
gen jp2_con=_b[_cons];

/* preserve coefficients */

rename alpha jp_alpha;
rename beta jp_beta;
rename rho jp_rho;

gen jp_weight=(csupply+hsupply)/(all_csupply+all_hsupply);

rename hdif_sup jp_age_supply;
rename lagg_ch jp_all_supply;
rename rel_age_wage jp_wage;
rename csupply jp_csupply;
rename hsupply jp_hsupply;
rename rel_age_supply jp_rel_age_supply;



keep jp_trend jp_own jp_agg jp_age2 jp_age3 jp_age4 jp_con jp2_own jp2_agg jp2_age2 jp2_age3 jp2_age4 jp2_con
year agegroup4 jp_rel_age_supply jp_age_supply jp_all_supply jp_wage jp_weight jp_alpha jp_beta 
jp_rho jp_csupply jp_hsupply;
sort year agegroup4;
save "\stataproject\educ_wagegap\data\jp_simulate.dta",replace;

cap log close;
