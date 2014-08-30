function [regsmat condnames] = getregsmat(runIdx)

    %% create the regressors matrix

    global regressorsPath;
    global withDiacriticsScanFileNameLength;
    global withoutDiacriticsScanFileNameLength;

    dataDir = regressorsPath;
    files = what(dataDir);
    files = files.mat;
    regsmat = [];
    [numOfRequiredRegFiles fileIdxs] = getRegsIdxs(files, runIdx);
    for iFile = 1 : numOfRequiredRegFiles

        load([dataDir files{fileIdxs(iFile)}]);

        %Create a new reg matrix

        % if with diacritics
        if size(files{fileIdxs(iFile)}, 2) == withDiacriticsScanFileNameLength
           outputMatrix = [ zeros(2, size(outputMatrix,2)) ; outputMatrix];
        % if without diacritics
        elseif size(files{fileIdxs(iFile)},2) == withoutDiacriticsScanFileNameLength
           outputMatrix = [outputMatrix(1:2,:) ; zeros(2,size(outputMatrix,2)) ; outputMatrix(3:4,:)];
        else error('unkown regressor file length');
        end

        regsmat = [regsmat outputMatrix];    
    end

    %% set the condition names list

    global conditionNames
    condnames = conditionNames;

end

function [numOfRequiredRegFiles fileIdxs] = getRegsIdxs(RegFiles, runIdx)

    global testsBuildMethod;
    
    if strcmp(testsBuildMethod,'OneRun') == 1
        numOfRequiredRegFiles = 1;
        fileIdxs = [runIdx];
    elseif strcmp (testsBuildMethod, 'EntireRuns') == 1
        numOfRequiredRegFiles = length(RegFiles);
        fileIdxs = [1 : numOfRequiredRegFiles];
    else
        error('Unkown testBuildMethod. Please use one of the two : OneRun or EntireRuns strings');
    end
        
end