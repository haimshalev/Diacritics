function [ newSubj ]  = CreateAnatomicalImageForSubject(subj, patternName);
%CREATEANATOMICALIMAGEFORSUBJECT Summary of this function goes here
%   Detailed explanation goes here

    disp(['Creating anatomical image from pattern : ' patternName ' for subj: ' subj.header.id]);
    
    newPatternName = [patternName '_vol1'];
    newSubj = duplicate_object(subj, 'pattern', patternName, newPatternName);
    newPatternMat = get_mat(newSubj, 'pattern', newPatternName);
    newSubj = set_mat(newSubj,'pattern', newPatternName, newPatternMat(:,1));

end

