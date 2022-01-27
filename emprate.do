# delimit;

use "\stataproject\educ_wagegap\data\rocho_wage.dta", clear;
drop  month district  mar rel n15 nu15_03 nu15_46 nu15_79 nu15_1012 nu15_1314;
/* Sample restriction */;
drop if sex==2;
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

/* generate population & employment rate */
gen emp=1 if empstat==1 | empstat==3;
collapse(count) age emp,by(year educ agegroup4);
rename age pop;
gen emprate=emp/pop;
gen us=0;
drop if educ==2;
gen lpop=log(pop);
sort year agegroup4 educ;
by year agegroup4: gen dif_pop=lpop[_n]-lpop[_n-1];

twoway connected emprate year if agegroup4==1 & educ==1 ||connected emprate year if agegroup4==2 & educ==1
|| connected emprate year if agegroup4==3 & educ==1 ||connected emprate year if agegroup4==4 & educ==1||,
 legend(label (1 "25-29") label(2 "30-39") label(3 "40-49") label(4 "50-59")) 
 ytitle("Employment Rate of HS Graduate") xtitle("Year") scheme(s2mono);
 
 twoway connected emprate year if agegroup4==1 & educ==3 ||connected emprate year if agegroup4==2 & educ==3
|| connected emprate year if agegroup4==3 & educ==3 ||connected emprate year if agegroup4==4 & educ==3||,
 legend(label (1 "25-29") label(2 "30-39") label(3 "40-49") label(4 "50-59")) 
 ytitle("Employment Rate of CL Graduate") xtitle("Year") scheme(s2mono);

preserve;
sort year agegroup4;
drop if dif_pop==.;
keep year agegroup4  dif_pop;
sort year;
save "\stataproject\educ_wagegap\data\pop_share.dta",replace;
restore;

sort year educ;
by year educ: egen all_pop=total(pop);
gen lall_pop=log(all_pop);
preserve;
collapse(mean) lall_pop, by(year educ);
sort year educ;
by year : gen dif_all_pop=lall_pop[_n]-lall_pop[_n-1];
drop if dif_all_pop==.;
sort year;
merge year using "\stataproject\educ_wagegap\data\pop_share.dta";
keep year agegroup4  dif_pop dif_all_pop;
sort year agegroup4;
save "\stataproject\educ_wagegap\data\pop_share.dta",replace;
restore;

sort year agegroup4 educ;
by year agegroup4: gen dif=emprate[_n]-emprate[_n-1];
drop if dif==.;
twoway connected dif year if agegroup4==1 ||connected dif year if agegroup4==2
|| connected dif year if agegroup4==3 ||connected dif year if agegroup4==4 ||,
 legend(label (1 "25-29") label(2 "30-39") label(3 "40-49") label(4 "50-59")) 
 ytitle("Difference of Employment Rate") xtitle("Year") scheme(s2mono);
