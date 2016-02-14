function [ featuresMask ] = CreateFeaturesMask( votedFeaturesMask , numFeatures)
%CREATEFEATURESMASK Summary of this function goes here
%   Detailed explanation goes here

%[~, featuresIdxs] = sort(votedFeaturesMask, 'descend');
%featuresMask = zeros(size(votedFeaturesMask));
%featuresMask(featuresIdxs(1:numFeatures)) = ones(numFeatures,1);

[sortedVotes, featuresIdxs] = sort(votedFeaturesMask, 'descend');
featuresIdxs = featuresIdxs(sortedVotes == max(sortedVotes));
jumps = floor(size(featuresIdxs,1) ./ numFeatures);

featuresIdxs = featuresIdxs(1:jumps:end,:);
featuresIdxs = featuresIdxs(1:numFeatures);
featuresMask = zeros(size(votedFeaturesMask));
featuresMask(featuresIdxs(1:numFeatures)) = ones(numFeatures,1);

end

