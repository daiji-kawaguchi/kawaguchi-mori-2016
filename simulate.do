# delimit;
cd E:;
set mem 2g;
use "\stataproject\educ_wagegap\data\jp_simulate.dta", clear;
merge year agegroup4 using "\stataproject\educ_wagegap\data\us_simulate.dta";
drop _merge;

preserve;
use "\stataproject\educ_wagegap\data\rlwage_4age.dta", clear;
collapse(mean) wei_hour ,by(year agegroup4);
rename wei_hour jp_hour;
sort year agegroup4;
save "\stataproject\educ_wagegap\data\jp_simweight.dta",replace;
restore;

preserve;
use "\stataproject\educ_wagegap\data\us_simweight.dta", clear;
sort year agegroup4;
save "\stataproject\educ_wagegap\data\us_simweight.dta",replace;
restore;

sort year agegroup4;
merge year agegroup4 using "\stataproject\educ_wagegap\data\jp_simweight.dta";
drop _merge;

sort year agegroup4;
merge year agegroup4 using "\stataproject\educ_wagegap\data\us_simweight.dta";
drop _merge;

sort agegroup4;
merge agegroup4 using "\stataproject\educ_wagegap\data\jp_cen_estimate.dta";
drop _merge;

sort agegroup4;
merge agegroup4 using "\stataproject\educ_wagegap\data\us_cen_estimate.dta";
drop _merge;


keep if year>=1986;

/* Create All Supply */
/* calculate US all supply using Japanese estimates */
gen usifjp_alpha_collage=jp_alpha*(us_csupply^jp_rho);
gen usifjp_beta_high=jp_beta*(us_hsupply^jp_rho);
/* sum up alpha_collage & beta_collage by year */;
sort year;
by year: egen usifjp_collage_sum=total(usifjp_alpha_collage);
by year: egen usifjp_high_sum=total(usifjp_beta_high);
/* generate aggregate data  */;
gen usifjp_agg_collage=usifjp_collage_sum^(1/jp_rho);
gen usifjp_agg_high=usifjp_high_sum^(1/jp_rho);
/* generate (own supply - aggregate supply) */;
gen usifjp_lagg_ch=log(usifjp_agg_collage/ usifjp_agg_high);
gen usifjp_hdif_sup= us_rel_age_supply -usifjp_lagg_ch;

/* calculate US all supply using Japanese estimates, 2.5% */;
gen usifjp_alpha_collage25=jp_alpha25*(us_csupply^jp_rho25);
gen usifjp_beta_high25=jp_beta25*(us_hsupply^jp_rho25);
/* sum up alpha_collage & beta_collage by year */;
sort year;
by year: egen usifjp_collage_sum25=total(usifjp_alpha_collage25);
by year: egen usifjp_high_sum25=total(usifjp_beta_high25);
/* generate aggregate data  */;
gen usifjp_agg_collage25=usifjp_collage_sum25^(1/jp_rho25);
gen usifjp_agg_high25=usifjp_high_sum25^(1/jp_rho25);
/* generate (own supply - aggregate supply) */;
gen usifjp_lagg_ch25=log(usifjp_agg_collage25/ usifjp_agg_high25);
gen usifjp_hdif_sup25= us_rel_age_supply -usifjp_lagg_ch25;

/* calculate US all supply using Japanese estimates, 97.5% */
gen usifjp_alpha_collage975=jp_alpha975*(us_csupply^jp_rho975);
gen usifjp_beta_high975=jp_beta975*(us_hsupply^jp_rho975);
/* sum up alpha_collage & beta_collage by year */;
sort year;
by year: egen usifjp_collage_sum975=total(usifjp_alpha_collage975);
by year: egen usifjp_high_sum975=total(usifjp_beta_high975);
/* generate aggregate data  */;
gen usifjp_agg_collage975=usifjp_collage_sum975^(1/jp_rho975);
gen usifjp_agg_high975=usifjp_high_sum975^(1/jp_rho975);
/* generate (own supply - aggregate supply) */;
gen usifjp_lagg_ch975=log(usifjp_agg_collage975/ usifjp_agg_high975);
gen usifjp_hdif_sup975= us_rel_age_supply -usifjp_lagg_ch975;


/* calculate Japan all supply using US estimates */
gen jpifus_alpha_collage=us_alpha*(jp_csupply^us_rho);
gen jpifus_beta_high=us_beta*(jp_hsupply^us_rho);
/* sum up alpha_collage & beta_collage by year */;
sort year;
by year: egen jpifus_collage_sum=total(jpifus_alpha_collage);
by year: egen jpifus_high_sum=total(jpifus_beta_high);
/* generate aggregate data  */;
gen jpifus_agg_collage=jpifus_collage_sum^(1/us_rho);
gen jpifus_agg_high=jpifus_high_sum^(1/us_rho);
/* generate (own supply - aggregate supply) */;
gen jpifus_lagg_ch=log(jpifus_agg_collage/ jpifus_agg_high);
gen jpifus_hdif_sup= jp_rel_age_supply -jpifus_lagg_ch;

