function [ classificationVec , confusionMartix ] = ClassifyData( testRun, timeCourse, irfDictionary, testedConditions, previousWindowSize, startTr, endTr, classificationMode, extraParams)
%ClassifyData Summary will return the classification of the test run
%matrix, 
% input:
% test run - numberOfVoxels X TR matrix that is the measured data that need
%            to be classified
% timeCourse - a vector of size of TR that holds the TRs in which a
%              specific condition was shown. The vector will have the
%              number of the condition or zero of no condition was shown in
%              the specified TR
% irfDictionary - numberOfVoxels X neuralResponseLength X conditions matrix
%                 which will hold the asstimated neural response of each
%                 voxel for each type of condition
% output:
% classificationVec - a time course vector with the classification of each
%                     condition

progressInterval = 2501;
numOfVoxels = size(irfDictionary, 1);
lengthOfIrf = size(irfDictionary, 2);
numOfConditions = size(irfDictionary, 3);
classificationVec = zeros(size(timeCourse));
confusionMartix = zeros(numOfConditions);

% pad the measured data with zeros of size of the irf
testRun = [testRun zeros(numOfVoxels, lengthOfIrf)];
timeCourse = [timeCourse zeros(1, lengthOfIrf)];

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
    [classificationWindowVec] = ClassifyWindow(measuredResponseWindow, timeCourseWindow, irfDictionary, testedConditions, previousWindowTRs, startTr, endTr, classificationMode, extraParams);

    % choose the classification of the current trial to be the
    % classification of the first TR in the extracted window
    classificationVec(trialStartTrIdx) = classificationWindowVec(1);
    
    % maintain the confusion matrix
    confusionMartix(targetCondition, classificationVec(trialStartTrIdx)) = confusionMartix(targetCondition, classificationVec(trialStartTrIdx)) + 1
    disp([' -- chosen condition ' num2str(classificationVec(trialStartTrIdx)) ' while the true condition is ' num2str(targetCondition)]);
    
end

% display the accurracy of the classification procedure
classificationVec = [classificationVec zeros(1,lengthOfIrf)];
toc
disp(['classification procedure was finished, accurracy = ' num2str(computeConfusionMatrixAccurracy(confusionMartix))]);

end % end of function 

