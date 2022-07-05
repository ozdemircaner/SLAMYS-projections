/*projecting SLAMYS from 2015 to 2050 using different scenarios
1- SSP scenarios from WIC Data Explorer are used for quantity of education, i.e. mean years of schooling
2- For the projection of quality of education, PIAAC/STEP scores of 45 countries for 2015 by age and education groups are used
3- Existing cohorts (in 2015) are projected to the future using the age pattern deerived from IALS-PIAAC data, see Reiter et al. 2020
4- For the upcoming time periods, adj_factor(SLAMYS/MYS) is increased or decreased according to various scenarios*/

global path1 "..." /*directory for files*/
insheet using $path1\ae_pat.csv, delimiter(";") /*Changes in adult skills with age. Derived from https://github.com/clreiter/WIC-Skills-Adjusted-Human-Capital/blob/master/SAMYS_empirical/Input/reconstruction_scores.xlsx*; 
													see Reiter, 2022; Lutz et al., 2021*/
save $path1\ae_pat.dta, replace /*data for age-skills pattern by age and 2 education groups*/
clear
insheet using $path1\slamys_2015.csv, delimiter(";") /* 2015 PIAAC and STEP scores by age and 2 education groups, See Lutz et al.,2021*/
/*applying age pattern to future time periods*/
merge m:1 age educ using $path1/ae_pat.dta
drop _merge
destring percentual_change, replace dpcomma
sort iso age educ
save $path1\base2015.dta, replace
gen slamys2015=score
save $path1\slamys2015.dta, replace
gen slamys2020=slamys2015*percentual_change
drop slamys2015
drop if age==60
recode age 15=20 20=25 25=30 30=35 35=40 40=45 45=50 50=55 55=60
drop percentual_change
save $path1\slamys2020.dta, replace
merge m:1 age educ using $path1/ae_pat.dta
drop _merge
destring percentual_change, replace dpcomma
gen slamys2025=slamys2020*percentual_change
drop slamys2020
drop if age==60
recode age 15=20 20=25 25=30 30=35 35=40 40=45 45=50 50=55 55=60
drop percentual_change
save $path1\slamys2025.dta, replace
merge m:1 age educ using $path1/ae_pat.dta
drop _merge
destring percentual_change, replace dpcomma
gen slamys2030=slamys2025*percentual_change
drop slamys2025
drop if age==60
recode age 15=20 20=25 25=30 30=35 35=40 40=45 45=50 50=55 55=60
drop percentual_change
save $path1\slamys2030.dta, replace
merge m:1 age educ using $path1/ae_pat.dta
drop _merge
destring percentual_change, replace dpcomma
gen slamys2035=slamys2030*percentual_change
drop slamys2030
drop if age==60
recode age 15=20 20=25 25=30 30=35 35=40 40=45 45=50 50=55 55=60
drop percentual_change
save $path1\slamys2035.dta, replace
merge m:1 age educ using $path1/ae_pat.dta
drop _merge
destring percentual_change, replace dpcomma
gen slamys2040=slamys2035*percentual_change
drop slamys2035
drop if age==60
recode age 15=20 20=25 25=30 30=35 35=40 40=45 45=50 50=55 55=60
drop percentual_change
save $path1\slamys2040.dta, replace
merge m:1 age educ using $path1/ae_pat.dta
drop _merge
destring percentual_change, replace dpcomma
gen slamys2045=slamys2040*percentual_change
drop slamys2040
drop if age==60
recode age 15=20 20=25 25=30 30=35 35=40 40=45 45=50 50=55 55=60
drop percentual_change
save $path1\slamys2045.dta, replace
merge m:1 age educ using $path1/ae_pat.dta
drop _merge
destring percentual_change, replace dpcomma
gen slamys2050=slamys2045*percentual_change
drop slamys2045
drop if age==60
recode age 15=20 20=25 25=30 30=35 35=40 40=45 45=50 50=55 55=60
drop percentual_change
save $path1\slamys2050.dta, replace
clear

/*merging periods*/
use iso country age educ slamys2015 using $path1\slamys2015.dta
merge 1:1 iso country age educ using $path1\slamys2020.dta
keep iso country age educ slamys2015 slamys2020
merge 1:1 iso country age educ using $path1\slamys2025.dta
keep iso country age educ slamys2015 slamys2020 slamys2025
merge 1:1 iso country age educ using $path1\slamys2030.dta
keep iso country age educ slamys2015 slamys2020 slamys2025 slamys2030
merge 1:1 iso country age educ using $path1\slamys2035.dta
keep iso country age educ slamys2015 slamys2020 slamys2025 slamys2030 slamys2035
merge 1:1 iso country age educ using $path1\slamys2040.dta
keep iso country age educ slamys2015 slamys2020 slamys2025 slamys2030 slamys2035 slamys2040
merge 1:1 iso country age educ using $path1\slamys2045.dta
keep iso country age educ slamys2015 slamys2020 slamys2025 slamys2030 slamys2035 slamys2040 slamys2045
merge 1:1 iso country age educ using $path1\slamys2050.dta
keep iso country age educ slamys2015 slamys2020 slamys2025 slamys2030 slamys2035 slamys2040 slamys2045 slamys2050
save $path1\slamys_ae_2015-2050.dta, replace

/*age education groups to acquire weighted total for countries*/
egen ae2=group(age educ)
merge m:1 ae2 using $path1\oecd_benchmark.dta /*Age-Education group averages for OECD*/ 

/*weighted averages for every time period*/
gen adj_factor2015=slamys2015/weighted_mean
gen adj_factor2020=slamys2020/weighted_mean
gen adj_factor2025=slamys2025/weighted_mean
gen adj_factor2030=slamys2030/weighted_mean
gen adj_factor2035=slamys2035/weighted_mean
gen adj_factor2040=slamys2040/weighted_mean
gen adj_factor2045=slamys2045/weighted_mean
gen adj_factor2050=slamys2050/weighted_mean
drop slamys* ae2 weighted_mean _merge

/*wide to long*/
egen iso_ae2=group(iso age educ), label /*generates iso age education combinations in one variable)*/
drop if iso_ae2==.
reshape long adj_factor, i(iso_ae2) j(year)
save $path1\slamys_ae_2015-2050_long_empty.dta, replace /*SLAMYS adjustment factors for 45 countries, age patterns applied. Emerging cohorts are missing*/

