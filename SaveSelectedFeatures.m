function [] = SaveSelectedFeatures(subj, diacriticalSigns, outputFolder, subjectName, runName)

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
        mkdir([outputFolder '/FeaturesMasks/' sibjectName '/' runName]);
        save( [outputFolder '/FeaturesMasks/' subjectName '/' runName '/featuresMask' ] , 'featuresMask');
    end

end