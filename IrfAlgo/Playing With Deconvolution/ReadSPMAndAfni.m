SPMFiles = cell(171,1);
%AfniFile = {'/Data/DiacriticsFramework/HaimShalevCode/ConverteFolder_08.02.14/AfniFilesBefore3dDeconvolve/001/A1/afni_003+tlrc.BRIK'};

for i = 1 : 171
    SPMFiles{i} = ['/Data/DiacriticsFramework/HaimShalevCode/ConverteFolder_08.02.14/PreProcesing_in2versions/001/A1/swauYaelJuly20104_' sprintf('%3.3d',i) '.img'];
end

%Afni = ReadBrik(AfniFile);
SPM = ReadSPM(SPMFiles);
