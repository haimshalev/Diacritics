%% main script

global projectName;
projectName = 'diacritics';

global currentSubject;
currentSubject = '001';

global subjectName;
subjectName = ['sub' currentSubject];

global dataDir;
dataDir = '/home/haimshalev/Diacritics/Data/';

%% mask properties

global maskPath;
maskPath = [dataDir 'Mask/afnimask+tlrc'];

%% scans properties

global scansPath;
scansPath = [dataDir 'Scans/ConvertedAfniDataWithout3dDeconvolveWithout3dRefit/WithoutDiacritics/' currentSubject '/'];

global combinedScansPath;
combinedScansPath = [scansPath 'AllRuns/allRuns+tlrc'];

global scanLength;
scanLength = 171;

global withDiacriticsScanFileNameLength;
withDiacriticsScanFileNameLength = 17;

global withoutDiacriticsScanFileNameLength;
withoutDiacriticsScanFileNameLength = 16;

%% regressors properties

global regressorsPath;
regressorsPath = [dataDir 'Regressors/WithoutDiacritics/'];

global conditionNames;
conditionNames = {'M', 'R', 'MD', 'RD', 'B', 'WL'};

%% featureSelection

global isAnova; % if false, using GLM for FeatureSelection
isAnova = false;

global isStaticNumber; % if false, using threshold selection
isStaticNumber = true;

% Static number of features - taking the best #numOfFeature voxels
global staticNumOfFeatures;
staticNumOfFeatures = 2500;

global staticFeaturesMaskName;
staticFeaturesMaskName = ['staticFeatures_' int2str(staticNumOfFeatures)];

% Threshold selection - taking all the voxels that pass the specified
% threshold
global featureThresh;
featureThresh = 0.5;

global threshMaskName;
threshMaskName = ['threshedFeatures_' int2str(featureThresh)];

% setting the correct features mask name to use according to the previous
% parameters
global currentFeaturesMaskName;
if (isStaticNumber) 
    currentFeaturesMaskName = staticFeaturesMaskName;
else
    currentFeaturesMaskName = threshMaskName;
end

%% classification

global chosenConditions;
chosenConditions = [1 2];

