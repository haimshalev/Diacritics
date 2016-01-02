function subj = preprocesssub(sub , runIdx)

    global globalVars;
    if strcmp(globalVars.testsBuildMethod, 'OneRun')
        subj = preprocesssubForOneTest(sub, runIdx);
    elseif strcmp(globalVars.testsBuildMethod,'EntireRuns')
        subj = preprocesssubForEntireTests(sub);
    elseif strcmp(globalVars.testsBuildMethod,'ScrambledEntireRuns')
        subj = preprocesssubForEntireTests(sub);
    else
        error('Unkown testsBuildMethod value. Please use OneRun or EntireRuns strings');
    end
end

function subj = preprocesssubForEntireTests(sub)

    global globalVars;

    % we want to z-score the EPI data (called 'epi'),
    % individually on each run (using the 'runs' selectors)
    subj = zscore_runs(sub,'epi','runs');

    % now, create selector indices for the n different iterations of
    % the nminusone
    subj = create_xvalid_indices(subj,'runs');

    % Run Anova to use it with voxel selection later - with this method we
    % cannot use convolved regressors
    subj = RunAnova(subj);

    % Run GLM (3dDeconvolve) to use voxel selection later - with this feature selection we
    % can convolve our regressors
    subj = RunGLM(subj,1);

end

function subj = preprocesssubForOneTest(sub , runIdx)

    global globalVars;

    % we want to z-score the EPI data (called 'epi'),
    % individually on each run (using the 'runs' selectors)
    subj = zscore_runs(sub,'epi','runs');

    % now, create selector indices for the n different iterations of
    % the nminusone
    subj = ResetInternalTestRuns(subj);

    % Run Anova to use it with voxel selection later - with this method we
    % cannot use convolved regressors
    subj = RunAnova(subj);

    % Run GLM (3dDeconvolve) to use voxel selection later - with this feature selection we
    % can convolve our regressors
    subj = RunGLM(subj , runIdx);
end
