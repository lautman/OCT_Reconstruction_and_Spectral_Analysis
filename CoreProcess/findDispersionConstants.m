function [a2, b2] = findDispersionConstants(k, apodization, interf, ascanAve, outputFolder,params,spectParams,balanceFunc)
% This function optimize dispersion compensation constant
%USAGE:
% [a2, b2] = findDispersionConstants(k, apodization, interf,...
     % ascanAve, outputFolder,params,spectParams,balanceFunc)
%INPUTS
%   - k chirp_vect
%   - apodization - apodization interf 
%   - interf - Bscans interf
%   - ascanAve - how may A scan averages wre taken
%   - outputFolder - where the data is saved? 
%   - params - dispersion parameter structure
%   - spectParams - spectral parameter structure
%   - balanceFunc - balance function parameter structure
%OUTPUTS
%   - a2 - dispersion constant 1
%   - b2 - dispersion constant 2
%Author: Orly Liba (~2017), edited by Ziv Lautman (January 2020)

nFrames = size(interf,3);
nAscans = size(interf,2);
FFTLength = length(k);
balanceEnable = balanceFunc.balanceEnable;

% Dispersion parameters
a2Inc = params.a2Inc; b2Inc = params.b2Inc;
a2 = params.a2; b2 = params.b2;
MaxIterA = params.MaxIterA; MaxIterB = params.MaxIterB;
framesLimit = min(params.framesLimit,nFrames); % number of frames to process for rapid optimization
minZa = params.minZa; maxZa = params.maxZa;
minXa = params.minXa; maxXa = params.maxXa;
minZb = params.minZb; maxZb = params.maxZb;
if (~isempty(minXa)) && (~isempty(minXa))
    interf = interf(:,1+ascanAve*(minXa-1):ascanAve*maxXa,:);
end

interf = interf(:,:,floor((nFrames-framesLimit)/2)+1:floor((nFrames+framesLimit)/2));
 
% Search dispersion compensation
chdir = 1;
a = [];
Metric = [];
for iter = 1:MaxIterA
    % determine step
    if iter == 1
        % do nothing, a2 = initial value
    elseif iter == 2
        a2 = a2 + (-1)^chdir*a2Inc;
    else
        if Metric(end) > Metric(end-1) % degradation
            chdir = chdir + 1;
        end
        a2 = a2 + (-1)^chdir*a2Inc/chdir;
    end
    a = [a a2];
    dispComp.a2 = a2;
    dispComp.b2 = b2;
    [BscanCpx,~, band1spatial, band2spatial, ~, ~] = calcSpectral2(k, apodization, interf, ascanAve, dispComp, spectParams, nFrames);
    if ~isempty(balanceFunc.func)
        [band1spatial,band2spatial,balanceFunc, h] = balanceBands(balanceEnable,band1spatial,band2spatial,balanceFunc);
    end
    band1spatial = medfilt2(mean(abs(band1spatial),3),[4 4],'symmetric');
    band2spatial = medfilt2(mean(abs(band2spatial),3),[4 4],'symmetric');        
    Metric = [Metric sum(sum(abs(band1spatial(minZa:maxZa,:)-band2spatial(minZa:maxZa,:))))];
    
    if iter == 1
        if ~isempty(outputFolder)
            figure; imagesc(log(mean(abs(BscanCpx),3))); colormap gray
            title(['Dispersion compensation, a_2=' num2str(a2) ', b_2=' num2str(b2) ])
            saveas(gca,[outputFolder '_initial_bscan'],'png');
            figure; imagesc(mean(abs(band1spatial),3)-mean(abs(band2spatial),3)); caxis([-1 1]);
            title(['Dispersion compensation, a_2=' num2str(a2) ', b_2=' num2str(b2) ])
            saveas(gca,[outputFolder '_diff'],'png');
        end
    end
end
if ~isempty(outputFolder)
    figure; plotyy(1:iter,a,1:iter,Metric)
    title('finding a')
    saveas(gca,[outputFolder '_a_calib'],'png');
    figure; imagesc(log(mean(abs(BscanCpx),3))); colormap gray
    title(['Dispersion compensation, a_2=' num2str(a2) ', b_2=' num2str(b2) ])
    saveas(gca,[outputFolder '_bscan_a_calib'],'png');
    figure; imagesc(mean(abs(band1spatial),3)-mean(abs(band2spatial),3)); caxis([-1 1]);
    title(['Dispersion compensation, a_2=' num2str(a2) ', b_2=' num2str(b2) ])
    saveas(gca,[outputFolder '_diff_a_calib'],'png');
end

close all









