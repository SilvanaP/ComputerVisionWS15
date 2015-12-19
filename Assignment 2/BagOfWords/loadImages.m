% Computer Vision VU
% Assignment 5 - Scene Recognition with Bag of VisualWords
% WS2015

% This function load images from a folder and its subfolders
function [images] = loadImages( folder )
% INPUT:
% folder ... name of the folder containing images
%
% OUTPUT:
% images ... cell-array of loaded images, second index is actual class

% create cell array
images = cell(800, 1);

% count loaded images
img_counter = 1;

% load images
filesInFolder = dir(folder);

n = size(filesInFolder, 1); % gives back 10 for 8 folders, start at 2!!!
if(n == 10)
    for i = 1:8             % for every subfolder:
        foldername = filesInFolder(i + 2).name;
        folderpath = fullfile(folder, foldername);
        filesInSubfolder = dir(folderpath);
        
        m = size(filesInSubfolder); % gives back 102, start a 3 !!!
        
        for j = 3:1:m
            fullpath = fullfile(folderpath, filesInSubfolder(j).name);
            image = imread(fullpath);
            images{img_counter, 1} = image;
            img_counter = img_counter + 1;
        end
    end
else % != 10
    for j = 3:1:n
        foldername = filesInFolder(j).name;
        folderpath = fullfile(folder, foldername);
        image = imread(folderpath);
        images{img_counter, 1} = image;
        img_counter = img_counter + 1;
    end
end

images = images(~cellfun(@isempty, images));
end