/* calculate Japan all supply using US estimates, 2.5% */
gen jpifus_alpha_collage25=us_alpha25*(jp_csupply^us_rho25);
gen jpifus_beta_high25=us_beta25*(jp_hsupply^us_rho25);
/* sum up alpha_collage & beta_collage by year */;
sort year;
by year: egen jpifus_collage_sum25=total(jpifus_alpha_collage25);
by year: egen jpifus_high_sum25=total(jpifus_beta_high25);
/* generate aggregate data  */;
gen jpifus_agg_collage25=jpifus_collage_sum25^(1/us_rho25);
gen jpifus_agg_high25=jpifus_high_sum25^(1/us_rho25);
/* generate (own supply - aggregate supply) */;
gen jpifus_lagg_ch25=log(jpifus_agg_collage25/ jpifus_agg_high25);
gen jpifus_hdif_sup25= jp_rel_age_supply -jpifus_lagg_ch25;

/* calculate Japan all supply using US estimates, 97.5% */
gen jpifus_alpha_collage975=us_alpha975*(jp_csupply^us_rho975);
gen jpifus_beta_high975=us_beta975*(jp_hsupply^us_rho975);
/* sum up alpha_collage & beta_collage by year */;
sort year;
by year: egen jpifus_collage_sum975=total(jpifus_alpha_collage975);
by year: egen jpifus_high_sum975=total(jpifus_beta_high975);
/* generate aggregate data  */;
gen jpifus_agg_collage975=jpifus_collage_sum975^(1/us_rho975);
gen jpifus_agg_high975=jpifus_high_sum975^(1/us_rho975);
/* generate (own supply - aggregate supply) */;
gen jpifus_lagg_ch975=log(jpifus_agg_collage975/ jpifus_agg_high975);
gen jpifus_hdif_sup975= jp_rel_age_supply -jpifus_lagg_ch975;


//** Calculate Counter factual & Predicted Values **//
/* 1. calculating by age groups */
gen byte age1=agegroup4==1;
gen byte age2=agegroup4==2;
gen byte age3=agegroup4==3;
gen byte age4=agegroup4==4;
gen jtrend=year-1985;

gen jp_under_jp=jp_con+ jp_agg*jp_all_supply+ jp_own*jp_age_supply
+jtrend* jp_trend+age2*jp_age2+age3*jp_age3+age4*jp_age4;

gen jp_under_us=jp_con+ jp_agg*usifjp_lagg_ch+ jp_own*usifjp_hdif_sup
+jtrend* jp_trend+age2*jp_age2+age3*jp_age3+age4*jp_age4;

gen jp2_under_us=jp2_con+ jp2_agg*usifjp_lagg_ch+ jp2_own*usifjp_hdif_sup
+jtrend* us_trend*0.72+age2*jp2_age2+age3*jp2_age3+age4*jp2_age4;

gen jp2_under_us25=jp2_con25+ jp2_agg25*usifjp_lagg_ch25+ jp2_own25*usifjp_hdif_sup25
+jtrend* us_trend*0.72+age2*jp2_age225+age3*jp2_age325+age4*jp2_age425;

gen jp2_under_us975=jp2_con975+ jp2_agg975*usifjp_lagg_ch975+ jp2_own975*usifjp_hdif_sup975
+jtrend* us_trend*0.72+age2*jp2_age2975+age3*jp2_age3975+age4*jp2_age4975;

gen us_under_us=us_con+  us_agg*us_all_supply+ us_own*us_age_supply
+jtrend* us_trend+age2*us_age2+age3*us_age3+age4*us_age4;

gen us_under_jp=us_con+ us_agg*jpifus_lagg_ch+ us_own*jpifus_hdif_sup
+jtrend* us_trend+age2*us_age2+age3*us_age3+age4*us_age4;

gen us_under_jp25=us_con25+ us_agg25*jpifus_lagg_ch25+ us_own25*jpifus_hdif_sup25
+jtrend* us_trend25+age2*us_age225+age3*us_age325+age4*us_age425;

gen us_under_jp975=us_con975+ us_agg975*jpifus_lagg_ch975+ us_own975*jpifus_hdif_sup975
+jtrend* us_trend975+age2*us_age2975+age3*us_age3975+age4*us_age4975;

keep year agegroup4 jp_wage us_wage jp_under_jp jp_under_us jp2_under_us jp2_under_us25 jp2_under_us975 us_under_us us_under_jp 
jp_hour us_hour us_under_jp25 us_under_jp975;


/* weighted average of relative wagG: weight is the supply share of each agegroup */
replace jp_under_jp=jp_under_jp*jp_hour;

replace jp_under_us=jp_under_us*us_hour;

replace jp2_under_us=jp2_under_us*us_hour;

