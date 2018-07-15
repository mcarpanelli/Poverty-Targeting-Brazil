//////////////////////////////////////////////////////////////////////////////////////////////////
/////////// Poverty Prediction in Brazil: Building dataset for analysis and modeling /////////////
//////////////////////////////////////////////////////////////////////////////////////////////////


/*
This file builds a dataset based on Brazil's National House Survey (PNAD) in 3 steps:
1. Cleans and selects variables from individual PNAD and collapses dataset into household size (poverty prediction is at household level)
2. Merges individual and household PNADs and cleans data
3. Exports clean and merged dataset into csv file
*/


*Setup
clear all
set mem 200m
set more off
local path = "/Users/mcarpanelli/Box Sync/MPA-ID/API 209 - Stats/PSfinal" 
global pathdo "/Users/mcarpanelli/Box Sync/MPA-ID/API 209 - Stats/PSfinal"
cd "$pathdo"

******************************************************
* 1. Clean Individual PNAD and collapse to household *
******************************************************

use Individuals_baseline.dta, clear
merge m:1 nkaggle using processed_data.dta
save base_individuals.dta, replace

clear all
use base_individuals.dta

*Auxiliary variables
*CHARACTERISTICS
gen gender=(v0302==2) /*male*/
gen head=(v0401==1 | v0402==1)

gen white=1 if v0404==2
replace white=0 if white==.
gen black=1 if v0404==4
replace black=0 if black==.
gen mixed=1 if v0404==6
replace mixed=0 if mixed==.

gen id=(v0408==2)
gen birthcert=(v0408==2)

gen sharehh=1 if v0409!=.
replace sharehh=0 if sharehh==.
gen intentionmove=(v0410==2)
gen married=(v4011<7)

gen cellphone=(v06112==1)

gen south=1 if uf>30
replace south=0 if south==.
gen southborn=1 if (54>v5030 & v5030>30)
replace southborn=0 if southborn==.

gen nkids=v1141+v1142
gen ndeadkids=v1161+v1162+v1111+v1112
gen nwomen=(gender==1)
gen nmen=(gender==0)
gen npeople=nmen+nwomen
gen neapeople=npeople if (15<v3033 & v3033<66)
replace neapeople=0 if neapeople==.
gen nold=npeople if (65<v3033 & v3033<99)
replace nold=0 if nold==.

gen ageaux=2012-v3033 if v3033>99
replace ageaux=100 if v3033==1912
replace ageaux=101 if v3033==1911
replace ageaux=102 if v3033==1910
replace ageaux=103 if v3033==1909
replace ageaux=104 if v3033==1908
gen age=v3033 if v3033<99
replace age=ageaux if age==.
replace age=100 if age>110

gen livesabroad=(v0504==2)
gen headmale=head*gender


*EDUCATION
gen readwrite=1 if v0601==1
replace readwrite=0 if readwrite==. 
gen school=(v0602==2)
gen private=(v6002==2)
gen college=(v4745==7)
gen highschool=(v4745==5)

gen educ=0 if v4803==1
replace educ=1 if v4803==2
replace educ=2 if v4803==3
replace educ=3 if v4803==4
replace educ=4 if v4803==5
replace educ=5 if v4803==6
replace educ=6 if v4803==7
replace educ=7 if v4803==8
replace educ=8 if v4803==9
replace educ=9 if v4803==10
replace educ=10 if v4803==11
replace educ=11 if v4803==12
replace educ=12 if v4803==13
replace educ=13 if v4803==14
replace educ=14 if v4803==15
replace educ=15 if v4803==16

gen educhead=educ if head==1

*WORK
gen childworks=1 if (v0701==1 | v0702==2 | v0703==2)
replace childworks=0 if childworks==.

gen employed=(v4746==1)

gen morethan1job=1 if v9005>1
replace morethan1job=0 if morethan1job==.

gen union=(v9087==1)

rename v9058 workedhs

gen jobagric=(v4808==1)
gen jobind=(v4809==2|v4809==3)
gen jobconstr=(v4809==4)
gen jobret=(v4809==5)
gen jobcomms=(v4809==7)
gen jobgovt=(v4809==8)
gen jobmaid=(v4809==10)

gen jobhighskills=(v4810<3)

gen anyhelp=1 if v9043==1 
replace anyhelp=1 if v9044==2
replace anyhelp=1 if v9045==1
replace anyhelp=1 if v9046==2
replace anyhelp=1 if v9047==1
replace anyhelp=0 if anyhelp==.

gen employee=1 if v9008<5
replace employee=0 if employee==.

gen entrepreneur=1 if (v9008>4 & v9008<8)
replace entrepreneur =0 if entrepreneur==.

gen headfirstjob=head*v9892

gen formalcontract=(v9042==2)
gen headfc=head*formalcontract
gen socialsec=(v9099==1) 

replace v0713=0 if v0713==.
replace v9101=0 if v9101==.
replace v9057=0 if v9057==.
replace v0715=0 if v0715==.

gen hsworked=v0713+v9101
gen longcommuting=(v9057>3)
rename v0715 hsworkedhouse