/*Distributions of level of education by age groups and countries in different SSP scenarios*/
/*SSP2*/
insheet using $path1\wicdf_age_educ_2015_2050_ssp2.csv, delimiter(";") clear /*only ssp2. Data downloaded from WIC Data Explorer*/
sort age
encode(age), gen(ageg)
recode ageg 1=15 2=20 3=25 4=30 5=35 6=40 7=45 8=50 9=55 10=60
drop age
gen age=ageg
drop ageg
sort isocode age
egen iso_ay=group(isocode age year), label /*generates iso age education combinations in one variable)*/
encode(education), gen(edu)
drop education
reshape wide distribution, i(iso_ay) j(edu)
gen educ1=distribution2+distribution5+distribution7+distribution9+distribution3
gen educ2=distribution10+distribution6
drop distribution*
reshape long educ, i(iso_ay) j(value)
rename educ percentage
rename value educ
label drop edu
rename isocode iso
save $path1\wic_age_educ_2015_2050.dta, replace /*Distributions of level of education by age groups and countries for SSP2 scenario */

/*SSP1*/
insheet using $path1\wicdf_age_educ_2015_2050_ssp1.csv, delimiter(";") clear /*only ssp1. Data downloaded from WIC Data Explorer*/
sort age
encode(age), gen(ageg)
recode ageg 1=15 2=20 3=25 4=30 5=35 6=40 7=45 8=50 9=55 10=60
drop age
gen age=ageg
drop ageg
sort isocode age
label drop iso_ay
egen iso_ay=group(isocode age year), label /*generates iso age education combinations in one variable)*/
encode(education), gen(edu)
drop education
reshape wide distribution, i(iso_ay) j(edu)
gen educ1=distribution2+distribution5+distribution7+distribution9+distribution3
gen educ2=distribution10+distribution6
drop distribution*
reshape long educ, i(iso_ay) j(value)
rename educ percentage
rename value educ
label drop edu
rename isocode iso
save $path1\wic_age_educ_2015_2050_ssp1.dta, replace /*Distributions of level of education by age groups and countries for SSP1 scenario*/

/*SSP3*/
insheet using $path1\wicdf_age_educ_2015_2050_ssp3.csv, delimiter(";") clear /*only ssp3. Data downloaded from WIC Data Explorer*/
sort age
encode(age), gen(ageg)
recode ageg 1=15 2=20 3=25 4=30 5=35 6=40 7=45 8=50 9=55 10=60
drop age
gen age=ageg
drop ageg
sort isocode age
label drop iso_ay
egen iso_ay=group(isocode age year), label /*generates iso age education combinations in one variable)*/
encode(education), gen(edu)
drop education
reshape wide distribution, i(iso_ay) j(edu)
gen educ1=distribution2+distribution5+distribution7+distribution9+distribution3
gen educ2=distribution10+distribution6
drop distribution*
reshape long educ, i(iso_ay) j(value)
rename educ percentage
rename value educ
label drop edu
rename isocode iso
save $path1\wic_age_educ_2015_2050_ssp3.dta, replace /*Distributions of level of education by age groups and countries for SSP1 scenario*/

/*PROJECTIONS FOR ONGOING PISA TRENDS IN QUALITY SCENARIO WITH SSP2*/
use $path1\slamys_ae_2015-2050_long_empty.dta, clear

/*ongoing PISA trends until 2030*/
/*countries with constant pisa trend*/
replace adj_factor = adj_factor[_n-1] if missing(adj_factor) & iso==40 & year<=2030  /*austria*/
replace adj_factor = adj_factor[_n-1] if missing(adj_factor) & iso==203 & year<=2030  /*czechia*/
replace adj_factor = adj_factor[_n-1] if missing(adj_factor) & iso==208 & year<=2030  /*denmark*/
replace adj_factor = adj_factor[_n-1] if missing(adj_factor) & iso==348 & year<=2030  /*hungary*/
replace adj_factor = adj_factor[_n-1] if missing(adj_factor) & iso==372 & year<=2030  /*ireland*/
replace adj_factor = adj_factor[_n-1] if missing(adj_factor) & iso==484 & year<=2030  /*mexico*/
replace adj_factor = adj_factor[_n-1] if missing(adj_factor) & iso==578 & year<=2030  /*norway*/
replace adj_factor = adj_factor[_n-1] if missing(adj_factor) & iso==705 & year<=2030  /*slovenia*/
replace adj_factor = adj_factor[_n-1] if missing(adj_factor) & iso==724 & year<=2030  /*spain*/
replace adj_factor = adj_factor[_n-1] if missing(adj_factor) & iso==840 & year<=2030  /*usa*/
replace adj_factor = adj_factor[_n-1] if missing(adj_factor) & iso==398 & year<=2030  /*kazakhstan*/

/*countries with decreasing pisa trend*/
replace adj_factor = 0.99*adj_factor[_n-1] if missing(adj_factor) & iso==36 & year<=2030  /*australia*/
replace adj_factor = 0.99*adj_factor[_n-1] if missing(adj_factor) & iso==56 & year<=2030  /*belgium*/
replace adj_factor = 0.99*adj_factor[_n-1] if missing(adj_factor) & iso==124 & year<=2030  /*canada*/
replace adj_factor = 0.99*adj_factor[_n-1] if missing(adj_factor) & iso==246 & year<=2030  /*finland*/
replace adj_factor = 0.99*adj_factor[_n-1] if missing(adj_factor) & iso==250 & year<=2030  /*france*/
replace adj_factor = 0.99*adj_factor[_n-1] if missing(adj_factor) & iso==300 & year<=2030  /*greece*/
replace adj_factor = 0.99*adj_factor[_n-1] if missing(adj_factor) & iso==380 & year<=2030  /*italy*/
replace adj_factor = 0.99*adj_factor[_n-1] if missing(adj_factor) & iso==392 & year<=2030  /*japan*/
replace adj_factor = 0.99*adj_factor[_n-1] if missing(adj_factor) & iso==410 & year<=2030  /*korea*/
replace adj_factor = 0.99*adj_factor[_n-1] if missing(adj_factor) & iso==554 & year<=2030  /*new zealand*/
replace adj_factor = 0.99*adj_factor[_n-1] if missing(adj_factor) & iso==703 & year<=2030  /*slovakia*/
replace adj_factor = 0.99*adj_factor[_n-1] if missing(adj_factor) & iso==752 & year<=2030  /*sweden*/
replace adj_factor = 0.98*adj_factor[_n-1] if missing(adj_factor) & iso==528 & year<=2030  /*netherlands*/
replace adj_factor = 0.97*adj_factor[_n-1] if missing(adj_factor) & iso==196 & year<=2030  /*cyprus*/
replace adj_factor = 0.97*adj_factor[_n-1] if missing(adj_factor) & iso==704 & year<=2030  /*vietnam*/

