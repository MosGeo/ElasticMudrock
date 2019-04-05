function ConditionalEffectNames=CreateNames_ConditionalEffect(ParametersNames)
%%
% The function creates string objects of conditional effects
% Author: Jihoon Park (jhpark3@stanford.edu)
% Date: 13 May 2016


% Input:
% ParametersNames: (cell, length=# of Parameters): Names of uncertain parameters
%
% Output: 
% ConditionalEffectNames: (cell, length1 X (# of Parameters)*(# of Parameters-1)) : Names of conditional effects.
%
% Example:
% ParameterNames={'X','Y','Z'} will gives output of ConditionalEffectNames={'Y|X','Z|X','X|Y','Z|Y','X|Z','Y|Z'}

%%
ConditionalEffectNames=cell(1,(length(ParametersNames)^2-length(ParametersNames))); % Initialize.
ncount=0;

% String object 'A|B' will be saved at each cell.

for k=1:length(ParametersNames)
    
    B=ParametersNames{k};
        
    for j=1:length(ParametersNames)
        
        if k==j
            
            continue
            
        end
        A=ParametersNames{j};
        name_handle=[A,'|',B];
        ncount=ncount+1;
        ConditionalEffectNames{ncount}=name_handle;
        
    end
       
end

end