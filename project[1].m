% ----------------------------------------
%                                        |
%  Banana Ripeness Detection             |
%                                        |
%-----------------------------------------

% TEAM MEMBERS :-
% CHIU CHANG ZE [B032210240]
% MOHAMAD NAZRUN NAQIB BIN MUHAMAD NAZIR [B0322210361]
% MEGAT SAZRULHIZAL BIN MEGAT ABDUL LATIFF [B032210517]


%-----------------------------------------
% P R O G R A M    S T A R T             |
%-----------------------------------------

clear all, close all, clc

% Read the image of bananas
bananaImage = imread('test4.jpeg');

% Convert the image to the HSV color space
hsvImage = rgb2hsv(bananaImage);

% Extract the Hue, Saturation, and Value channels
hueChannel = hsvImage(:,:,1);
saturationChannel = hsvImage(:,:,2);
valueChannel = hsvImage(:,:,3);

% Thresholding for green color
% Adjust the Hue, Saturation, and Value ranges to detect green color
greenMask = (hueChannel >= 0.2 & hueChannel <= 0.45) & ...
            (saturationChannel >= 0.4 & saturationChannel <= 1) & ...
            (valueChannel >= 0.4 & valueChannel <= 1);

% Morphological operations to remove noise and fill gaps
% Open operation to remove small noise
greenMask = imopen(greenMask, strel('disk', 5));
% Close operation to fill small gaps
greenMask = imclose(greenMask, strel('disk', 10));
% Fill holes inside the green areas
greenMask = imfill(greenMask, 'holes');

% Calculate the percentage of green pixels in the image
greenPixelRatio = sum(greenMask(:)) / numel(greenMask);


% Refine the thresholding for yellow color
yellowMask = (hueChannel >= 0.1 & hueChannel <= 0.2) &...
(saturationChannel >= 0.5 & saturationChannel <= 1) &...
(valueChannel >= 0.5 & valueChannel <= 1);

% Morphological operations to remove noise and fill gaps
yellowMask = imopen(yellowMask, strel('disk', 5));  % Remove small noise
yellowMask = imclose(yellowMask, strel('disk', 10));  % Fill small gaps
yellowMask = imfill(yellowMask, 'holes');  % Fill holes

% Calculate the percentage of yellow pixels in the image
yellowPixelRatio = sum(yellowMask(:)) / numel(yellowMask);

% Thresholding for black color
% Black color range in HSV is characterized by low value and low saturation
blackMask = (valueChannel <= 0.3) & (saturationChannel <= 0.5);

% Morphological operations to remove noise and fill gaps
% Open operation to remove small noise
blackMask = imopen(blackMask, strel('disk', 5));
% Close operation to fill small gaps
blackMask = imclose(blackMask, strel('disk', 10));
% Fill holes inside the black areas
blackMask = imfill(blackMask, 'holes');

% Calculate the percentage of black pixels in the image
blackPixelRatio = sum(blackMask(:)) / numel(blackMask);

% Display the original image and the mask
figure;
subplot(2, 2, 1);
imshow(bananaImage);
title('Original Image');
subplot(2, 2, 2);
imshow(yellowMask);
eval(['title("Yellow Mask, PixelRatio=',num2str(yellowPixelRatio),'")']);
subplot(2,2,3)
imshow(greenMask), eval(['title("Green Mask, PixelRatio=',num2str(greenPixelRatio),'")']);
subplot(2,2,4)
imshow(blackMask), eval(['title("Black Mask, PixelRatio=',num2str(blackPixelRatio),'")']);

% Combine the masks
combinedMask = yellowMask | greenMask | blackMask;

% Label connected components in the binary image
cc = bwconncomp(combinedMask);

% Get the properties of each connected component
stats = regionprops(cc, 'BoundingBox');

% Initialize variables for the combined bounding box
minX = inf; minY = inf; maxX = -inf; maxY = -inf;

% Determine the combined bounding box coordinates
for k = 1:length(stats)
    bbox = stats(k).BoundingBox;
    minX = min(minX, bbox(1));
    minY = min(minY, bbox(2));
    maxX = max(maxX, bbox(1) + bbox(3));
    maxY = max(maxY, bbox(2) + bbox(4));
end

% Calculate the width and height of the combined bounding box
width = maxX - minX;
height = maxY - minY;

% Display the original image with the combined bounding box
figure;
imshow(bananaImage);
title('Original Image with Combined Bounding Box');
hold on;
rectangle('Position', [minX, minY, width, height], 'EdgeColor', 'r', 'LineWidth', 2);
hold off;

% Determine ripeness based on the color ratios
if (yellowPixelRatio < 0.01 || greenPixelRatio >= 0.2) && blackPixelRatio < 0.01
    ripeness = 'Unripe';
elseif yellowPixelRatio >= 0.05 && yellowPixelRatio <= 0.9
    ripeness = 'Ripe';
else
    ripeness = 'Overripe';
end

% Display the ripeness result on the image
text(minX, minY - 10, ripeness, 'Color', 'r', 'FontSize', 12, 'FontWeight', 'bold');

% Display the ripeness result in the command window
disp(['Ripeness: ', ripeness]);

