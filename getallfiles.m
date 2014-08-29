function files = getallfiles(directory, fileType)

dirList = dir([directory '*' fileType]);
files = {dirList.name};

end