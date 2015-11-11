function BlobDetection(file, sigma0, k, levels, threshold, invert, special)
%file... file name (rgb images are converted to gray-scale via rgb2gray
%sigma... initial scale
%k... factor by which the scale is multiplied each level
%levels... number of levels in scale space
%threshold... point in scale space has to be above this value to be
%considered in local maximum computation
%invert ['','invert']... inverts gray-scale image (detects white circles)
%special ['',

%ex: BlobDetection('butterfly.jpg', 2, 1.25, 10, 80, 'invert', 'special');
%ex: lobDetection('dalmatiner.jpg', 2, 1.25, 10, 110, '', 'special');

%close all old figures
close all

%read file; save original
image = imread(file);
origimage = image;

%if input is rgb image
[~, ~, channels] = size(image);
if channels == 3
    image = rgb2gray(image);
end

%invert
if strcmp(invert, 'invert')
    image = uint8(double(image) * (-1) + 255);
end

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
    image = imresize(image, 0.5);
    origimage = imresize(origimage, 0.5);

    %choose keypoint
    keypoint_id_full = 2;
    keypoint_id_half = 1;
    
    %detect and plot blobs for half-sized image; optional: use other sigmas
    figure;
    x = sigmas;
    [scale_space_half, points_half] = detect_blob(origimage, image, x, levels, threshold);
    y = scale_space_half(points_half(keypoint_id_half,1),points_half(keypoint_id_half,2),:);
    
    %plot log response
    figure;
    plot(x(:),y(:),'go');
    hold on
    
    %for full-sized image
    x = sigmas; %all scales
    y = scale_space_full(points_full(keypoint_id_full,1),points_full(keypoint_id_full,2),:);
    plot(x(:),y(:),'ro');
   
    title(sprintf('LoG response for keypoint at (%d,%d) in full image (red) and at (%d,%d) in half-sized image (green)', points_full(keypoint_id_full,2), points_full(keypoint_id_full,1), ...
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
    filter = fspecial('log', filter_size, sigmas(i)) * sigmas(i)^2;

    scale_space(:,:,i) = abs(imfilter(image, filter, 'same', 'replicate'));

    %%debug
    %imshow(scale_space(:,:,i));             
    %pause(0.1);
end

%## non-maximum suppression
%x,y is a point with scale i, if it is
%- above a threshold
%- a local max. compared to its 8 neighboring points at scale i
%- a local max. compared to its 9 neighboring points at scale (i-1) and(i+1)

points = zeros(height * width * levels, 3);

scale_space_zeros = zeros(height+8, width+8, levels+2);
scale_space_zeros(5:4+height,5:4+width,2:1+levels) = scale_space(:,:,:);
j = 1;
for x = 5 : 1 : 4+height
    for y = 5 : 1 : 4+width
        for i = 2 : 1 : 1+levels
            if scale_space_zeros(x,y,i) > threshold
                if max(max(max(scale_space_zeros(x-4:x+4, y-4:y+4, i-1:i+1)))) == scale_space_zeros(x,y,i)
                    points(j, :) = [x-4; y-4; sigmas(i-1) * sqrt(2)];
                    j = j + 1;
                end
            end
        end
    end
end

%## plot
show_all_circles(origimage, points(1:j-1,2), points(1:j-1,1), points(1:j-1,3));
title(sprintf('%d circles (threshold = %d, scale space [%d,%d])', size(points(1:j-1,2),1), threshold, min(min(min(scale_space))), max(max(max(scale_space)))));

end