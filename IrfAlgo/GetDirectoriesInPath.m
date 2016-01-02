function [ directories ] = GetDirectoriesInPath( directoryPath , regex)
%GETDIRECTORIESINPATH Summary of this function goes here
%   Detailed explanation goes here

directoryFolders = dir(directoryPath);
directoryFolders = directoryFolders(3:end,:);
directoryFolders = directoryFolders([directoryFolders.isdir]);
directories = {directoryFolders.name};
directories = regexp(directories, regex, 'match');
directories = directories(~cellfun('isempty', directories));
end