/*countries with increasing pisa trend*/
replace adj_factor = 1.01*adj_factor[_n-1] if missing(adj_factor) & iso==276 & year<=2030  /*germany*/
replace adj_factor = 1.01*adj_factor[_n-1] if missing(adj_factor) & iso==376 & year<=2030  /*israel*/
replace adj_factor = 1.01*adj_factor[_n-1] if missing(adj_factor) & iso==440 & year<=2030  /*lithuania*/
replace adj_factor = 1.01*adj_factor[_n-1] if missing(adj_factor) & iso==826 & year<=2030  /*uk*/
replace adj_factor = 1.01*adj_factor[_n-1] if missing(adj_factor) & iso==643 & year<=2030  /*russia*/
replace adj_factor = 1.01*adj_factor[_n-1] if missing(adj_factor) & iso==268 & year<=2030  /*georgia*/
replace adj_factor = 1.01*adj_factor[_n-1] if missing(adj_factor) & iso==68 & year<=2030  /*bolivia-developing country average*/
replace adj_factor = 1.01*adj_factor[_n-1] if missing(adj_factor) & iso==218 & year<=2030  /*ecuador-developing country average*/
replace adj_factor = 1.01*adj_factor[_n-1] if missing(adj_factor) & iso==51 & year<=2030  /*armenia-developing country average*/
replace adj_factor = 1.01*adj_factor[_n-1] if missing(adj_factor) & iso==804 & year<=2030  /*ukraine-developing country average*/
replace adj_factor = 1.01*adj_factor[_n-1] if missing(adj_factor) & iso==288 & year<=2030  /*ghana-developing country average*/
replace adj_factor = 1.01*adj_factor[_n-1] if missing(adj_factor) & iso==404 & year<=2030  /*kenya-developing country average*/
replace adj_factor = 1.02*adj_factor[_n-1] if missing(adj_factor) & iso==170 & year<=2030  /*colombia*/
replace adj_factor = 1.02*adj_factor[_n-1] if missing(adj_factor) & iso==233 & year<=2030  /*estonia*/
replace adj_factor = 1.02*adj_factor[_n-1] if missing(adj_factor) & iso==616 & year<=2030  /*poland*/
replace adj_factor = 1.02*adj_factor[_n-1] if missing(adj_factor) & iso==792 & year<=2030  /*turkey*/
replace adj_factor = 1.02*adj_factor[_n-1] if missing(adj_factor) & iso==702 & year<=2030  /*singapore*/
replace adj_factor = 1.03*adj_factor[_n-1] if missing(adj_factor) & iso==604 & year<=2030  /*peru*/
replace adj_factor = 1.03*adj_factor[_n-1] if missing(adj_factor) & iso==152 & year<=2030  /*chile*/

/* %1,5 increase -average of the positive increases- after 2030 */
replace adj_factor = 1.015*adj_factor[_n-1] if missing(adj_factor)

/**computing weighted adj_factor merging education groups to calculate country averages**/
merge 1:1 iso year age educ using $path1/wic_age_educ_2015_2050.dta
drop if adj_factor==. /*keeping 45 countries that have PIAAC/STEP*/

gen adj_factor_w=adj_factor*percentage/100
egen iso_yae=group(iso year age), label /*generates iso year age education combinations in one variable)*/
keep iso_yae iso year age adj_factor_w educ

reshape wide adj_factor_w, i(iso_yae) j(educ)
gen adj_factor=(adj_factor_w1+adj_factor_w2)
drop iso_yae adj_factor_w*

save $path1\adj_factor_2015_2050.dta, replace
clear

/*Mean Years of Schooling data downloaded from WIC Data Explorer; csv file from WIC DE should be manually opened and first rows should be deleted*/
insheet using $path1\wicdf_mys_age_2015_2050.csv, delimiter(";") clear
rename isocode iso
rename years wic_mys
sort age
encode(age), gen(ageg)
recode ageg 1=15 2=20 3=25 4=30 5=35 6=40 7=45 8=50 9=55 10=60
drop age
rename ageg age

/*merging MYS and adj_factor data to calculate SLAMYS*/
merge 1:1 iso year age using $path1\adj_factor_2015_2050.dta
drop if adj_factor==.
gen slamys=adj_factor*wic_mys
/* outsheet using $path1\r\data\slamys_2015_2050.csv, comma replace /*to be used for graphs*/ */
drop _merge
save $path1\slamys_2015_2050.dta, replace

/*create cohorts*/
gen cohort=0
recode cohort 0=2000 if year==2015 & age==15
recode cohort 0=1995 if year==2015 & age==20
recode cohort 0=1990 if year==2015 & age==25
recode cohort 0=1985 if year==2015 & age==30
recode cohort 0=1980 if year==2015 & age==35
recode cohort 0=1975 if year==2015 & age==40
recode cohort 0=1970 if year==2015 & age==45
recode cohort 0=1965 if year==2015 & age==50
recode cohort 0=1960 if year==2015 & age==55
recode cohort 0=1955 if year==2015 & age==60

recode cohort 0=2005 if year==2020 & age==15
recode cohort 0=2000 if year==2020 & age==20
recode cohort 0=1995 if year==2020 & age==25
recode cohort 0=1990 if year==2020 & age==30
recode cohort 0=1985 if year==2020 & age==35
recode cohort 0=1980 if year==2020 & age==40
recode cohort 0=1975 if year==2020 & age==45
recode cohort 0=1970 if year==2020 & age==50
recode cohort 0=1965 if year==2020 & age==55
recode cohort 0=1960 if year==2020 & age==60

recode cohort 0=2010 if year==2025 & age==15
recode cohort 0=2005 if year==2025 & age==20
recode cohort 0=2000 if year==2025 & age==25
recode cohort 0=1995 if year==2025 & age==30
recode cohort 0=1990 if year==2025 & age==35
recode cohort 0=1985 if year==2025 & age==40
recode cohort 0=1980 if year==2025 & age==45
recode cohort 0=1975 if year==2025 & age==50
recode cohort 0=1970 if year==2025 & age==55
recode cohort 0=1965 if year==2025 & age==60

recode cohort 0=2015 if year==2030 & age==15
recode cohort 0=2010 if year==2030 & age==20
recode cohort 0=2005 if year==2030 & age==25
recode cohort 0=2000 if year==2030 & age==30
recode cohort 0=1995 if year==2030 & age==35
recode cohort 0=1990 if year==2030 & age==40
recode cohort 0=1985 if year==2030 & age==45
recode cohort 0=1980 if year==2030 & age==50
recode cohort 0=1975 if year==2030 & age==55
recode cohort 0=1970 if year==2030 & age==60

