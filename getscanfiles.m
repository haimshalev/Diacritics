function filenames = getscanfiles(runIdx)

    global globalVars;

    if (globalVars.diacriticalSigns)
        regex = '(dataset)[A-B](D)[1-2](+tlrc.BRIK)';
    else
        regex = '(dataset)[A-B][1-2](+tlrc.BRIK)';
    end
    
    scanFiles = getallfiles(globalVars.scansPath, regex);
    [numOfRequiredScanFiles fileIdxs] = getScanIdxs(scanFiles, runIdx);
    filenames = cell(1, numOfRequiredScanFiles);
    for idx = 1 : length(fileIdxs)
        filenames{idx} = [globalVars.scansPath scanFiles{fileIdxs(idx)}];
    end
end

function [numOfRequiredScanFiles fileIdxs] = getScanIdxs(scanFiles, runIdx)

    global globalVars;
    
    if strcmp(globalVars.testsBuildMethod,'OneRun') == 1
        numOfRequiredScanFiles = 1;
        fileIdxs = [runIdx];
    elseif strcmp (globalVars.testsBuildMethod, 'EntireRuns') == 1
        numOfRequiredScanFiles = length(scanFiles);
        fileIdxs = [1 : numOfRequiredScanFiles];
    elseif strcmp (globalVars.testsBuildMethod, 'ScrambledEntireRuns') == 1
        numOfRequiredScanFiles = length(scanFiles);
        fileIdxs = [1 : numOfRequiredScanFiles];
    else
        error('Unkown testBuildMethod. Please use one of the two : OneRun or EntireRuns strings');
    end
        
end