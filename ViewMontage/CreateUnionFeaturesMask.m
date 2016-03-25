function [ newSubj, numFeatures ] = CreateUnionFeaturesMask(subj, featuresMaskName)
%CREATEUNIONFEATURESMASK Summary of this function goes here
%   Detailed explanation goes here

    disp(['Creating union features mask of mask : ' featuresMaskName ' for subj: ' subj.header.id]);

    objType = 'mask';
    matches = find_group(subj, objType, featuresMaskName);
    
    if (isempty(matches))
        warning(['the specified features mask group : ' featuresMaskName ' is invalid, ignoring union of features masks']);
        newSubj = subj;
        numFeatures = 0;
        return;
    end
       
    maskName = [featuresMaskName '_union'];
    newSubj = combine_masks(subj, @(A,B) A | B, maskName, [featuresMaskName '_[0-9]+']);
    newMask = get_object(newSubj, 'mask', maskName);
    numFeatures = count(newMask.mat);
end

