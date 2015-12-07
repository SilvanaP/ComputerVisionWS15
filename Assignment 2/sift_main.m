close all;

stepRANSAC = 1000;
THRESHOLD = 5;

%STEP 1: Read in and convert
I = imread('ass4_data/officeview1.jpg');
I2 = imread('ass4_data/officeview2.jpg');

I = im2single(rgb2gray(I));
I2 = im2single(rgb2gray(I2));

% Perform SIFT
%F ... columns are keypoints
%      in the format [X;Y;Scale;Orientation]
%D ... Descriptor for each keypoint
[F, D] = vl_sift(I);
[F2, D2] = vl_sift(I2);

%STEP 2: Match and plot
[matches, scores] = vl_ubcmatch(D, D2) ;

%extract coordinates by the indices returned by matches
xI = F(1,matches(1,:));
yI = F(2,matches(1,:));
p1 = [xI', yI'];

xI2 = F2(1,matches(2,:));
yI2 = F2(2,matches(2,:));
p2 = [xI2', yI2'];

%match_plot(I, I2, p1, p2)

maxInliers = 0;
bestInliers = 0;
bestHomography = 0;

%STEP 3: RANSAC
for i = 1 : stepRANSAC
    
    % a) chose 4 samples randomly
    positions = randsample((size(matches,2)),4)';
    
    randI1 = [ xI(1,positions)' , yI(1,positions)' ];
    randI2 = [ xI2(1,positions)' , yI2(1,positions)' ];
    
    % b) estimate homography
    try
        % rand1...moving points, they shall be transformed
        % rand2...fixed points, they stay fixed
        tForm = cp2tform(randI1, randI2, 'projective');
    catch ME
        switch ME.identifier
            case 'images:cp2tform:rankError'
                warning('random points are linearly dependent');
            otherwise
                warning('smtgh else fucked up');
        end
        continue;
    end
    
    % c) transform all other puative matching points of first image 
    %    via forward spatial transformation tformfwd.
    %    (I just transform ALL points, including the 4 random ones - shoul be no problem?)

    [X, Y] = tformfwd(tForm, xI', yI');
    
    % d) calculate euclidean distance between transformed points and points
    % in I2
    
    xCoords = X - xI2';
    yCoords = Y - yI2';
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
    
    inX = zeros(size(matches,2), 1);
    inY = zeros(size(matches,2), 1);
    inX2 = zeros(size(matches,2), 1);
    inY2 = zeros(size(matches,2), 1);
    
    %Get all the inliers
    inX = xI' .* bestInliers;
    inY = yI' .* bestInliers;
    
    inX2 = xI2' .* bestInliers;
    inY2= yI2' .* bestInliers;
    
    try
    tFormBest = cp2tform([inX, inY],[inX2, inY2], 'projective');
    catch ME
        switch ME.identifier
            case 'images:cp2tform:rankError'
                warning('This shoudl not heppen with best inliers');
            otherwise
                warning('smtgh else fucked up');
        end
    end

%5. Transform first image into second image

sizeXY = [size(I2, 2), size(I2, 1)];
xData = [1, size(I2, 2)]; %
yData = [1, size(I2, 1)]; %
imageTransformed = imtransform(I, tFormBest, 'XData', xData, 'YData', yData, 'XYScale', sizeXY )





