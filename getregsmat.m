function [regsmat condnames] = getregsmat(runIdx)

    %% create the regressors matrix

    global globalVars;

    if (globalVars.diacriticalSigns)
        regex = '(regressors)[A-B](D)[1-2](.mat)';
    else
        regex = '(regressors)[A-B][1-2](.mat)';
    end
    
    files = getallfiles(globalVars.regressorsPath, regex);
    
    [numOfRequiredRegFiles, fileIdxs] = getRegsIdxs(files, runIdx);
    regsmat = [];
    for iFile = 1 : numOfRequiredRegFiles

        load([globalVars.regressorsPath files{fileIdxs(iFile)}]);

        %Create a new reg matrix

        if globalVars.diacriticalSigns
           %outputMatrix = [ zeros(2, size(outputMatrix,2)) ; outputMatrix];
           condnames = globalVars.conditionNames([3 4 5 6]);
        else
           %outputMatrix = [outputMatrix(1:2,:) ; zeros(2,size(outputMatrix,2)) ; outputMatrix(3:4,:)];
           condnames = globalVars.conditionNames([1 2 5 6]);
        end

        regsmat = [regsmat outputMatrix];    
    end

end

function [numOfRequiredRegFiles, fileIdxs] = getRegsIdxs(RegFiles, runIdx)

    global globalVars;
    
    if strcmp(globalVars.testsBuildMethod,'OneRun') == 1
        numOfRequiredRegFiles = 1;
        fileIdxs = runIdx;
    elseif strcmp (globalVars.testsBuildMethod, 'EntireRuns') == 1
        numOfRequiredRegFiles = length(RegFiles);
        fileIdxs = 1 : numOfRequiredRegFiles;
    elseif strcmp (globalVars.testsBuildMethod, 'ScrambledEntireRuns') == 1
        numOfRequiredRegFiles = length(RegFiles);
        fileIdxs = 1 : numOfRequiredRegFiles;
    else
        error('Unkown testBuildMethod. Please use one of the two : OneRun or EntireRuns strings');
    end
        
end