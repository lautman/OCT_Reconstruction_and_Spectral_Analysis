function saveAllFigs(h,pathToSave)
% This function saves all figures saved under h variable in pathToSave
% location
%
%USAGE:
%       saveAllFigs(Figures,pathToSave)
%INPUTS
%   - Figures - figures variable
%   - pathToSave - 'F:\...' path format
%OUTPUT
%    - saves all figures in h to pathToSave
%
%Author: Orly Liba (~2017), edited by Ziv Lautman (July 2019)
if ~isempty(h)
    for indFig = 1:length(h)
        figure(h(indFig))
        saveas(h(indFig),[pathToSave num2str(indFig)],'png');
    end
end