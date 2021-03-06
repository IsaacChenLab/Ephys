function cell_theta_OS_4Hz = OS_vs_4HzAmp(outputFolder, numCells, theta,...
                                          selectivityFile, AC_PSD_file)

% FUNCTION ARGUMENTS
%   outputFolder = name (in SINGLE quotes) of output folder which will be 
%       created, and into which all of the output will be saved. If outputFolder 
%        = 'dont save' then no .fig or .mat files will be saved and the script
%       will run much faster. If outputFolder is a complete path, then  '@'
%       should be added to the beginning so that user won't be prompted to
%       choose output directory later
%   numCells = number of total cells analyzed in the input data
%   theta = orientation in degrees that the AC_PSD data corresponds to.
%       Only cells whose preferred orietnation is within 22.5 degrees of theta
%       will be analyzed
%   selectivityFile =  optional; the complete path for an
%       Orientation_Selectivity.mat file (output of PolarPlots.m). If not
%       given, user will be prompted to browse for the file.
%   AC_PSD_file =  optional; the complete path for an AC_PSD_analysis.mat
%       file. If not given, user will be prompted to browse for the file. 
%       This file is the output of Chen_AC_PSD

% PLOTS GENERATED
%   1. Scatter plot of OS magnitude vs amplitude at 4Hz on PSD
%   --- figures are displayed and saved in the output folder ---

% OUTPUT
%   Column 1 = cell number
%   Column 2 = orientation (in degrees) or resultant vector
%   Column 3 = OS (magnitude of resultant vector), ie x axis
%   Column 4 = average of top 3 PSD peaks between 3.5 and 4.5 Hz, ie y axis

% get and read the Orientation Selectivity file
% this is where resultantVectors comes from
if ~exist('selectivityFile', 'var')  
    fprintf("\tSelect orientation selectivity file...");
    [data_file, data_path] = uigetfile('*.mat','Select .mat file...');
    fprintf("Selected!\n");
    selectivityFile = strcat(data_path, data_file);
end
load(selectivityFile);
 
% get and load the AC_PSD.mat file
% this is where AC_PSD_analysis comes from
if ~exist('AC_PSD_file', 'var')
    fprintf("\tSelect AC_PSD file...");
    [data_file, data_path] = uigetfile('*.mat','Select .mat file...');
    fprintf("Selected!\n");
    AC_PSD_file = strcat(data_path, data_file);
end
load(AC_PSD_file);

%prompt for file where output should be saved and create folder
if ~(strcmpi(outputFolder, 'dont save') || outputFolder(1) == '@')
    fprintf('\tSelect folder where output files should be placed...');
    target_folder = uigetdir('', 'Select output folder');
    fprintf('Selected!\n');
    target_folder = strcat(target_folder, '/', outputFolder);
end
if ~strcmpi(outputFolder, 'dont save')
   mkdir(target_folder);
end

% extract data from the input data structures
Hz_Scores = sortrows(AC_PSD_analysis{numCells+1}.Cell_4HzScore);
Select_Scores = sortrows(resultantVectors);

%find the cells that are oriented toward theta
LikesTheta = Select_Scores(:,2) >= theta-22.5 & Select_Scores(:,2) <= theta+22.5;
Hz_Scores = Hz_Scores(LikesTheta,:);
Select_Scores = Select_Scores(LikesTheta,:);

%plot
name = 'Orientation Selectivity vs 4Hz Amplitudue';
f = figure('Name', name, 'NumberTitle', 'off');
x = Select_Scores(:,3);
y = Hz_Scores(:,2);

scatter(x,y);
hold on

X = [ones(length(x),1) x];
b = X\y;
yCalc2 = X*b;
plot(x,yCalc2,'-');
Rsq = 1 - sum((y - yCalc2).^2)/sum((y - mean(y)).^2);
dim = [.2 .5 .3 .3];
str = ['r2 = ', num2str(Rsq)];
annotation('textbox',dim,'String',str,'FitBoxToText','on');

title(name);
xlabel('Orientation Selectivity');
xlim([0 1]);
ylabel('4Hz Amplitude');

%generate output matrix
cell_theta_OS_4Hz = [Select_Scores, Hz_Scores(:,2)];
cell_theta_OS_4Hz = sortrows(cell_theta_OS_4Hz, 3);

%save
if ~strcmpi(outputFolder, 'dont save')
    saveas(f, strcat(target_folder,'/OS_vs_4HzAmp.fig'));
    save(strcat(target_folder,'/cell_theta_OS_4Hz.mat'), 'cell_theta_OS_4Hz');
end

end
