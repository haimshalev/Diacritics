function [classificationVec, Grades, neuronsMask, votingOfEachVoxel] = ClassifyWindow( testWindow, timeCourse, irfDictionary, testedConditions, previousWindowTRs, startTrIdx, endTrIdx, classificationMode, extraParams)
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
%  startTrIdx - the start index of the trimmed window
%  endTrIdx - the end index of the trimmed window
%  classificationMode - one of the options : 'Summing', 'Voting',
%                       'Classifier'
% extraParams - used to pass extra parmas that used for classification
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

%% Reduce neurons by training statistics

if (strcmp(classificationMode,'Voting'))
    if (exist('extraParams','var') && isfield(extraParams,'stats'))
            disp('Doing statistical voting');
            stats = extraParams.stats;
        else
            stats = ones(1, size(irfDictionary, 1));
        end
                
        % add the statistics
        % first condition
        higherstats = stats - (0.5 + std(stats(stats~=0)));
        higherstats(higherstats <= 0) = 0;

        lowerstats = (0.5 - std(stats(stats~=0))) - stats;
        lowerstats(lowerstats <= 0) = 0;
        lowerstats(stats == 0) = 0;
end

% get the measured response matrix and normalize it so the avg will be zero
measuredResponse = testWindow - repmat(mean(testWindow,2), 1,size(testWindow,2));
removedNeurons = intersect(find(higherstats == 0), find(lowerstats == 0));
removedNeurons = union(removedNeurons,find(std(measuredResponse') < 10));
neuronsMask = ones(1,size(testWindow,1));
neuronsMask(removedNeurons) = zeros(size(removedNeurons));
neuronsMask = logical(neuronsMask);
measuredResponse(removedNeurons,:) = [];
numOfVoxels = size(measuredResponse, 1);

if (numOfVoxels == 0)
    disp('There are no voxels to classify in the window, ignoring window and returning -1 classification');
    classificationVec = -1;
    return;
end

measuredResponseNorms = arrayfun(@(idx) norm(measuredResponse(idx,:)), 1:size(measuredResponse,1));



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
parfor combinationIdx = 1 : numOfCombinations
       
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

% take the condition which maximied the grade
%first normalize the results mat to be between [-1:1]
maxAbsolute = max(abs(SumGradesMat(:)));
SumGradesMat = SumGradesMat./maxAbsolute;

Grades = zeros(size(SumGradesMat,1), size(irfDictionary, 1));
mask = logical(repmat(neuronsMask, size(SumGradesMat,1), 1));
Grades(mask) = SumGradesMat;

switch classificationMode
    case 'Summing'

        % take the winne using summing - add all the probabilities and get the max
        finalGrades = sum(SumGradesMat,2);
        [~, winnerCombination] = max(finalGrades);

        %Max(mean(Sum over all class combinations))
        %m(1) = mean(finalGrades(1:(length(finalGrades) ./ length(testedConditions))));
        %m(2) = mean(finalGrades(((length(finalGrades)./ length(testedConditions)) + 1):end));
        %[~, winnerClass]= max(m);
        %winnerCombination = ((winnerClass -1 ) * (size(SumGradesMat,1) ./ length(testedConditions))) + 1;
        
    case 'Voting'
        
        if (exist('extraParams','var') && isfield(extraParams,'stats'))
            disp('Doing statistical voting');
            stats = extraParams.stats;
        else
            stats = ones(1, size(irfDictionary, 1));
        end
        
        [~ ,winnerIndces]=max(SumGradesMat);
        [h, x] = hist(winnerIndces,length(testedConditions));
        votingOfEachVoxel = zeros(1, size(irfDictionary, 1));
        [~, votingOfEachVoxel(neuronsMask)] = min(abs(repmat(winnerIndces, length(testedConditions),1) - repmat(x',1,size(winnerIndces,2))));
        votes = zeros(1, length(testedConditions));
        
        % add the statistics
        % first condition       
        votes(1) = sum((votingOfEachVoxel == 1) .* higherstats);
        votes(2) = sum((votingOfEachVoxel == 1) .* lowerstats);
        
        % second condition
        votes(2) = votes(2) + sum((votingOfEachVoxel == 2) .* higherstats);
        votes(1) = votes(1) + sum((votingOfEachVoxel == 2) .* lowerstats);
        
        % vote for the winner
        [~, winnerClass] = max(votes);
        winnerCombination = ((winnerClass -1 ) * (size(SumGradesMat,1) ./ length(testedConditions))) + 1;
    case 'Classifier'
        
        if (~exist('extraParams') || ~isfield(extraParams,'classifiers') || ~isfield(extraParams, 'classifierNeuronsMask'))
            error('Missing extraParams to use classification with neural network classifier : extraParams should be a struct with this fields : {classifiers , classifierNeuronsMask}');
        end
        
        classifiers = extraParams.classifiers;
        classifierNeuronsMask = extraParams.classifierNeuronsMask;
        
        numberOfCombinationsForEachCondition = size(SumGradesMat,1) ./ length(testedConditions);
        dataToClassify = Grades';
        dataToClassify(~classifierNeuronsMask,:) = [];

        %split the data and use different classifiers
        y = zeros(size(testedConditions));
        for conditionIdx = 1 : numel(testedConditions)
            
            classifierAnswers = classifiers{conditionIdx}(dataToClassify);

            classifierMask = ones(size(classifierAnswers)) * -1;
            classifierMask(:,(numberOfCombinationsForEachCondition) * (conditionIdx - 1) + 1 : (numberOfCombinationsForEachCondition) * (conditionIdx - 1) + numberOfCombinationsForEachCondition) = 1;

            classifierAnswers = classifierAnswers .* classifierMask;

            % normalize the results - if the data is not from the class of the
            % classifier the results can be not between -1 and 1
            % normalize them to be zero mean with std of 1
            disp(['mean of classifier Ans for classifier ' num2str(conditionIdx) 'is ' num2str(mean(classifierAnswers)) ' and std ' num2str(std(classifierAnswers))]);
            y(conditionIdx) = (mean(abs(classifierAnswers -1))) ;%+ (std(abs(classifierAnswers - 1)));
        end


        [~, winnerClass] = min(y);
        winnerCombination = ((winnerClass -1 ) * (size(SumGradesMat,1) ./ length(testedConditions))) + 1;
        
        
    otherwise
        error('unkown classifying method');
end
 
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

