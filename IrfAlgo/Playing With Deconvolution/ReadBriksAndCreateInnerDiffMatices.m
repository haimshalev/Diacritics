function [ runIrfs, diffMatix ] = ReadBriksAndCreateInnerDiffMatices( runsIrfsPaths )
%READBRIKSANDCREATEINNERDIFFMATICES will go over each irf path, read it's
%brik and store it in a cell in the runIrfs matrix, and will create a
%difference matrix of all couples of conditions

    runIrfs = ReadBrik(runsIrfsPaths);

    % create diff matrices
    diffMatix = cell(length(runIrfs),length(runIrfs));
    for i = 1 : length(runIrfs)
        for j = 1 : length(runIrfs)
            diffMatix{i,j} = abs(runIrfs{i} - runIrfs{j});
        end
    end

end

