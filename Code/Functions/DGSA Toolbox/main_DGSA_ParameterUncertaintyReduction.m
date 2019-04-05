%% Distance based global sensitivity analysis - Application to reservoir responses
% Compute net conditional effects and reduce uncertainty of model parameters

% The script uses results from the previous script main_DGSA_Reservoir_Sensitivity.m

% Author : Jihoon Park (jhpark3@stanford.edu)
% Date : 17 May 2016


clear all; close all; fclose('all');
addpath(genpath(pwd))
load('DGSA_Completed'); % Load all variables from the previous script.
%%
load('Responses_PUR');
Responses_AfterPUR=WWPT_PUR; clear WWPT_PUR;


%% Net Conditional effects

% Net conditional effects for a single parameter
[NetConditionalEffects,Bin_MaxNetConditional]=ComputeNetConditionalEffects...
    ('oilexp', DGSA);

% Net conditional effects for every parameter
DisplayNetConditionalEffects_all(DGSA); 

%% Compare responses: Prior vs. After reduction of parameter uncertainty

ResponsesCompared.tgrid=365:365:7300; ResponsesCompared.idxResponse=2;
ResponsesCompared.QuantileLevel=[.1,.5,.9];
ResponsesCompared.xlab='Time(day)';ResponsesCompared.ylab='WWPT (stb)';
CompareResponses(PriorResponses,Responses_AfterPUR,ResponsesCompared);
