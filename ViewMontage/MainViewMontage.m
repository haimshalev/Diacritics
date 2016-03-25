%% Diacritics Project
% Main script - get mvpa, initialize data, train data

%% initialization code

global globalVars;
mvpa_add_paths;
RemoveAllFilesFromFolder(true);

%% Setting all the things we want to check

subjectsNames = {'001' '002' '003' '004' '007' '008' '009' '010' '011'};
withDiacritics = {true false};
testBuildMethods = {'EntireRuns'}; %{'EntireRuns' 'OneRun' 'OneRun', 'ScrambledEntireRuns'};
xRunMethod = {'nMinusOne'}; %{'nMinusOne' 'nMinusOne' 'RandomPartitions' 'nMinusOne' };

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
                    if (withDiacritics{diacriticalSignsIdx})
                        diacritics = 'd';
                    else 
                        diacritics = '';
                    end
                    initialSubj = init_subj(globalVars.projectName,getSubjectObjectName(runIdx,diacritics));
                    initialSubj = initsub(initialSubj, runIdx);  
                    initialSubj = preprocesssub(initialSubj, runIdx);

                    runsSubjects = [runsSubjects initialSubj];
                end

                %save(globalVars.outputSubjectFileName , 'runsSubjects', '-v7.3');
            end

            %% set the current test properties and train on the data

            trainResults = [];
            if strcmp(testBuildMethods{j}, 'OneRun')
               AllRunSubject = runsSubjects(runIdx); 
               AllRunSubject.header.id = [subjectsNames{i} '_' diacritics]
            end
            
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

                summarize(subj)

                if strcmp(testBuildMethods{j}, 'EntireRuns')
                    subj = CreateUnionFeaturesMask(subj, 'staticFeatures_2500');
                    subj = CreateIntersectFeaturesMask(subj, 'staticFeatures_2500');
                    subj = CreateAnatomicalImageForSubject(subj, 'epi');
                    
                    SaveSelectedFeatures(subj, withDiacritics{diacriticalSignsIdx}, subjectsNames{i}, globalVars.outputFolderPath, 'staticFeatures_2500');
                    
                    CreateFeaturesMontages(subj, 'epi_vol1', 'staticFeatures_2500');
                end

                % if we are in one run mode, lets save the features of each
                % run to a different subject to ouput the intersect and
                % union later
                if strcmp(testBuildMethods{j}, 'OneRun')
                    AllRunSubject = init_object(AllRunSubject,'mask',['staticFeatures_2500_' num2str(runIdx)]);
                    AllRunSubject = set_mat(AllRunSubject,'mask',['staticFeatures_2500_' num2str(runIdx)],get_mat(subj,'mask','staticFeatures_2500'));
                    object = get_object(AllRunSubject,'mask',['staticFeatures_2500_' num2str(runIdx)]);
                    object.group_name = 'staticFeatures_2500';
                    AllRunSubject = set_object(AllRunSubject,'mask',['staticFeatures_2500_' num2str(runIdx)], object);
                end
            end

            % if we are in one run mode, now we created the features , so
            % lets output them
            if strcmp(testBuildMethods{j}, 'OneRun')
                
                
                AllRunSubject = CreateUnionFeaturesMask(AllRunSubject, 'staticFeatures_2500');
                AllRunSubject = CreateIntersectFeaturesMask(AllRunSubject, 'staticFeatures_2500');
                AllRunSubject = CreateAnatomicalImageForSubject(AllRunSubject, 'epi');
                
                SaveSelectedFeatures(AllRunSubject, withDiacritics{diacriticalSignsIdx}, subjectsNames{i}, globalVars.outputFolderPath, 'staticFeatures_2500');
                
                CreateFeaturesMontages(AllRunSubject, 'epi_vol1', 'staticFeatures_2500');
                
                
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