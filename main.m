% Matlab R2013a

clc; clear all; close all;

%% Settings
Threshold = 1/2000;
sigma = 1;
k = 0.12;

%% Load image
IMG = imread('stars.jpg');                  % read source JPEG image into 3D array
IMG_hsv = rgb2hsv(IMG);                     % convert image from RGB to HSV

IMG_hsv_value = IMG_hsv(:,:,3);             % gray scale value
[Ix, Iy] = gradient(IMG_hsv_value);         % Shifts

Ix2 = Ix.^2;
Iy2 = Iy.^2;
Ixy = Ix.*Iy;

%% Window Function
windowsize = 3*sigma;
[Wx, Wy] = meshgrid(-windowsize : windowsize, -windowsize : windowsize);
w = exp(-(Wx .^ 2 + Wy .^ 2) / (2 * sigma ^ 2));

%% Convolutions
A = conv2(w, Ix2);
B = conv2(w, Iy2);
C = conv2(w, Ixy);

[x,y] = size(IMG_hsv_value);            % x,y is the width and length of the image
R = zeros(x, y);                        % Initialize Corner response R

%% Loop for each pixel
for xRows = 1:x
    for yColumns = 1:y  
        M = [A(xRows, yColumns), C(xRows, yColumns); C(xRows, yColumns), B(xRows, yColumns)];   % get M at each pixel
        R(xRows,yColumns) = det(M) - k * (trace(M) ^ 2);                                        % compute R at each pixel
    end
end

IMG_result = IMG;
IMG_map = zeros(x, y, 3);                                   % Corner response map

for xRows = 1:x
    for yColumns = 1:y
        if ((R(xRows, yColumns) > Threshold))               % For those corner response R larger than Threshold
        	IMG_result(xRows, yColumns, :) = [0, 0, 255];   % Mark corner point by blue
        	IMG_map(xRows, yColumns, :) = 255;              % Mark corner point by white
        end
    end
end

%% Show results
figure('Name', 'Corner Detected');  
imshow(IMG_result);

figure('Name', 'Corner Response Map');
imshow(IMG_map);