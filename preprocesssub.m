function subj = preprocesssub(sub , runIdx)

    global testsBuildMethod;
    if strcmp(testsBuildMethod, 'OneRun')
        subj = preprocesssubForOneTest(sub, runIdx);
    elseif strcmp(testsBuildMethod,'EntireRuns')
        subj = preprocesssubForEntireTests(sub);
    else
        error('Unkown testsBuildMethod value. Please use OneRun or EntireRuns strings');
    end

end

function subj = preprocesssubForEntireTests(sub)

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
    subj = RunGLM(subj,1);

end

function subj = preprocesssubForOneTest(sub , runIdx)

    global chosenConditions;

    % we want to z-score the EPI data (called 'epi'),
    % individually on each run (using the 'runs' selectors)
    subj = zscore_runs(sub,'epi','runs');

    % now, create selector indices for the n different iterations of
    % the nminusone
    subj = create_xvalid_indices(subj,'runs');
    runs = get_mat(subj, 'selector', 'runs_xval_1');
    runs = ones(size(runs));
    subj = set_mat(subj, 'selector', 'runs_xval_1', runs);

    % remove all the non tested conditions
    subj = removeUnUsedConditions(subj, chosenConditions);

    % Run Anova to use it with voxel selection later - with this method we
    % cannot use convolved regressors
    subj = RunAnova(subj);

    % Run GLM (3dDeconvolve) to use voxel selection later - with this feature selection we
    % can convolve our regressors
    subj = RunGLM(subj , runIdx);

    % remove all the TRs of the untested conditions, remove all the non tested conditions
    subj = updateSelectors(subj , 'conds_sh3', chosenConditions);

    % create the new xRunMatrices
    subj = CreateXRunMats(subj);

end
