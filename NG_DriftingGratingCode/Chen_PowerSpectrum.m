function Chen_PowerSpectrum(outputFolder, startTime,endTime, binSize, cellsToPlot, showPlots, binMatrix)

% FUNCTION ARGUMENTS
%   outputFolder = name (in SINGLE quotes) of output folder which will be 
%       created, and into which all of the output will be saved. If outputFolder 
%        = 'dont save' then no .fig or .mat files will be saved and the script
%       will run much faster. If outputFolder is a complete path, then  '@'
%       should be added to the beginning so that user won't be prompted to
%       choose output directory later
%   startTime, endTime = define the period time (in seconds) over which to 
%       analyze. If endTime exceeds the final time point in the data file,
%       it is truncated appropriately
%   binSize = the amount of time associated with each bin in the file to be
%       analyzed
%   cellsToPlot = a vector containing the cell numbers of each cell to be
%        plotted
%   maxLag = max time(s) to offset the auto-correlation (recommended 5s)
%   localMaxWidth = an autocorrelation local maximum 'm' is defined as a
%       value which is larger than all the values 'localMaxWidth' seconds
%       before 'm' and after 'm'. The units for localMaxWidth are seconds
%       (recommended 3*binSize).
%   showPlots = optional; set to 'dont show' if you don't want the figure
%       windows to pop up. They'll still be saved unless 'dont save' is
%       specified.
%   binMatrix = optional; if you want to pass in the actual variable as an
%       argument (like if this function is being called within another
%       script) then you won't be prompted to select a data file.

% IN-FUNCTION PROMPTS
%   1. .mat file which is output from FC_vs_time() containg a single variable
%       'binMatrix' which is a 'C x binSize' matrix where C is the number
%       of cells in the associated recording
%   2. folder where all the figures generated will be saved

% PLOTS GENERATED
%   1. Plot of bin'd firing rate over time
%   2. Auto-correlelogram
%   3. Fourier transform
%   --- figures are displayed and saved in the output folder ---

% OUTPUT
%   AC_FFT_Analysis = an array of struct, one struct for each cell. Each struct
%       has five fields:
%   AC_Time_Corr simply has data that was plotted in autocorelograms. Column 1
%       is x values (ie time offsets in seconds) and Column 2 is y values
%       (ie the correlation coefficient for each time offset).
%   AC_TimeOfMax_LocalMax_Period: Column 1 has the time offset (positive only) where
%       each local max was achieved (see 'localMaxWidth' for definition of local
%       max). Column 2 has the value of the correlation coeff which was
%       deemed a local max. Column 3 has the amount time between the
%       corresponding local max and the next one.
%   AC_ConfidenceInterval: upper and lower boundaries of the 95% confidence
%       intervals. If the distribution of spikes over time were truly random,
%       autocorrelation would be within the confidence interval (95% of the
%       time).
%   FFT_Freq_Amps simply has data that was plotted in FFT. Column 1
%       is x values (ie the frequencies) and Column 2 is y values
%       (ie the amplitude associated with each frequency).
%   FFT_MaxFreqs_MaxAmps: Column 1 has the 10 frequencies with greatest
%       amplitudes. Column 2 has the corresponding amplitudes.


%PROCESSING INPUT

%error if time input is invalid
if startTime < 0 || startTime > endTime
    error('invalid startTime given');
    return;
end

%dont show the plots if showPlots = 'dont show'
if exist('showPlots', 'var') && strcmp(showPlots, 'dont show')
   set(0,'DefaultFigureVisible','off');
else
    set(0,'DefaultFigureVisible','on');
end

%if a binMatrix wasn't given as an argument, prompt the user for a file
if ~exist('binMatrixFile', 'var')
    fprintf('\tSelect file to be analyzed...');
    [data_file, data_path] = uigetfile('*.mat', 'Select .mat file');
    fprintf('Selected!\n');
    load(strcat(data_path, data_file));
end

%prompt for file where output should be saved and create folder
if ~(strcmpi(outputFolder, 'dont save') || outputFolder(1) == '@')
    fprintf('\tSelect folder where output files should be placed...');
    target_folder = uigetdir('', 'Select output folder');
    fprintf('Selected!\n');
    target_folder = strcat(target_folder, '/', outputFolder);
