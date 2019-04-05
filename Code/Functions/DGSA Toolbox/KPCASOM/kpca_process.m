function [ Y, eigVector,eigValue ] = kpca_process( r_summary, type, kernel_para)
%this function does the kernel pca based on the choice of the kernel function and kernel parameters
%function is modified based on scipts of Quan Wang, 2011/05/10
%   two types of kernel functions are implemented: gaussian and ploynomial 
%	
if strcmp(type,'gaussian')
	%% Gaussian kernel PCA
	% d is the number of the models 
    d=size(r_summary,1);
    DIST=distanceMatrix(r_summary);
    DIST(DIST==0)=inf;
    DIST=min(DIST);
    %the sigma squared para (c=5)
    para=kernel_para*mean(DIST);
    disp('Performing Gaussian kernel PCA...');
    %running KPCA for different realizations
    [Y, eigVector,eigValue]=kPCA(r_summary,d,'gaussian',para);
elseif strcmp(type,'poly')
    %%polynomial kernel PCA
    d_poly=size(r_summary,1);
    para_poly=kernel_para;
    disp('Performing Polynomial kernel PCA...');
    %running KPCA for different realizations
    [Y, eigVector,eigValue]=kPCA(r_summary,d_poly,'poly',para_poly);
end
end

