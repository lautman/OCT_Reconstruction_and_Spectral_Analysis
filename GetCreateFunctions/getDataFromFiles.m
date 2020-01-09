function [interf, avgLogBscan, linBscan, BscanCpx, apodization,timeStamp] = ...
    getDataFromFiles(mode,fileAndPath,frameInd,outputFrameNum,xmlHeader,chirp_vect,...
    dispersionParams,filt,framesToAvg,bscanAve,additionalFrameAvgOverlap)
% This function runs the process to extract the Bscan interferograma, complex image,
% log(image) and more
%USAGE:
%[interf, avgLogBscan, linBscan, BscanCpx, apodization,timeStamp] = ...
 %   getDataFromFiles(mode,fileAndPath,frameInd,outputFrameNum,xmlHeader, ...
  %  chirp_vect,dispersionParams,filt,framesToAvg,bscanAve,additionalFrameAvgOverlap)
%INPUTS
%   - mode - 'speckVar', 'Bscan' or '3D' 
%   - fileAndPath - full path to file
%   - frameInd - which Bscan to process
%   - outputFrameNum - how many Bscans are there
%   - xmlHeader - xml data
%   - chirp_vect - chirp file
%   - dispersionParams - dispersion parameter
%   - filt - hann window of the chirp file
%   - framesToAvg - how many Bscans for the same image to average (if empty
%   average all bscans in the bscan image)
%   - bscanAve - how many bscan avegares were taken for each bscan
%   - additionalFrameAvgOverlap - any bscan overlap?
%OUTPUTS
%   - interf - interferograma of all the bscans of that frame
%   - avgLogBscan - 20* (Bscan Image (Intensity) after averaging all bscans)
%   - linBscan - Intensity value of each Bscan, after certain filter averaging
%   - BscanCpx - Complex Bscans
%   - apodization - apodization array
%   - timeStamp - when the Bscan was taken
%Author: Orly Liba (~2017), edited by Ziv Lautman (January 2020)

if outputFrameNum == 1
    frames2process = []; % process all frames
else %frames2process holds the number of .data file (raw OCT file) that correspond to each bscan
    switch mode
        case {'speckVar','3D'}            
            if frameInd == 1
                frames2process = 1 + ((frameInd-1)*framesToAvg)*bscanAve : (frameInd*framesToAvg + additionalFrameAvgOverlap)*bscanAve;
            elseif frameInd == outputFrameNum
                frames2process = 1 + ((frameInd-1)*framesToAvg - additionalFrameAvgOverlap)*bscanAve : frameInd*framesToAvg*bscanAve;
            else
                frames2process = 1 + ((frameInd-1)*framesToAvg - additionalFrameAvgOverlap)*bscanAve : ...
                    (frameInd*framesToAvg + additionalFrameAvgOverlap)*bscanAve;
            end
        case 'Bscan'
            frames2process = 1 + (frameInd-1)*framesToAvg : frameInd*framesToAvg;
    end
end

switch mode
    case {'speckVar','3D'}
        [~, ~, interf, avgLogBscan, linBscan, BscanCpx, apodization,timeStamp] = getBScans_SpeckVarMode(fileAndPath,xmlHeader,chirp_vect,dispersionParams,frames2process,filt);
    case 'Bscan'
        [~, ~, interf, avgLogBscan, linBscan, BscanCpx, apodization,timeStamp] = getBScans(fileAndPath,xmlHeader,chirp_vect,dispersionParams,frames2process,filt);
end