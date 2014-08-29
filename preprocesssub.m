function subj = preprocesssub(sub)

global chosenConditions;

% we want to z-score the EPI data (called 'epi'),
% individually on each run (using the 'runs' selectors)
subj = zscore_runs(sub,'epi','runs');

% now, create selector indices for the n different iterations of
% the nminusone
subj = create_xvalid_indices(subj,'runs');

% remove all the TRs of the untested conditions, remove all the non tested conditions
subj = updateSelectors(subj , 'conds_conv', chosenConditions);

% remove all the non tested conditions
subj = removeUnUsedConditions(subj, chosenConditions);

% Run Anova to use it with voxel selection later - with this method we
% cannot use convolved regressors
subj = RunAnova(subj);

% Run GLM (3dDeconvolve) to use voxel selection later - with this feature selection we
% can convolve our regressors
subj = RunGLM(subj);

end