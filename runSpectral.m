clc ;clear; close all

%%Run parameter file
run runSpectralParams
fprintf('%s Completed runSpectralParams\n',datestr(datetime));

%% Create main folder Spectral (outputFolderResults)
%Sub folders: angio, combined, combined_norm, angio_norm, struct, structnorm, dispersion, signal (outputFolderSignal)
% and speckVar (outputFolderSpeckVar)

[outputFolderResults,outputFolderSignal,outputFolderSpeckVar] =  createFolders(outputFolder);

%% Main

for fileInd = fileStartInd:1:length(filesToRun)
    % this section generate the variables signalBuff,bandBuff,
    % rawSpeckVarBuff,diffBuff,speckVarBuff,diffNormBuff as a zeros matrix
        
    fileName = filesToRun(fileInd).name;
    fileAndPath = [inputFolder fileName];
    fprintf('%s Starting file "%s" number: %d/%d (%.1f%%)\n',datestr(datetime),...
        fileName,fileInd-2,length(filesToRun)-2,100*(fileInd-2)/(length(filesToRun)-2));

    scanLabel = getScanLabel(fileName,scanMode,scanLabelVisEnable); 
    xmlHeader = xml_read([fileAndPath '\Header.xml']);
    [pixX, pixZ, pixY, ascanAve, bscanAve] = getParamsFromXml(xmlHeader,scanMode); 
    outputFrameNum = getFrameNum(xmlHeader,frames2Avg); 
    fprintf('%s Done extracting xml file\n',datestr(datetime));  
        
    % creates a zeros matrix based on dimenstion definition to save memory %   
    Buff = double(createBufferTemplate(viewRange, xmlHeader.Image.SizePixel.SizeX, pixX, pixZ, ...
        trueToScale, reSizeMethod, outputFrameNum)); 
    [signalBuff,bandBuff,rawSpeckVarBuff,diffBuff,speckVarBuff,diffNormBuff] = deal(Buff); 
    clear Buff
    
    %% sub main - Extract scan data, process and save %
    Bscancount = 1;
    for frameInd = [round(outputFrameNum/2):outputFrameNum 1:round(outputFrameNum/2)-1] 
        fprintf('%s processing Bscan number: %d/%d)\n',datestr(datetime),...
        Bscancount,outputFrameNum);
          
        % Extract data (interf, linBscan, etc.) from scans
        [interf, avgLogBscan, linBscan, ~, apodization,timeStamp] = ...
            getDataFromFiles(scanMode,fileAndPath,frameInd,outputFrameNum,xmlHeader,chirp_vect, ...
            dispersionParams,filt,frames2Avg,bscanAve,additionalFrameAvgOverlap);
        scanName = [scanLabel ' ' num2str(frameInd) ' ' datestr(datenum(timeStamp),30)];
        apodization = squeeze(mean(apodization,2));

        % Find dispersion coefficients
        % if needed, load balance function for improving the dispersion algorithm
        % load([outputFolderResults 'balance.mat']); 
        if isempty(dispComp.a2) || isempty(dispComp.b2)
            [a2, b2] = findDispersionConstants(kVect, apodization, interf, ascanAve, ...
                [outputFolder '/dispersion/'], dispersionParams,spectParams,balanceFunc);
            dispComp.a2 = a2;
            dispComp.b2 = b2;
            dispersionParams.a2 = a2;
            dispersionParams.b2 = b2;
            % Run get data again, this time with dispersion compensation
            [interf, avgLogBscan, linBscan, ~, apodization,timeStamp] = ...
            getDataFromFiles(scanMode,fileAndPath,frameInd,outputFrameNum,xmlHeader,...
            chirp_vect,dispersionParams,filt,frames2Avg,bscanAve,additionalFrameAvgOverlap);
        end

        % calculate SpeckleVariance
        if size(linBscan,3) >= stdLim
            [speckVarNorm] = speckleVariance(linBscan,normThr,stdSize);
        else
            speckVarNorm = [];
        end
        
        % SaveAlgoData %
        if saveAlgoData && strcmp(scanMode,'Bscan')
            saveAlgoDataPath = [outputFolderResults scanName '_Algo_'];
        else
            saveAlgoDataPath = [];
        end
        
        %Main DualBand Analysis %
        if DualBand
            [BscanCpx,BscanCpxNorm, band1spatial, band2spatial, compoundImg, diffImg, balanceFunc, h] =...
                spectralAnalysis(kVect, apodization, interf, ascanAve, dispComp, spectParams, ...
                balanceEnable, balanceFunc, size(interf,3), saveAlgoDataPath);
            save([outputFolderResults balanceFuncName],'balanceFunc')
            fprintf('%s Done DualBand Analysis\n',datestr(datetime));  
        end
        if ~balanceAsFirst
            balanceFunc.func = []; %balanceFunc.ROI = [];
        end
        
        %saves all figures in h to the folder%
        if DualBand && savePng 
            saveAllFigs(h,[outputFolderResults datestr(datenum(timeStamp),30) ...
                '_' scanName '_spectralSaves' '_' num2str(frameInd) '_']); 
        end

        % In order to see particles of larger WL in Telesto with better  contrast (green color)
        if DualBand && strcmp(OCTSystem,'Telesto')
            diffImg = -diffImg;
        end
        
        %Resize Images%
        if DualBand
            [linBscanResize,diffImg,compoundImg,~,speckVarNorm] = cropScaleOutput_DualBand(viewRange, ...
                trueToScale,reSizeMethod,pixX,pixZ,linBscan,diffImg,compoundImg,speckVarNorm);
        else
            [linBscanResize,linBscan,speckVarNorm] = cropScaleOutput(viewRange,...
                trueToScale,reSizeMethod,pixX,pixZ,linBscan,speckVarNorm);
        end
        
        % First Save: Intensity in Signal folder %
        if savePng
            plotAndSaveImg(log(mean(linBscanResize,3)), figVisEnable, [scanName ' log Bscan'], ...
                'gray', [], [outputFolderSignal datestr(datenum(timeStamp),30) '_' scanName ...
                '_Bscan_log_scale' num2str(frameInd)], 'png'); 
        end
        signalBuff(:,:,frameInd) = uint8(scale0To255(log(mean(linBscanResize,3))));

        % Second Save: Spectral signal from particles in spctral/struct
        % folder
        if DualBand && savePng
            plotAndSaveHSV(scaleAround0Between01(diffImg,diffScale), ...
                ones(size(diffImg)), 3*scale0To255(log(compoundImg)), figVisEnable, ...
                [scanName ' spectral analysis, structure'], [outputFolderResults '/struct/' ...
                datestr(datenum(timeStamp),30) '_' scanName '_structure' num2str(frameInd)],'png');
        end
        
        if DualBand
            diffBuff(:,:,frameInd) = uint8(255*scaleAround0Between01(diffImg,diffScale));
        end
        
        % if there are vessels calcualte speckle varaiance
        if ~isempty(speckVarNorm)
            rawSpeckVarBuff(:,:,frameInd) = uint8(scale0To255(speckVarNorm));
        % Third Save: SpeckleVariance in SpeckVar folder   
            if savePng
                plotAndSaveImg(speckVarNorm, figVisEnable, [scanName ...
                    ' normalized speckle variance'], 'jet', [0 0.7], [outputFolderSpeckVar ...
                    datestr(datenum(timeStamp),30) '_' scanName '_normalized_speckleVar'], 'png');
            end
            
            %Additional gating for SpeckleVariance%
            speckVarNormScaled = speckVarNorm - thrSpeckVar;
            speckVarNormScaled(speckVarNormScaled < 0) = 0;
            speckVarNormScaled(speckVarNormScaled > maxSpeckVar) = maxSpeckVar;
            speckVarNormScaled = scale0To255(speckVarNormScaled);
            
            %Forth Save: SpeckleVariance with spectral signal (no tissue)
            % in Spectral/Angio folder
            if DualBand && savePng 
                plotAndSaveHSV(scaleAround0Between01(diffImg,diffScale), ...
                    ones(size(diffImg)), speckVarNormScaled, figVisEnable, ...
                    [scanName ' spectral analysis, angio gated'], [outputFolderResults '/angio/' ...
                    datestr(datenum(timeStamp),30) '_' scanName '_angio_linear' num2str(frameInd)],'png');
            end
            speckVarBuff(:,:,frameInd) = uint8(speckVarNormScaled);
            
            % Fifth Save: SpeckleVariance with spectral signal and tissue
            % saves in Spectral/combined folder
            if DualBand
            plotAndSaveHSV(scaleAround0Between01(diffImg,diffScale), ...
                speckVarNormScaled/255, scale0To255(log(mean(abs(linBscanResize),3))),...
                figVisEnable, [scanName ' spectral analysis, combined angio gated'],...
                [outputFolderResults '/combined/' datestr(datenum(timeStamp),30) '_' ...
                scanName '_combined' num2str(frameInd)],'png');
            end
        end

        % Buffer saving: Spectral Siganl with thresholding
          if DualBand
            thr = 0.1;
            norm = compoundImg;
            norm(norm<thr) = thr;
            tempDiffNorm = (scaleAround0Between01(diffImg,diffScale)-1/2)./norm;

            % Sixth Save: Spectral Siganl with thresholding in 
            % spctral/structnorm folder
            if savePng
                plotAndSaveHSV(scaleAround0Between01(tempDiffNorm,diffNormScale), ...
                    ones(size(diffImg)), 3*scale0To255(log(compoundImg)), figVisEnable, ...
                    [scanName ' spectral analysis, diff normalized, structure'], ...
                    [outputFolderResults '/structnorm/' datestr(datenum(timeStamp),30) '_' ...
                    scanName '_structure_norm' num2str(frameInd)],'png'); 
            end
            diffNormBuff(:,:,frameInd) = uint8(255*scaleAround0Between01(tempDiffNorm,diffNormScale));

            % Seventh Save: Spectral Signal with thresholding, Speckle Variance and tissue
            %  in Spectral/combine_norm & Spectral/angio_norm folders
            if (~isempty(speckVarNorm)) && savePng 
                plotAndSaveHSV(scaleAround0Between01(tempDiffNorm,diffNormScale), ...
                    speckVarNormScaled/255, scale0To255(log(mean(abs(linBscanResize),3))), ...
                    figVisEnable, [scanName ' spectral analysis, diff normalized, combined'], ...
                    [outputFolderResults '/combined_norm/' datestr(datenum(timeStamp),30) '_' ...
                    scanName '_combined_norm' num2str(frameInd)],'png');
                
                plotAndSaveHSV(scaleAround0Between01(tempDiffNorm,diffNormScale), ones(size(diffImg)), ...
                    speckVarNormScaled, figVisEnable, [scanName ' spectral analysis, diff normalized, angio'], ...
                    [outputFolderResults '/angio_norm/' scanName '_angio_norm' num2str(frameInd)],'png');
            end
          end
        close all
        Bscancount=Bscancount+1;
    end % end of sub-main for loop
 
%% Buffer save
    
    if saveBuffers
       save([outputFolderResults datestr(datenum(timeStamp),30) '_' scanName '_Buffer'],...
       'signalBuff','diffBuff','speckVarBuff','diffNormBuff','xmlHeader','rawSpeckVarBuff');
    
    end
end % end of Main for loop

%% Clearing
if exist('tempWorkSpace.mat', 'file')==2
    delete('tempWorkSpace')
end

fprintf('%s Completed runSpectral, Bye Bye!\n',datestr(datetime));
