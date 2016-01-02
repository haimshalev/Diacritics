
function [ accurracy ] = computeConfusionMatrixAccurracy(confusionMatrix, conditions)

updateConfusionMat = zeros(size(confusionMatrix));

if (exist('conditions','var'))
    if (~isempty(conditions))
        updateConfusionMat(conditions, :) = confusionMatrix(conditions,:);
    end
end

% count the number of correct classification trials ./ number of trials
accurracy = 100 * (sum(diag(updateConfusionMat)) ./ sum(updateConfusionMat(:)));

end