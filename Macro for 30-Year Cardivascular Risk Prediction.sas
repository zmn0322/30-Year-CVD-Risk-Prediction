


options ps=80 ls=90 pageno=1 nodate center;
options compress=yes sastrace=',,,s' sastraceloc=saslog no$stsuffix;

/*Define Library*/
libname dat "C:\Users\s769102";

/*****************************************************************************************/
/*Program: Macro for 30-Year cardiovascular Risk Prediction                               */
/*Author: Matt Zhou                                                                       */
/*Creation Date: 09/12/2023                                                               */
/*Purpose: Estimate 30-year cardiovascular risk                                           */
/*Contact information: mengnan.m.zhou@kp.org                                              */

/*Input Data is at patient level*/ /*Description*/
/*Variables are required        */ 
/*MRN                           */ /*Unique ID            */
/*Age Numeric                   */ /*Age                   */
/*Gender Character: M/F         */ /*Gender                */
/*DM Numeric: 0/1               */ /*Diabete               */
/*BMI Numeric                   */ /*BMI                   */
/*Risk_cholesterol Numeric      */ /*Cholesterol           */
/*Risk_HDL Numeric              */ /*HDL                   */
/*Risk_HTN Numeric: 0/1         */ /*Treated Hypertension  */
/*Current_tobacco Numeric: 0/1  */ /*Current Smoking Status*/
/*Risk_SBP Numeric              */ /*SBP                   */

/*dat.Risk_calculator_import*/
/*Source: The Excel version can be downloaded from 
https://www.framinghamheartstudy.org/fhs-risk-functions/cardiovascular-disease-30-year-risk/
*/


/*Loop everyone one by one*/
%macro risk_calculator(inputdata,cohort_size,outputdata);

%do i = 1 %to &cohort_size.;/*cohort size*/
data _30yr_risk;
set &inputdata.;/*cohort data*/
if _N_=&i.;
/*creat linke variable in order to merge with calculator*/
link=1;
keep mrn gender age link risk_sbp risk_cholesterol risk_hdl current_tobacco risk_htn dm bmi;
run;

proc sql;
create table _30yr_risk_v2 as 
select a.*,b.*
from _30yr_risk as a full join dat.Risk_calculator_import/*risk calculator 1340 rows with link and order variable*/ as b on a.link=b.link;
quit;

data _30yr_risk_v3;
set _30yr_risk_v2;
/*Create male flag for calculation*/
if gender="F" then male_flag=0;
else if gender='M' then male_flag=1;
else male_flag=.;

/*CVD_No_BMI*/
CVD_No_BMI_x_beta=0.34362*male_flag+2.63588*log(age)+1.8803*log(risk_sbp)+1.12673*log(risk_cholesterol)+(-0.90941)*log(risk_hdl)+0.59397*current_tobacco+0.5232*risk_htn+0.68602*dm;
CVD_No_BMI_dx_beta=0.48123*male_flag+3.39222*log(age)+1.39862*log(risk_sbp)+(-0.00439)*log(risk_cholesterol)+0.16081*log(risk_hdl)+0.99858*current_tobacco+0.19035*risk_htn+0.49756*dm;
CVD_No_BMI_exp_x_beta=exp(CVD_No_BMI_x_beta-21.29326612);
CVD_No_BMI_exp_dx_beta=exp(CVD_No_BMI_dx_beta-20.12840698);
CVD_No_BMI_acs=CVD_No_BMI1**CVD_No_BMI_exp_x_beta;
CVD_No_BMI_ads=CVD_No_BMI2**CVD_No_BMI_exp_dx_beta;

