function plotAndSaveImg(Img, figVisEnable, titleStr, colorMapOption, caxisRange, outputPath,fileType)
% This function converts each pixel in img to [0-255] scale
%
%USAGE:
%       plotAndSaveImg(Img, figVisEnable, titleStr, colorMapOption, caxisRange, outputPath,fileType)
%INPUTS
%   - img - image file
%
%Author: Orly Liba (~2017), edited by Ziv Lautman (July 2019)

Img = Img - min(Img(:));
Img = Img/max(Img(:))*255;
Img = uint8(Img);
imwrite(Img,[outputPath '.' fileType],fileType);

