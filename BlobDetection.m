function BlobDetection(file, sigma0, k, levels, threshold, special)
%file... file name (rgb images are converted to gray-scale via rgb2gray
%sigma... initial scale
%k... factor by which the scale is multiplied each level
%levels... number of levels in scale space
%threshold... point in scale space has to be above this value to be
%considered in local maximum computation
%special ['','special']... detect blobs for half-sized version and output
%figures for the report

%USAGE:
%ex: BlobDetection('butterfly.jpg', 2, 1.25, 10, 140, 'special');
%ex: BlobDetection('Images\dalmatiner.jpg', 2, 1.25, 10, 100, '');

%close all old figures
close all

%read file; keep original
image = imread(file);
origimage = image;

%if input is rgb image
[~, ~, channels] = size(image);
if channels == 3
    image = rgb2gray(image);
end

image = double(image);

%compute sigmas
sigmas = zeros(levels,1);
sigmas(1) = sigma0;
for i = 1 : 1 : levels-1
    sigmas(i+1) = sigmas(i) * k;
end

%detect and plot blobs
[scale_space_full, points_full] = detect_blob(origimage, image, sigmas, levels, threshold);

%## additional output
if strcmp(special, 'special')
    scale = 0.5;
    image = imresize(image, scale, 'nearest');
    origimage = imresize(origimage, scale);

    %choose keypoint for comparison plot; e.g. 1,1 for butterfly (t=100), 1,2 for
    %dalmatiner (t=140)
    keypoint_id_full = 1;
    keypoint_id_half = 1;
    
    %detect and plot blobs for half-sized image; optional: use other sigmas
    figure;
    x = sigmas;
    [scale_space_half, points_half] = detect_blob(origimage, image, x, levels, threshold); %calc keypoints
    y = scale_space_half(points_half(keypoint_id_half,1),points_half(keypoint_id_half,2),:);
    
    %plot log response
    figure;
    plot(x(:),y(:),'go');
    hold on
    
    %for full-sized image
    x = sigmas; %all scales
    y = scale_space_full(points_full(keypoint_id_full,1),points_full(keypoint_id_full,2),:);
    plot(x(:),y(:),'ro');
   
    title(sprintf('response at (%d,%d) in full- (red) and at (%d,%d) in half-sized image (green)', points_full(keypoint_id_full,2), points_full(keypoint_id_full,1), ...
                                                                                                     points_half(keypoint_id_half,2), points_half(keypoint_id_half,1)));
    hold off
end

end

function [scale_space, points] = detect_blob(origimage, image, sigmas, levels, threshold)

[height, width] = size(image);
scale_space = zeros(height, width, levels);

%## building the scale space
for i = 1 : 1 : levels
    filter_size = 2 * floor(3*sigmas(i)) + 1;
    filter = (sigmas(i)^2) * fspecial('log', filter_size, sigmas(i));

    scale_space(:,:,i) = abs(imfilter(image, filter, 'same', 'replicate'));

%     %debug
%     imshow(scale_space(:,:,i)/255);             
%     pause(1.0);
end

%## non-maximum suppression
%x,y is a point with scale i, if it is
%- above a threshold
%- a local max. compared to its 8 neighboring points at scale i
%- a local max. compared to its 9 neighboring points at scale (i-1) and(i+1)
points = zeros(height * width * levels, 3);

scale_space_zeros = zeros(height+2, width+2, levels+2);
scale_space_zeros(2:1+height,2:1+width,2:1+levels) = scale_space(:,:,:);
j = 1;
for x = 2 : 1 : 1+height
    for y = 2 : 1 : 1+width
        for i = 2 : 1 : 1+levels
            if scale_space_zeros(x,y,i) > threshold %point in scale-space is > threshold
                  if max(max(max(scale_space_zeros(x-1:x+1, y-1:y+1, i-1:i+1)))) == scale_space_zeros(x,y,i) %point is max in the 3x3x3 neighborhood
                    points(j, :) = [x-1; y-1; sigmas(i-1) * sqrt(2)]; %x,y,i run from 2 -> -1
                    j = j + 1;
                  end
            end
        end
    end
end

%## plot
show_all_circles(origimage, points(1:j-1,2), points(1:j-1,1), points(1:j-1,3));
title(sprintf('%d circles (threshold = %d, scale space [%d,%d])', size(points(1:j-1,2),1), threshold, uint8(min(min(min(scale_space)))), uint8(max(max(max(scale_space))))));

end