replace jp2_under_us25=jp2_under_us25*us_hour;

replace jp2_under_us975=jp2_under_us975*us_hour;

replace us_under_us=us_under_u*us_hour;

replace us_under_jp=us_under_jp*jp_hour;

replace us_under_jp25=us_under_jp25*jp_hour;

replace us_under_jp975=us_under_jp975*jp_hour;

replace jp_wage=jp_wage*jp_hour;
replace us_wage=us_wage*us_hour;

collapse(sum) jp_under_jp jp_under_us jp2_under_us jp2_under_us25 jp2_under_us975 
us_under_us us_under_jp us_under_jp25 us_under_jp975 jp_wage us_wage,by(year);

sort year;

* generate change from 1986 to each year *
keep if year<=2006;
foreach X of varlist jp_under_jp jp_under_us jp2_under_us jp2_under_us25 jp2_under_us975 
jp_wage us_under_us us_under_jp us_under_jp25 us_under_jp975 us_wage {;
gen `X'86=`X' if year==1986;
replace `X'86=`X'86[_n-1] if `X'86==.;
gen c_`X'=`X'-`X'86;
};

drop if year>2006;
/* Level comparison */
/*
twoway connected jp_under_jp year || connected jp_under_us year 
|| connected jp_wage year||,legend(label (1 "JP with JP data") 
label(2 "JP with US data") label(3 "JP actual")) scheme(s2mono) 
text(.363 1986 "0.36",place(e)) text(.213 1986 "0.21",place(e))
text(-0.043 1986 "-0.04",place(e)) text(.339 1986 "0.34",place(n))
text(.384 2006 "0.38",place(e)) text(.339 2006 "0.34",place(n))
text(.166 2006 "0.17",place(n)) text(.341 2006 "0.34",place(s));
graph save "\stataproject\educ_wagegap\out\gsimulate_jp.gph",replace;

twoway connected us_under_us year|| connected us_under_jp year 
|| connected us_wage year||,legend(label (1 "US with US data") 
label(2 "US with JP data") label(3 "US actual"))  scheme(s2mono)
text(.464 1986 "0.46",place(e)) text(.800 1986 "0.80",place(e))
text(.464 1986 "0.46",place(e)) text(.719 2006 "0.72",place(n))
text(.874 2006 "0.87",place(n)) text(.694 2006 "0.69",place(s));
graph save "\stataproject\educ_wagegap\out\gsimulate_us.gph",replace;

/* Change comparison based on 1986 */
/* Full time */;
twoway connected c_jp_under_jp year || connected c_jp2_under_us year
|| connected c_jp_wage year||,legend(label (1 "JP with JP supply") 
label(2 "JP with US supply")  label(3 "JP actual")) scheme(s2mono) 
text(-0.0275 2006 "-0.03",place(n)) text(.14 2006 "0.13",place(n)) 
text(-0.0437 2006 "-0.04",place(s)) xtitle("Year");
graph save "\stataproject\educ_wagegap\out\gsimulate_cjp.gph",replace;
/*
* Full time *;
twoway connected c_us_under_us year|| connected c_us_under_jp year 
|| connected c_us_wage year||,legend(label (1 "US with US supply") 
label(2 "US with JP supply") label(3 "US actual"))  scheme(s2mono)
text(.23 2006 "0.23",place(n)) text(.11 2006 "0.12",place(n)) 
text(.225 2006 "0.22",place(s)) xtitle("Year") ;
graph save "\stataproject\educ_wagegap\out\gsimulate_cus.gph",replace;
*/;*/;

/* Change comparison based on 1986 */;
twoway connected c_jp_under_jp year || connected c_jp2_under_us year
|| connected c_jp_wage year||line c_jp2_under_us25 year, lpattern(longdash) ||line c_jp2_under_us975 year, lpattern(longdash)||,legend(label (1 "JP with JP supply") 
label(2 "JP with US supply")  label(3 "JP actual") label(4 "95% conf. interval") label(5 "")) scheme(s2mono) 
text(-0.0275 2006 "-0.01",place(n)) text(.14 2006 "0.13",place(n)) 
text(-0 2006 "-0.01",place(s)) xtitle("Year");
graph save "\stataproject\educ_wagegap\out\gsimulate_cjp.gph",replace;

twoway connected c_us_under_us year|| connected c_us_under_jp year 
|| connected c_us_wage year||line c_us_under_jp25 year, lpattern(longdash)||line c_us_under_jp975 year, lpattern(longdash)
||,legend(label (1 "US with US supply") 
label(2 "US with JP supply") label(3 "US actual") label(4 "95% conf. interval") label(5 ""))  scheme(s2mono)
text(.25 2006 "0.24",place(n)) text(.09 2006 "0.08",place(n)) 
text(.215 2006 "0.22",place(s)) xtitle("Year") ;
graph save "\stataproject\educ_wagegap\out\gsimulate_cus.gph",replace;

