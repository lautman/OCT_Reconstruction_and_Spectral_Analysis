function img = scale0To255(img)
% This function converts each pixel in img to [0-255] scale
%
%USAGE:
%       newImg = scale0To255(img)
%INPUTS
%   - img - image file
%OUTPUT
%    - img - image file in [0-255] scale
%
%Author: Orly Liba (~2017), edited by Ziv Lautman (July 2019)

img = img - min(img(:));
img = img/max(img(:));
img = img*255;