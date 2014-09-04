function [ subj ] = ResetInternalTestRuns( subj )

    % remove all the x_runs
    subj = RemoveXRuns(subj);

    % initialize the first run 
    runs = get_mat(subj, 'selector', 'runs');
    runs(runs ~= 0) = ones(size(runs~=0));
    subj = set_mat(subj, 'selector', 'runs', runs);
    
    % now, create selector indices for the n different iterations of
    % the nminusone, it will create only one because we have only one run
    % configured
    subj = create_xvalid_indices(subj,'runs');
    
    % the first matrix will contain only two's because it is the first
    % and all of the data goes for testing instead of training,
    % so convert all the two's to one's
    runs = get_mat(subj, 'selector', 'runs_xval_1');
    runs(runs ~= 0) = ones(size(runs~=0));
    subj = set_mat(subj, 'selector', 'runs_xval_1', runs);
    
end