recode cohort 0=2020 if year==2035 & age==15
recode cohort 0=2015 if year==2035 & age==20
recode cohort 0=2010 if year==2035 & age==25
recode cohort 0=2005 if year==2035 & age==30
recode cohort 0=2000 if year==2035 & age==35
recode cohort 0=1995 if year==2035 & age==40
recode cohort 0=1990 if year==2035 & age==45
recode cohort 0=1985 if year==2035 & age==50
recode cohort 0=1980 if year==2035 & age==55
recode cohort 0=1975 if year==2035 & age==60

recode cohort 0=2025 if year==2040 & age==15
recode cohort 0=2020 if year==2040 & age==20
recode cohort 0=2015 if year==2040 & age==25
recode cohort 0=2010 if year==2040 & age==30
recode cohort 0=2005 if year==2040 & age==35
recode cohort 0=2000 if year==2040 & age==40
recode cohort 0=1995 if year==2040 & age==45
recode cohort 0=1990 if year==2040 & age==50
recode cohort 0=1985 if year==2040 & age==55
recode cohort 0=1980 if year==2040 & age==60

recode cohort 0=2030 if year==2045 & age==15
recode cohort 0=2025 if year==2045 & age==20
recode cohort 0=2020 if year==2045 & age==25
recode cohort 0=2015 if year==2045 & age==30
recode cohort 0=2010 if year==2045 & age==35
recode cohort 0=2005 if year==2045 & age==40
recode cohort 0=2000 if year==2045 & age==45
recode cohort 0=1995 if year==2045 & age==50
recode cohort 0=1990 if year==2045 & age==55
recode cohort 0=1985 if year==2045 & age==60

recode cohort 0=2035 if year==2050 & age==15
recode cohort 0=2030 if year==2050 & age==20
recode cohort 0=2025 if year==2050 & age==25
recode cohort 0=2020 if year==2050 & age==30
recode cohort 0=2015 if year==2050 & age==35
recode cohort 0=2010 if year==2050 & age==40
recode cohort 0=2005 if year==2050 & age==45
recode cohort 0=2000 if year==2050 & age==50
recode cohort 0=1995 if year==2050 & age==55
recode cohort 0=1990 if year==2050 & age==60

keep area iso age slamys cohort adj_factor
rename adj_factor adj_factor_ssp2

/*defining WB income groups*/
gen income=1 /*High income */
recode income 1=2 if iso==51 | iso==152	|iso==218 |iso==268	| iso==398 | iso==484 | iso==604 | iso==643 | iso==792 /*Upper middle income*/
recode income 1=3 if iso==68| iso==288	| iso==404	| iso==704 | iso==804	/*Lower middle income*/

/*defining school closure category from March 2020 to end of July 2021*/
gen closure=0 /*no closures or less than 4 weeks*/
recode closure 0=1 if  iso==36 | iso==51 | iso==56 | iso==196 |iso==208 | iso==233 | iso==250 | iso==392 | iso==554 | iso==578 | ///
						iso==643 | iso==702 | iso==704 | iso==724 | iso==752 /*less than 21 weeks, Azevedo et al. optimistic scenario*/
recode closure 0=2 if iso==40 | iso==246 | iso==268 | iso==276 | iso==300 | iso==348 | iso==372 | iso==376 | ///
						iso==380 | iso==398	| iso==440 | iso==528 | iso==703 | iso==804 | iso==826 | iso==840 /*22-30 weeks, intermediate scenario*/
recode closure 0=3 if iso==124 | iso==152 | iso==203 | iso==288 | iso==404 | iso==410 | iso==616 | iso==705 ///
						 | iso==792	/*31-40 weeks, pessimistic scenario*/
recode closure 0=4 if iso==68 | iso==170 | iso==218 | iso==484 | iso==604 /*more than 40 weeks, very pessimistic scenario*/

/*covid effect for 2000 and 2005 cohorts*/
gen slamys_covid = cond(cohort==2010 & income==1 & closure==1, 0.97*slamys,  /// /*high income countries, optimistic scenario*/
					cond(cohort==2005 & income==1 & closure==1, 0.97*slamys, ///
					cond(cohort==2010 & income==1 & closure==2, 0.93*slamys, /// /*high income countries, intermediate scenario*/
					cond(cohort==2005 & income==1 & closure==2, 0.93*slamys, ///
					cond(cohort==2010 & income==1 & closure==3, 0.89*slamys, /// /*high income countries, pessimistic scenario*/
					cond(cohort==2005 & income==1 & closure==3, 0.89*slamys, ///
					cond(cohort==2010 & income==1 & closure==4, 0.86*slamys, /// /*high income countries, very pessimistic scenario*/
					cond(cohort==2005 & income==1 & closure==4, 0.86*slamys, ///
					cond(cohort==2010 & income==2 & closure==1, 0.96*slamys, /// /*upper middle income countries, optimistic scenario*/
					cond(cohort==2005 & income==2 & closure==1, 0.96*slamys, ///
					cond(cohort==2010 & income==2 & closure==2, 0.92*slamys, /// /*upper middle income countries, intermediate scenario*/
					cond(cohort==2005 & income==2 & closure==2, 0.92*slamys, ///
					cond(cohort==2010 & income==2 & closure==3, 0.88*slamys, /// /*upper middle income countries, pessimistic scenario*/
					cond(cohort==2005 & income==2 & closure==3, 0.88*slamys, ///
					cond(cohort==2010 & income==2 & closure==4, 0.86*slamys, /// /*upper middle income countries, very pessimistic scenario*/
					cond(cohort==2005 & income==2 & closure==4, 0.86*slamys, ///
					cond(cohort==2010 & income==3 & closure==1, 0.95*slamys, /// /*lower middle income countries, optimistic scenario*/
					cond(cohort==2005 & income==3 & closure==1, 0.95*slamys, ///
					cond(cohort==2010 & income==3 & closure==2, 0.91*slamys, /// /*lower middle income countries, intermediate scenario*/
					cond(cohort==2005 & income==3 & closure==2, 0.91*slamys, ///
					cond(cohort==2010 & income==3 & closure==3, 0.88*slamys, /// /*lower middle income countries, pessimistic scenario*/
					cond(cohort==2005 & income==3 & closure==3, 0.88*slamys, ///
					cond(cohort==2010 & income==3 & closure==4, 0.85*slamys, /// /*lower middle income countries, very pessimistic scenario*/
					cond(cohort==2005 & income==3 & closure==4, 0.85*slamys, ///
						slamys))))))))))))))))))))))))
