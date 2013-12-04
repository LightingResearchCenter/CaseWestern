function batchMillerDot
%BATCHMILLERDOT Summary of this function goes here
%   Detailed explanation goes here
addpath('IO','centroidAnalysis');

%% File handling

% Read in data from excel spreadsheet of dimesimeter/actiwatch info
% Set starting path to look in
startingFile = fullfile([filesep,filesep],'root','projects',...
    'NIH Alzheimers','CaseWesternData','index.xlsx');
% Select lookup table file
[workbookName, workbookPath] = uigetfile(startingFile,...
    'Select Subject Information Spreadsheet');
workbookFile = fullfile(workbookPath,workbookName);
% Import contents of lookup file
[subject,week,days,dimeStart,dimeSN,dimePath,actiStart,~,...
    actiPath,rmStart,rmStop] = importIndex(workbookFile);

%% Select an output location
savePath = uigetdir(fullfile(workbookPath,'Analysis','millerDots'),...
    'Select an output location');

errorPath = fullfile(saveDir,['miller_dot_error_log_',...
    datestr(now,'yyyy-mm-dd_HH-MM'),'.txt']);

%% Perform vectorized calculations

% Set start and stop times for analysis
actiStart(isnan(actiStart)) = 0;
dimeStart(isnan(dimeStart)) = 0;
startTime = max([actiStart,dimeStart],[],2);
stopTime = startTime + days;

% Determine the season
monthStr = datestr(startTime,'mm');
monthCell =  mat2cell(monthStr,ones(length(monthStr),1));
month = str2double(monthCell);
idxSeason = month < 3 | month >= 11; % true = winter, false = summer

%% Create figure window
close all;
fig = figure;
paperPosition = [0 0 8.5 11];
set(fig,'PaperUnits','inches',...
    'PaperType','usletter',...
    'PaperOrientation','portrait',...
    'PaperPositionMode','manual',...
    'PaperPosition',paperPosition,...
    'Units','inches',...
    'Position',paperPosition);

%% Set spacing values
xMargin = 0.5/paperPosition(3);
xSpace = 0.125/paperPosition(3);
yMargin = 0.5/paperPosition(4);
ySpace = 0.125/paperPosition(4);

%% Calculate usable space for plots
workHeight = 1-2*ySpace-2*yMargin;
workWidth = 1-2*xMargin;

%% Position axes
w1 = workWidth-4*xSpace;
h1 = w1*paperPosition(4)/paperPosition(3);
y1 = yMargin + (workHeight - h1)/2;
x1 = xMargin;

%% Begin main loop
lengthSub = length(subject);
for i1 = 1:lengthSub
    
    if(isempty(actiPath{i1,1}))
        continue;
    end

    % Creates a title from the Subject name and intervention number
    errorTitle = ['Subject ',num2str(subject(i1)),...
        ' Week ',num2str(week(i1))];

    % Checks if there is a listed actiwatch file for the subject and if
    % there is not it moves to the next subject
    if (isempty(actiPath(i1)) == 1)
        reportError( errorTitle, 'No actiwatch data available', errorPath );
        continue;
    end
    % Check if actiwatch file exists
    if exist(actiPath{i1},'file') ~= 2
        warning(['Actiwatch file does not exist. File: ',actiPath{i1}]);
        continue;
    end

    % Reads the data from the actiwatch data file
    try
        [aTime, PIM] = importActiwatch(actiPath{i1});
    catch err
        reportError( errorTitle, err.message, errorPath );
        continue;
    end
    % Reads the data from the dimesimeter data file
    try
        [dTime, CS, AI] = importDime(dimePath{i1, 1},dimeSN(i1));
    catch err
        reportError( errorTitle, err.message, errorPath );
        continue;
    end

    % Resample the actiwatch activity for dimesimeter times
    PIMts = timeseries(PIM,aTime);
    PIMts = resample(PIMts,dTime);
    PIMrs = PIMts.Data;

    % Remove excess data and not an number values
    idx1 = isnan(PIMrs) | dTime < startTime(i1) | dTime > stopTime(i1);
    % Remove specified sections if any
    if (~isnan(rmStart(i1)))
        idx2 = dTime >= rmStart(i1) & dTime <= rmStop(i1);
    else
        idx2 = false(length(dTime),1);
    end
    idx3 = ~(idx1 | idx2);
    dTime = dTime(idx3);
    PIM = PIMrs(idx3);
    AI = AI(idx3);
    CS = CS(idx3);

    % Normalize Actiwatch activity to Dimesimeter activity
    AIn = PIM*(mean(AI)/mean(PIM));
    
    % Begin plotting
    clf(fig);
    if isempty(dTime);
        continue;
    end
    titleStr = {['Subject ',num2str(subject(i1)),' Week',num2str(week(i1))];...
        [datestr(dTime(1),'mm/dd/yyyy HH:MM'),' - ',datestr(dTime(end),'mm/dd/yyyy HH:MM')]};
    plotTitle(fig,titleStr,yMargin);
    dateStamp(fig,xMargin,yMargin);
    % Create axes
    axes('Parent',fig,'OuterPosition',[x1 y1 w1 h1]);
    % Create plot
    try
        [C_time,C_magnitude] = millerDot(dTime,CS,AIn);
    catch
        continue;
    end
    % Plot annotation
    noteStr = {['Centroid time: ',datestr(C_time,'HH:MM')];...
        ['Centroid magnitude: ',num2str(C_magnitude,3)]};
    plotNotes(fig,noteStr);
    % Save plot to file
    [~, fileBase, ~]= fileparts(actiPath{i1,1});
    reportFile = fullfile(savePath,[fileBase(1:8),'.pdf']);
    saveas(gcf,reportFile);
end

close all;

end

%% Subfunction to plot a centered title block
function plotTitle(fig,titleStr,yMargin)
% Create title
titleHandle = annotation(fig,'textbox',...
    [0.5,1-yMargin,0.1,0.1],...
    'String',titleStr,...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'LineStyle','none',...
    'FontSize',14);
% Center the title and shift down
titlePosition = get(titleHandle,'Position');
titlePosition(1) = 0.5-titlePosition(3)/2;
titlePosition(2) = 1-yMargin-titlePosition(4);
set(titleHandle,'Position',titlePosition);
end

%% Subfunction to plot a date stamp in the top right corner
function dateStamp(fig,xMargin,yMargin)
% Create date stamp
dateStamp = ['Printed: ',datestr(now,'mmm. dd, yyyy HH:MM')];
datePosition = [0.8,1-yMargin,0.1,0.1];
dateHandle = annotation(fig,'textbox',datePosition,...
    'String',dateStamp,...
    'FitBoxToText','on',...
    'HorizontalAlignment','right',...
    'LineStyle','none');
% Shift left and down
datePosition = get(dateHandle,'Position');
datePosition(1) = 1-xMargin-datePosition(3);
datePosition(2) = 1-yMargin-datePosition(4); 
set(dateHandle,'Position',datePosition);
end

%% Subfunction to plot a centered annotation block
function plotNotes(fig,noteStr)
% Find position of axes
axesPosition = get(gca,'Position');
% Create title
noteHandle = annotation(fig,'textbox',...
    [0.5,axesPosition(2),0.1,0.1],...
    'String',noteStr,...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'LineStyle','none',...
    'FontSize',14);
% Center the annotation and shift down
notePosition = get(noteHandle,'Position');
notePosition(1) = 0.5-notePosition(3)/2;
notePosition(2) = axesPosition(2)-notePosition(4);
set(noteHandle,'Position',notePosition);
end

