function plotAndSaveHSV(imgH, imgS, imgV, figVisEnable, titleStr, outputPath,fileType)
% This function converst HSV image format (imgH/S/V) to RGB format
%
%USAGE:
%       plotAndSaveHSV(imgH,imgS,imgV,~,~,outputPath,fileType)
%INPUTS
%   - imgH - Value from 0 to 1 that corresponds to the color’s position on a color wheel.
%            *This is usually particles we want to show in the image*
%   - imgS - Amount of hue or departure from neutral. 0 indicates a neutral shade,
%            whereas 1 indicates maximum saturation.
%            *This is usually the structure we want to emphasize in the
%            image*%            
%   - imgv - Maximum value [0-255] among the red, green, and blue components of a specific color.
%            * This is usually the background image*
%   - outputPath - where to save the image | 'F:\x\y...' 
%   - outputPath - which filetype to save | 'jpg','png'...
%OUTPUT
%    - RGB image
%
%Author: Orly Liba (~2017), edited by Ziv Lautman (July 2019)

imgV(imgV>255)= 255;
imwrite(uint8(hsv2rgb(cat(3,imgH,imgS,imgV))),[outputPath '.' fileType],fileType);