collapse (mean) age gender white black mixed id cellphone readwrite employed morethan1job employee entrepreneur meaneduc=educ birthcert agefirstjob=v9892 mhsworked=hsworked mhsworkedhouse=hsworkedhouse (sum) nkids ndeadkids npeople nmen nwomen neapeople nold sumhsworked=hsworked sumhsworkedhouse=hsworkedhouse (max) south southborn school private childworks maxeduc=educ educhead headmale sharehh livesabroad headfc socialsec headfirstjob intentionmove married college highschool union jobagric jobind jobconstr jobret jobcomms jobgovt jobmaid jobhighskills anyhelp maxhsworked=hsworked maxhsworkedhouse=hsworkedhouse longcommuting, by(nkaggle)

gen menwomen=nmen/nwomen
gen dependency=((nkids+nold)/neapeople)



save base_individuals_collapsed.dta, replace


clear all


**************************************************
* 2. Merge Individual and Household PNAD + Clean *
**************************************************

use Households_baseline.dta, clear
merge m:1 nkaggle using processed_data.dta
rename _merge _merge0
merge m:m nkaggle using base_individuals_collapsed.dta
drop if _merge==2
save base_hh.dta, replace

clear all
use base_hh.dta
                        
*Dummies

*ASSETS
gen ownshouse=((v0207==1)|(v0207==2))
gen ownsland=(v0210==2)

gen phone_mobile=(v0220==2)

gen phone_fix=(v2020==2)

gen radio=(v0225==1)

gen tv=1 if v0226==2
replace tv=1 if v0227==1
replace tv=0 if tv==.

gen tvbw=(v0227==1)

gen dvd=(v2027==1)

gen fridge=1 if v0228<6
replace fridge =0 if fridge==.

gen computer=1 if v0231==1
replace computer=0 if computer==.

gen washer=(v0230==2)

gen car=(v2032==2)
gen motorbike=(v2032==4)
gen carbike=(v2032==6)

gen nassets= phone_mobile+ phone_fix+ radio+ tv+ dvd+ fridge+ computer+ carbike+ washer
 
*SERVICES
gen water=(v0211==1)
gen sewer=(v0217==1)
gen natgas=(v0223==2)
gen trash_collection=1 if v0218<3
replace trash_collection=0 if trash_collection==.

gen electricity=(v0219==1)

gen internet=(v0232==2)

*HOUSE FEATURES
gen permanenthome=(v0201==1)
gen apt=(v0202==2)

gen rent=v0208 if v0208<999999999	

gen roofjute=(v0204>4)
gen walljute=(v0203>4)

gen waternet=(v0212==2)
gen waterwell=(v0214==2)
gen bathroom=(v0215==1)
gen stove=((v0221==1)|(v0222==2))
gen stove_botgas=(v0223==1)
gen stove_natgas=(v0223==2)
gen waterfilter=(v0224==2)

rename v0205 nrooms
rename v0206 nbedrooms
rename v2016 nbathrooms
rename v0106 nadults

gen peopleroom= npeople/nbedrooms

*REGION FEAUTURES
gen regmetrop=(v4107==1)
gen region1=(region==1)
gen region2=(region==2)
gen region3=(region==3)
gen region4=(region==4)
gen region5=(region==5)

*OTHER
gen kid=(nkids!=0)
gen kidschool=kid*school
gen kidprivate=kid*private
gen agesq=age*age
gen maintratio=nadults*employed/npeople
gen rentpc=rent/npeople

egen mnpeople=mean(npeople)
gen npeople1=npeople-mnpeople
gen npeople2=npeople1*npeople1

* DROP
drop v0101 v0104 v0105 v0203 v0204 v0208 v0209 v0210 v0211 v0215 v0220 v2020 v0221 v0222 v0224 v0225 v0226 v0227 v2027 v0228 v0229 v0230 v0231 v0232 v2032 v0201 v0202 v0207 v0212 v0213 v0214 v0218 v0219 v0216 v0217 v0223 v4600 v4601

*Fill in missings
sum if _n<110508
egen mnrooms=mean(nrooms)
replace nrooms=mnrooms if nrooms==.
egen mnbedrooms=mean(nbedrooms)
replace nbedrooms=mnrooms if nbedrooms==.
egen mnbathrooms=mean(nbathrooms)
replace nbathrooms=mnbathrooms if nbathrooms==.
egen mmeaneduc=mean(meaneduc)
replace meaneduc=mmeaneduc if meaneduc==.
egen mmaxeduc=mean(maxeduc)
replace maxeduc=mmaxeduc if maxeduc==.
egen magefirstjob=mean(agefirstjob)
replace agefirstjob=magefirstjob if agefirstjob==.
egen meduchead=mean(educhead)
replace educhead=meduchead if educhead==.
egen mmenwomen=mean(menwomen)
replace menwomen=mmenwomen if menwomen==.
egen mdependency=mean(dependency)
replace dependency=mdependency if dependency==.
egen mrent=mean(rent)
replace rent=mrent if rent==.
egen mpeopleroom=mean(peopleroom)
replace peopleroom=mpeopleroom if peopleroom==.
egen mheadfirstjob=mean(headfirstjob)
replace headfirstjob=mheadfirstjob if headfirstjob==.

