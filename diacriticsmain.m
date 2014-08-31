%% Diacritics Project
% Main script - get mvpa, initialize data, train data

%% initialization code

% Get the global variables
GlobalVars
global projectName;
global subjectName;
global outputSubjectFileName;

warning off
needToInitialize = true;
mvpa_add_paths;
RemoveAllFilesFromFolder;

%% initialize subjects
if needToInitialize == true
    
    % initialize each subj run with a seperate subj object
    [numberOfRuns runsSubjects] = getNumberOfSubjectsToCreate;
    
    for runIdx = 1 : numberOfRuns
        
        RemoveAllFilesFromFolder;
        
        % return an initialized subj structure
        % first param - the name of the db, second param - the structure name
        % (should be the name of the subject we work on)
        initialSubj = init_subj(projectName,getSubjectObjectName(runIdx));
        initialSubj = initsub(initialSubj, runIdx);  
        subjectStatistics = gatherStatistics(initialSubj);
        initialSubj = preprocesssub(initialSubj, runIdx);
        initialSubj = updateSelectors(initialSubj, 'conds_sh3', [1 2]);

        runsSubjects = [runsSubjects initialSubj];
    end
    
    save(outputSubjectFileName , 'runsSubjects', '-v7.3');
end

%% set the current test properties and train on the data

for runIdx = 1:length(runsSubjects)
    % save the initialized subject stuct to HD
    subj = runsSubjects(runIdx);

    % run feature selection 
    subj = runFeatureSelection(subj);

    summarize(subj)

    % train on the subject data and get the results
    [subj, trainResults] = trainsub(subj);
end

warning on