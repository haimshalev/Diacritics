function [subj] = CreateXRunMats(subj)
    
    global xRunMethod;
    if strcmp(xRunMethod, 'nMinusOne')
        subj = CreateNMinusOneXRuns(subj);
    elseif strcmp(xRunMethod, 'RandomPartitions')
        subj = CreateRandomPartitionsXRuns(subj);
    else
        error('Unkown xRunMethod chosen');
    end
    
    % now, create selector indices for the n different iterations of
    % the nminusone
    subj = remove_object(subj,'selector','runs_xval_1');
    args.ignore_runs_zeros = true;
    args.ignore_jumbled_runs = true;
    subj = create_xvalid_indices(subj,'runs',args);
       
end

function subj = CreateNMinusOneXRuns(subj)

    % create leave one out runs
    runs = get_mat(subj, 'selector', 'runs_xval_1');
    runs(runs ~= 0) = 1 : count(runs);
    subj = set_mat(subj, 'selector', 'runs', runs);
    
end

function subj = CreateRandomPartitionsXRuns(subj)
    
    global xRunPartitions;
    
    % create a partition runs
    runs = get_mat(subj, 'selector', 'runs_xval_1');
    randIndeces = randperm(count(runs));
    partitionSize = ceil(count(runs)/xRunPartitions);
    
    currentPartition = 1;
    randPartitions = zeros(size(randIndeces));
    
    for i = 1 : count(randIndeces)
        randPartitions(randIndeces(i)) = currentPartition;
        if mod(i,partitionSize) == 0
            currentPartition = currentPartition + 1;
        end
    end
    
    runs(runs ~= 0) = randPartitions;
    subj = set_mat(subj, 'selector', 'runs', runs);

end