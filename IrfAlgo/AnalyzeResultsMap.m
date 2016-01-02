function [] = AnalyzeResultsMap( resultsMap )
clc

maskingConditions = {[1 2 3 4], [1 2 3], [1 2], 4};

for conditionsIdx = 1 : numel(maskingConditions)
    
    conditions = maskingConditions{conditionsIdx};
    
    ComputeBestPreviousWindowSize(resultsMap, conditions);

    ComputeBestAccurracyConfigurationForEachSubjectRun(resultsMap, conditions);
    
    ComputeMeanAccurracyConfiguration(resultsMap, conditions);
end

disp(' ');
disp('Analyze script ended successfully');
end

function [] = ComputeBestPreviousWindowSize(resultsMap, conditions)
    
    disp(' ');
    answer = input(['Press "y" to display the best previous window size while masking only conditions ' mat2str(conditions) ' -> '], 's');
    if (strcmp(answer,'y') == 0) 
        return;
    end
    
    % get all the keys of configurations
    configurations = resultsMap.keys();

    % each key as subjectNum.Run.LengthOfIrf , we need to group by
    % subjectNum.Run and find the highest configuration accurracy
    previousWindowLengthMap = containers.Map();
    for i = 1 : numel(configurations)
        
        key = char(configurations{i});
        keyArr = strsplit(key,'.');

        value = resultsMap(key);
        confusionMatrix = value('confusionMatrix');
        confusionMatrixAcc = computeConfusionMatrixAccurracy(confusionMatrix, conditions);

        previousWindowSizeMapKey = [keyArr{5}];
        if (~previousWindowLengthMap.isKey(previousWindowSizeMapKey))
            previousWindowLengthMap(previousWindowSizeMapKey) = confusionMatrixAcc;
        else
            previousWindowLengthMap(previousWindowSizeMapKey) = [previousWindowLengthMap(previousWindowSizeMapKey) confusionMatrixAcc];
        end

    end

    %print the results
    configurations = previousWindowLengthMap.keys();
    highestMean = 0;
    highestMeanWindowIdx = '';
    values = cell(numel(configurations),1);
    
    for i = 1 : numel(configurations)

        key = char(configurations{i});
        keyArr = strsplit(key,'.');
        previousWindowSize = str2double(keyArr);
        value = previousWindowLengthMap(key);
        values{previousWindowSize} = [values{previousWindowSize} value];
        
    end
    
    minSizeOfSamples = inf;
    for i = 1 : size(values, 1)
        if (size(values{i},2) < minSizeOfSamples)
            minSizeOfSamples = size(values{i},2);
        end
    end
    
    for i = 1 : numel(configurations)

        key = char(configurations{i});
        keyArr = strsplit(key,'.');
        previousWindowSize = str2double(keyArr);
        value = previousWindowLengthMap(key);
        disp(['The mean accurracy of previousWindow :  ' keyArr{1} ' is ' num2str(mean(value(1:minSizeOfSamples))) ' and STD : ' num2str(std(value(1:minSizeOfSamples)))]);

        if (mean(value) > highestMean)
            highestMean = mean(value(1:minSizeOfSamples));
            highestMeanWindowIdx = keyArr{1};
        end        
    end
    disp(['The highest accurracy is on previous window size : ' highestMeanWindowIdx ' with accurracy of ' num2str(highestMean)]);
    
    % display histograms   
    histograms = zeros(minSizeOfSamples, size(values,1));
    for i = 1 : numel(configurations)
      vals = values{i};
      histograms(:,i) = vals(1:minSizeOfSamples)';
    end
    figure;
    hist(histograms);
end

function [] = ComputeBestAccurracyConfigurationForEachSubjectRun(resultsMap, conditions)
    
    disp(' ');
    answer = input(['Press "y" to display the best configuration accurracy for each subject run while masking only conditions ' mat2str(conditions) ' -> '], 's');
    if (strcmp(answer,'y') == 0) 
        return;
    end

    % get all the keys of configurations
    configurations = resultsMap.keys();

    %% compare the confusion matrix accuracies of each subject in each run and plot the best
    % one

    % each key as subjectNum.Run.LengthOfIrf , we need to group by
    % subjectNum.Run and find the highest configuration accurracy
    subjectRunMap = containers.Map();
    for i = 1 : numel(configurations)

        key = char(configurations{i});
        keyArr = strsplit(key,'.');

        value = resultsMap(key);
        confusionMatrix = value('confusionMatrix');
        confusionMatrixAcc = computeConfusionMatrixAccurracy(confusionMatrix, conditions);

        subjectRunMapKey = [keyArr{1} '.' keyArr{2}];
        if (~subjectRunMap.isKey(subjectRunMapKey))
            subjectRunMap(subjectRunMapKey) = {strjoin(keyArr(3:end),'.'), confusionMatrixAcc};
        end

        biggestAccurracy = subjectRunMap(subjectRunMapKey);
        biggestAccurracy = biggestAccurracy{2};
        if (confusionMatrixAcc > biggestAccurracy)
            subjectRunMap(subjectRunMapKey) = {strjoin(keyArr(3:end),'.'), confusionMatrixAcc};
        end

    end

    %print the results
    configurations = subjectRunMap.keys();
    values = size(numel(configurations),1);
    for i = 1 : numel(configurations)

        key = char(configurations{i});
        keyArr = strsplit(key,'.');
        value = subjectRunMap(key);
        disp(['The best accurracy of subject ' keyArr{1} ' in run ' keyArr{2} ' for conditions ' mat2str(conditions) ' was configuration ' value{1} ' with accurracy of ' num2str(value{2})]);
        values(i) = value{2};
    end
    disp (['mean accurracy for conditions ' mat2str(conditions) ' is ' num2str(mean(values)) ' with std ' num2str(std(values))]);
end

function [] = ComputeMeanAccurracyConfiguration(resultsMap, conditions)
    
    disp(' ');
    answer = input(['Press "y" to display the mean accurracy and std for each irf length over all configuration while masking only conditions ' mat2str(conditions) ' -> '], 's');
    if (strcmp(answer,'y') == 0) 
        return;
    end

    % get all the keys of configurations
    configurations = resultsMap.keys();

    % each key as subjectNum.Run.LengthOfIrf , we need to group by
    % subjectNum.Run and find the highest configuration accurracy
    irfLengthMap = containers.Map();
    for i = 1 : numel(configurations)

        key = char(configurations{i});
        keyArr = strsplit(key,'.');

        value = resultsMap(key);
        confusionMatrix = value('confusionMatrix');
        confusionMatrixAcc = computeConfusionMatrixAccurracy(confusionMatrix, conditions);

        irfMapKey = [keyArr{4}];
        if (~irfLengthMap.isKey(irfMapKey))
            irfLengthMap(irfMapKey) = confusionMatrixAcc;
        else
            irfLengthMap(irfMapKey) = [irfLengthMap(irfMapKey) confusionMatrixAcc];
        end

    end

    %print the results
    configurations = irfLengthMap.keys();
    for i = 1 : numel(configurations)

        key = char(configurations{i});
        keyArr = strsplit(key,'.');
        value = irfLengthMap(key);
        disp(['The mean accurracy of irfLength :  ' keyArr{1} ' is ' num2str(mean(value)) ' and STD : ' num2str(std(value))]);

    end
end

