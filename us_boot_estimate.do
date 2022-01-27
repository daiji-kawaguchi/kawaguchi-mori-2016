
clear
insheet using "E:\stataproject\educ_wagegap\data\us_centile.csv"
replace variable=variable[_n-1] if variable==.
reshape wide centile,i( percentile) j(variable)
rename centile1 us_rho
rename centile2 alpha1_
rename centile3 alpha2_
rename centile4 alpha3_
rename centile5 alpha4_
rename centile6 beta1_
rename centile7 beta2_
rename centile8 beta3_
rename centile9 beta4_
rename centile10 us_own
rename centile11 us_agg
rename centile12 us_age2
rename centile13 us_age3
rename centile14 us_age4
rename centile15 us_con
rename centile16 us_trend

gen n=1
replace percentile=25 if percentile==2.5
replace percentile=975 if percentile==97.5
reshape wide us_rho alpha1_-alpha4_ beta1_-beta4_ us_own us_agg us_age2-us_age4 us_con us_trend,i( n) j(percentile)

rename alpha1_25 alpha25_1
rename alpha1_50 alpha50_1
rename alpha1_975 alpha975_1

rename alpha2_25 alpha25_2
rename alpha2_50 alpha50_2
rename alpha2_975 alpha975_2

rename alpha3_25 alpha25_3
rename alpha3_50 alpha50_3
rename alpha3_975 alpha975_3

rename alpha4_25 alpha25_4
rename alpha4_50 alpha50_4
rename alpha4_975 alpha975_4

rename beta1_25 beta25_1
rename beta1_50 beta50_1
rename beta1_975 beta975_1

rename beta2_25 beta25_2
rename beta2_50 beta50_2
rename beta2_975 beta975_2

rename beta3_25 beta25_3
rename beta3_50 beta50_3
rename beta3_975 beta975_3

rename beta4_25 beta25_4
rename beta4_50 beta50_4
rename beta4_975 beta975_4

reshape long alpha25_ alpha50_ alpha975_ beta25_ beta50_ beta975_ , i(n) j(agegroup4)
gen us_alpha25=exp(alpha25_)
gen us_alpha50=exp(alpha50_)
gen us_alpha975=exp(alpha975_)

gen us_beta25=exp(beta25_)
gen us_beta50=exp(beta50_)
gen us_beta975=exp(beta975_)

drop alpha25_ alpha50_ alpha975_ beta25_ beta50_ beta975_

sort agegroup4
save "E:\stataproject\educ_wagegap\data\us_cen_estimate.dta",replace




