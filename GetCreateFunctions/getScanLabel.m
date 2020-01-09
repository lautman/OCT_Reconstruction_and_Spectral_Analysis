function scanLabel = getScanLabel(fileName,mode,scanLabelVisEnable)
% This function extract the scan name from the folder name
%
%USAGE:
%       scanLabel = getScanLabel(fileName,mode,scanLabelVisEnable)
%INPUTS
%   - fileName - entire folder name as appears on the drive
%   - mode - 'SpeckVar', '3D' or 'Bscan' so it could know how many
%            letters to ignore in folder name
%   - scanLabelVisEnable - 1 to print the scanLabel, 0 not to print
%Author: Orly Liba (~2017), edited by Ziv Lautman (January 2020)

switch mode
    case 'speckVar'
        scanLabel = fileName(1:end-12);
    case 'Bscan'
        scanLabel = fileName(1:end-7);
    case '3D'
        scanLabel = fileName(1:end-7);
end
scanLabel(strfind(scanLabel,'_')) = ' ';
scanLabel(strfind(scanLabel,'(')) = ''; 
scanLabel(strfind(scanLabel,')')) = '';
if strcmp(scanLabelVisEnable,'on')
    disp(scanLabel)
end