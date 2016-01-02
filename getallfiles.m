function files = getallfiles(directoryPath, regex)

directory = dir(directoryPath);
directory = directory(3:end,:);
directories = {directory.name};
passedFiles = regexp(directories, regex, 'match');
files = directories(~cellfun('isempty', passedFiles));
end