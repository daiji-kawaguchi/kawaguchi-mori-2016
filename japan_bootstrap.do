#delimit;
cd E:\;
cap log close;
set more off;
log using "stataproject\educ_wagegap\log\bootstrap_jp.log",replace;
clear all;
set mem 2g;
set seed 1;
local nrep=500;
set matsize 500;
matrix results=J(`nrep', 15, .);

forvalues i=1/`nrep' {;
di `i';
qui clear;
qui use "stataproject\educ_wagegap\data\japanregress.dta";
qui bsample;

//* Regression Analysis based on C&L(2001) *//
/* 1st step */
qui xi: reg  rel_age_wage rel_age_supply i.agegroup4 i.year [aweight=weight];

/* calculate sigma and eta */;
gen sigma_a=-(1/_b[rel_age_supply]);
gen rho=1-1/ sigma_a;
qui matrix results[`i', 1]=1-1/(-(1/_b[rel_age_supply]));
///* regression eq.(9), (10) *///;

/* regression eq.(9): collage */
/* calculate dep. var. */;
qui xi i.year i.agegroup4,noomit prefix(_D);
gen dep_9=clwage+(1/sigma_a)*log(csupply);

/* regression (9) */;
qui xi: reg  dep_9  i.year _Dagegroup4_1-_Dagegroup4_4 [aweight=weight];

/* calculate alpha */;
gen alpha=exp(_b[_Dagegroup4_1]) if agegroup4==1;
forvalues j=2/4{;
replace alpha=exp(_b[_Dagegroup4_`j']) if agegroup4==`j';
};
qui matrix results[`i', 2]=_b[_Dagegroup4_1];
qui matrix results[`i', 3]=_b[_Dagegroup4_2];
qui matrix results[`i', 4]=_b[_Dagegroup4_3];
qui matrix results[`i', 5]=_b[_Dagegroup4_4];

/* regression (10) */;
/* calculate dep. var. */;
gen dep_10=hlwage+(1/sigma_a)*log(hsupply);

/* regression (10) */;
qui xi: reg  dep_10  i.year _Dagegroup4_1-_Dagegroup4_4 [aweight=weight];

/* calculate beta */;
gen beta=exp(_b[_Dagegroup4_1]) if agegroup4==1;
forvalues j=2/4{;
replace beta=exp(_b[_Dagegroup4_`j']) if agegroup4==`j';
};
qui matrix results[`i', 6]=_b[_Dagegroup4_1];
qui matrix results[`i', 7]=_b[_Dagegroup4_2];
qui matrix results[`i', 8]=_b[_Dagegroup4_3];
qui matrix results[`i', 9]=_b[_Dagegroup4_4];

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
/* Using US trend estimates 
DV2=rel_age_wage-trend*0.016*0.724796912 */;
qui reg DV2  hdif_sup lagg_ch _Dagegroup4_2-_Dagegroup4_4  [aweight=weight];

qui matrix results[`i', 10]=_b[hdif_sup];
qui matrix results[`i', 11]=_b[lagg_ch];
qui matrix results[`i', 12]=_b[_Dagegroup4_2];
qui matrix results[`i', 13]=_b[_Dagegroup4_3];
qui matrix results[`i', 14]=_b[_Dagegroup4_4];
qui matrix results[`i', 15]=_b[_cons];

};

svmat results;
centile results1-results15, centile(2.5 50 97.5);
log close;
