function [ globalParams ] = SetGlobalVars(currentSubject, testBuildMethod, decisionMethod, xRunMethod, chosenConditions)

    %% setting deafault argument values

    if (~exist('currentSubject','var') || isempty(currentSubject))
        currentSubject = '001';
    end

    if (~exist('testBuildMethod','var') || isempty(testBuildMethod))
        testBuildMethod = 'OneRun';
    end

    if (~exist('decisionMethod', 'var') || isempty(decisionMethod))
        decisionMethod = 'binary';
    end

    if (~exist('xRunMethod', 'var') || isempty(xRunMethod))
        xRunMethod = 'nMinusOne';
    end

    if (~exist('chosenConditions', 'var') || isempty(chosenConditions))
        chosenConditions = [1 2];
    end

    %% initializing main script vars

    globalParams.projectName = 'diacritics';
    globalParams.currentSubject = currentSubject;
    globalParams.subjectName = ['sub' globalParams.currentSubject];
    globalParams.dataDir = '/home/haimshalev/Diacritics/Data/';

    % how to create the subjects objects. The values are : OneRun/EntireRuns
    globalParams.testsBuildMethod = testBuildMethod;

    %% mask properties

    globalParams.maskPath = [globalParams.dataDir 'Mask/afnimask+tlrc'];

    %% scans properties

    globalParams.scansPath = [globalParams.dataDir 'Scans/ConvertedAfniDataWithout3dDeconvolveWithout3dRefit/WithoutDiacritics/' globalParams.currentSubject '/'];
    globalParams.combinedScansPath = [globalParams.scansPath 'AllRuns/allRuns+tlrc'];

    globalParams.scanLength = 171;

    globalParams.withDiacriticsScanFileNameLength = 17;

    globalParams.withoutDiacriticsScanFileNameLength = 16;

    %% regressors properties

    globalParams.regressorsPath = [globalParams.dataDir 'Regressors/WithoutDiacritics/'];

    globalParams.conditionNames = {'M', 'R', 'MD', 'RD', 'B', 'WL'};

    %% featureSelection

    % if false, using GLM for FeatureSelection
    globalParams.isAnova = false;

    % if false, using threshold selection
    globalParams.isStaticNumber = true;

    % Static number of features - taking the best #numOfFeature voxels
    globalParams.staticNumOfFeatures = 2500;

    globalParams.staticFeaturesMaskName = ['staticFeatures_' int2str(globalParams.staticNumOfFeatures)];

    % Threshold selection - taking all the voxels that pass the specified
    % threshold
    globalParams.featureThresh = 0.5;

    globalParams.threshMaskName = ['threshedFeatures_' int2str(globalParams.featureThresh)];

    % setting the correct features mask name to use according to the previous
    % parameters
    if (globalParams.isStaticNumber) 
        globalParams.currentFeaturesMaskName = globalParams.staticFeaturesMaskName;
    else
        globalParams.currentFeaturesMaskName = globalParams.threshMaskName;
    end

    %% classification

    globalParams.chosenConditions = chosenConditions;

    % how the classificaion should work : binary or maxClass
    globalParams.decisionMethod = decisionMethod; 

    % performance method function name
    if (strcmp(globalParams.decisionMethod,'binary') == 1)
        globalParams.performanceMethod = 'perfmet_binaryDecision';
    elseif (strcmp(globalParams.decisionMethod,'maxClass') == 1)
        globalParams.performanceMethod = 'perfmet_maxclass';
    else
        error('unrecognized classification decision method');
    end

    % x_runs Creation Method (Currently for oneRun) values :
    % nMinusOne/RandomPartitions
    globalParams.xRunMethod = xRunMethod;

    globalParams.xRunPartitions = 2;

    %% output files

    globalParams.outputFolderPath = '../Output/';

    globalParams.subjectsFolderPath = [ globalParams.outputFolderPath 'Subjects/'];

    globalParams.trainResultsFolderPath = [ globalParams.outputFolderPath 'TrainResults/'];

    globalParams.outputSubjectFileName = [globalParams.subjectsFolderPath globalParams.subjectName ' ' ...
                             globalParams.testsBuildMethod ' Conds ' int2str(globalParams.chosenConditions) ...
                             ' IsAnova ' int2str(globalParams.isAnova)];

    globalParams.outputTrainResultFileName = [globalParams.trainResultsFolderPath globalParams.subjectName ' ' ...
                             globalParams.testsBuildMethod ' Conds ' int2str(globalParams.chosenConditions) ...
                             ' IsAnova ' int2str(globalParams.isAnova) ' decisionMethod ' ...
                             globalParams.decisionMethod ];

     if strcmp(globalParams.testsBuildMethod, 'OneRun')
         globalParams.outputTrainResultFileName = [globalParams.outputTrainResultFileName ' xRun ' globalParams.xRunMethod];
         globalParams.outputSubjectFileName = [globalParams.outputSubjectFileName ' xRun ' globalParams.xRunMethod];
     end
 
end % end of function
