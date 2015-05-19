function [ classificationVec ] = ClassifyTestData( testRun, timeCourse, irfDictionary)
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

numOfVoxels = size(irfDictionary, 1);
lengthOfIrf = size(irfDictionary, 2);
numOfConditions = size(irfDictionary, 3);

classificationVec = zeros(size(timeCourse));

%% classification

% try to choose the best classification for ech trial base on the
% similarity measument

% go over each measured trial type
for targetCondition = 1: numOfConditions
    %go over each trial of the current targetCondition
    for trialStartTrIdx = find(timeCourse == targetCondition)
        % get the measured response matrix
        measuredResponse = testRun(:, trialStartTrIdx : trialStartTrIdx + lengthOfIrf - 1);
        
        % use cross correlation to check which condition best fit to the
        % measured response
        bestCrossCorreleationGrade = -1;
        % go over each condition and check what is the condition that is
        % most similar to the measured condition
        for condition = 1 : numOfConditions
            % get the response matrix for the current condition
            approximatedResponseMatrix = irfDictionary(:,:,condition);
            % sum the log probability of the cross correlation prob for all the voxels 
            conditionGrade = 0;
            for voxelIdx = 1: numOfVoxels
                % get the measurment using cross correlation
                conditionGrade = conditionGrade + log(max(xcorr(measuredResponse,approximatedResponseMatrix,'coeff')));
                
            end
            % if the condition grade is the current max, set the current
            % classification
            if (conditionGrade > bestCrossCorreleationGrade)
                classificationVec(trialStartTrIdx) = condition;
                bestCrossCorreleationGrade = conditionGrade;
            end
        end
    end
end % end of main for
 
end % end of function 

