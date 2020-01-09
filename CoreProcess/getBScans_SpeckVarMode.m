function [xml_header, params, interfAll, avgLogBscan, linBscan, BscansCpx, apodization, timeStamp]...
    = getBScans_SpeckVarMode(fileAndPath,xml_header,chirpVect,dispComp,frameRange,filt)
% This function extract the Bscan interferograma, complex image,
% log(image) and more
%USAGE:
% [xml_header, params, interfAll, avgLogBscan, linBscan, BscansCpx, apodization, timeStamp]...
  %  = getBScans_SpeckVarMode(fileAndPath,xml_header,chirpVect,dispComp,frameRange,filt)
%INPUTS
%   - fileAndPath - full path to file
%   - xmlHeader - xml data
%   - chirp_vect - chirp file
%   - dispComp - dispersion parameter
%   - filt - hann window of the chirp file
%   - frameRange - holds the number of .data file (raw OCT file) that correspond to each bscan
%OUTPUTS
%   - xmlHeader - xml data
%   - params - parameter structure
%   - interfAll - interferograma of all the bscans of that frame
%   - avgLogBscan - 20* (Bscan Image (Intensity) after averaging all bscans)
%   - linBscan - Intensity value of each Bscan, after certain filter averaging
%   - BscanCpx - Complex Bscans
%   - apodization - apodization array
%   - timeStamp - when the Bscan was taken
%Author: Orly Liba (~2017), edited by Ziv Lautman (January 2020)

%image dimensions extract%
k_n = flipud(chirpVect);
N = length(k_n);
m = 0:N-1;
[K, M] = meshgrid(k_n,m(1:end/2));

%temp FFT variable
TempFFTM = exp(2*pi*1i.*M.*K/N);

%Y,X Pixel size extract%
params.size.x = xml_header.Image.SizePixel.SizeX;
if  isfield( xml_header.Image.SizePixel,'SizeY')
    params.size.y = xml_header.Image.SizePixel.SizeY;
else
    params.size.y = 1;
end

%Speckle Avergaring Setting%
if  isfield(xml_header.Acquisition,'SpeckleAveraging') && ...
        isfield(xml_header.Acquisition.SpeckleAveraging,'SlowAxis')
    params.slowAxisAvg = xml_header.Acquisition.SpeckleAveraging.SlowAxis;
else
    params.slowAxisAvg = 1;
end

if isempty(frameRange)
    numOfFrames = params.size.y*params.slowAxisAvg;
    frameRange = 1:numOfFrames;    
else
    numOfFrames = length(frameRange);
end
params.size.z = xml_header.Image.SizePixel.SizeZ;
spectralInd = 0;
for ind = 1:length(xml_header.DataFiles.DataFile)
    if strcmp(xml_header.DataFiles.DataFile(ind).CONTENT(1:13),'data\Spectral')
        spectralInd = ind;
    end
end
if spectralInd == 0
    error('ERROR: getBscan, missing raw spectral data in folder')
end

%Image parameters%
interf_size = xml_header.DataFiles.DataFile(spectralInd).ATTRIBUTE.SizeX;
apod_size = xml_header.DataFiles.DataFile(spectralInd).ATTRIBUTE.ApoRegionEnd0;
params.avg.spectra = xml_header.Acquisition.IntensityAveraging.Spectra;
% params.avg.ascan = xml_header.Acquisition.IntensityAveraging.AScans;

if  isfield(xml_header.Acquisition,'SpeckleAveraging') && isfield(xml_header.Acquisition.SpeckleAveraging,'FastAxis')
    params.avg.ascan = xml_header.Acquisition.SpeckleAveraging.FastAxis;
elseif isfield(xml_header.Acquisition,'IntensityAveraging') && isfield(xml_header.Acquisition.IntensityAveraging,'AScans')
    params.avg.ascan = xml_header.Acquisition.IntensityAveraging.AScans;
end

params.avg.bscan = xml_header.Acquisition.IntensityAveraging.BScans;
timeStamp = getTimeStamp(num2str(xml_header.Acquisition.Timestamp));
width_image = params.size.x;
ascan_ave = params.avg.ascan;
ascan_binning = params.avg.spectra;

%Create empty variables to save scan (reduces memory)%
BscansCpx=zeros(N/2,width_image*ascan_ave,numOfFrames);
linBscan=zeros(N/2,width_image,numOfFrames);
interfAll = zeros(N,width_image*ascan_ave,numOfFrames);
apodization = zeros(N,apod_size,numOfFrames);
if isempty(filt)
    filt = ones(N,width_image*ascan_ave);
else
    filt = repmat(filt,[1,width_image*ascan_ave]);
end

%dispersion compensation%
a2 = dispComp.a2; 
Phase = exp(1i*(a2*k_n'.^2/N))';
Phase = repmat(Phase,[1 width_image*ascan_ave 1]);

%Bscan core processing%
buffInd = 1;
avgLogBscan = 0;
for frameInd = frameRange
    %load Bscan
    fid = fopen([fileAndPath '/data/Spectral' num2str(frameInd-1) '.data']);
    temp = fread(fid,inf,'short');
    fclose(fid);
   
    %Extract interf, apodization
    size_arr = [N,interf_size];
    temp = temp(1:N*interf_size,:); % new addition, clipping temp to the expected size
    temp = reshape(temp,size_arr);    
    apodization(:,:,buffInd) = flipud(temp(:,1:apod_size));
    interf = flipud(temp(:,apod_size+1:end));    
    
    %FFT prep
    apod = mean(apodization(:,:,buffInd),2);    
    interf = interf - repmat(apod,1,width_image*ascan_ave*ascan_binning);   
    avgFilt = ones(1,ascan_binning)/(ascan_binning);
    interfAvg = filter2(avgFilt,interf);
    % interfAvg = interfAvg(:,max(1,floor((ascan_binning)/2)):ascan_binning:end);
    interfAvg = interfAvg(:,max(1,floor((ascan_binning)/2)):ascan_binning:end);        
    interfAll(:,:,buffInd) = interfAvg;
    % interfAll(:,:,frameInd) = interf;     
    interfAvg = interfAvg.*filt; % apply filt after filling up buffer    
    
    %process bscan, FFT
    BscansCpx(:,:,buffInd) = TempFFTM*(interfAvg.*Phase); 
    
    %Filtering
    avgFilt = ones(1,ascan_ave)/(ascan_ave);
    bscanAvg = filter2(avgFilt,abs(BscansCpx(:,:,buffInd)));
    bscanAvg = bscanAvg(:,max(1,floor((ascan_ave)/2)):ascan_ave:end,:);
    linBscan(:,:,buffInd) = bscanAvg;
    avgLogBscan = avgLogBscan + abs(bscanAvg);
    
    buffInd = buffInd + 1;
end

avgLogBscan = 20*log10(avgLogBscan/length(frameRange));

