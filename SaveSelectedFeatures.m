function [] = SaveSelectedFeatures(subj, diacriticalSigns, outputFolder, subjectName, testMethod)

    if (strcmp(testMethod, 'EntireRuns'))
        SaveSelectedFeaturesEntireRuns(subj, diacriticalSigns, outputFolder, subjectName);
    else
        if (strcmp(testMethod, 'OneRun'))
            SaveSelectedFeaturesOneRun(subj, diacriticalSigns, outputFolder, subjectName);
        end
    end
end

function [] = SaveSelectedFeaturesEntireRuns(subj, diacriticalSigns, outputFolder, subjectName)
    % save the chosen features for the current subject and
    % diacritical/non diacritical signs
    intersectedFeatures = find(subj.masks{1,2}.mat);
    for featureIdx = 3 : size(subj.masks, 2)
        intersectedFeatures= intersect(intersectedFeatures, find(subj.masks{1,featureIdx}.mat));
    end
    
    if (diacriticalSigns == 1)
        runs = {'AD1','AD2','BD1','BD2'};
    else
        runs = {'A1','A2','B1','B2'};
    end

    % each feature mask will be the features mask learned for all the
    % training runs (all runs except the tested one)
    for runIdx = 1 : numel(runs)
        featuresMask= subj.masks{1,runIdx + 1}.mat;
        mkdir([outputFolder '/FeaturesMasks/' subjectName '/' runs{runIdx}]);
        save( [outputFolder '/FeaturesMasks/' subjectName '/' runs{runIdx} '/featuresMask' ] , 'featuresMask');
    end

end

function [] = SaveSelectedFeaturesOneRun(subj, diacriticalSigns, outputFolder, subjectName)
    % save the chosen features for the current subject and
    % diacritical/non diacritical signs
    intersectedFeatures = find(subj.masks{1,2}.mat);
    for featureIdx = 3 : size(subj.masks, 2)
        intersectedFeatures= intersect(intersectedFeatures, find(subj.masks{1,featureIdx}.mat));
    end

    featuresMask = zeros(size(subj.masks{1,1}.mat));
    featuresMask(intersectedFeatures) = 1;
    if (diacriticalSigns == 1)
        runs = {'AD1','AD2','BD1','BD2'};
    else
        runs = {'A1','A2','B1','B2'};
    end

    for runIdx = 1 : numel(runs)
        mkdir([outputFolder '/FeaturesMasks/' sibjectName '/' runs{runIdx}]);
        save( [outputFolder '/FeaturesMasks/' subjectName '/' runs{runIdx} '/featuresMask' ] , 'featuresMask');
    end

end