/*HCVD_No_BMI*/
HCVD_No_BMI_x_beta=0.55021*male_flag+2.83511*log(age)+1.99822*log(risk_sbp)+1.4775*log(risk_cholesterol)+(-0.86736)*log(risk_hdl)+0.70063*current_tobacco+0.39241*risk_htn+0.9137*dm;
HCVD_No_BMI_dx_beta=0.47666*male_flag+3.53291*log(age)+1.43216*log(risk_sbp)+0.00704*log(risk_cholesterol)+0.09148*log(risk_hdl)+0.97352*current_tobacco+0.11888*risk_htn+0.45355*dm;
HCVD_No_BMI_exp_x_beta=exp(HCVD_No_BMI_x_beta-24.72839981);
HCVD_No_BMI_exp_dx_beta=exp(HCVD_No_BMI_dx_beta-20.56609979);
HCVD_No_BMI_acs=HCVD_No_BMI1**HCVD_No_BMI_exp_x_beta;
HCVD_No_BMI_ads=HCVD_No_BMI2**HCVD_No_BMI_exp_dx_beta;

/*CVD_BMI*/
CVD_BMI_x_beta=0.54089*male_flag+2.7684*log(age)+1.69824*log(risk_sbp)+0.68916*current_tobacco+0.53163*risk_htn+1.01325*log(bmi)+0.79624*dm;
CVD_BMI_dx_beta=0.47835*male_flag+3.43911*log(age)+1.57043*log(risk_sbp)+0.98257*current_tobacco+0.18871*risk_htn+(-0.52377)*log(bmi)+0.51411*dm;
CVD_BMI_exp_x_beta=exp(CVD_BMI_x_beta-21.89281378);
CVD_BMI_exp_dx_beta=exp(CVD_BMI_dx_beta-18.82684236);
CVD_BMI_acs=CVD_BMI1**CVD_BMI_exp_x_beta;
CVD_BMI_ads=CVD_BMI2**CVD_BMI_exp_dx_beta;

/*HCVD_BMI*/
HCVD_BMI_x_beta=0.73413*male_flag+3.07187*log(age)+1.79939*log(risk_sbp)+0.79437*current_tobacco+0.3926*risk_htn+1.1166*log(bmi)+1.03634*dm;
HCVD_BMI_dx_beta=0.47275*male_flag+3.55871*log(age)+1.5204*log(risk_sbp)+0.96516*current_tobacco+0.11331*risk_htn+(-0.27572)*log(bmi)+0.45868*dm;
HCVD_BMI_exp_x_beta=exp(HCVD_BMI_x_beta-23.93525811);
HCVD_BMI_exp_dx_beta=exp(HCVD_BMI_dx_beta-19.79731622);
HCVD_BMI_acs=HCVD_BMI1**HCVD_BMI_exp_x_beta;
HCVD_BMI_ads=HCVD_BMI2**HCVD_BMI_exp_dx_beta;
run;


/*get the lead values*/
proc sort data=_30yr_risk_v3;by mrn descending order;run;

data _30yr_risk_v4;
set _30yr_risk_v3;
by mrn;
CVD_No_BMI1_lead=lag(CVD_No_BMI1);
HCVD_No_BMI1_lead=lag(HCVD_No_BMI1);
CVD_BMI1_lead=lag(CVD_BMI1);
HCVD_BMI1_lead=lag(HCVD_BMI1);

if first.mrn then do;
CVD_No_BMI1_lead=.;
HCVD_No_BMI1_lead=.;
CVD_BMI1_lead=.;
HCVD_BMI1_lead=.;
end;
run;
proc sort data=_30yr_risk_v4;by mrn order;run;

