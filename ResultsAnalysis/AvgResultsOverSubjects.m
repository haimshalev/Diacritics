function [ avgResults, allTests ] = AvgResultsOverSubjects( input_args )

    globalVars  = SetGlobalVars();
    
    %% get the results files file paths
    
    % get the trainReults folder path
    trainResultsFolder = globalVars.trainResultsFolderPath;
    
    % get all the file names in the folder
    trainResultsFileNames = dir(trainResultsFolder);
    trainResultsFileNames = {trainResultsFileNames.name};
    
    % take only the ones needed
    regExp = regexptranslate('wildcard', 'sub* OneRun Conds 1  2 IsAnova 0 decisionMethod binary xRun nMinusOne.mat');
    requiredFiles = regexp(trainResultsFileNames, regExp, 'match');
    requiredFiles(cellfun('isempty',requiredFiles))= [];
    
    %% load all the files
    if (exist('allTests','var') ~= 1)
        for fileNameIdx = 1 : length(requiredFiles)

            currentFileName = [globalVars.trainResultsFolderPath char(requiredFiles{fileNameIdx})];
            disp(['Start reading :' currentFileName]);

            % load the current test results. The name of the variable soppose
            % to be 'trainResults'
            load(currentFileName); 
            allTests{fileNameIdx} = trainResults;
            % remove the unused members
            for i = 1 : length(allTests{fileNameIdx})
                allTests{1, fileNameIdx}(1, i).resultsObjects = [];
            end        
        end
    end
    
    %% initialize the return struct
    
   avgResults = InitializeAvgTrainResultsObj(globalVars);
      

end

function [avgTrainResults] = InitializeAvgTrainResultsObj(globalVars)

    % every 'OneRun' testresults object got 4 cells (because each test is independent):
    %   for diacritics : AD1 AD2 BD1 BD2
    %   for withoutDiacritics : A1 A2 B1 B2
    if (strcmp(globalVars.testsBuildMethod, 'OneRun'))
        avgTrainResults = cell(1,4);
        
    % every 'EntireRuns' testresults object got only 1 cell (all the
    % tests are used together)
    elseif strcmp(globalVars.testsBuildMethod, 'EntireRuns')
        avgTrainResults = [];
    else
        error('Unkown testsBuildMethod value');
    end

end

