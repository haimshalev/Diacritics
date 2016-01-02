function [ normIrfCombination ] = CreateResponseForCombination( currentCombination,previousWindowTRs, trialsInWindowIdxs, irfDictionary )
%CREATERESPONSEFORCOMBINATION Summary of this function goes here
%   Detailed explanation goes here

   lengthOfIrf = size(irfDictionary,2);
   trialsInPreviousWindowIdxs = find(previousWindowTRs);
   lengthOfPreviousWindow = size(previousWindowTRs,2);
   irfCombination = zeros(size(irfDictionary,1), lengthOfPreviousWindow + lengthOfIrf .* 2); % create the padded initialized mat
       
    % add the previous winodow effects to the current new irfcombination
    for trialIdx = trialsInPreviousWindowIdxs
        irfCombination(:,trialIdx : trialIdx + lengthOfIrf - 1) = irfCombination(:,trialIdx : trialIdx + lengthOfIrf - 1) + irfDictionary(:,:,previousWindowTRs(trialIdx));
    end
    
    % add each response of each condition in the current combination to the irf
    for trialIdx = 1 : length(trialsInWindowIdxs)
        currentCondition = currentCombination(trialIdx);
        trialIndexInWindow = trialsInWindowIdxs(trialIdx);
        irfCombination(:,trialIndexInWindow : trialIndexInWindow + lengthOfIrf - 1) = irfCombination(:,trialIndexInWindow : trialIndexInWindow + lengthOfIrf - 1) + irfDictionary(:,:,currentCondition);
    end    
    
    %take only the current window (with the effect of the previous one)
    irfCombination = irfCombination(:,lengthOfPreviousWindow + 1: lengthOfPreviousWindow + lengthOfIrf );
      
    %normalize the irf combination 
    normIrfCombination = irfCombination - repmat(mean(irfCombination,2), 1,size(irfCombination,2));

end