drop mnrooms mnbedrooms mnbathrooms mmeaneduc mmaxeduc magefirstjob meduchead mmenwomen mdependency mrent mpeopleroom mheadfirstjob


* Recodify urban
rename urban urban_old
gen urban =(urban_old == 1)

drop urban_old

*Labels

label var npeople "Household size"
label var urban "Urban area"
label var region "Region"
label var region1 "South"
label var region2 "Southeast"
label var region3 "Centerwest"
label var region4 "Northeast"
label var region5 "North"
label var age "Average age of household"
label var gender "Proportion of men in household"
label var white "Proportion of whites in household"
label var black "Proportion of blacks in household"
label var mixed "Proportion of mixed in household"
label var id "Proportion of people who have ID in household"
label var birthcert "Proportion of people who have birth certificate in household"
label var cellphone "Proportion of people who own a cellphone in household"
label var readwrite "Proportion of people who can read and write in household"
label var employed "Proportion of people employed in household"
label var morethan1job "Proportion of people who have more than 1 job in household"
label var employee "Proportion of people who are employees in household"
label var entrepreneur "Proportion of people who are entrepreneurs in household"
label var meaneduc "Average years of education in household"
label var agefirstjob "Average age of first job in household"
label var nkids "Number of kids in household"
label var ndeadkids "Number of dead kids in household"
label var nadults "Number of adults in household"
label var nmen "Number of men in household"
label var nwomen "Number of women in household"
label var neapeople "Number of economically active people in household"
label var nold "Number of old people in household"
label var south "Proportion of whouseholds who live in Regions 1-3"
label var southborn "Proportion of households who were born in Regions 1-3"
label var kid "Proportion of households who have kids"
label var kidschool "Proportion of households who have kids who attend school"
label var kidprivate "Proportion of households who have kids who attend a private school"
label var maxeduc "Years of education of the most educated person of the household"
label var educhead "Years of education of the head of the household"
label var headmale "Proportion of households whose head is a man"
label var sharehh "Proportion of households who share their home with other people"
label var livesabroad "Proportion of households who have at least 1 person living abroad"
label var headfc "Proportion of heads of household who have a formal labor contract"
label var socialsec "Proportion of households who contribute to the social security system"
label var menwomen "Ratio men:women"
label var dependency "Ratio (kids+old):adults"
label var ownshouse "Proportion of households who own their home"
label var ownsland "Proportion of households who own their land"
label var phone_mobile "Proportion of households who own at least 1 mobile phone"
label var phone_fix "Proportion of households who own a fix phone"
label var radio "Proportion of households who own a radio"
label var tv "Proportion of households who own a tv"
label var tvbw "Proportion of households who own a black and white tv"
label var dvd "Proportion of households who own a dvd"
label var fridge "Proportion of households who own a fridge"
label var computer "Proportion of households who own a computer"
label var washer "Proportion of households who own a washing machine"
label var car "Proportion of households who own a car"
label var motorbike "Proportion of households who own a motorbike"
label var carbike "Proportion of households who own a car and a motorbike"
label var water "Proportion of households who have running water"
label var trash_collection "Proportion of households with access to trash collection service"
label var electricity "Proportion of households who have electricity"
label var internet "Proportion of households who have internet"
label var rent "Average monthly rent paid (Reais)"
label var roofjute "Proportion of households who live in houses with jute roof"
label var walljute "Proportion of households who live in houses with jute walls"
label var waterwell "Proportion of households who get water from a well"
label var bathroom "Proportion of households who have a bathroom in their house"
label var stove "Proportion of households who have a stove in their house"
label var waterfilter "Proportion of households who have a waterfilter"
label var peopleroom "Ratio people:rooms"
label var regmetrop "Proportion of households who live in a metropolitan region"
label var nassets "Average number of assets owned by the household"
label var permanenthome "Proportion of households whose home is permanent"
label var apt "Proportion of households who live in an appartment"
label var waternet "Proportion of households who access a water network"
label var sewer "Proportion of households who access a sewer network"
label var natgas "Proportion of households who access a gas network"
label var childworks "Proportion of households with at least one child who works"
label var jobagric "Proportion of households where at least one person works in agriculture"
label var jobind "Proportion of households where at least one person works in an industry"
label var jobconstr "Proportion of households where at least one person works in construction"
label var jobret "Proportion of households where at least one person works in retail"
label var jobcomms "Proportion of households where at least one person works in communications"
label var jobgovt "Proportion of households where at least one person works in the government"
label var jobmaid "Proportion of households where at least one person works as a maid"
label var jobhighskills "Proportion of households where at least one person has a high-skills job"
label var anyhelp "Proportion of households who receive some help (estipend, food, transportation, education, health)"
label var headfirstjob "Average age at which the head started working"
label var married "Proportion of households with at least one married couple"
label var college "Proportion of households with at least one college graduate"
label var highschool "Proportion of households with at least one highschool graduate"
label var union "Proportion of households where at least one person is affiliated to a labor union"



********************
* 3. Export to CSV *
********************

outsheet * using pnad_clean.csv, comma
