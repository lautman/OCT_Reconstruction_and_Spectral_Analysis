function [BscanCpx,BscanCpxNorm, band1spatial, band2spatial, compoundImg, diffImg, balanceFunc, h] =...
    spectralAnalysis(k, apodization, interf, ascanAve, dispComp, params, balanceEnable, balanceFunc, frames2Avg, saveAlgoDataPath)
%%This function is the main DualBand method, it performs bands seperation,
%%balancing and normalization
%
%USAGE:
% [BscanCpx,BscanCpxNorm, band1spatial, band2spatial, compoundImg, diffImg, balanceFunc, h] =...
   % spectralAnalysis(k, apodization, interf, ascanAve, dispComp, params, balanceEnable, balanceFunc, frames2Avg, saveAlgoDataPath)
%
% INPUTS:
%   - k - chirp vector 
%   - apodization - OCT baseline intensity, without the tissue scatterers
%   - interf - interferogram data, apodization corrected.
%   - ascanAve - how many A scan averages were taken
%   - dispComp - dispersion compensation constants
%   - params -  Spectral params strucutre
%   - balanceEnable - 1 to balance the bands  
%   - balanceFunc - balance strcuture 
%   - frames2Avg - [] for 2D, 6 for 3D
%   - saveAlgoDataPath - save raw algo data? 
% OUTPUTS:
%   - BscanCpx - complex Bscan 
%   - BscanCpxNorm - complex Bscan normalized after Wiener 
%   - band1spatial - intensity values of band1
%   - band2spatial - intensity values of band2
%   - diffImg - difference between band1spatial to band2spatial
%   - compoundImg - band1spatial + band2spatial
%   - balanceFunc - balance strcuture updated
%   - h - set of figures showing the balancing effect
%Author: Orly Liba (~2017), edited by Ziv Lautman (July 2019)

nFrames = size(interf,3);
nAscans = size(interf,2);
FFTLength = length(k);

% Run the DubalBand calculation
[BscanCpx,BscanCpxNorm, band1spatial, band2spatial, ~, ~] = calcSpectral(k,...
    apodization, interf, ascanAve, dispComp, params, frames2Avg, saveAlgoDataPath);

if params.view
    figure; imagesc(log(mean(abs(BscanCpxNorm),3))); colormap gray
    figure; imagesc(mean(abs(band1spatial),3)-mean(abs(band2spatial),3)); caxis([-1 1]);
end

%Balance the bands
[band1spatial,band2spatial,balanceFunc, h] = balanceBands(balanceEnable,band1spatial,band2spatial,balanceFunc);
band1spatial(band1spatial<0) = 0;
band2spatial(band2spatial<0) = 0;

[diffImg, compoundImg] = deal(zeros(FFTLength/2,nAscans/ascanAve,floor(nFrames/frames2Avg)));
for ind = 1:floor(nFrames/frames2Avg)
    band1Temp = mean(band1spatial(:,:,1+frames2Avg*(ind-1):frames2Avg*ind),3);
    band2Temp = mean(band2spatial(:,:,1+frames2Avg*(ind-1):frames2Avg*ind),3);
    
    if params.medFiltBandsEnable
        band1Temp = medfilt2(band1Temp,[params.medFiltSize params.medFiltSize],'symmetric');
        band2Temp = medfilt2(band2Temp,[params.medFiltSize params.medFiltSize],'symmetric');
    end
    
    diffImg(:,:,ind) = params.GainB1*band1Temp - band2Temp; % longWL-shortWL
    compoundImg(:,:,ind) = params.GainB1*band1Temp + band2Temp;
end
% band1 = high WL (red) , band2 = low WL (blue)

%%
if ~isempty(saveAlgoDataPath)    
    band1AfterBalance  = mean(band1Temp,3);
    band2AfterBalance  = mean(band2Temp,3); 
    save([saveAlgoDataPath 'after_balance'],'band1AfterBalance','band2AfterBalance')
end

