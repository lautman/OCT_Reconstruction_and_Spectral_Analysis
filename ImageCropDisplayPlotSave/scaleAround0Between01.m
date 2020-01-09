function scaledImg = scaleAround0Between01(Img,ext)
% This function converts each pixel in Img to [0-1] scale
%
%USAGE:
%       scaledImg = scaleAround0Between01(Img,ext)
%INPUTS
%   - Img - image file (double)
%   - ext - scale parameter (min & max threshold)
%OUTPUT
%    - scaledImg - image scaled between 0 to 1
%
%Author: Orly Liba (~2017), edited by Ziv Lautman (July 2019)

% set maximum values in Img to ext
Img(Img > ext) = ext;

% set minimum values in Img to ext
Img(Img < -ext) = -ext;

% Increase all values in Img by ext
% (set all minimum values to zero, maximum to 2*ext)
scaledImg = Img + ext;

% [0-1] scaling
scaledImg = scaledImg/ext/2;
