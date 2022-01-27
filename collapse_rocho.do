#delimit ;
cap log close;
log using "\stataproject\educ_wagegap\log\collapse_rocho.log",replace;
clear;
*clear matrix;
set mem 2000m;
set more off;

use "\stataproject\educ_wagegap\data\rocho_wage.dta", clear;
drop  month district  mar rel n15 nu15_03 nu15_46 nu15_79 nu15_1012 nu15_1314;
/* Sample restriction */;
*drop if hour<35;
drop if sex==2;

/* replace age(year) to age(nendo) */
gen cohort=1925+birth_year if birth_nengo==3;
replace cohort=1911+birth_year if birth_nengo==2;
replace cohort=1867+birth_year if birth_nengo==1;
replace cohort=1988+birth_year if birth_nengo==4;
replace cohort=birth_year if birth_nengo==5 | birth_nengo==0;
replace cohort=cohort-1 if birth_month<=3;
replace age=year-cohort;

keep if age>=25 & age<=59;

/* drop in school & generate education index before 2001 */
keep if educ_stat==2 | year>=2002;
replace educ=educ_year if year<=2001;
replace educ=educ-1 if year<=2001 & educ>=2;
drop if educ==.;

/* drop in school & generate education index after 2002 */
drop if educ<=3 & year>=2002;
drop if educ==7 | educ==.;
replace educ=educ-3 if year>=2002;
label drop educ;
 
/* generate age groups */
recode age  (25/29=1) (30/39=2) (40/49=3) (50/59=4) , gen(agegroup4);


/* keep working status = main worker */
keep if empstat==1;

/* generate dummy for education and quartic in experience and age */
gen college=1 if educ==3;
replace college=0 if college==.;
gen j_college=1 if educ==2;
replace j_college=0 if j_college==.;

recode agegroup4 (1=27) (2=35) (3=45) (4=55),gen(age_g);
gen college_age_g=college*age_g;
gen j_college_age_g=j_college*age_g;
gen college_age=college*age;
gen j_college_age=j_college*age;

forvalues i=2/4 {;
gen age`i'_g=age_g^`i';
gen college_age`i'_g=college*age`i'_g;
gen j_college_age`i'_g=j_college*age`i'_g;
gen age`i'=age^`i';
gen college_age`i'=college*age`i';
gen j_college_age`i'=j_college*age`i';
};


/* translate wage to real wage using CPI */
preserve;
clear; 
insheet using "\stataproject\educ_wagegap\data\CPI.csv";
gen deflator=cpi/100;
sort year;
save "\stataproject\educ_wagegap\data\CPI.dta",replace;
restore;

sort year;
merge year using "\stataproject\educ_wagegap\data\CPI.dta";
drop _merge;
gen rwage=deflator*wage;
gen rlwage=log(rwage);


/* caliculate geographic mean */
preserve;
collapse(count) rlwage,by(year prefecture);
sort year ;
rename rlwage population;
by year : egen tot_pop=total(population);
gen mean_pop=population/tot_pop;
drop population tot_pop;
reshape wide mean_pop,i(year) j(prefecture);
sort year ;
save "\stataproject\educ_wagegap\data\prefecture.dta",replace;
restore;

sort year ;
merge year  using "\stataproject\educ_wagegap\data\prefecture.dta",;
tab _merge;
drop _merge;
rename prefecture pref;

//* construct relative wage series by sex-education-experience groups *//

forvalues t=0/22 {;
local s=`t'+1986;

xi: reg rlwage age age2 age3 age4 college j_college college_age college_age2 college_age3 college_age4 
j_college_age j_college_age2 j_college_age3 j_college_age4 i.pref if year==`s' & sex==1 & class<=4;

gen pm=_b[_cons]+_b[age]*age_g+_b[age2]*age2_g+_b[age3]*age3_g+_b[age4]*age4_g+
_b[college]*college+_b[j_college]*j_college+_b[college_age]*college_age_g+
_b[college_age2]*college_age2_g+_b[college_age3]*college_age3_g+_b[college_age4]*college_age4_g+
_b[j_college_age]*j_college_age_g+_b[j_college_age2]*j_college_age2_g+_b[j_college_age3]*j_college_age3_g+
_b[j_college_age4]*j_college_age4_g+_b[_Ipref_2]*mean_pop2-_b[_Ipref_47]*mean_pop47 if e(sample) ;*/;


if `t'==0 {;
gen pwage=pm;
};
if `t'>0 {;
replace pwage=pm if pwage==.;
};
drop pm;
};



