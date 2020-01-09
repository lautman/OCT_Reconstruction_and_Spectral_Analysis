function [scanMode,saveBuffers,savePng] = getScanMode(fileName)
if ~isempty(strfind(fileName,'Mode2D'))
    scanMode = 'Bscan';
    saveBuffers = 0; % needed for creating 3D and analyzing 2D
    savePng = 1; % needed for saving png figures during processing
elseif ~isempty(strfind(fileName,'ModeSpeckle'))
    scanMode = 'speckVar';
    saveBuffers = 1;
    savePng = 0; 
elseif ~isempty(strfind(fileName,'Mode3D'))
    scanMode = '3D';
    saveBuffers = 1; 
    savePng = 0; 
else
    error('Scan mode not detected in file name!');
end


    

