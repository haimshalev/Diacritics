function [subj] = CreateXRunMats(subj)
    
    global globalVars;
    
    % if we don't working within runs don't work with this method and
    % return
    if ~strcmp(globalVars.testsBuildMethod, 'OneRun')
        return;
    end
    
    subj = ResetInternalTestRuns(subj);
    % update the selectors to the tested conds
    subj = updateSelectors(subj, 'conds_sh3', [1 2]);
    
    if strcmp(globalVars.xRunMethod, 'nMinusOne')
        subj = CreateNMinusOneXRuns(subj);
    elseif strcmp(globalVars.xRunMethod, 'RandomPartitions')
        subj = CreateRandomPartitionsXRuns(subj);
    else
        error('Unkown xRunMethod chosen');
    end
    
    % now, create selector indices for the n different iterations of
    % the nminusone
    subj = RemoveXRuns(subj);
    args.ignore_runs_zeros = true;
    args.ignore_jumbled_runs = true;
    subj = create_xvalid_indices(subj,'runs',args);
    
    % update the selectors to the tested conds
    subj = updateSelectors(subj, 'conds_sh3', [1 2]);
 
end

function subj = CreateNMinusOneXRuns(subj)

    % create leave one out runs
    
    % the method will randomly choose coupes of tr's with one neg and one
    % pos condition. Thus creating n/2 cross validation groups
    
    [posRegs, negRegs, randPosRegsOrder, randNegRegsOrder] = SeperatePosAndNegTRs(subj, 'conds_sh3');
    
    runs = get_mat(subj, 'selector', 'runs_xval_1');
    
    %set all the positive TRs groups
    for i = 1 : length(randPosRegsOrder)
        runs(posRegs(i)) = randPosRegsOrder(i);
    end
    
    %and now for all the negative TRs
    for i = 1 : length(randNegRegsOrder)
        runs(negRegs(i)) = randNegRegsOrder(i);
    end
    
    subj = set_mat(subj, 'selector', 'runs', runs);
    
end

function subj = CreateRandomPartitionsXRuns(subj)
    
    global globalVars;
    
    [posRegs, negRegs, randPosRegsOrder, randNegRegsOrder] = SeperatePosAndNegTRs(subj, 'conds_sh3');
    allRegs = length(posRegs) + length(negRegs);
    
    % create a partition runs
    runs = get_mat(subj, 'selector', 'runs_xval_1');
    partitionSizePos = ceil(count(runs)/(globalVars.xRunPartitions .* (allRegs/length(posRegs))));
    partitionSizeNeg = ceil(count(runs)/(globalVars.xRunPartitions .* (allRegs/length(negRegs))));
    
    % set the partitions for the positive TRs
    currentPartition = 1;  
    for i = 1 : length(posRegs)
        runs(posRegs(randPosRegsOrder(i))) = currentPartition;
        if mod(i,partitionSizePos) == 0
            currentPartition = currentPartition + 1;
        end
    end
   
    % and set the partitions for the negative TRs
    currentPartition = 1;
    for i = 1 : length(negRegs)
        runs(negRegs(randNegRegsOrder(i))) = currentPartition;
        if mod(i,partitionSizeNeg) == 0
            currentPartition = currentPartition + 1;
        end
    end
    
    subj = set_mat(subj, 'selector', 'runs', runs);

end

function [posTRs , negTRs, randPosRegsOrder, randNegRegsOrder] = SeperatePosAndNegTRs(subj, regressorName)

    regs = get_mat(subj, 'regressors', regressorName);
    posTRs = find(regs(1,:) ~= 0);
    randPosRegsOrder = randperm(length(posTRs));
    negTRs = find(regs(2,:) ~= 0);
    randNegRegsOrder = randperm(length(negTRs));
    
end