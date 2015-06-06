clc
disp ('IRF algorithm tester - start running on subject 1 run A1');

% create the irf dictionary using the deconvolved data
disp('reading irf dictionary');
irfDictionary = [];
irfDictionary(:,:,1) = ReadIRF('/Data/DiacriticsFramework/HaimShalevCode/3dDeconvolveTest_04.11.14/OutputFolder/001/A1/dataset_M.irf+tlrc.BRIK');
irfDictionary(:,:,2) = ReadIRF('/Data/DiacriticsFramework/HaimShalevCode/3dDeconvolveTest_04.11.14/OutputFolder/001/A1/dataset_R.irf+tlrc.BRIK');
irfDictionary(:,:,3) = ReadIRF('/Data/DiacriticsFramework/HaimShalevCode/3dDeconvolveTest_04.11.14/OutputFolder/001/A1/dataset_B.irf+tlrc.BRIK');
irfDictionary(:,:,4) = ReadIRF('/Data/DiacriticsFramework/HaimShalevCode/3dDeconvolveTest_04.11.14/OutputFolder/001/A1/dataset_WL.irf+tlrc.BRIK');

NumOfConditions = size(irfDictionary,3);
disp(['irfDictionary was read, numOfConditions ' num2str(NumOfConditions) ' , sizeofDictionary ' mat2str(size(irfDictionary))]);

%% mask the data

% note, the data is un masked, mvpa first masks the data so we need to do
% it also
disp('loading mask');
% load the mask and reshape it
load('mask.mat');
mask = logical(reshape(mask,numel(mask), 1));

% apply the mask to the irf dictionary
disp('masking the irfDictionary');
irfDictionary = irfDictionary(mask,:,:);
disp(['irfDictionary was masked , current size ' mat2str(size(irfDictionary))]);

%% regressors 

% load the regressors matrix, matrix with 4 rows (M R B WL) and with all
% runs of a specific type (diacritical or not diacritical) - in our case
% this is A1 and this is not diacritical

% load the regressors and take only the first run
disp('reading regressors');
load('regressorsA1.mat');
regressorsA1 = regressorsA1(:,1:171);

regressors = zeros(1,size(regressorsA1,2));
for conditionNum = 1 : NumOfConditions
    regressors = regressors + (conditionNum .* regressorsA1(conditionNum,:));
end

%% apply feature selection

% load the mask and reshape it (for now 2500 features)
disp('loading chosen features (voxels)');
load('featuresMask.mat');
featuresMask = logical(reshape(featuresMask,numel(featuresMask), 1));
disp(['features mask was loaded, number of features in the mask are ' num2str(count(featuresMask))]);

% mask the features
disp('masking the features with the master mask');
featuresMask = featuresMask(logical(mask));
disp(['featuresMask was masked , current size ' mat2str(size(featuresMask))]);

% apply the mask to the irf dictionary
disp('masking the irfDictionary with the features mask');
irfDictionary = irfDictionary(featuresMask,:,:);
disp(['irfDictionary was masked , current size ' mat2str(size(irfDictionary))]);

%% read the masked scans

% load the scans
disp('loading scans');
load('scans.mat');
disp(['scans were loaded, the size of scans are ' mat2str(size(scans))]);

% mask the scans with only the selected features
disp(['masking the scans with only the ' num2str(count(featuresMask)) ' selected features']);
scans = scans(featuresMask,:);
disp(['scans was masked, current size ' mat2str(size(scans))]);

%% try to classify the data
[classificationRes, confusionMatrix] = ClassifyTestData(scans, regressors, irfDictionary);
confusionMatrix