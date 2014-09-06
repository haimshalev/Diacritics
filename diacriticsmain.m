%% Diacritics Project
% Main script - get mvpa, initialize data, train data

%% initialization code

global globalVars;
mvpa_add_paths;
RemoveAllFilesFromFolder(true);

% all the things we want to check
subjectsNames = {'001' '002' '003' '004' '007' '008' '009' '010' '011'};
regressorsNames = {'Regressors/Subjects 001-004/WithoutDiacritics/' 'Regressors/Subjects 001-004/WithoutDiacritics/' ...
                   'Regressors/Subjects 001-004/WithoutDiacritics/' 'Regressors/Subjects 001-004/WithoutDiacritics/' ...
                   'Regressors/Subjects 006-012/WithoutDiacritics/' 'Regressors/Subjects 006-012/WithoutDiacritics/' ...
                   'Regressors/Subjects 006-012/WithoutDiacritics/' 'Regressors/Subjects 006-012/WithoutDiacritics/' ...
                   'Regressors/Subjects 006-012/WithoutDiacritics/'};
testBuildMethods = {'OneRun' 'EntireRuns' 'OneRun'};
xRunMethod = {'RandomPartitions' 'nMinusOne' 'nMinusOne'};

% iterate over all the subjects
for i = 1 : length(subjectsNames)
    
    % iterate over all the test methods
    for j= 1 : length(testBuildMethods)
        
        % Get the global variables

        warning off
        globalVars = SetGlobalVars(subjectsNames{i}, regressorsNames{i}, testBuildMethods{j}, 'binary', xRunMethod{j}, [1 2])
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
                subjectStatistics = gatherStatistics(initialSubj);
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

            % create the new xRunMatrices if needed
            subj = CreateXRunMats(subj);

            % run feature selection 
            subj = runFeatureSelection(subj);

            summarize(subj)

            % train on the subject data and get the results
            [subj, runTrainResults] = trainsub(subj);

            % save the current train results
            trainResults = [trainResults runTrainResults];

        end

        save(globalVars.outputTrainResultFileName, 'trainResults', '-v7.3');
        warning on
        clear('runsSubjects');
        clear('trainResults');
        clc
        
    end % end of the test build method
end % end of the subject