data _30yr_risk_v5;
set _30yr_risk_v4;
by mrn;
/*CVD NO BMI*/
CVD_No_BMI_diff_log=log(CVD_No_BMI1)-log(CVD_No_BMI1_lead);
CVD_No_BMI_diff_log_lag=lag(CVD_No_BMI_diff_log);
CVD_No_BMI_acs_lag=lag(CVD_No_BMI_acs);
CVD_No_BMI_ads_lag=lag(CVD_No_BMI_ads);
CVD_No_BMI_askla=CVD_No_BMI_exp_x_beta*CVD_No_BMI_diff_log_lag*CVD_No_BMI_acs_lag*CVD_No_BMI_ads_lag;
/*HCVD NO BMI*/
HCVD_No_BMI_diff_log=log(HCVD_No_BMI1)-log(HCVD_No_BMI1_lead);
HCVD_No_BMI_diff_log_lag=lag(HCVD_No_BMI_diff_log);
HCVD_No_BMI_acs_lag=lag(HCVD_No_BMI_acs);
HCVD_No_BMI_ads_lag=lag(HCVD_No_BMI_ads);
HCVD_No_BMI_askla=HCVD_No_BMI_exp_x_beta*HCVD_No_BMI_diff_log_lag*HCVD_No_BMI_acs_lag*HCVD_No_BMI_ads_lag;

/*CVD BMI*/
CVD_BMI_diff_log=log(CVD_BMI1)-log(CVD_BMI1_lead);
CVD_BMI_diff_log_lag=lag(CVD_BMI_diff_log);
CVD_BMI_acs_lag=lag(CVD_BMI_acs);
CVD_BMI_ads_lag=lag(CVD_BMI_ads);
CVD_BMI_askla=CVD_BMI_exp_x_beta*CVD_BMI_diff_log_lag*CVD_BMI_acs_lag*CVD_BMI_ads_lag;
/*HCVD BMI*/
HCVD_BMI_diff_log=log(HCVD_BMI1)-log(HCVD_BMI1_lead);
HCVD_BMI_diff_log_lag=lag(HCVD_BMI_diff_log);
HCVD_BMI_acs_lag=lag(HCVD_BMI_acs);
HCVD_BMI_ads_lag=lag(HCVD_BMI_ads);
HCVD_BMI_askla=HCVD_BMI_exp_x_beta*HCVD_BMI_diff_log_lag*HCVD_BMI_acs_lag*HCVD_BMI_ads_lag;


if first.mrn then do;
CVD_No_BMI_askla=CVD_No_BMI_exp_x_beta*(-log(CVD_No_BMI1));
HCVD_No_BMI_askla=HCVD_No_BMI_exp_x_beta*(-log(HCVD_No_BMI1));
CVD_BMI_askla=CVD_BMI_exp_x_beta*(-log(CVD_BMI1));
HCVD_BMI_askla=HCVD_BMI_exp_x_beta*(-log(HCVD_BMI1));
end;
run;

/*rolled them up one record per patient*/
proc sql;
create table _30yr_risk_v6 as 
select mrn,sum(CVD_No_BMI_askla) as CVD_No_BMI_risk_score,sum(HCVD_No_BMI_askla) as HCVD_No_BMI_risk_score, sum(CVD_BMI_askla) as CVD_BMI_risk_score, sum(HCVD_BMI_askla) as HCVD_BMI_risk_score
from _30yr_risk_v5
group by mrn;
quit;


/*stack everyone together*/
%if &i.=1 %then %do;
	data &outputdata.;
	set _30yr_risk_v6;
	run;
%end;
%else %do;
	data &outputdata.;
	set _30yr_risk_v6 &outputdata.;
	run;
%end;

%end %do;

proc sort data=&outputdata.;by mrn;run;
%mend;
%risk_calculator(inputdata=,cohort_size=,outputdata=);












/************************************************************************Example******************************************************************************************/

/*Sample Data*/
data _sample;
infile datalines delimiter=','; 
input MRN $ gender $ age risk_sbp risk_cholesterol risk_hdl current_tobacco risk_htn dm bmi;
datalines;                      
001,M,35,120,230.8,59,0,0,1,23
002,F,50.5,135.2,.,66,1,1,1,23.5
003,F,41,132.4,235,64,0,1,1,.
004,.,39.6,133,238.5,63.7,1,1,0,25.4
005,M,38,.,.,.,0,1,0,.
;
run;
proc print data=_sample;run;


/*Define Parameters*/
%risk_calculator(inputdata=_sample,cohort_size=5,outputdata=RiskScore);
proc print data=Risk_Score;run;
