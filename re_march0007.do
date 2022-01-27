# delimit;
set more off;
clear;
forvalues y=0/7 {;
clear;
use \stataproject\educ_wagegap\data\cps_clean\mar0`y'.dta,clear;

keep if agely>=25 & agely<=59;
recode agely (25/29=1) (30/39=2) (40/49=3) (50/59=4),gen(agegroup);
*keep if fulltime==1;
*keep if fullyear==1;
*keep if wageworker==1;

gen beduc=1 if school<=2;
replace beduc=2 if school==3;
replace beduc=3 if school>=4;

gen byte beduc1=beduc==1;
gen byte beduc2=beduc==2;
gen byte beduc3=beduc==3;

gen age2=agely^2;
gen age3=agely^3;
gen age4=agely^4;

gen age_beduc2=agely*beduc2;
gen age_beduc3=agely*beduc3;

gen age2_beduc2=age2*beduc2;
gen age2_beduc3=age2*beduc3;

gen age3_beduc2=age3*beduc2;
gen age3_beduc3=age3*beduc3;

gen age4_beduc2=age4*beduc2;
gen age4_beduc3=age4*beduc3;

drop if _state>21;
gen byte west=_state==19 | _state==20 | _state==21;
gen byte midwest=_state==6 | _state==7 | _state==8 | _state==9 | _state==10;
gen byte northeast=_state==1 |_state==2|_state==3|_state==4|_state==5|_state==11;
gen byte south=west==0 & midwest==0 & northeast==0;

gen lwage=log(winc_ws*gdp);
drop if bcwkwgkm==1;
drop if allocated==1;

qui reg lwage beduc2 beduc3 midwest northeast south black other agely age2-age4
age_beduc2 age_beduc3 age2_beduc2 age2_beduc3 age3_beduc2 age3_beduc3
age4_beduc2 age4_beduc3 [pw=wgt_wks] if female==0 & wageworker==1;

egen mean_south=mean(south) if e(sample);
egen mean_ne=mean(northeast) if e(sample);
egen mean_west=mean(west) if e(sample);
egen mean_midwest=mean(midwest) if e(sample);

* school level 1 *;
foreach i of numlist 27 35 45 55 {;
gen mp1`i'=_b[_cons]+mean_south*_b[south]+mean_ne*_b[northeast]+mean_midwest*_b[midwest]
+`i'*_b[agely]+`i'^2*_b[age2]+`i'^3*_b[age3]+`i'^4*_b[age4];
};

*school level 2-3 *;
foreach j of numlist 2/3 {;
foreach i of numlist 27 35 45 55 {;
gen mp`j'`i'=_b[_cons]+_b[beduc`j']+mean_south*_b[south]+mean_ne*_b[northeast]+mean_midwest*_b[midwest]
+`i'*_b[agely]+`i'^2*_b[age2]+`i'^3*_b[age3]+`i'^4*_b[age4]+`i'*_b[age_beduc`j']+`i'^2*_b[age2_beduc`j']+
`i'^3*_b[age3_beduc`j']+`i'^4*_b[age4_beduc`j'] ;
};};

drop mean_south mean_ne mean_west mean_midwest;

qui reg lwage beduc2 beduc3 midwest northeast south black other agely age2-age4
age_beduc2 age_beduc3 age2_beduc2 age2_beduc3 age3_beduc2 age3_beduc3
age4_beduc2 age4_beduc3 [pw=wgt_wks] if female==1 & wageworker==1;

egen mean_south=mean(south) if e(sample);
egen mean_ne=mean(northeast) if e(sample);
egen mean_west=mean(west) if e(sample);
egen mean_midwest=mean(midwest) if e(sample);

* school level 1 *;
foreach i of numlist 27 35 45 55 {;
gen fp1`i'=_b[_cons]+mean_south*_b[south]+mean_ne*_b[northeast]+mean_midwest*_b[midwest]
+`i'*_b[agely]+`i'^2*_b[age2]+`i'^3*_b[age3]+`i'^4*_b[age4];
};

*school level 2-3 *;
foreach j of numlist 2/3 {;
foreach i of numlist 27 35 45 55 {;
gen fp`j'`i'=_b[_cons]+_b[beduc`j']+mean_south*_b[south]+mean_ne*_b[northeast]+mean_midwest*_b[midwest]
+`i'*_b[agely]+`i'^2*_b[age2]+`i'^3*_b[age3]+`i'^4*_b[age4]+`i'*_b[age_beduc`j']+`i'^2*_b[age2_beduc`j']+
`i'^3*_b[age3_beduc`j']+`i'^4*_b[age4_beduc`j'] ;
};};

preserve;
collapse(mean) year mp127 mp227 mp327 mp135 mp235 mp335 mp145 mp245 mp345 mp155 mp255 mp355
 fp127 fp227 fp327 fp135 fp235 fp335 fp145 fp245 fp345 fp155 fp255 fp355 ;
append using  \stataproject\educ_wagegap\data\re_mcps.dta;
save \stataproject\educ_wagegap\data\re_mcps.dta,replace;
restore;


preserve;
keep lwage year beduc1-beduc3 agely age2-age4 female midwest northeast south wgt_wks;
append using  \stataproject\educ_wagegap\data\re_price.dta;
save \stataproject\educ_wagegap\data\re_price.dta,replace;
restore;

preserve;
drop if female==1;
collapse(sum) hrslwk ,by(year agegroup beduc female);
rename hrslwk rel_hour;
keep year agegroup beduc female rel_hour;
append using \stataproject\educ_wagegap\data\re_hour.dta;
save \stataproject\educ_wagegap\data\re_hour.dta,replace;
restore;

preserve;
forvalues i=1/4 {;
reg lwage beduc3 if agegroup==`i' & female==0;
gen se=_se[beduc3] if e(sample);
if `i'==1{;
gen weight=1/(se^2);
};
else {;
replace weight=1/(se^2) if weight==.;
};
drop se;
};
rename agegroup agegroup4;
collapse(mean) weight,by(year agegroup4);
append using \stataproject\educ_wagegap\data\cps_weight.dta;
save \stataproject\educ_wagegap\data\cps_weight.dta,replace;
restore;

append using \stataproject\educ_wagegap\data\all_cps.dta;
save \stataproject\educ_wagegap\data\all_cps.dta,replace;
};

use \stataproject\educ_wagegap\data\re_hour.dta;
collapse(mean) rel_hour,by(year beduc agegroup female);
sort year beduc agegroup female;
save \stataproject\educ_wagegap\data\re_hour.dta,replace;

clear;
use \stataproject\educ_wagegap\data\re_mcps.dta;
reshape long mp1 mp2 mp3 fp1 fp2 fp3 , i(year) j(agegroup);
reshape long mp fp, i(year agegroup) j(beduc);
recode agegroup (27=1) (35=2) (45=3) (55=4);
rename mp p0;
rename fp p1;
reshape long p,i(year agegroup beduc) j(female);

sort year beduc agegroup female;
merge year beduc agegroup female using \stataproject\educ_wagegap\data\re_hour.dta;
drop _merge;
save \stataproject\educ_wagegap\data\re_mcps.dta,replace;
