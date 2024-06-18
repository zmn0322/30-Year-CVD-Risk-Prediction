This repository contains code to predict 30-year CVD risk in the following paper:

An, J., Zhang, Y., Zhou, H., Zhou, M., Safford, M. M., Muntner, P., Moran, A. E., & Reynolds, K. (2023). Incidence of Atherosclerotic Cardiovascular Disease in Young Adults at Low Short-Term But High Long-Term Risk. J Am Coll Cardiol, 81(7), 623-632. 


The first step is to download Risk_calculator_import.sas7bdat(Can be found in this repository) and save it in your study directory. The data includes important prediction calculation information.
If have any issue to open Risk_calculator_import.sas7bdat, Please download Risk_calculator_import.xlsx and import to SAS.

To run the Macro, need to define the parameters: 

    1.Cohort_size = the population size for the study. 
  
    2.Inputdata = the population data including sex, age, systolic blood pressure, total cholesterol, high density lipoprotein cholesterol, diabetes, BMI, smoking, and treated hypertension.
  
    3.Outputdata = output data with 30-year cardiovascular risk predications under either hard CVD outcome or full ranges of CVD outcome and BMI information availability scenarios. 

The Inputdata must be at individual level and other than ID need to have the variables:

•	Gender = categorical variable having two values ‘M’ and ‘F’.
•	Age = numeric variable ranging from 20 to 59.
•	Risk_sbp = numeric variable - systolic blood pressure.
•	Risk_cholesterol = numeric variable - total cholesterol.
•	Risk_HDL = numeric variable - high density lipoprotein cholesterol.
•	BMI = numeric variable - body mass index.
•	DM = binary variable - diabetes mellitus.
•	Current_tobacco = binary variable - smoking status.
•	Risk_HTN = binary variable - use of antihypertensive treatment.

For further information or assistance with this code, please reach out to the main author - Matt Zhou by email mengnan.m.zhou@kp.org




