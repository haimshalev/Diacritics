% get all the data 
% TODO: add string which indicates which files are needed
if (~exist('alltests','var'))
    [ avgResults, allTests ] = AvgResultsOverSubjects( input_args );
end

% for each test save it's avg results
for testIdx = 1 : length(alltests{1})
       
    allSubjectsCurrentTests = alltests{subjectIdx}(testIdx);
    for subjectIdx = 2: length(alltests)
        allSubjectsCurrentTests(subjectIdx) = alltests{subjectIdx}(testIdx);
    end
    
    % get the results
    [avgResults(testIdx).avgForEachTestOverIterationsOverSubjects, ...
     avgResults(testIdx).stdForEachTestOverIterationsOverSubjects ] = ...
        GetAvgStdForASpecificField({allSubjectsCurrentTests.avgForEachTestOverIterations});
    [avgResults(testIdx).avgForEachIterationOverTestsOverSubjects, ...
     avgResults(testIdx).stdForEachIterationOverTestsOverSubjects ] = ...
        GetAvgStdForASpecificField({allSubjectsCurrentTests.avgForEachIterationsOverTests});
    
end