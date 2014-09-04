function [ subj ] = RemoveXRuns( subj )

    % remove all the selector matrices except the first one which is the
    % runs matrix
    subj.selectors(2:size(subj.selectors, 2)) = [];

end

