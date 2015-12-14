function [] = stitch_images(path, prefix, type, startIndex, endIndex, output);
%usage: stitch_images('ass4_data','officeview','.jpg',1,5,0)
%       stitch_images('ass4_data','campus','.jpg',1,5,0)
%---------
%path... e.g. ass4_data
%prefix... e.g. campus or officeview
%type... image type, e.g. .jpg
%startIndex... index of first image e.g. 1
%endIndex... index of last image e.g. 5
%output... = 1 -> generate output for report

%check input
last_char = path(end-1:end);
if ~strcmp(last_char,'/')
   path = [path '/']; 
end

%load images
firstImage = imread([path, prefix, num2str(startIndex), type]);
[height,width,channels] = size(firstImage);
images = zeros(height,width,channels,endIndex,'uint8');
images(:,:,:,1) = firstImage;
for i = startIndex+1 : endIndex
    newImage = imread([path, prefix, num2str(i), type]);
    images(:,:,:,i) = newImage;
end

%alpha maps
border = zeros(height,width);
border(1,1:end) = 1;
border(end,1:end) = 1;
border(1:end,1) = 1;
border(1:end,end) = 1;
alpha = uint8(bwdist(border));
alphas = repmat(alpha,1,1,3,endIndex);

% 1) compute homographies between all image pairs from left to right
for i = startIndex : endIndex - 1
    [homographiesToNext(i)] = sift_main(images(:,:,:,i), images(:,:,:,i+1), 0);
end

%choose index of center (reference) image
centerIndex = floor((endIndex-startIndex)/2 + startIndex);

% 2) compute transformations to center image from pair-wise homography's
%tranformations and inverse-transformations
transformToCenter = repmat(eye(3),1,1,endIndex);
%mappings of i in [start,center-1] -> centerIndex
for i = startIndex : centerIndex-1
    transformToCenter(:,:,i) = homographiesToNext(i).tdata.T; %e.g. i=1 -> 1,2
    
    if i+1 <= centerIndex - 1
        for j = i+1 : centerIndex - 1
           transformToCenter(:,:,i) = homographiesToNext(j).tdata.T * transformToCenter(:,:,i); %e.g. j=2 -> 2,3
        end
    end
end
%mappings of i in [end,center+1] -> centerIndex
for i = endIndex : -1 : centerIndex+1
    transformToCenter(:,:,i) = homographiesToNext(i-1).tdata.Tinv; %e.g. i=5 -> 5,4
    
    if i-1 >= centerIndex + 1
        for j = i-1 : -1 : centerIndex + 1
           transformToCenter(:,:,i) = homographiesToNext(j-1).tdata.Tinv * transformToCenter(:,:,i); %e.g. j=3 -> 4,3
        end
    end
end
%mapping centerIndex -> centerIndex stays identity

% 3) compute size of output panorama
%define corner points
LT = [0,0,1];
LB = [0,height,1];
RT = [width,0,1];
RB = [width,height,1];
points = repmat([LT;LB;RT;RB]',1,1,endIndex);
%transform points
for i = startIndex : endIndex
%     plot(points(1,:,i),points(2,:,i),'bo')
%     hold on
    points(:,:,i) = transformToCenter(:,:,i) * points(:,:,i);
%     plot(points(1,:,i),points(2,:,i),'ro')
%     hold off
end
%find min/max x/y coordinates
minValues = min(points, [], 2);
maxValues = max(points, [], 2);

minX = min(minValues(1,:,:));
minY = min(minValues(2,:,:));
maxX = max(maxValues(1,:,:));
maxY = max(maxValues(2,:,:));

%%%TODO%%%
% find correct min/max values
% (see values below "debug" in next for-loop)

% 4) transform images
xyScale = [1,1];

xData = [minX, maxX];
yData = [minY, maxY];

transformedImages = [];
transformedAlphas = [];
for i = startIndex : endIndex
    %debug: hardcoded; generated values crop too much
    if strcmp(prefix,'officeview')
        %approximate values for "officeview"
        xData = [-700,1500];
        yData = [-200,1300];
    end
    if strcmp(prefix,'campus') 
        %approximate values for "campus"
        xData = [-600,1000];
        yData = [-200,700];
    end
    
    %transform images
    imageToTransform = images(:,:,:,i);
    tForm = maketform('projective', transformToCenter(:,:,i)); %create transformation structure
    transformedImages = cat(4, transformedImages, imtransform(imageToTransform, tForm, 'XData', xData, 'YData', yData));
    
    %transform alphas
    transformedAlphas = cat(4, transformedAlphas, imtransform(alphas(:,:,:,i), tForm, 'XData', xData, 'YData', yData));
end

% 5) feathering
blendedImage = sum(double(transformedImages) .* double(transformedAlphas), 4);
blendedImage = blendedImage ./ sum(double(transformedAlphas), 4); %normalization
blendedImage = uint8(blendedImage);
fFeathering = figure;
set(fFeathering,'name','Stitching with blending','numbertitle','off')
imshow(blendedImage);

% for report; stitching without blending
if output == 1
    base = transformedImages(:,:,:,centerIndex);
    for i = startIndex : endIndex
        if i ~= centerIndex
            additionalImage = transformedImages(:,:,:,i);
            base(base==0) = additionalImage(base==0);
        end
    end
    fBase = figure;
    set(fBase,'name','Stitching without blending','numbertitle','off')
    imshow(base);
end

% %debug
% int16(xData)
% int16(yData)

end