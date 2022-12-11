clc
clear all
close all
data_filename = uigetdir; % filename for all folders
topLevelFolder = data_filename;  % Get a list of all files and folders in this folder.
files = dir(topLevelFolder);    % Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];   % Extract only those that are directories.
subFolders = files(dirFlags);   % A structure with extra info. Get only the folder names into a cell array.
subFolderNames = {subFolders(3:end).name}; % Start at 3 to skip .
for index = 1:length(subFolderNames)
    blsh = '\';
    path_in = strcat(data_filename,blsh,subFolderNames(index));
    bottomLevelFolder = string(path_in);
    files_in = dir(bottomLevelFolder);    % Get a logical vector that tells which is a directory.
    dirFlags_in = [files_in.isdir];   % Extract only those that are directories.
    subFolders_in = files_in(dirFlags_in);   % A structure with extra info. Get only the folder names into a cell array.
    subFolderNames_in = {subFolders_in(3:end).name};
    for in_index = 1 : length(subFolderNames_in)
        path = strcat(path_in,blsh,subFolderNames_in(in_index),blsh);
        path = string(path);
        dumy = string(subFolderNames_in(in_index));
        tif_files = dir(fullfile(path,'*.tif'));
        numf = length(tif_files);
        for cnt = 1:numf
            img = imread(fullfile(path,tif_files(cnt).name));   
            [rows, columns, numberOfColorChannels] = size(img);
            if(numberOfColorChannels<3)
                delete(strcat(path,tif_files(cnt).name));
            end
        end
        fprintf("%s cleaning completed\n",dumy);
    end
    fprintf(".........................\n");
    fprintf("%s folder cleaning completed\n",string(subFolderNames(index)));
    fprintf(".........................\n");
end