function [] = SaveSelectedFeatures(subj, diacriticalSigns, subjectName, outputFolder, maskName)
  
    masksNames = find_group(subj,'mask', maskName);
    
    if (diacriticalSigns == true)
        runs = {'AD1','AD2','BD1','BD2'};
        diacriticalChar = '_d';
    else
        runs = {'A1','A2','B1','B2'};
        diacriticalChar = '';
    end
    
    for maskIdx = 1 : numel(masksNames)
        mask = get_mat(subj,'mask', masksNames{maskIdx});
        mkdir([outputFolder '/FeaturesMasks/' subjectName '/' runs{maskIdx}]);
        save( [outputFolder '/FeaturesMasks/' subjectName '/' runs{maskIdx} '/featuresMask' ] , 'mask');
    end
    
    % save the intersect features
    mask = get_mat(subj,'mask', [maskName '_intersect']);
    if (~isempty(mask))
        mkdir([outputFolder '/FeaturesMasks/' subjectName]);
        save( [outputFolder '/FeaturesMasks/' subjectName '/' 'featuresMask' '_intersect' diacriticalChar] , 'mask');
    end
    
    % save the union features
    mask = get_mat(subj,'mask', [maskName '_union']);
    if (~isempty(mask))
        mkdir([outputFolder '/FeaturesMasks/' subjectName]);
        save( [outputFolder '/FeaturesMasks/' subjectName '/' 'featuresMask' '_union' diacriticalChar] , 'mask');
    end

end