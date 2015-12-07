
I = imread('ass4_data/officeview1.jpg');
%save it just in case
originalimage = I;
figure(1); 
imshow(originalimage);

%convert to single so vl_sift takes it
I = im2single(rgb2gray(I));

%each column of F is a keypoint
%in the format [X;Y;Scale;Orientation]
%[F, D] = vl_sift(I);
%alternatively, threshold can be set to reduce the number of features
[F, D] = vl_sift(I, 'PeakThresh', 0.02);
%[F, D] = vl_sift(I, 'edgethresh', 3) ;

%plot all features
r1 = vl_plotframe(F);
r2 = vl_plotframe(F);
set(r1,'color','k','linewidth',3) ;
set(r2,'color','y','linewidth',2) ;

% plot 50 random features:
% perm = randperm(size(F,2)) ;
% sel = perm(1:50) ;
% h1 = vl_plotframe(F(:,sel)) ;
% h2 = vl_plotframe(F(:,sel)) ;
% set(h1,'color','k','linewidth',3) ;
% set(h2,'color','y','linewidth',2) ;
% h3 = vl_plotsiftdescriptor(D(:,sel),F(:,sel)) ;
% set(h3,'color','g') ;