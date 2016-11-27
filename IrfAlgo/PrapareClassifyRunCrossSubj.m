function [scans, regressors, irfDictionary, features]  = PrapareClassifyRunCrossSubj(subject, run, irfFileLengthFolder, regressorsFolder, scansFolder, maskPath, featuresFolder, irfDictionariesFolder, LearningOutputFolder, featuresRun, featuresSubject)
%CLASSIFYRUN Summary of this function goes here
%   Detailed explanation goes here

if nargin < 10
    featuresRun = run;
end
if nargin < 11
    featuresSubject = subject;
end

% create the irf dictionary using the deconvolved data
irfDictionaryFolder = [irfDictionariesFolder '/' irfFileLengthFolder];
disp(['reading irf dictionary from:' irfDictionaryFolder]);
irfFolder = [irfDictionaryFolder '/' featuresSubject '/' featuresRun];
irfDictionary = [];
irfDictionary(:,:,1) = ReadIRF([irfFolder '/dataset_M.irf+tlrc.BRIK']);
irfDictionary(:,:,2) = ReadIRF([irfFolder '/dataset_R.irf+tlrc.BRIK']);
irfDictionary(:,:,3) = ReadIRF([irfFolder '/dataset_B.irf+tlrc.BRIK']);
irfDictionary(:,:,4) = ReadIRF([irfFolder '/dataset_WL.irf+tlrc.BRIK']);

NumOfConditions = size(irfDictionary,3);
disp(['irfDictionary was read, numOfConditions ' num2str(NumOfConditions) ' , sizeofDictionary ' mat2str(size(irfDictionary))]);

%% mask the data

% note, the data is un masked, mvpa first masks the data so we need to do
% it also
disp(['loading mask from file : ' maskPath]);
% load the mask and reshape it
load(maskPath);
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
regressorFile = [regressorsFolder '/' subject '/regressors' run '.mat'];
disp(['reading regressors of run: ' run ' from file' regressorFile]);
load(regressorFile);
outputMatrix = outputMatrix(:,1:171);

summedRows = sum(outputMatrix,1); % remove TRs with two trials
outputMatrix(:,summedRows > 1) = zeros(size(outputMatrix(:,summedRows > 1) ));
regressors = zeros(1,size(outputMatrix,2));
for conditionNum = 1 : size(outputMatrix,1)
    regressors = regressors + (conditionNum .* outputMatrix(conditionNum,:));
end

%% read the masked scans

% load the scans
scansPath = [scansFolder '/' subject '/' run '/' 'scans.mat'];
disp(['loading scans from file:' scansPath]);
load(scansPath);
disp(['scans were loaded, the size of scans are ' mat2str(size(scans))]);

%% apply feature selection

features = zeros(size(mask));

% go over all the same diacritical type runs of all the other subject and
% gather all the features masks
% get all the subjects
subjects = GetDirectoriesInPath(scansFolder, '[0-9]{3,3}');

% go over each configuration
for subjectIdx = 1 : numel(subjects)      
    
    subjectName = char(subjects{subjectIdx});
    
    % ignore the current subject
    if (strcmp(subjectName, featuresSubject)) continue; end
    
    % get all the runs
    runsNames = GetDirectoriesInPath([scansFolder '/' subjectName], '[A-B][D]?[1-2]');
    
    for runIdx = 1 : numel(runsNames)
        
        runName = char(runsNames{runIdx});
        
        % ignoure other run types
        if (length(runName) ~= length(featuresRun)) continue; end
        
        % load the features mask 
        % load the mask and reshape it (for now 2500 features)
        if (~strcmp(featuresFolder, ''))
            featuresMaskPath = [featuresFolder '/' subjectName '/' runName '/' 'featuresMask.mat'];
            disp(['loading chosen features (voxels) from file' featuresMaskPath]);
            featuresMask = load(featuresMaskPath);
            fieldNames = fieldnames(featuresMask);
            featuresMask = getfield(featuresMask, fieldNames{1});
            featuresMask = logical(featuresMask);
            featuresMask = reshape(featuresMask,numel(featuresMask), 1);
            
            % use the statistics of this run fold to reduce the number of
            % neurons and take only the best ones
            % load the statistics for the features
            statisticsPath = [LearningOutputFolder '/' subjectName '/' runName '/statistics'];
            statistics = load(statisticsPath);

            [featuresMask(featuresMask == 1), ~, ~] = GetBestStats(statistics.corrects'./ statistics.trials , 1.8);
            
            features = features | featuresMask;
            disp(['features mask was loaded, number of features in the mask are ' num2str(count(features))]);
        end
    end
end

% mask the features
disp('masking the features with the master mask');
features = features(logical(mask));
disp(['featuresMask was masked , current size ' mat2str(size(features))]);

% apply the mask to the irf dictionary
disp('masking the irfDictionary with the features mask');
irfDictionary = irfDictionary(features,:,:);
disp(['irfDictionary was masked , current size ' mat2str(size(irfDictionary))]);

% mask the scans with only the selected features
disp(['masking the scans with only the ' num2str(count(features)) ' selected features']);
scans = scans(features,:);
disp(['scans was masked, current size ' mat2str(size(scans))]);



%% deTrend the runs
disp('De trending each voxel run values: removes a continuous , piecewise linear treand');
detrendScans = zeros(size(scans));

plotDeTrendedScans = false;
if (plotDeTrendedScans)
    figure
    t = 1:171;
end

parfor i = 1 : size(scans,1)
    detrendScans(i,:) = detrend(scans(i,:),'linear',171);
    
    %{
    if (plotDeTrendedScans)
        subplot(1,2,1);
        plot(t,scans(i,:));
        title(['scans of voxel ' num2str(i)]);

        subplot(1,2,2);
        plot(t,detrendScans(i,:));
        title(['detrend scans of voxel ' num2str(i)]);
        waitforbuttonpress
    end
    %}
end
scans = detrendScans;

disp('Scans where de trended');

end
