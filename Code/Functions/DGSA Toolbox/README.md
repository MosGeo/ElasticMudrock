# Distance based generalized sensitiviy analysis (DGSA)

 The program is to apply DGSA to obtain main/conditional effects and utilize them in uncertainty quantification. 
 
 All variables, procedures, and results are provided at Manual_DGSA.pdf 

 Main scripts
 
 1) main_DGSA_analytic.m: an analytic example originally written by Céline Scheidt. The forward model is simply a bivariate function that helps users understand and utilize DGSA. 
 
 2) main_DGSA_Reservoir_Sensitivity.m: an example of applying DGSA to reservoir responses. Both main and conditional effects are computed and visualized. In addition, responses are plotted according to the classes they belong to. 
 
 3) main_DGSA_ParameterUncertaintyReduction.m: uncertainty of parameters is reduced by decreasing uncertainty of insensitive parameters based on net conditional effects. The third script uses the variables from the second script – they are separated for convenience. Thus, if a user wants to perform reduction of parameter uncertainty, the second script main_DGSA_Reservoir_Sensitivity should be run first and all the results should be saved.  
 
 4) main_compareDGSA_Sobol.m: validates the results of DGSA by comparing to Sobol’s indices. If a user only needs to apply DGSA, he or she does not need to run this script.
