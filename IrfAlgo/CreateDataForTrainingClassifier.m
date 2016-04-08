function [runDataPoints, runTargets , neuronsMask] = CreateDataForTrainingClassifier( testRun, timeCourse, irfDictionary, testedConditions, previousWindowSize, startTr, endTr, classificationMode)
%TRAINCLASSIFIER Summary of this function goes here
%   Detailed explanation goes here

progressInterval = 2501;
numOfVoxels = size(irfDictionary, 1);
lengthOfIrf = size(irfDictionary, 2);
numOfConditions = size(irfDictionary, 3);
classificationVec = zeros(size(timeCourse));
confusionMartix = zeros(numOfConditions);

% pad the measured data with zeros of size of the irf
testRun = [testRun zeros(numOfVoxels, lengthOfIrf)];
timeCourse = [timeCourse zeros(1, lengthOfIrf)];

% initialize the output vars
runDataPoints = cell(size(testedConditions));
runTargets = cell(size(testedConditions));
neuronsMask = ones(1, size(irfDictionary,1));

%% classification

disp('starting classification procedure');
tic
fprintf('numberOfVoxels = %d, originalLengthOfIrfs = %d , classified condtions = %s, numberOfConditions = %d, PlotInterval = %d\n , PreviousWindowSize = %d, StartTr = %d, EndTr = %d\n', ...
    numOfVoxels, lengthOfIrf, mat2str(testedConditions), numOfConditions, progressInterval, previousWindowSize, startTr, endTr);

% try to choose the best classification for ech trial base on the
% similarity measument

% go over each measured trial type
for trialStartTrIdx = find(timeCourse)
    targetCondition = timeCourse(trialStartTrIdx);
    
    if (isempty(find(testedConditions == targetCondition)))
        disp(['skipping the classification procefure of trial ' num2str(trialStartTrIdx) ' of conditions ' num2str(targetCondition) ', the condition should not be classified']);
        continue;
    end
    
    if (trialStartTrIdx <= lengthOfIrf)
        disp(['skipping the classification procedure of trial ' num2str(trialStartTrIdx) ' of condition ' num2str(targetCondition) ', its the first window']);
        continue;
    end
    
    disp(['classifying the window of trial ' num2str(trialStartTrIdx) ' of condition ' num2str(targetCondition)]);
      
    % extract the current window and classify it
    measuredResponseWindow = testRun(:, trialStartTrIdx : trialStartTrIdx + lengthOfIrf - 1);
    timeCourseWindow = timeCourse(trialStartTrIdx : trialStartTrIdx + lengthOfIrf - 1);
    previousWindowTRs = timeCourse(trialStartTrIdx - previousWindowSize : trialStartTrIdx - 1);
    [~, gradesMat, maskedNeurons] = ClassifyWindow(measuredResponseWindow, timeCourseWindow, irfDictionary, testedConditions, previousWindowTRs, startTr, endTr, classificationMode);

    % lets set the data points for the target condition data set
    runDataPoints{targetCondition} = [runDataPoints{targetCondition} ; gradesMat];
    targetsMat = ones(size(gradesMat,1),1) * -1;
    conditionIdx = find(targetCondition == testedConditions);
    startIdxOfCorrectConditions = ((conditionIdx -1 ) * (size(gradesMat,1) ./ length(testedConditions))) + 1;
    endIdxOfCorrectConditions = ((conditionIdx) * (size(gradesMat,1) ./ length(testedConditions)));
    targetsMat(startIdxOfCorrectConditions: endIdxOfCorrectConditions) = 1;
    runTargets{targetCondition} = [runTargets{targetCondition} ; targetsMat];
    neuronsMask = neuronsMask & maskedNeurons;
end

% display the accurracy of the classification procedure
toc
disp(['classification procedure was finished, accurracy = ' num2str(computeConfusionMatrixAccurracy(confusionMartix))]);


end