/* weight dataset for regression */
forvalues t=0/22 {;
local s=`t'+1986;
forvalues i=1/4 {;
reg lwage college if year==`s' & agegroup4==`i';
gen se=_se[college] if e(sample);

if `t'==0 & `i'==1{;
gen weight=1/(se^2);
};
else {;
replace weight=1/(se^2) if weight==.;
};
drop se;
};
};

preserve;
collapse(mean) weight, by(year agegroup4);
save "\stataproject\educ_wagegap\data\weight_for_regress.dta",replace;
restore;

/* generate fixed weight for calculation of composition-adjusted mean */
preserve;
collapse(sum) hour ,by(year agegroup4);
sort year;
by year:egen total_hour=total(hour);
gen wei_hour=hour/total_hour;
keep wei_hour agegroup4 year;
sort year agegroup4;
save "\stataproject\educ_wagegap\data\rlwage_4age_weight.dta",replace;
restore;

preserve;
collapse(sum) hour ,by(educ age);
sort educ age;
save "\stataproject\educ_wagegap\data\rlwage_age_weight.dta",replace;
restore;

preserve;
collapse(mean) pwage ,by(year educ agegroup4);
sort  year agegroup4;
merge year agegroup4 using "\stataproject\educ_wagegap\data\rlwage_4age_weight.dta"; 
drop _merge;
save "\stataproject\educ_wagegap\data\rlwage_4age.dta",replace;
restore;

preserve;
collapse(mean) pwage ,by(year educ age);
sort educ age;
merge educ age using "\stataproject\educ_wagegap\data\rlwage_age_weight.dta"; 
drop _merge;
save "\stataproject\educ_wagegap\data\rlwage_age.dta",replace;
restore;


/* generate residual for figure 2*/
forvalues t=0/22 {;
local s=`t'+1986;
xi:reg lwage college j_college i.age college_age college_age2 college_age3 college_age4 
j_college_age j_college_age2 j_college_age3 j_college_age4 if year==`s'  & class>=4;
predict re if e(sample),residuals ;
if `t'==0 {;
gen resid=re;
};
if `t'>0 {;
replace resid=re if resid==.;
};
drop re;
};

/* generate percentile data */
# delimit;
forvalues t=0/22 {;
local s=`t'+1986;
preserve;
pctile pcm_wage=rlwage if sex==1 & year==`s' & class>=4,nq(100) genp(per_m);
pctile pcm_resid=resid if sex==1 & year==`s' & class>=4,nq(100) genp(resid_m);
keep pcm_wage  per_m pcm_resid resid_m;
drop if pcm_wage==. ;
gen year=`s';
if `t'>=1 {;
append using "\stataproject\educ_wagegap\data\pctile.dta";
};
save "\stataproject\educ_wagegap\data\pctile.dta",replace;
restore;
};

/* construct relative supply */

/* generate weight for junior collage */
xi: reg rwage age age2 age3 age4  college j_college i.pref  i.year;

gen b_high=_b[_cons];
gen b_some=_b[j_college];
gen b_college=_b[college];

gen CL_share=b_some/b_college;
gen HS_share=1-CL_share;
display HS_share CL_share;

/* generate quantity data */
collapse(sum)hour (mean) HS_share CL_share ,by(year educ age agegroup4);
sort year educ age;
merge year educ age using "\stataproject\educ_wagegap\data\jp_pop_age.dta";
drop _merge;
gen supply=hour ;

/* age supply */
preserve;
collapse(sum) supply  (mean) HS_share CL_share,by(year educ age);
reshape wide supply ,i(year age) j(educ);
replace supply1=supply1+supply2*HS_share;
replace supply3=supply3+supply2*CL_share;
drop supply2 HS_share CL_share;
reshape long supply,i(year age) j(educ);
save "\stataproject\educ_wagegap\data\age_supply.dta", replace;
restore;

/* overall supply */
preserve;
collapse(sum) supply  (mean) HS_share CL_share,by(year educ);
sort year educ;

/* divide junior college worker into college and high school worker */
reshape wide supply ,i(year) j(educ);
replace supply1=supply1+supply2*HS_share;
replace supply3=supply3+supply2*CL_share;
drop supply2  HS_share CL_share;
reshape long supply ,i(year) j(educ);
save "\stataproject\educ_wagegap\data\overall_supply.dta", replace;
restore;

/* supply by age group */
collapse(sum) supply  (mean) HS_share CL_share,by(year educ agegroup4);
reshape wide supply ,i(year agegroup4) j(educ);
replace supply1=supply1+supply2*HS_share;
replace supply3=supply3+supply2*CL_share;
drop supply2 HS_share CL_share ;
reshape long supply,i(year agegroup4) j(educ);
save "\stataproject\educ_wagegap\data\by_age_supply.dta", replace;


log close;
