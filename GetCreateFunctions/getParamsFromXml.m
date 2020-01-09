function [pixX, pixZ, pixY, ascanAve, bscanAve] = getParamsFromXml(xmlHeader, mode)
% This function extracts scan settings: x,y & z Pixel sizes, how many A 
% scan averaging and B scan avergaing were.
%
%USAGE:
%       [pixX, pixZ, pixY, ascanAve, bscanAve] = getParamsFromXml(xmlHeader, mode)
%INPUTS
%   - xmlHeader - xml file from xml_read function
%   - mode - 'speckVar', 'Bscan' or '3D' 
%OUTPUTS
%   - pixX - x pixel size (um)
%   - pixZ - z pixek size (um)
%   - pixY - y pixel size (um)
%   - ascanAve - how many A scan averages
%   - bscanAve - how many BscanAve
%Author: Orly Liba (~2017), edited by Ziv Lautman (January 2020)

pixX = xmlHeader.Image.PixelSpacing.SpacingX*1000;
pixZ = xmlHeader.Image.PixelSpacing.SpacingZ*1000;
switch mode
    case 'speckVar'
        bscanAve =  xmlHeader.Acquisition.SpeckleAveraging.SlowAxis;
        if  isfield(xmlHeader.Acquisition,'SpeckleAveraging') && isfield(xmlHeader.Acquisition.SpeckleAveraging,'FastAxis')
            ascanAve = xmlHeader.Acquisition.SpeckleAveraging.FastAxis;
        elseif isfield(xmlHeader.Acquisition,'IntensityAveraging') && isfield(xmlHeader.Acquisition.IntensityAveraging,'AScans')
            ascanAve = xmlHeader.Acquisition.IntensityAveraging.AScans;
        end        
        pixY = xmlHeader.Image.PixelSpacing.SpacingY*1000;
    case 'Bscan'        
        if isfield(xmlHeader.Image.SizePixel,'SizeY')
            bscanAve =  xmlHeader.Image.SizePixel.SizeY;
        else
            bscanAve = 1;
        end
        ascanAve = xmlHeader.Acquisition.IntensityAveraging.AScans;
        pixY = 0;
    case '3D'
        bscanAve = 1;
        ascanAve = xmlHeader.Acquisition.IntensityAveraging.AScans;
        pixY = xmlHeader.Image.PixelSpacing.SpacingY*1000;
end

