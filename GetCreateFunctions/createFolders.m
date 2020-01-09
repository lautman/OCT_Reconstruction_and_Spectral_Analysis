function [outputFolderResults,outputFolderSignal,outputFolderSpeckVar] =  createFolders(outputFolder)
% This function creates 3 new folders (Spectral,Signal,SpeckVar) in the
% main folder outputFolder
%
%USAGE:
%       [Spectral,Signal,SpeckVar] =  createFolders(outputFolder)
%INPUTS
%   - outputFolder - where shuold the scripts save the results
%                    for example: 'F:\Users\Ziv\Results\'
%Author: Orly Liba (~2017), edited by Ziv Lautman (January 2020)

outputFolderResults = [outputFolder 'spectral/'];
if ~isdir(outputFolderResults)
    mkdir(outputFolderResults)
end
if ~isdir([outputFolderResults '/angio'])
    mkdir([outputFolderResults '/angio'])
end
if ~isdir([outputFolderResults '/combined'])
    mkdir([outputFolderResults '/combined'])
end
if ~isdir([outputFolderResults '/combined_norm'])
    mkdir([outputFolderResults '/combined_norm'])
end
if ~isdir([outputFolderResults '/angio_norm'])
    mkdir([outputFolderResults '/angio_norm'])
end
if ~isdir([outputFolderResults '/struct'])
    mkdir([outputFolderResults '/struct'])
end
if ~isdir([outputFolderResults '/structnorm'])
    mkdir([outputFolderResults '/structnorm'])
end
outputDisp = [outputFolder 'dispersion/'];
if ~isdir(outputDisp)
    mkdir(outputDisp)
end
outputFolderSignal = [outputFolder 'signal/'];
if ~isdir(outputFolderSignal)
    mkdir(outputFolderSignal)
end
outputFolderSpeckVar  = [outputFolder 'speckVar/'];
if ~isdir(outputFolderSpeckVar)
    mkdir(outputFolderSpeckVar)
end