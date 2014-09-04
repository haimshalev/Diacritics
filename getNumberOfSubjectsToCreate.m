function [ numOfSubjects subjectsArr ] = getNumberOfSubjectsToCreate()

    global globalVars;

    subjectsArr = [];
    
    if strcmp(globalVars.testsBuildMethod, 'OneRun')
        numOfSubjects = size(getallfiles(globalVars.scansPath, '.BRIK'),2);
    elseif strcmp(globalVars.testsBuildMethod,'EntireRuns')
        numOfSubjects = 1;
    else
        error('Unkown testsBuildMethod value. Please use OneRun or EntireRuns strings');
    end

end

