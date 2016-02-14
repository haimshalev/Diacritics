function [unMaskedFeaturesVec] = CreateUnMaskedFeaturesVec(featuresVec, maskPath)

    %% mask the data

    % note, the data is un masked, mvpa first masks the data so we need to do
    % it also
    disp(['loading mask from file : ' maskPath]);
    % load the mask and reshape it
    load(maskPath);
    mask = logical(reshape(mask,numel(mask), 1));
    
    %% create un masked features vec
    unMaskedFeaturesVec = zeros(size(mask));
    unMaskedFeaturesVec(mask) = featuresVec;

end