save $path1\slamys_covid_2015_2050.dta, replace


/*PROJECTIONS FOR ONGOING PISA TRENDS IN QUALITY SCENARIO WITH SSP1*/
use $path1\slamys_ae_2015-2050_long_empty.dta, clear

/*increase in quality with the best pisa trend*/
replace adj_factor = 1.03*adj_factor[_n-1] if missing(adj_factor)/*chile*/

//**computing weighted adj_factor merging education groups**//
merge 1:1 iso year age educ using $path1/wic_age_educ_2015_2050_ssp1.dta /*constructed via wic_age_educ_dist.do*/
drop if adj_factor==. /*keeping 45 countries that have PIAAC/STEP*/

gen adj_factor_w=adj_factor*percentage/100
egen iso_yae=group(iso year age), label /*generates iso year age education combinations in one variable)*/
keep iso_yae iso year age adj_factor_w educ

reshape wide adj_factor_w, i(iso_yae) j(educ)
gen adj_factor=(adj_factor_w1+adj_factor_w2)
drop iso_yae adj_factor_w*

save $path1\adj_factor_2015_2050_ssp1.dta, replace
clear

/*Mean Years of Schooling data from WIC Data Explorer; csv file from WIC DE should be manually opened and first rows should be deleted*/
insheet using $path1\wicdf_mys_age_2015_2050_ssp1.csv, delimiter(";") clear
rename isocode iso
rename years wic_mys
sort age
encode(age), gen(ageg)
recode ageg 1=15 2=20 3=25 4=30 5=35 6=40 7=45 8=50 9=55 10=60
drop age
rename ageg age

/*merging MYS and adj_factor data to calculate SLAMYS*/
merge 1:1 iso year age using $path1\adj_factor_2015_2050_ssp1.dta
drop if adj_factor==.
gen slamys=adj_factor*wic_mys
/* outsheet using $path1\r\data\slamys_2015_2050_ssp1.csv, comma replace */
drop _merge
save $path1\slamys_2015_2050_ssp1.dta, replace

/*create cohorts*/
gen cohort=0
recode cohort 0=2000 if year==2015 & age==15
recode cohort 0=1995 if year==2015 & age==20
recode cohort 0=1990 if year==2015 & age==25
recode cohort 0=1985 if year==2015 & age==30
recode cohort 0=1980 if year==2015 & age==35
recode cohort 0=1975 if year==2015 & age==40
recode cohort 0=1970 if year==2015 & age==45
recode cohort 0=1965 if year==2015 & age==50
recode cohort 0=1960 if year==2015 & age==55
recode cohort 0=1955 if year==2015 & age==60

recode cohort 0=2005 if year==2020 & age==15
recode cohort 0=2000 if year==2020 & age==20
recode cohort 0=1995 if year==2020 & age==25
recode cohort 0=1990 if year==2020 & age==30
recode cohort 0=1985 if year==2020 & age==35
recode cohort 0=1980 if year==2020 & age==40
recode cohort 0=1975 if year==2020 & age==45
recode cohort 0=1970 if year==2020 & age==50
recode cohort 0=1965 if year==2020 & age==55
recode cohort 0=1960 if year==2020 & age==60

recode cohort 0=2010 if year==2025 & age==15
recode cohort 0=2005 if year==2025 & age==20
recode cohort 0=2000 if year==2025 & age==25
recode cohort 0=1995 if year==2025 & age==30
recode cohort 0=1990 if year==2025 & age==35
recode cohort 0=1985 if year==2025 & age==40
recode cohort 0=1980 if year==2025 & age==45
recode cohort 0=1975 if year==2025 & age==50
recode cohort 0=1970 if year==2025 & age==55
recode cohort 0=1965 if year==2025 & age==60

recode cohort 0=2015 if year==2030 & age==15
recode cohort 0=2010 if year==2030 & age==20
recode cohort 0=2005 if year==2030 & age==25
recode cohort 0=2000 if year==2030 & age==30
recode cohort 0=1995 if year==2030 & age==35
recode cohort 0=1990 if year==2030 & age==40
recode cohort 0=1985 if year==2030 & age==45
recode cohort 0=1980 if year==2030 & age==50
recode cohort 0=1975 if year==2030 & age==55
recode cohort 0=1970 if year==2030 & age==60

recode cohort 0=2020 if year==2035 & age==15
recode cohort 0=2015 if year==2035 & age==20
recode cohort 0=2010 if year==2035 & age==25
recode cohort 0=2005 if year==2035 & age==30
recode cohort 0=2000 if year==2035 & age==35
recode cohort 0=1995 if year==2035 & age==40
recode cohort 0=1990 if year==2035 & age==45
recode cohort 0=1985 if year==2035 & age==50
recode cohort 0=1980 if year==2035 & age==55
recode cohort 0=1975 if year==2035 & age==60

recode cohort 0=2025 if year==2040 & age==15
recode cohort 0=2020 if year==2040 & age==20
recode cohort 0=2015 if year==2040 & age==25
recode cohort 0=2010 if year==2040 & age==30
recode cohort 0=2005 if year==2040 & age==35
recode cohort 0=2000 if year==2040 & age==40
recode cohort 0=1995 if year==2040 & age==45
recode cohort 0=1990 if year==2040 & age==50
recode cohort 0=1985 if year==2040 & age==55
recode cohort 0=1980 if year==2040 & age==60

recode cohort 0=2030 if year==2045 & age==15
recode cohort 0=2025 if year==2045 & age==20
recode cohort 0=2020 if year==2045 & age==25
recode cohort 0=2015 if year==2045 & age==30
recode cohort 0=2010 if year==2045 & age==35
recode cohort 0=2005 if year==2045 & age==40
recode cohort 0=2000 if year==2045 & age==45
recode cohort 0=1995 if year==2045 & age==50
recode cohort 0=1990 if year==2045 & age==55
recode cohort 0=1985 if year==2045 & age==60

recode cohort 0=2035 if year==2050 & age==15
recode cohort 0=2030 if year==2050 & age==20
recode cohort 0=2025 if year==2050 & age==25
recode cohort 0=2020 if year==2050 & age==30
recode cohort 0=2015 if year==2050 & age==35
recode cohort 0=2010 if year==2050 & age==40
recode cohort 0=2005 if year==2050 & age==45
recode cohort 0=2000 if year==2050 & age==50
recode cohort 0=1995 if year==2050 & age==55
recode cohort 0=1990 if year==2050 & age==60

keep area iso age slamys cohort adj_factor
rename adj_factor adj_factor_ssp1


