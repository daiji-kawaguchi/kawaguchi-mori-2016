#delimit ;
cap log close;
log using "\stataproject\educ_wagegap\log\collapse_census.log",replace;
clear;
*clear matrix;
set mem 2000m;
set more off;

use E:\stataproject\data\wagecensus1989-2008\data\wcm1989_2008.dta ,clear;
drop if sex==2;
keep if age>=25 & age<=59;

/*drop Rinjiroudousha */;
drop if contract==2 & year<=2004;
drop if contract==5 & year>=2005;

drop if occ>=852 & occ<=862 & year>=2005;
drop if occ==849 & year>=2005; drop if occ==209 & year>=2005; drop if occ==225 & year>=2005;
drop if occ==227 & year>=2005; drop if occ==203 & year>=2005; drop if occ==233 & year>=2005;
drop if occ==235 & year>=2005; drop if occ==210 & year>=2005; drop if occ==226 & year>=2005; 
drop if occ==228 & year>=2005; drop if occ==237 & year>=2005;

drop if educ==.;

recode age  (25/29=1) (30/39=2) (40/49=3) (50/59=4) , gen(agegroup4);

replace educ=1 if educ==2;
replace educ=2 if educ==3;
replace educ=3 if educ==4;
label drop educ;
label define educ 1 "Junior & High" 2 "Junior College" 3 "College";
label value educ educ;

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

/*
/* translate wage to real wage using CPI */
preserve;
clear; 
insheet using "\stataproject\educ_wagegap\data\CPI_89_08.csv";
gen deflator=cpi/100;
sort year;
save "\stataproject\educ_wagegap\data\CPI_89_08.dta",replace;
restore;
*/;

sort year;
merge year using "\stataproject\educ_wagegap\data\CPI_89_08.dta";
drop _merge;
drop if year<=1988;
gen rwage=deflator*wage;
gen rlwage=log(rwage);

/*
/* caliculate geographic mean */
preserve;
collapse(count) rlwage,by(year prefecture);
sort year;
rename rlwage population;
by year: egen tot_pop=total(population);
gen mean_pop=population/tot_pop;
drop population tot_pop;
drop if prefecture==.;
reshape wide mean_pop,i(year) j(prefecture);
sort year;
save "\stataproject\educ_wagegap\data\prefecture_c.dta",replace;
restore;
*/;

sort year ;
merge year using "\stataproject\educ_wagegap\data\prefecture_c.dta",;
tab _merge;
drop _merge;
rename prefecture pref;

//* construct relative wage series by sex-education-experience groups *//

forvalues t=0/19 {;
local s=`t'+1989;

xi: reg rlwage age age2 age3 age4 college j_college college_age college_age2 college_age3 college_age4 
j_college_age j_college_age2 j_college_age3 j_college_age4 i.pref [pweight=weight] if year==`s';

gen pm=_b[_cons]+_b[age]*age_g+_b[age2]*age2_g+_b[age3]*age3_g+_b[age4]*age4_g+
_b[college]*college+_b[j_college]*j_college+_b[college_age]*college_age_g+
_b[college_age2]*college_age2_g+_b[college_age3]*college_age3_g+_b[college_age4]*college_age4_g+
_b[j_college_age]*j_college_age_g+_b[j_college_age2]*j_college_age2_g+_b[j_college_age3]*j_college_age3_g+
_b[j_college_age4]*j_college_age4_g+_b[_Ipref_2]*mean_pop2-_b[_Ipref_47]*mean_pop47 if e(sample) ;*/;

gen pm2=_b[_cons]+_b[age]*age+_b[age2]*age2+_b[age3]*age3+_b[age4]*age4+
_b[college]*college+_b[j_college]*j_college+_b[college_age]*college_age+
_b[college_age2]*college_age2+_b[college_age3]*college_age3+_b[college_age4]*college_age4+
_b[j_college_age]*j_college_age+_b[j_college_age2]*j_college_age2+_b[j_college_age3]*j_college_age3+
_b[j_college_age4]*j_college_age4+_b[_Ipref_2]*mean_pop2-_b[_Ipref_47]*mean_pop47 if e(sample) ;

if `t'==0 {;
gen pwage=pm;
gen pwage2=pm2;
};
if `t'>0 {;
replace pwage=pm if pwage==.;
replace pwage2=pm2 if pwage2==.;
};
drop pm pm2;
};


