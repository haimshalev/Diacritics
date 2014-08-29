function [regsmat condnames] = getregsmat()

%% create the regressors matrix

global regressorsPath;
global withDiacriticsScanFileNameLength;
global withoutDiacriticsScanFileNameLength;

dataDir = regressorsPath;
files = what(dataDir);
files = files.mat;
regsmat = [];
for iFile = 1 : length(files)
   load([dataDir files{iFile}]);
   
   %Create a new reg matrix
   
   % if with diacritics
   if size(files{iFile}, 2) == withDiacriticsScanFileNameLength
       outputMatrix = [ zeros(2, size(outputMatrix,2)) ; outputMatrix];
   % if without diacritics
   elseif size(files{iFile},2) == withoutDiacriticsScanFileNameLength
       outputMatrix = [outputMatrix(1:2,:) ; zeros(2,size(outputMatrix,2)) ; outputMatrix(3:4,:)]
   else error('unkown regressor file length');
   end
   
   regsmat = [regsmat outputMatrix];    
end

%% set the condition names list

global conditionNames
condnames = conditionNames;

end