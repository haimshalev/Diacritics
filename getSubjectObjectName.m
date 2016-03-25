function [ name ] = getSubjectObjectName( runIdx , diacriticalSign)
    
    if (~exist('diacriticalSign','var') || strcmp(diacriticalSign,''))
        diacriticalSign = '';
    else 
        diacriticalSign = ['_' diacriticalSign];
    end

    global globalVars;
    
    if strcmp(globalVars.testsBuildMethod, 'OneRun') == 1
        name = [globalVars.subjectName '_run' int2str(runIdx) diacriticalSign];
    elseif strcmp(globalVars.testsBuildMethod, 'EntireRuns') == 1
        name = [globalVars.subjectName diacriticalSign];
    elseif strcmp(globalVars.testsBuildMethod, 'ScrambledEntireRuns') == 1
        name = [globalVars.subjectName diacriticalSign];
    else
        error('Unkown testBuildMethod. Please use one of the two : OneRun or EntireRuns strings');
    end

end

