%% Diacritics Project
% Main script - get mvpa, initialize data, train data

%% initialization code

global globalVars;
mvpa_add_paths;
RemoveAllFilesFromFolder(true);

%% Setting all the things we want to check

subjectsNames = {'001' '002' '003' '004' '007' '008' '009' '010' '011'};
diacriticalSignsIdx = {false true};
testBuildMethods = {'EntireRuns' 'OneRun' 'OneRun', 'ScrambledEntireRuns'};
xRunMethod = {'nMinusOne' 'nMinusOne' 'RandomPartitions' 'nMinusOne' };

%% start running

%iterate over all the subjects
for diacriticalSignsIdx = 1 : length(withDiacritics)
    for i = 1 : length(subjectsNames)

        % iterate over all the test methods
        for j= 1 : length(testBuildMethods)

            % Get the global variables

            warning off
            globalVars = SetGlobalVars(subjectsNames{i}, withDiacritics{diacriticalSignsIdx}, testBuildMethods{j}, 'maxClass', xRunMethod{j}, [1 2]) 
            needToInitialize = true;

            %% initialize subjects
            if needToInitialize == true

                % initialize each subj run with a seperate subj object
                [numberOfRuns runsSubjects] = getNumberOfSubjectsToCreate();

                for runIdx = 1 : numberOfRuns

                    RemoveAllFilesFromFolder(false);

                    % return an initialized subj structure
                    % first param - the name of the db, second param - the structure name
                    % (should be the name of the subject we work on)
                    initialSubj = init_subj(globalVars.projectName,getSubjectObjectName(runIdx));
                    initialSubj = initsub(initialSubj, runIdx);  
                    initialSubj = preprocesssub(initialSubj, runIdx);

                    runsSubjects = [runsSubjects initialSubj];
                end

                save(globalVars.outputSubjectFileName , 'runsSubjects', '-v7.3');
            end

            %% set the current test properties and train on the data

            trainResults = [];
            for runIdx = 1:length(runsSubjects)

                % save the initialized subject stuct to HD
                subj = runsSubjects(runIdx);

                % remove all the TRs of the untested conditions, remove all the non tested conditions
                subj = updateSelectors(subj , 'conds_sh3', globalVars.chosenConditions);

                % remove all the non tested conditions
                subj = removeUnUsedConditions(subj, globalVars.chosenConditions);

                % create the new xRunMatrices if needed
                subj = CreateXRunMats(subj);

                % scramble runs 
                subj = ScrambleRuns(subj);

                % run feature selection
                subj = runFeatureSelection(subj);

                %SaveSelectedFeatures(subj, globalVars.diacriticalSigns, globalVars.outputFolderPath, globalVars.currentSubject, globalVars.testsBuildMethod);               

                summarize(subj)

                % train on the subject data and get the results
                [subj, runTrainResults] = trainsub(subj);

                % save the current train results
                trainResults = [trainResults runTrainResults];

            end

            %save(globalVars.outputTrainResultFileName, 'trainResults', '-v7.3');
            warning on
            RemoveAllFilesFromFolder(false);
            clear('runsSubjects');
            clear('trainResults');
            clc

        end % end of the test build method
    end % end of the subject
end % end of diacritical signs