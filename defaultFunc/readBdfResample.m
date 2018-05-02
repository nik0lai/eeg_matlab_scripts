function readBdfResample(newSrate, bdfFiles, bdfPath, setPath)
function [resampTrack] = readBdfResample(newSrate, bdfFiles, bdfPath, setPath)
% READBDFRESAMPLE reads bdf files (pop_biosig), change the sample rate,
% export .set file.
% INPUT (* = required)
%       *newSrate: a number indicating the new sampling rate. If the number
%                  is bigger than the current sampling rate a warning will 
%                  appear.
%       bdfFiles: a cell with bdf file names. If empty it will look for all
%                 bdf files within bdfFiles
%       *bdfPath: path to folder containing bdf files
%       *setPath: path to folder where set files will be write

% If no bdfFiles arg passed, get bdf files from bdfPath
if isempty(bdfFiles)    
    bdfFiles = dir(fullfile(bdfPath, '/*.bdf'));
    bdfFiles = {bdfFiles.name};
end

if ~size(bdfFiles, 2) > 0
    
    error(['Are you messing with me? No bdf files within ' bdfPath])
    
elseif size(bdfFiles, 2) > 0
    
    for i = 1:size(bdfFiles, 2)
        
    % table to track information
    srateCols   = array2table(zeros(size(bdfFiles, 2), 4),'VariableNames', {'oldRate', 'newRate', 'channNum', 'eegDur'});    
    resampTrack = [table(bdfFiles', 'VariableNames', {'name'}) srateCols];
    
        bdfFileTmp = char(bdfFiles(i));
                
        tmpEEG = pop_biosig(fullfile(bdfPath, bdfFileTmp));
        tmpEEG = pop_editset(tmpEEG, 'setname', bdfFileTmp(:,1:length(bdfFileTmp)-4)); % asign dataset name using bdf file name
        
        
        if tmpEEG.srate < newSrate
            warning(['On ' bdfFileTmp ' subject. New sampling rate is bigger than actual sampling rate'])
        elseif tmpEEG.srate == newSrate
            warning(['On ' bdfFileTmp ' subject. New sampling rate is equal to actual sampling rate'])
        elseif tmpEEG.srate > newSrate
            disp(['On ' bdfFileTmp 'sample rate is: ' num2str(tmpEEG.srate) ' Hz'])
            
            tmpEEG = pop_resample(tmpEEG, newSrate);
            resampTrack(i, 2) = {tmpEEG.srate}; % track info: original sample rate
            
            resampTrack(i, 3) = {tmpEEG.srate}; % track info: new sample rate
            resampTrack(i, 4) = {tmpEEG.nbchan}; % track info: number of channels
            resampTrack(i, 5) = {tmpEEG.xmax}; % track info: eeg duration
            disp(['number of channels: ' num2str(tmpEEG.nbchan)])
            disp(['eeg duration: ' num2str(tmpEEG.xmax) ' seconds'])
            % size(EEG.times,2)/EEG.srate
            [~, ~, ~] = mkdir(setPath);
            pop_saveset( tmpEEG, 'filename', bdfFileTmp,'filepath',setPath);
        end
        
    end
    
    
end

end
