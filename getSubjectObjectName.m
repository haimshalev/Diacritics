function [ name ] = getSubjectObjectName( runIdx )

    global testsBuildMethod;
    global subjectName;
    
    if strcmp(testsBuildMethod, 'OneRun') == 1
        name = [subjectName '_run' int2str(runIdx)];
    elseif strcmp(testsBuildMethod, 'EntireRuns') == 1
        name = subjectName;
    else
        error('Unkown testBuildMethod. Please use one of the two : OneRun or EntireRuns strings');
    end

end

