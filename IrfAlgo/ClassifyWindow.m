function [ classificationVec ] = ClassifyWindow( testWindow, timeCourse, irfDictionary, testedConditions, previousWindowTRs, startTrIdx, endTrIdx)
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
% previousWindowTRs - a vector of size of windowLength that holds the relative TRs in which a
%              specific condition was shown. The vector will have the
%              number of the condition or zero of no condition was shown in
%              the specified TR. This window represents the past events
%              that can effect the current window
%  previousWindow - The measured data of the previous window so we can
%               build or new measured data on it
% output:
% classificationVec - a time course vector with the classification of each
%                     condition

progressInterval = 2501;
lengthOfIrf = size(irfDictionary, 2);
numOfConditions = size(irfDictionary, 3);
classificationVec = zeros(size(timeCourse));

% get the indexes of all the trials in this window
trialsInWindowIdxs = find(timeCourse) + size(previousWindowTRs,2);

% create the combinatios matrix of the trials in this window
combinations = CreateCombinations(1:numOfConditions,length(trialsInWindowIdxs), testedConditions);
numOfCombinations = size(combinations,1);

% get the measured response matrix and normalize it so the avg will be zero
measuredResponse = testWindow - repmat(mean(testWindow,2), 1,size(testWindow,2));
removedNeurons = find(std(measuredResponse') < 10);
measuredResponse(removedNeurons,:) = [];
measuredResponseNorms = arrayfun(@(idx) norm(measuredResponse(idx,:)), 1:size(measuredResponse,1));

numOfVoxels = size(measuredResponse, 1);
%% classification

disp('starting classification procedure for a new window');
tic
fprintf('numberOfVoxels = %d, originalLengthOfIrfs = %d , testedconditiosn = %s, numberOfConditions = %d, PlotInterval = %d\ntrialsInCurrentWindow = %d numberOfPermutations = %d StartTr = %d , EndTr = %d\n', ...
    numOfVoxels,lengthOfIrf,mat2str(testedConditions),numOfConditions,progressInterval,size(trialsInWindowIdxs,2),numOfCombinations, startTrIdx, endTrIdx);

% try to choose the best classification for this window base on the
% similarity measument

%% new
      
% create the irfs for each combination
SumGradesMat = zeros(numOfCombinations,numOfVoxels);
for combinationIdx = 1 : numOfCombinations
       
    % create a dictionary of the response for each combination
    % the current combination will determine which irf we need to create
    currentCombination = combinations(combinationIdx,:);
 
    irfCombination = CreateResponseForCombination(currentCombination, previousWindowTRs, trialsInWindowIdxs, irfDictionary);
    irfCombination(removedNeurons,:) = [];
    irfCombinationNorms = arrayfun(@(idx) norm(irfCombination(idx,:)), 1:size(irfCombination,1));
    irfCombination = irfCombination .* repmat((measuredResponseNorms ./ irfCombinationNorms)', [1,lengthOfIrf]);
    transposedIrfCombination = irfCombination';
    
    % create a similarity grade of the current permutation to the measured
    % data
    SumGradesMat(combinationIdx,:) = diag(measuredResponse(:,startTrIdx:endTrIdx) * transposedIrfCombination(startTrIdx:endTrIdx,:)); % the indexes are here so we will be able easily start from the second tr if we want it
end

%{
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
%}

% take the condition which maximied the grade
%first normalize the results mat to be between [-1:1]
maxAbsolute = max(abs(SumGradesMat(:)));
SumGradesMat = SumGradesMat./maxAbsolute;

% take the winne using summing - add all the probabilities and get the max
finalGrades = sum(SumGradesMat,2);
[~, winnerCombination] = max(finalGrades);

%Max(mean(Sum over all class combinations))
%m(1) = mean(finalGrades(1:(length(finalGrades) ./ length(testedConditions))));
%m(2) = mean(finalGrades(((length(finalGrades)./ length(testedConditions)) + 1):end));
%[~, winnerClass]= max(m);
%winnerCombination = ((winnerClass -1 ) * (size(SumGradesMat,1) ./ length(testedConditions))) + 1;

% take the winner combination using voting
[~,winnerIndces]=max(SumGradesMat);
h = hist(winnerIndces,length(testedConditions));
[~, winnerClass] = max(h);
winnerCombination = ((winnerClass -1 ) * (size(SumGradesMat,1) ./ length(testedConditions))) + 1;

classificationVec(logical(timeCourse)) = combinations(winnerCombination,:);

%% plotting the winner combination and the measured data
   
% create a dictionary of the response for each combination
% the current combination will determine which irf we need to create
currentCombination = combinations(winnerCombination,:);

irfCombination = CreateResponseForCombination(currentCombination,previousWindowTRs, trialsInWindowIdxs, irfDictionary);

for i = 2501 :50 :2500
    plot([irfCombination(i,:) ; measuredResponse(i,:)]');
    title(['voxel number ' num2str(i)]);
    waitforbuttonpress 
end

disp('finished classifying window');
toc
end % end of function 

