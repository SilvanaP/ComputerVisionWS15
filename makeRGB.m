function [ RGB ] = makeRGB( R, G, B )
%CREATERGB Composes full RGB image from three Prokudin-Gorskii images
% Input: Paths to files

%read in images
red = imread(R);
green = imread(G);
blue = imread(B);

maxCorr = 0;
maxCorrRB = 0;
bestXdisp = 0;
bestXdispRB = 0;
bestYdisp = 0;
bestYdispRB = 0;

%copy green and blue, so we can shift them 
greenshiftX = green;
blueshiftX = blue;

%start doing correlation
for x = -15:15
    for y = -15:15
        
        %do RG, RB correlation at same time to be more efficient
        corr_R_G = corr2(circshift(greenshiftX, [y, x]), red);
        corr_R_B = corr2(circshift(blueshiftX, [y, x]), red);
        
            %Keep track of best correlation value and best displacement
            if corr_R_G > maxCorr
                maxCorr = corr_R_G;
                bestXdisp = x;
                bestYdisp = y;
            end

            if corr_R_B > maxCorrRB
                maxCorrRB = corr_R_B;
                bestXdispRB = x;
                bestYdispRB = y;
            end
    end
end

%now shift the original blue, green channels by the best matching x,y
greenXaligned = circshift(green, [bestYdisp,bestXdisp]);  
blueXaligned = circshift(blue, [bestYdispRB,bestXdispRB]); 

%Result after matching
RGB = cat(3, red, greenXaligned, blueXaligned);
imshow(RGB);

%result with no matching performed:
%origRGB = cat(3, red, green, blue);

end

