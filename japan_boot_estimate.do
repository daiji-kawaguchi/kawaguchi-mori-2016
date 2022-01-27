
clear
insheet using "E:\stataproject\educ_wagegap\data\japan_centile.csv"
replace variable=variable[_n-1] if variable==.
reshape wide centile,i( percentile) j(variable)
rename centile1 jp_rho
rename centile2 alpha1_
rename centile3 alpha2_
rename centile4 alpha3_
rename centile5 alpha4_
rename centile6 beta1_
rename centile7 beta2_
rename centile8 beta3_
rename centile9 beta4_
rename centile10 jp2_own
rename centile11 jp2_agg
rename centile12 jp2_age2
rename centile13 jp2_age3
rename centile14 jp2_age4
rename centile15 jp2_con
gen n=1
replace percentile=25 if percentile==2.5
replace percentile=975 if percentile==97.5
reshape wide jp_rho alpha1_-alpha4_ beta1_-beta4_ jp2_own jp2_agg jp2_age2-jp2_age4 jp2_con,i( n) j(percentile)

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
gen jp_alpha25=exp(alpha25_)
gen jp_alpha50=exp(alpha50_)
gen jp_alpha975=exp(alpha975_)

gen jp_beta25=exp(beta25_)
gen jp_beta50=exp(beta50_)
gen jp_beta975=exp(beta975_)

drop alpha25_ alpha50_ alpha975_ beta25_ beta50_ beta975_

sort agegroup4
save "E:\stataproject\educ_wagegap\data\jp_cen_estimate.dta",replace




