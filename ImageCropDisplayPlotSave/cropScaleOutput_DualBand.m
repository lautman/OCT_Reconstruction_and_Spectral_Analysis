function [linBscanResize,diffImg,compoundImg,linBscan,speckVarNorm] = ...
    cropScaleOutput_DualBand(viewRange,trueToScale,reSizeMethod,pixX,pixZ,linBscan,diffImg,compoundImg,speckVarNorm)
% This function resizes linBscan, diffImg, compoundImg & speckVarNorm 
% either in x (if pixX>pixZ) or in z(if pixZ>pixX)
%
%USAGE:
%       [linBscanResize,diffImg,compoundImg,linBscan,speckVarNorm] = ...
%   cropScaleOutput_DualBand(viewRange,trueToScale,reSizeMethod,pixX,pixZ,linBscan ...
%   ,diffImg,compoundImg,speckVarNorm)
%
%INPUTS
%   - viewRange - defines the depth of view in the image to review
%   - trueToScale - 1 to scale the images, 0 not to
%   - reSizeMethod - Interpolation method available in imresize function
%   - pixX - size of pixel in x
%   - pixZ - size of pixel in z
%   - linBscan - absolute value of the complex image of each Bscan
%   - diffImg - image with the two bands (no substraction)
%   - compoundImg - image contains the substraction of the bands
%   - speckVarNorm - speckle variance normalization
%
%OUTPUT
%   - linBscanResize - resized image
%   - diffImg - resized image
%   - compoundImg - resized image
%   - linBscan- resized image
%   - speckVarNorm - resized image
%
%Author: Orly Liba (~2017), edited by Ziv Lautman (January 2020)

% Defining new variables for each image, based on the required ViewRange
linBscan = linBscan(viewRange,:,:);
linBscanResize = linBscan;
diffImg = diffImg(viewRange,:,:);
compoundImg = compoundImg(viewRange,:,:);
if ~isempty(speckVarNorm)
    speckVarNorm = speckVarNorm(viewRange,:,:);
end

% if scaling is required, scale !
if trueToScale
    if pixX > pixZ %resizing in the x direction
        linBscanResize = imresize(linBscan,[size(linBscan,1)...
            size(linBscan,2)*pixX/pixZ],reSizeMethod);
        diffImg = imresize(diffImg,[size(diffImg,1) ...
            size(diffImg,2)*pixX/pixZ],reSizeMethod);
        compoundImg = imresize(compoundImg,[size(compoundImg,1)...
            size(compoundImg,2)*pixX/pixZ],reSizeMethod);
        if ~isempty(speckVarNorm)
            speckVarNorm = imresize(speckVarNorm,[size(speckVarNorm,1)...
                size(speckVarNorm,2)*pixX/pixZ],reSizeMethod);
        end
    else % resizing in the z direction
        linBscanResize = imresize(linBscan,[size(linBscan,1)*pixZ/pixX...
            size(linBscan,2)],reSizeMethod);
        diffImg = imresize(diffImg,[size(diffImg,1)*pixZ/pixX...
            size(diffImg,2)],reSizeMethod);
        compoundImg = imresize(compoundImg,[size(compoundImg,1)*pixZ/pixX...
            size(compoundImg,2)],reSizeMethod);
        if ~isempty(speckVarNorm)
            speckVarNorm = imresize(speckVarNorm,...
                [size(speckVarNorm,1)*pixZ/pixX size(speckVarNorm,2)]...
                ,reSizeMethod);
        end
    end
end