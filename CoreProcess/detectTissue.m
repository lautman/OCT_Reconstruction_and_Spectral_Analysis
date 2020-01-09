function [mask, noiseMask, artifactBoundry] = detectTissue(img)
% This function detects tissue location & boundary, and creates an adequate
% mask
%
%USAGE:
%       [mask, noiseMask, artifactBoundry] = detectTissue(img)
%INPUTS
%   - img - img needs to be double
%OUTPUT
%    - mask - a binary image marking the entire tissue (inside+boundary)
%    - noiseMask - a binary image marking everything besides mask
%    - artifactBoundry - how many rows from the top were marked as
%      articafts and were masked out (zero value). Default is 63.
%
%Author: Orly Liba (~2017), edited by Ziv Lautman (July 2019)

logIntensity = log(img);

% Create a binary mask (1 for pixel value that is larger than the mean,
% afterwards filling the holes in the binary mask 
mask = imfill(logIntensity > mean(logIntensity(:)),'holes');
noiseMask = mask<1; % everything that is not filled is noise

% Find all connected components in the binary mask (marks the tissue!)
% alongside noise
CC = bwconncomp(mask);

% numPixels saves the number of pixels each connected component in CC has
numPixels = cellfun(@numel,CC.PixelIdxList);

% idx saves the location of the largest component in terms
% of pixels (assumption, the largest is the tissue!) in numPixels
[~,idx] = max(numPixels);

% create a new mask based only on the largest components
iTemp = zeros(size(logIntensity,1), size(logIntensity,2));
iTemp(CC.PixelIdxList{idx})=1;
mask = iTemp;

% Remove artifact at the top of the image
artifactBound = 60; % Assuming the artifact is above this region
artifactBoundBuff = 3; % Assuming the artifact is above this region
artifactBound = find(sum(mask(1:artifactBound,:),2) == size(mask,2),1,'last');
mask(1:artifactBound+artifactBoundBuff,:) = 0;
artifactBoundry = artifactBound+artifactBoundBuff;