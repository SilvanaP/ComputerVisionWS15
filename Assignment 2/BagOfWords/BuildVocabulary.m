% Computer Vision VU
% Assignment 5 - Scene Recognition with Bag of VisualWords
% WS2015

function [C] = BuildVocabulary(folder, num_clusters)
% INPUT:
% folder ......... name of the folder containing the training images
% num_clusters ... number of clusters, i.e. size of vocabulary

% OUTPUT:
% C .............. confusion matrix, (size = 128* numClusters)
%                  (one column per center)

disp(sprintf('### Building Vocabulary ###'));
% read all 800 images from folder
images_all = loadImages(folder);

% calculate step size, s.t. ~100 features per image are used
% (i.e. NUMKEYPOINTS from vl_dsift is ~100)
size_x = size(images_all{1}, 2);
size_y = size(images_all{1}, 1);

val = floor(sqrt((size_x * size_y)/100));
if (val == 0)
    step = 2;
else
    step = val;
end

% collect SIFT-features
[frames_all, descriptors_all] = vl_dsift(single(images_all{1}), 'step', step, 'fast');
% [FRAMES,DESCRS] = VL_DSIFT(I) extracts a dense set of SIFT
%                   keypoints from image I.
% -I ... class SINGLE and grayscale
% -FRAMES ... 2 x NUMKEYPOINTS matrix, each colum storing the center (x,y)
%                   of a keypoint frame
% -DESCRS ... 128 x NUMKEYPOINTS matrix with one descriptor per column


% repeat for rest of images and append results horizontaly
for k = 2:800
    size_x = size(images_all{k}, 2);
    size_y = size(images_all{k}, 1);
    
    val = floor(sqrt((size_x * size_y)/100));
    if (val == 0)
        step = 2;
    else
        step = val;
    end
    % features of current image
    disp(sprintf('Building Vocab: calc SIFT for image %d', k));
    [frames, descriptors] = vl_dsift(single(images_all{k}), 'step', step, 'fast');
    
    % concatenate side by side
    frames_all = [frames_all frames];
    descriptors_all = [descriptors_all descriptors];
end

% k-means clustering
disp(sprintf('Building Vocab: K-Means-clustering with %d clusters...', num_clusters));
[C, A] = vl_kmeans(single(descriptors_all), num_clusters);
% [C, A] = VL_KMEANS(X, NUMCENTERS) clusters columns of matrix X in
% NUMCENTERS centroids C with k-means.
% -X ... may be either SINGLE or DOUBLE.
% -C ... has the same number of rows of X and NUMCENTER columns, with one 
%        column per center.
% -A ... is a UINT32 row vector specifying the assignments of the data X to
%        the NUMCENTER centers.

end





% Mini-Description:
% vocabulary is formed by sampling many local features the training set
% (i.e. 100’s of thousands of features) and then clustering them with
% K-Means. The number of clusters numClusters is the size of the
% vocabulary, e.g. if numClusters == 50, then the 128 dimensional
% SIFT feature space is partitioned into 50 regions.
%
% For any new SIFT feature, we can figure out which cluster it belongs to
% (if we save the centroids of the original clusters, i.e. the vocab.)