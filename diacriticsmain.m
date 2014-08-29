 %% Diacritics Project
% Main script - get mvpa, initialize data, train data

%% initialization code

% Get the global variables
GlobalVars
global projectName;
global subjectName;
global chosenConditions;
global isAnova;

warning off
needToInitialize = true;
mvpa_add_paths;
RemoveAllFilesFromFolder;

%% initialize subject 
if needToInitialize == true
    
    % return an initialized subj structure
    % first param - the name of the db, second param - the structure name
    % (should be the name of the subject we work on)
    
    initialSubj = init_subj(projectName,subjectName);
    initialSubj = initsub(initialSubj);  
    subjectStatistics = gatherStatistics(initialSubj);
    initialSubj = preprocesssub(initialSubj);
    
    save([subjectName 'cond' int2str(chosenConditions) ' IsAnova ' int2str(isAnova)], 'initialSubj', '-v7.3');
end

%% set the current test properties and train on the data

% save the initialized subject stuct to HD
subj = initialSubj;

% remove the unused selectors ( now all of the unused)
% we using the first two conditions beacause we deleted all of the unused
% conditions at the preprocesssub function
subj = updateSelectors(subj, 'conds_sh3', [1 2]);

% run feature selection 
subj = runFeatureSelection(subj);

summarize(subj)

% train on the subject data and get the results
[subj, trainResults] = trainsub(subj);

warning on