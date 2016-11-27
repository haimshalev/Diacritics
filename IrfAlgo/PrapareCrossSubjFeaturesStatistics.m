function [corrects, trials]  = PrapareCrossSubjFeaturesStatistics(subject, run, featuresFolder, LearningOutputFolder)

    % go over all the same diacritical type runs of all the other subject and
    % gather all the features masks
    % get all the subjects
    subjects = GetDirectoriesInPath(LearningOutputFolder, '[0-9]{3,3}');

    % go over each configuration
    for subjectIdx = 1 : numel(subjects)      

        subjectName = char(subjects{subjectIdx});

        % ignore the current subject
        if (strcmp(subjectName, subject)) continue; end

        % get all the runs
        runsNames = GetDirectoriesInPath([LearningOutputFolder '/' subjectName], '[A-B][D]?[1-2]');

        for runIdx = 1 : numel(runsNames)

            runName = char(runsNames{runIdx});

            % ignoure other run types
            if (length(runName) ~= length(run)) continue; end

            % load the features mask 
            featuresMaskPath = [featuresFolder '/' subjectName '/' runName '/' 'featuresMask.mat'];
            disp(['loading chosen features (voxels) from file' featuresMaskPath]);
            featuresMask = load(featuresMaskPath);
            fieldNames = fieldnames(featuresMask);
            featuresMask = getfield(featuresMask, fieldNames{1});
            featuresMask = logical(featuresMask);
            featuresMask = reshape(featuresMask,numel(featuresMask), 1);
            disp(['features mask was loaded, number of features in the mask are ' num2str(count(featuresMask))]);

            % load the statistics for the features
            statisticsPath = [LearningOutputFolder '/' subjectName '/' runName '/statistics'];
            statistics = load(statisticsPath);

            if (~exist('corrects') | ~exist('trials'))
                corrects = zeros(size(featuresMask));
                trials = zeros(size(featuresMask));
            end

            corrects(featuresMask) = corrects(featuresMask) + statistics.corrects';
            trials(featuresMask) = trials(featuresMask) + statistics.trials;
        end
    end

    featuresMask = (trials ~= 0);
    corrects = corrects(featuresMask);
    trials = trials(featuresMask);

end