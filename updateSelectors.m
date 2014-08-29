function [ subj ] = updateSelectors( subj , regressorsMatName, chosenConditions)

% get the regressors matrix which will tell us which selectors we don't use
regressors = get_mat(subj, 'regressors', regressorsMatName);

% Reminder : condnames located in the global vars file; 

% create a regressors maps
regressorsMask = zeros(1,size(regressors,2));
for i = chosenConditions
    regressorsMask = regressorsMask | regressors(i,:);
end

% for each x_run selector
for i=2 : size(subj.selectors,2)
    
    % update the selector matrix
    subj.selectors{i}.mat = subj.selectors{i}.mat .* regressorsMask;
end

end

