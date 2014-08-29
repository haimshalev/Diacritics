function [ subj ] = removeUnUsedConditions( subj, usedConditions )

% go over all the regressors matrices
for regMatIdx= 1 : size(subj.regressors,2)
    
    currentRegMat = subj.regressors{regMatIdx}.mat;
    
    % go over all the conditions in the current matrix
    for i=size(currentRegMat, 1):-1:1
        % remove the un used conditions
        if ~ismember(i,usedConditions)
             currentRegMat(i,:) = [];
        end
    end

    subj.regressors{regMatIdx}.mat = currentRegMat;
    
    % update the size of the current regressors matrix
    subj.regressors{regMatIdx}.matsize = size(subj.regressors{regMatIdx}.mat);
end

end