/*defining WB income groups*/
gen income=1 /*High income */
recode income 1=2 if iso==51 | iso==152	|iso==218 |iso==268	| iso==398 | iso==484 | iso==604 | iso==643 | iso==792 /*Upper middle income*/
recode income 1=3 if iso==68| iso==288	| iso==404	| iso==704 | iso==804	/*Lower middle income*/

/*defining school closure category from March 2020 to end of July 2021*/
gen closure=0 /*no closures or less than 4 weeks*/
recode closure 0=1 if  iso==36 | iso==51 | iso==56 | iso==196 | iso==233 | iso==250 | ///
						iso==392 | iso==554 | iso==578 | iso==208 | ///
						iso==643 | iso==702 | iso==704 | iso==724 | iso==752 /*less than 21 weeks, Azevedo et al. optimistic scenario*/
recode closure 0=2 if iso==40 |  iso==246 | iso==268 | iso==276 | iso==300 | iso==348 | iso==372 | iso==376 | ///
						iso==380 | iso==398	| iso==440 | iso==528 | iso==703 | iso==804 | iso==826 | iso==840 /*22-30 weeks, intermediate scenario*/
recode closure 0=3 if iso==124 | iso==152 | iso==203 | iso==288 | iso==404 | iso==410 | iso==616 | iso==705  | iso==792/*31-40 weeks, pessimistic scenario*/
recode closure 0=4 if iso==68 | iso==170 | iso==218 | iso==484 | iso==604	 /*more than 40 weeks, very pessimistic scenario*/

/*covid effect for 2000 and 2005 cohorts*/
gen slamys_covid = cond(cohort==2010 & income==1 & closure==1, 0.97*slamys,  /// /*high income countries, optimistic scenario*/
					cond(cohort==2005 & income==1 & closure==1, 0.97*slamys, ///
					cond(cohort==2010 & income==1 & closure==2, 0.93*slamys, /// /*high income countries, intermediate scenario*/
					cond(cohort==2005 & income==1 & closure==2, 0.93*slamys, ///
					cond(cohort==2010 & income==1 & closure==3, 0.89*slamys, /// /*high income countries, pessimistic scenario*/
					cond(cohort==2005 & income==1 & closure==3, 0.89*slamys, ///
					cond(cohort==2010 & income==1 & closure==4, 0.86*slamys, /// /*high income countries, very pessimistic scenario*/
					cond(cohort==2005 & income==1 & closure==4, 0.86*slamys, ///
					cond(cohort==2010 & income==2 & closure==1, 0.96*slamys, /// /*upper middle income countries, optimistic scenario*/
					cond(cohort==2005 & income==2 & closure==1, 0.96*slamys, ///
					cond(cohort==2010 & income==2 & closure==2, 0.92*slamys, /// /*upper middle income countries, intermediate scenario*/
					cond(cohort==2005 & income==2 & closure==2, 0.92*slamys, ///
					cond(cohort==2010 & income==2 & closure==3, 0.88*slamys, /// /*upper middle income countries, pessimistic scenario*/
					cond(cohort==2005 & income==2 & closure==3, 0.88*slamys, ///
					cond(cohort==2010 & income==2 & closure==4, 0.86*slamys, /// /*upper middle income countries, very pessimistic scenario*/
					cond(cohort==2005 & income==2 & closure==4, 0.86*slamys, ///
					cond(cohort==2010 & income==3 & closure==1, 0.95*slamys, /// /*lower middle income countries, optimistic scenario*/
					cond(cohort==2005 & income==3 & closure==1, 0.95*slamys, ///
					cond(cohort==2010 & income==3 & closure==2, 0.91*slamys, /// /*lower middle income countries, intermediate scenario*/
					cond(cohort==2005 & income==3 & closure==2, 0.91*slamys, ///
					cond(cohort==2010 & income==3 & closure==3, 0.88*slamys, /// /*lower middle income countries, pessimistic scenario*/
					cond(cohort==2005 & income==3 & closure==3, 0.88*slamys, ///
					cond(cohort==2010 & income==3 & closure==4, 0.85*slamys, /// /*lower middle income countries, very pessimistic scenario*/
					cond(cohort==2005 & income==3 & closure==4, 0.85*slamys, ///
						slamys))))))))))))))))))))))))
rename slamys slamys_ssp1
rename slamys_covid slamys_covid_ssp1
save $path1\slamys_covid_2015_2050_ssp1.dta, replace


/*PROJECTIONS FOR ONGOING PISA TRENDS IN QUALITY SCENARIO WITH SSP3*/

use $path1\slamys_ae_2015-2050_long_empty.dta, clear

/*freezed quality trend*/
replace adj_factor = adj_factor[_n-1] if missing(adj_factor)

//**computing weighted adj_factor merging education groups**//
merge 1:1 iso year age educ using $path1/wic_age_educ_2015_2050_ssp3.dta /*constructed via wic_age_educ_dist.do*/
drop if adj_factor==. /*keeping 45 countries that have PIAAC/STEP*/

gen adj_factor_w=adj_factor*percentage/100
egen iso_yae=group(iso year age), label /*generates iso year age education combinations in one variable)*/
keep iso_yae iso year age adj_factor_w educ

reshape wide adj_factor_w, i(iso_yae) j(educ)
gen adj_factor=(adj_factor_w1+adj_factor_w2)
drop iso_yae adj_factor_w*

save $path1\adj_factor_2015_2050_ssp3.dta, replace
clear

/*Mean Years of Schooling data from WIC Data Explorer; csv file from WIC DE should be manually opened and first rows should be deleted*/
insheet using $path1\wicdf_mys_age_2015_2050_ssp3.csv, delimiter(";") clear
rename isocode iso
rename years wic_mys
sort age
encode(age), gen(ageg)
recode ageg 1=15 2=20 3=25 4=30 5=35 6=40 7=45 8=50 9=55 10=60
drop age
rename ageg age

/*merging MYS and adj_factor data to calculate SLAMYS*/
merge 1:1 iso year age using $path1\adj_factor_2015_2050_ssp3.dta
drop if adj_factor==.
gen slamys=adj_factor*wic_mys
/* outsheet using $path1\r\data\slamys_2015_2050_ssp3.csv, comma replace */
drop _merge
save $path1\slamys_2015_2050_ssp3.dta, replace

