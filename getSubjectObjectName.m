function [ name ] = getSubjectObjectName( runIdx )
    
    global globalVars;
    
    if strcmp(globalVars.testsBuildMethod, 'OneRun') == 1
        name = [globalVars.subjectName '_run' int2str(runIdx)];
    elseif strcmp(globalVars.testsBuildMethod, 'EntireRuns') == 1
        name = globalVars.subjectName;
    else
        error('Unkown testBuildMethod. Please use one of the two : OneRun or EntireRuns strings');
    end

end

