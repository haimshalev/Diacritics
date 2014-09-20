function [ subjectStatistics ] = gatherStatistics( subj )

    %% for each test, check how much TR include each condition

    % get the number of conditions
    regressorMat = subj.regressors{1,1}.mat;
    numOfConditions = size(regressorMat, 1);
       
    % get the number of tests
    numOfTests = length(getscanfiles(1));
    
    subjectStatistics.CounterConditions = zeros(numOfConditions,numOfTests);
    
    % for each condition on every test
    for conditionIdx = 1 : numOfConditions
        for testIdx = 1 : numOfTests
            currentCondition = regressorMat(conditionIdx, :);
            currentCondition = currentCondition((testIdx * 171 - 170): testIdx*171);
            subjectStatistics.CounterConditions(conditionIdx, testIdx) = count(currentCondition);
        end
    end

end

