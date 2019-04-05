% Scipt to get spatial rank for spatial models using KPCA and SOM
% there are two test cases: one is on the gradual deformation example
% the other is on an emsemble of 500 realizations of 2D 68*64 permeability grid 

% Author: Guang Yang 

clear all; close all; clc


%% example 1
model1='gaussian_realz1';
model2='gaussian_realz2';
%read in the two SGS simulated models 
r1=read_model(model1);
r2=read_model(model2);

%theta vector
theta=0:0.1:1;

%realization matrix resulting from gradual deformation
r_ensemble=[];
r_temp=r1*sin(theta*pi)+r2*cos(theta*pi);
r_ensemble=[r_ensemble r_temp];

%run the KPCASOM_rank script
%we used Gaussian radial basis function kernel
%For Gaussian RBF, kernel_para is for setting up the sigma value in RBF function 
% sigma= kernel_para * mean distance between models 
kernel_para=5;
[Y_eig,ndim,rank]=KPCASOM_rank(r_ensemble,'gaussian',kernel_para);

%% example 2
%read in the models 
temp=load('ModelsExample2.mat');
r_ensemble_2D=temp.perm_ensemble;
%get the spatial rank for the models 
[Y_eig_2,ndim_2,rank_2]=KPCASOM_rank(r_ensemble_2D,'gaussian',kernel_para);