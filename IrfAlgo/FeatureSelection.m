function [ featuresVec ] = FeatureSelection( testRun, timeCourse, irfDictionary, testedConditions)
%FEATURESELECTION Summary of this function goes here
%   Detailed explanation goes here
progressInterval = 2501;
numOfVoxels = size(irfDictionary, 1);
lengthOfIrf = size(irfDictionary, 2);
numOfConditions = size(irfDictionary, 3);

% pad the measured data with zeros of size of the irf
testRun = [testRun zeros(numOfVoxels, lengthOfIrf)];
timeCourse = [timeCourse zeros(1, lengthOfIrf)];

%% classification

disp('starting feature selection procedure');
tic
fprintf('numberOfVoxels = %d, originalLengthOfIrfs = %d , classified condtions = %s, numberOfConditions = %d, PlotInterval = %d\n', ...
    numOfVoxels, lengthOfIrf, mat2str(testedConditions), numOfConditions, progressInterval);

% try to choose the best classification for ech trial base on the
% similarity measument

% go over each measured trial type
featuresVec = zeros(numOfVoxels, size(testedConditions,2));
for trialStartTrIdx = find(timeCourse)
    targetCondition = timeCourse(trialStartTrIdx);
    targetConditionIdx = find(testedConditions == targetCondition, 1);
    if (isempty(targetConditionIdx))
        disp(['skipping the feature training procefure of trial ' num2str(trialStartTrIdx) ' of condition ' num2str(targetCondition) ', the condition should not be used for training']);
        continue;
    end
        
    if (trialStartTrIdx <= lengthOfIrf)
        disp(['skipping the feature training procedure of trial ' num2str(trialStartTrIdx) ' of condition ' num2str(targetCondition) ', its the first window']);
        continue;
    end
    
    disp(['starting feature training on the window of trial ' num2str(trialStartTrIdx) ' of condition ' num2str(targetCondition)]);
     
    %remvoe not active voxels
    voxelsMask = ones(numOfVoxels,1);
    parfor voxel = 1 :numOfVoxels
        % get the measured response matrix and normalize it so the avg will be zero
        if (find(std(testRun(voxel,:)') < 10) == 1)
            voxelsMask(voxel) = 0;
        end
    end
    
    %vote for each voxel which classifies correctly the current training
    %point
    
    currentTestRun = testRun(:, trialStartTrIdx : trialStartTrIdx + lengthOfIrf - 1);
    currentTimeCourse = timeCourse(trialStartTrIdx : trialStartTrIdx + lengthOfIrf - 1);
    for voxel = 1 : numOfVoxels
        
        if (voxelsMask(voxel) == 1)
            % extract the current window and classify it
            measuredResponseWindow = currentTestRun(voxel,:);
            timeCourseWindow = currentTimeCourse;
            disp(['Testing feature (voxel) ' num2str(voxel) '/' num2str(numOfVoxels) ' for trial ' num2str(trialStartTrIdx) ' for condition ' num2str(targetCondition)]);
            [classificationWindowVec] = ClassifyWindow(measuredResponseWindow, timeCourseWindow, irfDictionary(voxel,:,:), testedConditions, 1, 1, lengthOfIrf);

            % if classified correctly, vote for the voxel
            if (classificationWindowVec(1) == targetCondition)
                disp(['Voting!!! for feature (voxel) ' num2str(voxel) '/' num2str(numOfVoxels)  ' for trial ' num2str(trialStartTrIdx) ' for condition ' num2str(targetCondition)]);
                featuresVec(voxel,targetConditionIdx) = featuresVec(voxel,targetConditionIdx) + 1;
            end
        end
    end    
end
toc
disp('feature selection procedure was finished');

end % end of function 

