function [ numOfSubjects subjectsArr ] = getNumberOfSubjectsToCreate()

    global testsBuildMethod;
    global scansPath;

    subjectsArr = [];
    
    if strcmp(testsBuildMethod, 'OneRun')
        numOfSubjects = size(getallfiles(scansPath, '.BRIK'),2);
    elseif strcmp(testsBuildMethod,'EntireRuns')
        numOfSubjects = 1;
    else
        error('Unkown testsBuildMethod value. Please use OneRun or EntireRuns strings');
    end

end

