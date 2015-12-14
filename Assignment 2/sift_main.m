function [homography] = sift_main(image1, image2, output)
%image1... a rgb-image
%image2... a rgb-image
%output... = 1 -> generate output for report

close all;

stepRANSAC = 1000;
THRESHOLD = 5;

%STEP 1: Read in and convert
I1 = im2single(rgb2gray(image1));
I2 = im2single(rgb2gray(image2));

% Perform SIFT
%F ... columns are keypoints
%      in the format [X;Y;Scale;Orientation]
%D ... Descriptor for each keypoint
[F1, D1] = vl_sift(I1);
[F2, D2] = vl_sift(I2);

%STEP 2: Match and plot
[matches, scores] = vl_ubcmatch(D1, D2) ;

%extract coordinates by the indices returned by matches
xI1 = F1(1,matches(1,:));
yI1 = F1(2,matches(1,:));
p1 = [xI1', yI1'];

xI2 = F2(1,matches(2,:));
yI2 = F2(2,matches(2,:));
p2 = [xI2', yI2'];

%Plot the first macthes
if output == 1
    match_plot(I1, I2, p1, p2)
end

maxInliers = 0;
bestInliers = 0;
bestHomography = 0;

%STEP 3: RANSAC
for i = 1 : stepRANSAC
    
    % a) chose 4 samples randomly
    positions = randsample((size(matches,2)),4)';
    
    randI1 = [ xI1(positions)', yI1(positions)' ];
    randI2 = [ xI2(positions)', yI2(positions)' ];
    
    % b) estimate homography
    try
        % rand1...moving points, they shall be transformed
        % rand2...fixed points, they stay fixed
        tForm = cp2tform(randI1, randI2, 'projective');
    catch ME
        switch ME.identifier
            case 'images:cp2tform:rankError'
                if output == 1
                    warning('random points are linearly dependent');
                end
            otherwise
                if output == 1
                    warning('smtgh else fucked up');
                end
        end
        continue;
    end
    
    % c) transform all other puative matching points of first image 
    %    via forward spatial transformation tformfwd.
    %    (I just transform ALL points, including the 4 random ones - shoul be no problem?)

    [X1, Y1] = tformfwd(tForm, xI1', yI1');
    
    % d) calculate euclidean distance between transformed points and points
    % in I2
    
    xCoords = X1 - xI2';
    yCoords = Y1 - yI2';
    eucledean = sqrt(xCoords.*xCoords + yCoords.*yCoords);
    
    inliers = eucledean < THRESHOLD;
    numInliers = sum(inliers(:));
    
    if(numInliers > maxInliers)
        maxInliers = numInliers;
        bestInliers = inliers;
        bestHomography = tForm;
    end
end

%4. Reestimate homography
    
inX1 = zeros(size(matches,2), 1);
inY1 = zeros(size(matches,2), 1);
inX2 = zeros(size(matches,2), 1);
inY2 = zeros(size(matches,2), 1);

%Get all the inliers
inX1 = xI1' .* bestInliers;
inX1 = inX1(inX1~=0);
inY1 = yI1' .* bestInliers;
inY1 = inY1(inY1~=0);

inX2 = xI2' .* bestInliers;
inX2 = inX2(inX2~=0);
inY2 = yI2' .* bestInliers;
inY2 = inY2(inY2~=0);
    
try
tFormBest = cp2tform([inX1, inY1],[inX2, inY2], 'projective');
catch ME
    switch ME.identifier
        case 'images:cp2tform:rankError'
            if output == 1
                warning('This shoudl not heppen with best inliers');
            end
        otherwise
            if output == 1
                warning('smtgh else fucked up');
            end
    end
end

%Plot the "ideal" matches
%match_plot(I, I2,[inX, inY],[inX2, inY2])

%5. Transform first image into second image
if output == 1
    sizeXY = [1, 1]; %size of a pixel in x, y dimension (why do we even need that?)
    xData = [1, size(I2, 2)]; %index  of first and  last column
    yData = [1, size(I2, 1)]; %index  of first and last row
    res = imtransform(I1, tFormBest, 'XData', xData, 'YData', yData, 'XYScale', sizeXY);

    figure();
    imshow(res);

    figure();
    imshow(I2);

    figure();
    imshow(abs(res - I2));
end

%return values
homography = tFormBest;

end