/*create cohorts*/
gen cohort=0
recode cohort 0=2000 if year==2015 & age==15
recode cohort 0=1995 if year==2015 & age==20
recode cohort 0=1990 if year==2015 & age==25
recode cohort 0=1985 if year==2015 & age==30
recode cohort 0=1980 if year==2015 & age==35
recode cohort 0=1975 if year==2015 & age==40
recode cohort 0=1970 if year==2015 & age==45
recode cohort 0=1965 if year==2015 & age==50
recode cohort 0=1960 if year==2015 & age==55
recode cohort 0=1955 if year==2015 & age==60

recode cohort 0=2005 if year==2020 & age==15
recode cohort 0=2000 if year==2020 & age==20
recode cohort 0=1995 if year==2020 & age==25
recode cohort 0=1990 if year==2020 & age==30
recode cohort 0=1985 if year==2020 & age==35
recode cohort 0=1980 if year==2020 & age==40
recode cohort 0=1975 if year==2020 & age==45
recode cohort 0=1970 if year==2020 & age==50
recode cohort 0=1965 if year==2020 & age==55
recode cohort 0=1960 if year==2020 & age==60

recode cohort 0=2010 if year==2025 & age==15
recode cohort 0=2005 if year==2025 & age==20
recode cohort 0=2000 if year==2025 & age==25
recode cohort 0=1995 if year==2025 & age==30
recode cohort 0=1990 if year==2025 & age==35
recode cohort 0=1985 if year==2025 & age==40
recode cohort 0=1980 if year==2025 & age==45
recode cohort 0=1975 if year==2025 & age==50
recode cohort 0=1970 if year==2025 & age==55
recode cohort 0=1965 if year==2025 & age==60

recode cohort 0=2015 if year==2030 & age==15
recode cohort 0=2010 if year==2030 & age==20
recode cohort 0=2005 if year==2030 & age==25
recode cohort 0=2000 if year==2030 & age==30
recode cohort 0=1995 if year==2030 & age==35
recode cohort 0=1990 if year==2030 & age==40
recode cohort 0=1985 if year==2030 & age==45
recode cohort 0=1980 if year==2030 & age==50
recode cohort 0=1975 if year==2030 & age==55
recode cohort 0=1970 if year==2030 & age==60

recode cohort 0=2020 if year==2035 & age==15
recode cohort 0=2015 if year==2035 & age==20
recode cohort 0=2010 if year==2035 & age==25
recode cohort 0=2005 if year==2035 & age==30
recode cohort 0=2000 if year==2035 & age==35
recode cohort 0=1995 if year==2035 & age==40
recode cohort 0=1990 if year==2035 & age==45
recode cohort 0=1985 if year==2035 & age==50
recode cohort 0=1980 if year==2035 & age==55
recode cohort 0=1975 if year==2035 & age==60

recode cohort 0=2025 if year==2040 & age==15
recode cohort 0=2020 if year==2040 & age==20
recode cohort 0=2015 if year==2040 & age==25
recode cohort 0=2010 if year==2040 & age==30
recode cohort 0=2005 if year==2040 & age==35
recode cohort 0=2000 if year==2040 & age==40
recode cohort 0=1995 if year==2040 & age==45
recode cohort 0=1990 if year==2040 & age==50
recode cohort 0=1985 if year==2040 & age==55
recode cohort 0=1980 if year==2040 & age==60

recode cohort 0=2030 if year==2045 & age==15
recode cohort 0=2025 if year==2045 & age==20
recode cohort 0=2020 if year==2045 & age==25
recode cohort 0=2015 if year==2045 & age==30
recode cohort 0=2010 if year==2045 & age==35
recode cohort 0=2005 if year==2045 & age==40
recode cohort 0=2000 if year==2045 & age==45
recode cohort 0=1995 if year==2045 & age==50
recode cohort 0=1990 if year==2045 & age==55
recode cohort 0=1985 if year==2045 & age==60

recode cohort 0=2035 if year==2050 & age==15
recode cohort 0=2030 if year==2050 & age==20
recode cohort 0=2025 if year==2050 & age==25
recode cohort 0=2020 if year==2050 & age==30
recode cohort 0=2015 if year==2050 & age==35
recode cohort 0=2010 if year==2050 & age==40
recode cohort 0=2005 if year==2050 & age==45
recode cohort 0=2000 if year==2050 & age==50
recode cohort 0=1995 if year==2050 & age==55
recode cohort 0=1990 if year==2050 & age==60

keep area iso age slamys cohort adj_factor
rename adj_factor adj_factor_ssp3


/*defining WB income groups*/
gen income=1 /*High income */
recode income 1=2 if iso==51 | iso==152	|iso==218 |iso==268	| iso==398 | iso==484 | iso==604 | iso==643 | iso==792 /*Upper middle income*/
recode income 1=3 if iso==68| iso==288	| iso==404	| iso==704 | iso==804	/*Lower middle income*/

/*defining school closure category from March 2020 to end of July 2021*/
gen closure=0 /*no closures or less than 4 weeks*/
recode closure 0=1 if  iso==36 | iso==51 | iso==56 | iso==196 | iso==233 | iso==250 | ///
						iso==392 | iso==554 | iso==578 | iso==208 | ///
						iso==643 | iso==702 | iso==704 | iso==724 | iso==752 /*less than 21 weeks, Azevedo et al. optimistic scenario*/
recode closure 0=2 if iso==40 | iso==246 | iso==268 | iso==276 | iso==300 | iso==348 | iso==372 | iso==376 | ///
						iso==380 | iso==398	| iso==440 | iso==528 | iso==703 | iso==804 | iso==826 | iso==840 /*22-30 weeks, intermediate scenario*/
recode closure 0=3 if iso==124 | iso==152 | iso==203 | iso==288 | iso==404 | iso==410 | iso==616 | iso==705  | iso==792/*31-40 weeks, pessimistic scenario*/
recode closure 0=4 if iso==68 | iso==170 | iso==218 | iso==484 | iso==604	 /*more than 40 weeks, very pessimistic scenario*/

