function [ numOfSubjects subjectsArr ] = getNumberOfSubjectsToCreate()

    global globalVars;

    subjectsArr = [];
    
    if strcmp(globalVars.testsBuildMethod, 'OneRun')
         if (globalVars.diacriticalSigns)
            regex = '(dataset)[A-B](D)[1-2](+tlrc.BRIK)';
        else
            regex = '(dataset)[A-B][1-2](+tlrc.BRIK)';
         end
        numOfSubjects = size(getallfiles(globalVars.scansPath, regex),2);
    elseif strcmp(globalVars.testsBuildMethod,'EntireRuns')
        numOfSubjects = 1;
    elseif strcmp(globalVars.testsBuildMethod,'ScrambledEntireRuns')
        numOfSubjects = 1;        
    else
        error('Unkown testsBuildMethod value. Please use OneRun or EntireRuns strings');
    end

end