/* weight dataset for regression */
forvalues t=0/19 {;
local s=`t'+1989;
forvalues i=1/4 {;
reg lwage college if year==`s' & sex==1 & agegroup4==`i';
gen se=_se[college] if e(sample);

if `t'==0 & `i'==1{;
gen weight2=1/(se^2);
};
else {;
replace weight2=1/(se^2) if weight2==.;
};
drop se;
};
};

preserve;
collapse(mean) weight2, by(year agegroup4);
save "\stataproject\educ_wagegap\data\C_weight_for_regress.dta",replace;
restore;

/* generate fixed weight for calculation of composition-adjusted mean */
preserve;
collapse(sum) hour ,by(educ agegroup4);
sort educ agegroup4;
save "\stataproject\educ_wagegap\data\C_rlwage_4age_weight.dta",replace;
restore;

preserve;
collapse(sum) hour ,by(educ age);
sort educ age;
save "\stataproject\educ_wagegap\data\C_rlwage_age_weight.dta",replace;
restore;

preserve;
collapse(mean) pwage ,by(year educ agegroup4);
sort educ agegroup4;
merge educ agegroup4 using "\stataproject\educ_wagegap\data\C_rlwage_4age_weight.dta"; 
drop _merge;
save "\stataproject\educ_wagegap\data\C_rlwage_4age.dta",replace;
restore;
drop pwage;

preserve;
collapse(mean) pwage2 ,by(year educ age);
sort educ age;
merge educ age using "\stataproject\educ_wagegap\data\C_rlwage_age_weight.dta"; 
drop _merge;
save "\stataproject\educ_wagegap\data\C_rlwage_age.dta",replace;
restore;


/* generate residual for figure 2*/
forvalues t=0/19 {;
local s=`t'+1989;
xi:reg lwage college j_college i.age college_age college_age2 college_age3 college_age4 
j_college_age j_college_age2 j_college_age3 j_college_age4 [pweight=weight]if year==`s';
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

forvalues t=0/19 {;
local s=`t'+1989;
preserve;
pctile pcm_wage=rlwage if year==`s' ,nq(100) genp(per_m);
pctile pcm_resid=resid if year==`s' ,nq(100) genp(resid_m);
keep pcm_wage per_m pcm_resid resid_m;
drop if pcm_wage==. ;
gen year=`s';
if `t'>=1 {;
append using "\stataproject\educ_wagegap\data\C_pctile.dta";
};
save "\stataproject\educ_wagegap\data\C_pctile.dta",replace;
restore;
};

/* construct relative supply */

drop if year<=1988;

/* generate weight for junior collage */
xi: reg rwage age age2 age3 age4  college j_college i.pref i.year [pweight=weight];

gen b_high=_b[_cons];
gen b_some=_b[j_college];
gen b_college=_b[college];

gen CL_share=b_some/b_college;
gen HS_share=1-CL_share;
display HS_share CL_share;

/* generate quantity data */
collapse(sum)hour (mean) HS_share CL_share ,by(year educ age agegroup4);
rename hour supply;

/* age supply */
preserve;
collapse(sum) supply  (mean) HS_share CL_share,by(year educ age);
reshape wide supply ,i(year age) j(educ);
replace supply1=supply1+supply2*HS_share;
replace supply3=supply3+supply2*CL_share;
drop supply2 HS_share CL_share;
reshape long supply,i(year age) j(educ);
save "\stataproject\educ_wagegap\data\C_age_supply.dta", replace;
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
save "\stataproject\educ_wagegap\data\C_overall_supply.dta", replace;
restore;

/* supply by age group */
collapse(sum) supply  (mean) HS_share CL_share,by(year educ agegroup4);

reshape wide supply ,i(year agegroup4) j(educ);
replace supply1=supply1+supply2*HS_share;
replace supply3=supply3+supply2*CL_share;
drop supply2 HS_share CL_share ;
reshape long supply,i(year agegroup4) j(educ);
save "\stataproject\educ_wagegap\data\C_by_age_supply.dta", replace;


log close;
