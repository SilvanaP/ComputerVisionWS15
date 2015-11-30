% Computer Vision VU
% Assignment 2 - Image Segmentation by K-means Clustering
% WS2015

%% ### Preprocessing ###
% Load data
clear;
clc;

k = 3;                                          % number of clusters, min 1
improvementRatio = 1.05;                        % min 1


filename = 'simple.PNG';
%filename = 'future.jpg';
%filename = 'mm.jpg';
img = im2double(imread(filename));

height = size(img, 1);
width = size(img, 2);

% extract colorchannels
red = img(:, :, 1);
green = img(:, :, 2);
blue = img(:, :, 3);

% turn colormatrizes into vectors
r_vec = red(:);
g_vec = green(:);
b_vec = blue(:);

% create vector for xpos
xmat = repmat(1:1:width, [height, 1]);
x_vec = xmat(:);

% create vector for ypos
ymat = repmat(transpose(1:1:height), [1, width]);
y_vec = ymat(:);

% create a matrix with: r, g, b, pox, poy
% each row corresponds to 1 datapoint
points = [r_vec, g_vec, b_vec, x_vec, y_vec];         % rgb at (posx, posy)
% points = [r_vec, g_vec, b_vec];                     % only rgb

% Normalize data
% new =(old-min)/(max-min) per coloum, assume colorchannels are independent
for m = 1:size(points, 2)
    points(:, m) = (points(:, m) - min(points(:, m))) ./ (max(points(:, m)) - min(points(:, m)));
end





%% ### Run K-Means and evaluate result ###

% run k-means on points with k clusters until improvementRatio is reached
[labels, centroids] = kmeansClustering(points, k, improvementRatio);

% calc lookuptable for centroidNumber per pixel
% (column number corresponds to centroid number)
for i = 1:1:size(labels, 1)             % rows
    for j = 1:1:size(labels, 2)         % columns
        if(labels(i, j) == 1) 
            labels(i, j) = j; 
        end
    end
end

% sum up each row indivually 
%(each row contains now only zeros and the centroid number)
% and reshape into original image dimensions
clusterIndex = reshape(sum(labels, 2), [height, width]);


% ### Show Result ###
newImg = zeros(size(img));
for i = 1:1:size(img, 1)                                          % rows
    for j = 1:1:size(img, 2)                                      % columns
        newImg(i, j, 1) = centroids(clusterIndex(i, j), 1);
        newImg(i, j, 2) = centroids(clusterIndex(i, j), 2);
        newImg(i, j, 3) = centroids(clusterIndex(i, j), 3);
    end
end

imshow(newImg);
