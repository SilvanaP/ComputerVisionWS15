% Computer Vision VU
% Assignment 5 - Scene Recognition with Bag of VisualWords
% WS2015

% This function builds a feature representation for every image in folder,
% which can be used for classification of new images later on.
% An image is represented by the normalized histogram of visual words,
% i.e. all SIFT features of an image are assigned to visual words and the
% number of occurrences of every word is counted.
% The vector (histogram) is normalized to unit length to account for
% changing image resolutions.

function [training, group] = BuildKNN(folder, C)
% INPUT:
% folder ....... folder of training images
% C ............ confusion matrix of vocabulary, contains all "words"
%                (one column per center)

% OUTPUT:
% training ..... matrix of feature points, each rows represents an image
% group ........ vector that indicates the class label

disp(sprintf('### Build KNN ###'));
training = [];
group = zeros(800,1);

% load (800) training images
allImages = loadImages(folder);

% extract SIFT-feature from images
for k = 1:1:800
    % calc features of image number k
    disp(sprintf('Build KNN: calc SIFT for image %d', k));
    [frames, descriptors] = vl_dsift(single(allImages{k}), 'step', 2, 'fast');
    
    % Assign SIFT-features to visual words in vocabulary C
    C_transp = transpose(C);
    descriptors_transp = transpose(descriptors);
    Idx = knnsearch(single(C_transp), single(descriptors_transp));
    % IDX = knnsearch(X,Y) finds nearest neighbor in X for each point in Y.
    % IDX is column vector, each row contains the index of the
    % nearest neighbor in X for the corresponding row in Y
    
    % count number of word-occurrences
    bin_range = 1:50;
    histogramCount = histc(Idx, bin_range);
    sumHistogram = sum(histogramCount);
    
    % Normalize to unit length (account for different image resolutions)
    normalized = histogramCount / sumHistogram;
    
    % append norm vector to training matrix
    training = [training normalized];
    
    % add correct class-label (known in trainingset!!!)
    if (k >= 1) && (k <= 100)
        group(k) = 1;
    elseif (k >= 101) && (k <= 200)
        group(k) = 2;
    elseif (k >= 201) && (k <= 300)
        group(k) = 3;
    elseif (k >= 301) && (k <= 400)
        group(k) = 4;
    elseif (k >= 401) && (k <= 500)
        group(k) = 5;
    elseif (k >= 501) && (k <= 600)
        group(k) = 6;
    elseif (k >= 601) && (k <= 700)
        group(k) = 7;
    elseif (k >= 701) && (k <= 800)
        group(k) = 8;
    end
end

% Transpose back
training = training.';

end

