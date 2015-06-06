firstRunsIrfsPaths= {
    '/Data/DiacriticsFramework/HaimShalevCode/3dDeconvolveTest_04.11.14/OutputFolder/001/A1/dataset_B.irf+tlrc.BRIK' ...
    '/Data/DiacriticsFramework/HaimShalevCode/3dDeconvolveTest_04.11.14/OutputFolder/001/A1/dataset_M.irf+tlrc.BRIK' ...
    '/Data/DiacriticsFramework/HaimShalevCode/3dDeconvolveTest_04.11.14/OutputFolder/001/A1/dataset_R.irf+tlrc.BRIK' ...
    };
[firstRunIrfs, firstRunDiffMatrix] = ReadBriksAndCreateInnerDiffMatices(firstRunsIrfsPaths);

secondRunIrfsPaths = {
    '/Data/DiacriticsFramework/HaimShalevCode/3dDeconvolveTest_04.11.14/OutputFolder/001/A2/dataset_B.irf+tlrc.BRIK' ...
    '/Data/DiacriticsFramework/HaimShalevCode/3dDeconvolveTest_04.11.14/OutputFolder/001/A2/dataset_M.irf+tlrc.BRIK' ...
    '/Data/DiacriticsFramework/HaimShalevCode/3dDeconvolveTest_04.11.14/OutputFolder/001/A2/dataset_R.irf+tlrc.BRIK' ...
    };
[secondtRunIrfs, secondRunDiffMatrix] = ReadBriksAndCreateInnerDiffMatices(secondRunIrfsPaths);

% try to understand if there are any cross runs irf diffrences
% create diff matrices
diffMatix = cell(length(firstRunIrfs),length(secondtRunIrfs));
for i = 1 : length(firstRunIrfs)
    for j = 1 : length(secondtRunIrfs)
        diffMatix{i,j} = abs(firstRunIrfs{i} - secondtRunIrfs{j});
    end
end

bucketOfRun1Path = {
    '/Data/DiacriticsFramework/HaimShalevCode/3dDeconvolveTest_04.11.14/OutputFolder/001/dataset_A1.bucket+tlrc.BRIK'
    };
a1Bucket = ReadBrik(bucketOfRun1Path);
