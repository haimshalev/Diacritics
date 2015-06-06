function [ combinationMat ] = CreateCombinations( values, lengthOfCombination )
%CREATECOMBINATIONS Summary of this function goes here
%   Detailed explanation goes here

combinationMat = [];
numOfValues = length(values);
sizeOfCombinationMat = power(numOfValues, lengthOfCombination);

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

end

