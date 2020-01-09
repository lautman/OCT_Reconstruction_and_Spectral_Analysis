%% This file define all parameters needed for reconstrcution, dual-band
% Analysis & Speckle Variance
% Written by Orly Liba (~2017), Edited by Ziv Lautman (January 2020)

%% System parameters
OCTSystem = 'Telesto'; % 'Ganymede'
version = 'V4'; % 'sdr'
scanMode = 'speckVar'; %'speckVar'; % 'Bscan', '3D'

%% I/O parameters
inputFolder = 'E:\BrainProject\Post-NewProtocol\12-3-2019\BrainFirstMouseVolume\';
outputFolder = 'E:\BrainProject\Post-NewProtocol\12-3-2019\trial2\';
balanceFuncName = 'balance.mat';
balanceFuncPath = [];
saveBuffers = 1; % Save raw data? needed for creating 3D and analyzing 2D
saveAlgoData = 0; % needed for creating algorithms for explaining the steps in the algorithm
savePng = 1; % needed for saving png figures during processing 1-yes, 0-no
DualBand = 1; %0; %Do you want to run DualBand processing? 1-yes, 0-no

%% Dual-Band: Spectral analysis parameters
if strcmp(OCTSystem,'Ganymede')
        spectParams.sizeHannBand = 400;
        spectParams.banInc = 50;%100;
        spectParams.start_band = 35;
        spectParams.end_band = 2035;
        spectParams.sizeHannBand1 = 1125;
        spectParams.sizeHannBand2 = 900;
        spectParams.start_band1 = 85;
        spectParams.end_band2 = 1948;   
        spectParams.WienerSpectralNormalizationDamping = 0.05;
    
elseif strcmp(OCTSystem,'Telesto')
        spectParams.sizeHannBand = 200;
        spectParams.banInc = 25;%100;
        spectParams.start_band = 1;
        spectParams.end_band = 1024;
        spectParams.start_band1 = 85;
        spectParams.end_band2 = 1948;   
        spectParams.sizeHannBand1 = 563;
        spectParams.sizeHannBand2 = 461;
        spectParams.start_band1 = 1;
        spectParams.end_band2 = 1024;
        spectParams.WienerSpectralNormalizationDamping = 0;
        
else
        error('ERROR: Wrong OCTSystem name! (spectralParams)')
end

spectParams.apodNormThr = 10; %lower boundary of apodization...
    %everything lower than 10 is set to 10 (not to divide by small numbers)
spectParams.wienerParam = 2;
spectParams.view = 0;
spectParams.GainB1 = 1;
spectParams.numOfBands = floor((spectParams.end_band - spectParams.start_band + 1 - spectParams.sizeHannBand)/spectParams.banInc)+1;
spectParams.medFiltBandsEnable = 0;
spectParams.medFiltSize = 4;   % median filter size
spectParams.WienerSpectralNormalization = 1; % if 0, truncated division is performed

%% Dispersion compensation parameters

if strcmp(OCTSystem,'Ganymede')
    dispersionParams.a2 = 21.5/1000;
    dispersionParams.b2 = 7.75/1000;
elseif strcmp(OCTSystem,'Telesto')
    dispersionParams.a2 = -8.8/1000;
    dispersionParams.b2 = 0/1000;
end

dispersionParams.a2Inc = 1/1000;
dispersionParams.b2Inc = 0.2/1000;
dispersionParams.MaxIterA = 30;
dispersionParams.MaxIterB = 1;
dispersionParams.framesLimit = 10;
dispersionParams.minXa = [];
dispersionParams.maxXa = [];
dispersionParams.minZa = 10;
dispersionParams.maxZa = 500;
dispersionParams.minZb = 40;
dispersionParams.maxZb = 700;
dispComp.a2 = dispersionParams.a2; %[]; % Leave empty ([]) to run dispersion comp. algo.
dispComp.b2 = dispersionParams.b2;

%% Balancing parameters

balanceEnable = 0; % 1 for performing balancing; 0 not performing
balanceFunc.balanceEnable = balanceEnable; 0;
balanceAsFirst = 0;
balanceFunc.func = []; %will be returned by calcBalanceFunc
balanceFunc.ROI = []; % [top bottom left right] - leave empty ...
                                    % to mark the tissue region
balanceFunc.noise = [0 0]; % 0 for manually selecting noise in image;...
                      % other values to state noise in [band1 band2]
balanceFunc.meanNoiseLevel = [0 0]; % unless not 0, will be returned by calcBalanceFunc
balanceFunc.power = 5;
balanceFunc.autoROI = 1; % 1 for automated tissue detection ROI; ...
                            % 0 - manually choosing
balanceFunc.exclude_vessels = 0;% 1 for images with vessels; 0 without vessels
balanceFunc.exclude_vessels_thr = 0.4; %when calculating the balancing it excludes ...
                                %vessels above certain threshold
balanceFunc.normThr = 0.2;
balanceFunc.stdSize = 5;
balanceFunc.figVisEnable = 'on';
% load([outputFolder 'spectral/' balanceFuncName])

%% Speckle variance

stdSize = 4;
stdLim = stdSize; % number of frames, under which std will not be performed
normThr = 700;

%% Display and scaling

figVisEnable = 'off'; % 'off' or 'on'
trueToScale = 0;
reSizeMethod = 'bilinear';
frames2Avg2D = []; % leave empty ([]) to average all frames in Bscan
viewRange = [1:512]; % before rescaling to TrueToScale
scanLabelVisEnable = 'off';
frames2Avg3D = 1; % averaging of frames at different locations
additionalFrameAvgOverlap = 0; % on every side

%% specific display parameters

diffScale = 2000; %2000; %specifies the nano-particles intense threshold
diffNormScale = 0.0002; %threshold for normalization
thrSpeckVar = 0.3; %threshold for angio SpeckVar
maxSpeckVar = 1.0; %threshold for angio SpeckVar

%% Configuration Code, loading chirp

% Add paths
addpath('C:\MATLAB_Share\Matlab files for all\');
addpath('C:\MATLAB_Share\Matlab files for all\xml_io_tools\');
addpath([pwd '/functions/']);

% Load version specific stuff
if strcmp(OCTSystem,'Ganymede')
    load FFTM_Ganymede
    load('C:\MATLAB_Share\Matlab files for all\Chirp_Ganymede.mat')
    filt = [];
elseif strcmp(OCTSystem,'Telesto')
    load FFTM_Telesto
    load('C:\MATLAB_Share\Matlab files for all\Chirp_Telesto.mat')
    filt = hann(length(chirp_vect));    
else
    error('ERROR: Wrong OCTSystem name! (spectralParams)')
end

if strcmp(version,'V4')
    filesToRun = dir([inputFolder]);
    fileStartInd = 3;
elseif strcmp(version,'sdr')
    error('ERROR: SDR not supported in this version. Please try an older version of the code.')
else
    error('ERROR: Wrong version! (runspectral)')
end

FFT_length = length(chirp_vect);
kVect = fliplr(chirp_vect');
k = fliplr([0:1:FFT_length-1]);

switch scanMode
    case {'speckVar','3D'}
        frames2Avg = frames2Avg3D;
    case 'Bscan'
        additionalFrameAvgOverlap = 0;
        frames2Avg = frames2Avg2D;
end
save('tempWorkSpace')