/*covid effect for 2000 and 2005 cohorts*/
gen slamys_covid = cond(cohort==2010 & income==1 & closure==1, 0.97*slamys,  /// /*high income countries, optimistic scenario*/
					cond(cohort==2005 & income==1 & closure==1, 0.97*slamys, ///
					cond(cohort==2010 & income==1 & closure==2, 0.93*slamys, /// /*high income countries, intermediate scenario*/
					cond(cohort==2005 & income==1 & closure==2, 0.93*slamys, ///
					cond(cohort==2010 & income==1 & closure==3, 0.89*slamys, /// /*high income countries, pessimistic scenario*/
					cond(cohort==2005 & income==1 & closure==3, 0.89*slamys, ///
					cond(cohort==2010 & income==1 & closure==4, 0.86*slamys, /// /*high income countries, very pessimistic scenario*/
					cond(cohort==2005 & income==1 & closure==4, 0.86*slamys, ///
					cond(cohort==2010 & income==2 & closure==1, 0.96*slamys, /// /*upper middle income countries, optimistic scenario*/
					cond(cohort==2005 & income==2 & closure==1, 0.96*slamys, ///
					cond(cohort==2010 & income==2 & closure==2, 0.92*slamys, /// /*upper middle income countries, intermediate scenario*/
					cond(cohort==2005 & income==2 & closure==2, 0.92*slamys, ///
					cond(cohort==2010 & income==2 & closure==3, 0.88*slamys, /// /*upper middle income countries, pessimistic scenario*/
					cond(cohort==2005 & income==2 & closure==3, 0.88*slamys, ///
					cond(cohort==2010 & income==2 & closure==4, 0.86*slamys, /// /*upper middle income countries, very pessimistic scenario*/
					cond(cohort==2005 & income==2 & closure==4, 0.86*slamys, ///
					cond(cohort==2010 & income==3 & closure==1, 0.95*slamys, /// /*lower middle income countries, optimistic scenario*/
					cond(cohort==2005 & income==3 & closure==1, 0.95*slamys, ///
					cond(cohort==2010 & income==3 & closure==2, 0.91*slamys, /// /*lower middle income countries, intermediate scenario*/
					cond(cohort==2005 & income==3 & closure==2, 0.91*slamys, ///
					cond(cohort==2010 & income==3 & closure==3, 0.88*slamys, /// /*lower middle income countries, pessimistic scenario*/
					cond(cohort==2005 & income==3 & closure==3, 0.88*slamys, ///
					cond(cohort==2010 & income==3 & closure==4, 0.85*slamys, /// /*lower middle income countries, very pessimistic scenario*/
					cond(cohort==2005 & income==3 & closure==4, 0.85*slamys, ///
						slamys))))))))))))))))))))))))
rename slamys slamys_ssp3
rename slamys_covid slamys_covid_ssp3
save $path1\slamys_covid_2015_2050_ssp3.dta, replace
	
/*merging slamys data with SSP1, SSP2 and SSP3 scenarios*/
use $path1\slamys_covid_2015_2050.dta, clear
merge 1:1 iso age cohort using $path1\slamys_covid_2015_2050_ssp1.dta
drop _merge
rename slamys slamys_ssp2
rename slamys_covid slamys_covid_ssp2
merge 1:1 iso age cohort using $path1\slamys_covid_2015_2050_ssp3.dta
drop _merge
gen year=cohort+age
save $path1\slamys_covid_2015_2050_ssp_age.dta, replace /*3 scenarios with and without covid effects by age groups*/
/* outsheet using $path1\R\data\slamys_covid_2015_2050_ssp_age.csv, comma replace /*to be used for graphs*/ */



///*calculating country totals for 20-64 age population*///
drop income closure area cohort
egen iso_ay=group(iso age year), label /*generates iso age year combinations in one variable)*/
reshape long slamys_, i(iso_ay) j(scenario, string)
drop iso_ay
save $path1\slamys_covid_ssps_long.dta, replace

/*Population by age data from WIC Data Explorer; csv file from WIC DE should be manually opened and first rows should be deleted*/
insheet using $path1\wicdf_20_64_pop.csv, delimiter(";") clear
rename scenario scen
rename isocode iso
gen scenario = lower(scen)
drop scen
gen age_t=substr(age,1,2)
drop age
gen age=real(age_t)
drop age_t
expand 2 /*duplicationg cases*/
sort iso year age scenario
replace scenario = subinstr(scenario, "ssp1", "covid_ssp1", .) if !mod(_n,2) /*rename duplicated cases*/
replace scenario = subinstr(scenario, "ssp2", "covid_ssp2", .) if !mod(_n,2)
replace scenario = subinstr(scenario, "ssp3", "covid_ssp3", .) if !mod(_n,2)
/*calculating weights of age groups within 20-64-year-old population*/
egen iso_ys=group(iso year scenario), label
reshape wide population, i(iso_ys) j(age)
gen agegprop20=population20/(population20 + population25 + population30 + population35 + population40 + population45 + population50 + population55 + population60)
gen agegprop25=population25/(population20 + population25 + population30 + population35 + population40 + population45 + population50 + population55 + population60)
gen agegprop30=population30/(population20 + population25 + population30 + population35 + population40 + population45 + population50 + population55 + population60)
gen agegprop35=population35/(population20 + population25 + population30 + population35 + population40 + population45 + population50 + population55 + population60)
gen agegprop40=population40/(population20 + population25 + population30 + population35 + population40 + population45 + population50 + population55 + population60)
gen agegprop45=population45/(population20 + population25 + population30 + population35 + population40 + population45 + population50 + population55 + population60)
gen agegprop50=population50/(population20 + population25 + population30 + population35 + population40 + population45 + population50 + population55 + population60)
gen agegprop55=population55/(population20 + population25 + population30 + population35 + population40 + population45 + population50 + population55 + population60)
gen agegprop60=population60/(population20 + population25 + population30 + population35 + population40 + population45 + population50 + population55 + population60)
drop population*
reshape long agegprop, i(iso_ys) j(age)
/*merging with slamys data*/
merge m:1 year iso age scenario using $path1\slamys_covid_ssps_long.dta 
keep if _merge==3
drop _merge
gen slamys_w=slamys_*agegprop
drop slamys_ agegprop adj_factor*
reshape wide slamys_w, i(iso_ys) j(age)
gen slamys_=slamys_w20+slamys_w25+slamys_w30+slamys_w35+slamys_w40+slamys_w45+slamys_w50+slamys_w55+slamys_w60
drop slamys_w* iso_ys
egen iso_year=group(iso year), label
reshape wide slamys, i(iso_year) j(scenario, string)
drop iso_year
save $path1\slamys_2015_2050_country_totals.dta, replace
/* merging with mys data*/
insheet using $path1\wicdf_mys_20_64_2015_2050.csv, delimiter(";") clear
rename years mys_
rename scenario scen
rename isocode iso
gen scenario = lower(scen)
drop scen
label drop iso_year
egen iso_year=group(iso year), label 
reshape wide mys_, i(iso_year) j(scenario, string)
drop iso_year
merge 1:1 iso year using $path1\slamys_2015_2050_country_totals.dta
keep if _merge==3
drop age _merge
/* outsheet using $path1\R\data\slamys_mys_2015_2050_ssps.csv, comma replace /*to be used for graphs*/ */
save $path1\slamys_mys_2015_2050_ssps.dta, replace





