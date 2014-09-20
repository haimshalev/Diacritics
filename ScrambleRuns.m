function [ subj ] = ScrambleRuns( subj )
%SCRAMBLERUNS Summary of this function goes here
%   Detailed explanation goes here

    global globalVars;
    
    % if we don't working within runs don't work with this method and
    % return
    if ~strcmp(globalVars.testsBuildMethod, 'ScrambledEntireRuns')
        return;
    end
    
    % remove all the x_runs
    subj = RemoveXRuns(subj);
    
    % initialize the first run 
    runsmat = get_mat(subj, 'selector', 'runs');
    runsmat = zeros(size(runsmat));
        
    % get the number of each condition
    regressorMat = get_mat(subj, 'regressors', 'conds_sh3');
    
    % create 4 scrambled cross validation groups

    % go over each condition and split the tr's to the 4 groups
    for conditionIdx = [1 2]
        currentConditionRegressors = regressorMat(conditionIdx,:);
        tr = 0;
        for trIdx = 1 : length(currentConditionRegressors)
            if (currentConditionRegressors(trIdx) == 1)
                runsmat(trIdx) = mod(tr,4) + 1;
                tr = tr+1;
            end
        end
    end
    
    subj = set_mat(subj, 'selector', 'runs', runsmat);
    
    % now, create selector indices for the n different iterations of
    % the nminusone
    args.ignore_runs_zeros = true;
    args.ignore_jumbled_runs = true;
    subj = create_xvalid_indices(subj,'runs',args);
end

