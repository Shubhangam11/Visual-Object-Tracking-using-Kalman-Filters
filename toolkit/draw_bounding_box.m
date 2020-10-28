function [] = draw_bounding_box(image,boundingBox)
%DRAW_BOUNDING_BOX Summary of this function goes here
%   Detailed explanation goes here
imshow(image);
hold on;
x = [boundingBox(1:2:end) boundingBox(1)];
y = [boundingBox(2:2:end) boundingBox(2)];
h = fill(x,y,'r');
set(h,'facealpha',.1)
hold off
end

