function [ output_args ] = MeanOfAvgResults( avgResults )
%MEANOFAVGRESULTS Summary of this function goes here
%   Detailed explanation goes here

avg = zeros(length(avgResults),1);
stdArr = zeros(length(avgResults),1);
for i = 1 : length(avgResults)
    avg(i) = mean(avgResults(i).avgForEachIterationOverTestsOverSubjects)
    stdArr(i) = mean(avgResults(i).stdForEachIterationOverTestsOverSubjects);
end

disp(['mean ' num2str(mean(avg)) ' with std ' num2str(mean(stdArr))]);

end

