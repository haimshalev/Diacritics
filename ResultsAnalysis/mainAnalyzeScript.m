regStrings = { 'sub* OneRun Conds 1  2 IsAnova 0 decisionMethod binary xRun RandomPartitions.mat'
               'sub* OneRun Conds 3  4 IsAnova 0 decisionMethod binary xRun RandomPartitions.mat'
               'sub* EntireRuns Conds 1  2 IsAnova 0 decisionMethod binary.mat'
               'sub* EntireRuns Conds 3  4 IsAnova 0 decisionMethod binary.mat'
               'sub* ScrambledEntireRuns Conds 1  2 IsAnova 0 decisionMethod binary.mat'
               'sub* ScrambledEntireRuns Conds 3  4 IsAnova 0 decisionMethod binary.mat'};
           
regStrings = {'sub* DiacriticalSigns 1 OneRun Conds 1  2  3 IsAnova 0 decisionMethod maxClass xRun nMinusOne'};

outputStrings = { 'conds12OneRunWithRandomPartitions'
                  'conds34OneRunWithRandeomPartitions'
                  'conds12EntireRuns'
                  'conds34EntireRuns'
                  'conds12ScrambledEntireRuns'
                  'conds34ScrambledEntireRuns'};
              
 outputStrings={'conds123OneRunWithNMinusOneDiacriticalSigns'};
              
for stringIdx = 1 : length(regStrings)

    % get all the data 
    % TODO: add string which indicates which files are needed
    [ avgResults, alltests ] = AvgResultsOverSubjects( regStrings(stringIdx));
    

    % for each test save it's avg results
    for testIdx = 1 : length(alltests{1})

        allSubjectsCurrentTests = alltests{1}(testIdx);
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
    
    save(outputStrings{stringIdx}, 'avgResults');
end