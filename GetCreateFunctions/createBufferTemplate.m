function Buff = createBufferTemplate(viewRange,nAscans, pixX,pixZ, trueToScale,reSizeMethod,outputFrameNum)
% This function creates empty image template to save scan details (buffer) 
% The function also correct image size based on pixel size (X,Z).
%USAGE:
%       Buff = createBufferTemplate(viewRange,nAscans, pixX, pixZ, trueToScale,reSizeMethod,outputFrameNum)
%INPUTS
%   - viewRange - how many pixels the image has
%   - nAscans - how many Ascans are there in the image
%   - pixX - x pixel size (um)
%   - pixZ - z pixel size (um)
%   - trueToScale - Should we scale?
%   - reSizeMethod - which method to resize the image
%   - outputFrameNum - how many Bscans/frames do we have
%OUTPUTS
%   - Buff - empty (zeros) buffer template array at the size of the number
%   of outputFrameNum (Bscans were taken in the volume).
%Author: Orly Liba (~2017), edited by Ziv Lautman (January 2020)

Buff = zeros(length(viewRange),nAscans);
if trueToScale
    if pixX > pixZ
        [Buff] = imresize(Buff,[size(Buff,1) size(Buff,2)*pixX/pixZ],reSizeMethod);
    else
        [Buff] = imresize(Buff,[size(Buff,1)*pixZ/pixX size(Buff,2)],reSizeMethod);
    end
end
Buff = repmat(Buff,[1,1,outputFrameNum]);