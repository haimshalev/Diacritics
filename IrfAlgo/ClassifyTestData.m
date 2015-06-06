function [ classificationVec , confusionMartix ] = ClassifyTestData( testRun, timeCourse, irfDictionary)
%CLASSIFYTESTDATA Summary will return the classification of the test run
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
lengthOfIrfOrig = size(irfDictionary, 2);
lengthOfIrf = lengthOfIrfOrig;
numOfConditions = size(irfDictionary, 3);
classificationVec = zeros(size(timeCourse));
confusionMartix = zeros(numOfConditions);

% pad the measured data with zeros of size of the irf
testRun = [testRun zeros(numOfVoxels, lengthOfIrf)];
timeCourse = [timeCourse zeros(1, lengthOfIrf)];

%% classification

disp('starting classification procedure');
fprintf('numberOfVoxels = %d, originalLengthOfIrfs = %d , trimmedIrfsLength = %d, numberOfConditions = %d, PlotInterval = %d\n', ...
    numOfVoxels, lengthOfIrfOrig, lengthOfIrf, numOfConditions, progressInterval);

% try to choose the best classification for ech trial base on the
% similarity measument

% go over each measured trial type
for targetCondition = 1: numOfConditions
    %go over each trial of the current targetCondition
    for trialStartTrIdx = find(timeCourse == targetCondition)
        disp(['classifying the window of trial ' num2str(trialStartTrIdx) ' of condition ' num2str(targetCondition)]);
      
        % extract the current window and classify it
        measuredResponseWindow = testRun(:, trialStartTrIdx : trialStartTrIdx + lengthOfIrf - 1);
        timeCourseWindow = timeCourse(trialStartTrIdx : trialStartTrIdx + lengthOfIrf - 1);
        [classificationWindowVec] = ClassifyWindow(measuredResponseWindow, timeCourseWindow, irfDictionary);
        
        % choose the classification of the current trial to be the
        % classification of the first TR in the extracted window
        classificationVec(trialStartTrIdx) = classificationWindowVec(1);
        
        % maintain the confusion matrix
        confusionMartix(targetCondition, classificationVec(trialStartTrIdx)) = confusionMartix(targetCondition, classificationVec(trialStartTrIdx)) + 1
        disp([' -- chosen condition ' num2str(classificationVec(trialStartTrIdx)) ' while the true condition is ' num2str(targetCondition)]);
    end
end % end of main for

% display the accurracy of the classification procedure
classificationVec = [classificationVec zeros(1,lengthOfIrf)];
accurracy = ((count(classificationVec == timeCourse) - count(classificationVec == 0)) * 100 ) / count(timeCourse);
disp(['classification procedure was finished, accurracy = ' num2str(accurracy)]);

end % end of function 

