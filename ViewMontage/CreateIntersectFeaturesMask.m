function [ newSubj, numFeatures ] = CreateIntersectFeaturesMask(subj, featuresMaskName)
%CREATEINTERSECTFEATURESMASK Summary of this function goes here
%   Detailed explanation goes here

    disp(['Creating intersect features mask of mask : ' featuresMaskName ' for subj: ' subj.header.id]);

    objType = 'mask';
    matches = find_group(subj, objType, featuresMaskName);
    
    if (isempty(matches))
        warning(['the specified features mask group: ' featuresMaskName ' is invalid, ignoring union of features masks']);
        newSubj = subj;
        numFeatures = 0;
        return;
    end
    
    maskName = [featuresMaskName '_intersect'];
    newSubj = combine_masks(subj, @(A,B) A & B, maskName, [featuresMaskName '_[0-9]+']);
    newMask = get_object(newSubj, 'mask', maskName);
    numFeatures = count(newMask.mat);

end