end

%if complete path was given as outputFolder argument, set target_folder to
%output folder
if outputFolder(1) == '@'
    target_folder = outputFolder(2:end);
end

%create output folder
if ~strcmpi(outputFolder, 'dont save')
   mkdir(target_folder);
end


%SETTING SOME VARIABLES

%shorten endTime if its too long
startBin = floor(startTime/binSize) + 1;
endBin = floor(endTime/binSize);
if endBin > size(binMatrix,2)
    endBin = size(binMatrix,2);
    endTime = endBin * binSize;
end

%set some general variables
time = endTime - startTime;
numBins = endBin - startBin;
numCells = length(cellsToPlot);
fourHzTop3 = zeros(numCells,2);
AC_FFT_analysis = cell(numCells+1,1);


for cIndex = 1:numCells
    
    c = cellsToPlot(cIndex);
    data = binMatrix(c, startBin:endBin);
    
    
%FOURIER TRANSFORM
    %compute and normalize the single spectrum FFT
%     F = fft(data);
%     F = abs(F) / numBins;
%     F = F(1: floor(numBins/2)+1);
%     F(2:end) = F(2:end)*2;
    
    %power spectrum
    PF = periodogram(data,rectwin(length(data)),length(data), 1/binSize);
    
    %set the X axis
    freqs = (0:numBins/2) / time;
    
    %plot the FFT
    FFT_name = strcat('PSD_Cell_',num2str(c));
    FFT_plot = figure('Name', FFT_name, 'NumberTitle', 'off');
    ax3 = axes;
    length(freqs)
    length(PF)
    plot(ax3, freqs(2:end), PF(2:end-1));  %dont plot DC, screws up the axis
    title(ax3, ['Power Spectral Density of Firing Rate vs Time for Cell ' num2str(c)]);
    xlabel(ax3, 'Frequency (Hz)');
    ylabel(ax3, 'Power');
       
%     %find the 20 strongest frequencies and corresponding amplitudes
%     [ampRankValues, ampRankIndex] = sort(PF,'descend');
%     maxAmps = ampRankValues(1:20);
%     maxFreqs = freqs(ampRankIndex(1:20));
    
    % find avg of the three strongest amps between 3.5 and 4.5 Hz, and normalize
    % according to 3*peak_avg
%     rank4Hz = sort( PF(351:451), 'descend');
%     fourHzTop3(cIndex,2) = mean(rank4Hz(1:3)) / ((sum(PF)/5000)*3);
%     if isnan(fourHzTop3(cIndex,2))
%         fourHzTop3(cIndex,2) = 0;
%     end
%     fourHzTop3(cIndex,1) = c;
    
    
% OUTPUT
    %save each figure
    if ~strcmpi(outputFolder, 'dont save')
        %saveas(FR_plot, strcat(target_folder, '/', FR_name, '.fig'));
        %saveas(AC_plot, strcat(target_folder, '/', AC_name, '.fig'));
        saveas(FFT_plot, strcat(target_folder, '/', FFT_name, '.fig')); 
    end
    
%     %add the struct for this neuron to the array of structs
%     s = struct('AC_Time_Corr', [auto_x' r_vector'],...
%                'AC_TimeOfMax_LocalMax_Period', [maximaTimes maxima periods],...
%                'AC_ConfidenceIntervals', [lowCI; upCI],...
%                'FFT_Freqs_Amps', [freqs' PF'],...
%                'FFT_MaxFreqs_MaxAmps', [maxFreqs' maxAmps']);
%     AC_FFT_analysis{c} = s;        
end

%     fourHzTop3 = sortrows(fourHzTop3, 2, 'descend');
%     s = struct('Cell_4HzScore', fourHzTop3);
%     AC_FFT_analysis{numCells + 1} = s;
    
% %save the output analysis
% if ~strcmpi(outputFolder, 'dont save')
%     save( strcat(target_folder,'/AC_FFT_analysis.mat'), 'AC_FFT_analysis');
% end

end
