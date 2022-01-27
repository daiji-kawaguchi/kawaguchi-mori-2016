set more off
use Z:\research\educ_gap\jgss2008.dta,clear 
gen year=2008
keep if tpjob<=4
keep if sexa==1
keep if ageb>=25 & ageb<=59

gen college=1 if xxlstsch==12 | xxlstsch==13
replace college=0 if xxlstsch==8 | xxlstsch==9
tab college

save Z:\research\educ_gap\jgss0008.dta,replace

use Z:\research\educ_gap\jgss2001.dta ,clear
keep if TP12JOB<=9
gen year=2001
keep if sexa==1
keep if ageb>=25 & ageb<=59

gen college=1 if xxlstsch==11 | xxlstsch==12
replace college=0 if xxlstsch==8 | xxlstsch==9
tab college

append using Z:\research\educ_gap\jgss0008
save Z:\research\educ_gap\jgss0008.dta,replace
gen y2008=1 if year==2008
replace y2008=0 if year==2001

tabstat docompj  if year==2001,by( college) stat(mean sem)
tabstat docompj  if year==2008,by( college) stat(mean sem)
tabstat docompj  if year==2001,by( college) stat(mean sem)
tabstat docompj  if year==2008,by( college) stat(mean sem)

ttest docompj if year==2001 ,by(college)
ttest docompj if year==2008 ,by(college)
ttest docompj if college==0 ,by(year)
ttest docompj if college==1 ,by(year)

gen y08_college=y2008*college
reg docompj y2008 college y08_college
reg docompj y2008 college y08_college ageb
outreg2 using Z:\research\educ_gap\pc_use.txt,replace se noaster nonote bdec(3)
outreg2 using Z:\stataproject\educ_gap\out\pc_use.txt,replace
