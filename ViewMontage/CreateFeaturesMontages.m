function [ output_args ] = CreateFeaturesMontages( subj , patternName, featuresGroupName)
%CREATEFEATURESMONTAGES Summary of this function goes here
%   Detailed explanation goes here

    global globalVars;
    
    disp(['Creating features montages of subject: ' subj.header.id]);
    
    if (~isempty(find_obj(subj, [featuresGroupName '_intersect'])))
        view_montage(subj,'pattern',patternName,'mask', [featuresGroupName '_intersect'], 'printfig', globalVars.outputFolderPath, 'invisible', true);
    end
    
    if (~isempty(find_obj(subj, [featuresGroupName '_union'])))
        view_montage(subj,'pattern',patternName,'mask', [featuresGroupName '_union'],'printfig', globalVars.outputFolderPath, 'invisible', true);
    end

    matches = find_group(subj,'mask', featuresGroupName);
    if (isempty(matches))
        matches = find_group_single(subj, 'mask', featuresGroupName);
    end
    
    for featureFold = matches
        view_montage(subj,'pattern',patternName,'mask', char(featureFold),'printfig', globalVars.outputFolderPath, 'invisible', true);
    end
    
end

