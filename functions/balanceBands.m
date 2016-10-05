function [band1spatial,band2spatial,balanceFunc, h] = balanceBands(balanceEnable,band1spatial,band2spatial,balanceFunc)

nFrames = size(band1spatial,3);
nAscans = size(band1spatial,2);

h = [];
if balanceEnable
    if isempty(balanceFunc.func) || isempty(balanceFunc.ROI)  
        if (balanceFunc.exclude_vessels) && (size(band1spatial,3) >= balanceFunc.stdSize)
            speckVar = speckleVariance(band1spatial+band1spatial,balanceFunc.normThr,balanceFunc.stdSize);
        else
            speckVar = [];
        end
        [balanceFunc, h] = calcBalanceFunc(medfilt2(mean(band1spatial,3),[4 4],'symmetric'),...
                                           medfilt2(mean(band2spatial,3),[4 4],'symmetric'),speckVar,balanceFunc);
    end
    ROI = balanceFunc.ROI;
    
%     band1spatial = band1spatial - balanceFunc.meanNoiseLevel(1);
%     band1spatial(band1spatial<0) = min(band1spatial(band1spatial(:)>0));
%     band2spatial = band2spatial - balanceFunc.meanNoiseLevel(2);    
%     band2spatial(band2spatial < 0) = min(band2spatial(band2spatial(:)>0));
    
    band1spatial = band1spatial - balanceFunc.meanNoiseLevel(1);
    band1spatial(band1spatial<0) = 0;
    band2spatial = band2spatial - balanceFunc.meanNoiseLevel(2);    
    band2spatial(band2spatial < 0) = 0;
    
    band1spatialCrop = band1spatial(ROI(1):ROI(2),:,:);
    band1spatialCrop = band1spatialCrop./repmat(balanceFunc.func(:,1),[1 nAscans nFrames]);
    band2spatialCrop = band2spatial(ROI(1):ROI(2),:,:);
    band2spatialCrop = band2spatialCrop./repmat(balanceFunc.func(:,2),[1 nAscans nFrames]);
    
    band1spatial(ROI(1):ROI(2),:,:) = band1spatialCrop;
    band2spatial(ROI(1):ROI(2),:,:) = band2spatialCrop;
    
    band1spatial = band1spatial + mean(balanceFunc.meanNoiseLevel);
    band2spatial = band2spatial + mean(balanceFunc.meanNoiseLevel);
    
else
    band1spatial = band1spatial - balanceFunc.meanNoiseLevel(1);
    band1spatial(band1spatial<0) = 0;%min(band1spatial(band1spatial(:)>0));
    band2spatial = band2spatial - balanceFunc.meanNoiseLevel(2);
    band2spatial(band2spatial<0) = 0;%min(band2spatial(band2spatial(:)>0));
    band1spatial = band1spatial + mean(balanceFunc.meanNoiseLevel);
    band2spatial = band2spatial + mean(balanceFunc.meanNoiseLevel);
end