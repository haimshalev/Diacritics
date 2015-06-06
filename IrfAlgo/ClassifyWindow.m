function [ classificationVec ] = ClassifyWindow( testWindow, timeCourse, irfDictionary)
%CLASSIFYTESTDATA Summary will return the best permutation classification
%for the whole window
%matrix, 
% input:
% testWindow - numberOfVoxels X windowLength matrix that is the measured data that need
%            to be classified
% timeCourse - a vector of size of windowLength that holds the relative TRs in which a
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

% get the indexes of all the trials in this window
trialsInWindowIdxs = find(timeCourse);

% create the combinatios matrix of the trials in this window
combinations = CreateCombinations(1:numOfConditions,length(trialsInWindowIdxs));
numOfCombinations = size(combinations,1);

% get the measured response matrix
measuredResponse = testWindow;

% pad the measured data with zeros of size of the irf
testWindow = [testWindow zeros(numOfVoxels, lengthOfIrf)];
timeCourse = [timeCourse zeros(1, lengthOfIrf)];

%% classification

disp('starting classification procedure for a new window');
fprintf('numberOfVoxels = %d, originalLengthOfIrfs = %d , trimmedIrfsLength = %d, numberOfConditions = %d, PlotInterval = %d\ntrialsInCurrentWindow = %d numberOfPermutations = %d', ...
    numOfVoxels,lengthOfIrfOrig,lengthOfIrf,numOfConditions,progressInterval,size(trialsInWindowIdxs,1),numOfCombinations);

% try to choose the best classification for this window base on the
% similarity measument

%% new
      
% create the irfs for each combination
irfCombinations = zeros(size(testWindow,1), size(testWindow,2), numOfCombinations); % create the padded initialized mat

% create a dictionary of the response for each combination
for combinationIdx = 1 : numOfCombinations
    
    % the current combination will determine which irf we need to create
    currentCombination = combinations(combinationIdx,:);

    for trialIdx = 1 : length(trialsInWindowIdxs) % add each response of each condition in the current combination to the irf
        currentCondition = currentCombination(trialIdx);
        trialIndexInWindow = trialsInWindowIdxs(trialIdx);
        irfCombinations(:,trialIndexInWindow : trialIndexInWindow + lengthOfIrf - 1,combinationIdx) = irfCombinations(:,trialIndexInWindow : trialIndexInWindow + lengthOfIrf - 1, combinationIdx) + irfDictionary(:,:,currentCondition);
    end
end

VecsMat = zeros(numOfCombinations + 1, lengthOfIrf);
CurrentGradesMat = zeros(numOfCombinations,1);
SumGradesMat = ones(numOfCombinations,1);

for voxelIdx = 1: numOfVoxels
    % get the measurment
    measuredVec = measuredResponse(voxelIdx,:);

    % use cross correlation to check which condition best fit to the
    % measured response

    % go over each combination and check what is the combination that is
    % most similar to the measured condition
    for combinationIdx = 1 : numOfCombinations
        % get the response for the specific voxel
        irfVec = irfCombinations(voxelIdx,1:lengthOfIrf,combinationIdx);
        %bias the irf to be in the starting place of the
        %measuredVec
        irfVec = irfVec + (measuredVec(1) - irfVec(1));
        VecsMat(combinationIdx,:) = irfVec;
        CurrentGradesMat(combinationIdx) = (max(xcorr(measuredVec(2:end), irfVec(2:end), 'coeff')));
        SumGradesMat(combinationIdx) = CurrentGradesMat(combinationIdx) .* SumGradesMat(combinationIdx);
    end 

    %plotting commands
    % add the measured data to the plot mat
    if (mod(voxelIdx, progressInterval) == 0)
        VecsMat(combinationIdx + 1,:) = measuredVec;
        plot(VecsMat');
        hold on 
        % plot the highlights (another conditions starts)
        plot(trialsInWindowIdxs,measuredVec(trialsInWindowIdxs),'o','MarkerSize',10);
        hold off
        [~,currentWinnerCondition] = max(SumGradesMat);
        anotherConditionsStr = sprintf('%d', timeCourse(trialsInWindowIdxs));
        winnerCombination = sprintf('%d', combinations(currentWinnerCondition,:));
        title(sprintf('voxel %d response for all combinations and for condition %d\nwinnerIs=%s\n otherHighlightedConds = %s', ...
            voxelIdx, timeCourse(1),winnerCombination, anotherConditionsStr));
        waitforbuttonpress
    end
    
    % plot voxel progress
    if (voxelIdx > 1)
        for j = 0 : log10(voxelIdx - 1)
            fprintf('\b');
        end
    end
    if (voxelIdx == 1)
        fprintf('\n');
    end
    fprintf('%d',voxelIdx);
end

% take the condition which maximied the grade
[~, winnerCombination] = max(SumGradesMat);
classificationVec(logical(timeCourse)) = combinations(winnerCombination,:);

end % end of function 

