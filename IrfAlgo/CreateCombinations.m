function [ combinationMatResult ] = CreateCombinations( values, lengthOfCombination , testedConditions)
%CREATECOMBINATIONS Summary of this function goes here
%   Detailed explanation goes here

combinationMat = [];
numOfValues = length(values);

for columnIdx = 1 : lengthOfCombination
    column = [];
    for valuesIterationIdx = power(numOfValues, lengthOfCombination  - columnIdx) : -1 : 1
        for value = values
            for valueIdx = 1 : power(numOfValues,columnIdx - 1)
                column = [column ; value];
            end
        end
    end
    combinationMat = [column combinationMat];
end

combinationMatResult = [];
for testedCondition = testedConditions
    combinationMatResult = [combinationMatResult ; combinationMat(combinationMat(:,1) == testedCondition,:)];
end

end

