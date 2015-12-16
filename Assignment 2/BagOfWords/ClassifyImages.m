% Computer Vision VU
% Assignment 5 - Scene Recognition with Bag of VisualWords
% WS2015

% This function classifys all images in the test set
% The function is similar to BuildKNN, but this time the visual word
% histogram of an image is used for classifying it with the Matlab function
% knnclassify (e.g. k = 3) and the training features with class labels

function [conf_matrix, class] = ClassifyImages(folder, C, training, group)
% INPUT:
% folder ........ folder of testimages
% C ............. confusion matrix
% training ...... matrix of feature points, each rows represents an image
% group ......... vector that indicates the class label

% OUTPUT:
% conf_matrix ... confusion matrix, elements at position (i, j) indicate
%                 how often an image with classlabel i is classified to the
%                 class with label j.

disp(sprintf('### Classify Images ###'));
testImages = [];

% load n testimages
images_all = loadImages(folder);
n = size(images_all, 1);

% extract SIFT-features
disp(sprintf('Classify: assign SIFT-features to visual words in vocabulary'));
for k = 1:1:n
    disp(sprintf('Classify: assign image %d', k));
    if(size(images_all{k}, 3) == 3)         % --> rgb
        img = im2double(images_all{k});
        img = rgb2gray(img);
        img = single(img);
    else                                    % --> grayscale
        img = single(images_all{k});
    end
    
    [frames, descriptors] = vl_dsift(img, 'step', 2, 'fast');
    
    % assign SIFT-features to visual words in vocabulary C
    descriptors_transp = transpose(descriptors);
    C_transp = transpose(C);
    Idx = knnsearch(single(C_transp), single(descriptors_transp));
    
    % count number of word-occurrences
    binranges = 1:50;
    histCount = histc(Idx, binranges);
    sumHistogram = sum(histCount);
    
    % Normalize to unit length of the vector (account for different image
    % resolutions)
    norm = histCount / sumHistogram;
    
    % append norm vectors to sample matrix
    testImages = [testImages norm];
end

testImages = transpose(testImages);

% classify testimages
disp(sprintf('Classify: classify images'));
class = knnclassify(testImages, training, group, 3, 'euclidean');  % k = 3

% create conf_matrix
% elements at position (i, j) indicate how often an image with class label
% i is classified to the class with label j
size_class = size(class, 1)

conf_matrix = zeros(8, 8);
for k = 1:size_class
    conf_matrix(group(k), class(k)) = conf_matrix(group(k), class(k)) + 1;
end
end

