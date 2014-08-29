function filenames = getscanfiles()

global scansPath;
scansDir = scansPath;

scanFiles = getallfiles(scansDir, '.BRIK');
filenames = cell(1, length(scanFiles));

for iFile = 1 : length(scanFiles)
    filenames{iFile} = [scansDir scanFiles{iFile}];
end

end