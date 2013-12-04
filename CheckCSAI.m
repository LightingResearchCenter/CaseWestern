function CheckCSAI
%CHECKCSAI

% Close any open figures
close all;

%% Enable paths to required subfunctions
addpath('IO');

%% File handling
caseWesternHome = fullfile([filesep,filesep],'root','projects',...
    'NIH Alzheimers','CaseWesternData');
% Read in data from excel spreadsheet of dimesimeter/actiwatch info
workbookFile = fullfile(caseWesternHome,'index.xlsx');
% Import contents of lookup file
[subject,week,days,daysimStart,daysimSN,daysimPath,actiStart,~,...
    actiPath,rmStart,rmStop] = importIndex(workbookFile);

% Select an output location
username = getenv('USERNAME');
saveDir = uigetdir(fullfile('C:','Users',username,'Desktop'),...
    'Select location to save output.');
errorPath = fullfile(saveDir,[datestr(now,'yyyy-mm-dd_HH-MM'),...
    '_checkCSAI_error_log.txt']);

%% Creates a text file that records any errors in the data in the same path
%as the results
fid = fopen( errorPath, 'w' );
fprintf( fid, 'Error Report \r\n' );
fclose( fid );

%% Have user select input range of subjects
uniqueSubjects = unique(subject);
options = cellstr(num2str(uniqueSubjects));
choice1 = 0;
while choice1 == 0
    choice1 = menu('Select first subject',options);
end
choice2 = 0;
while choice2 == 0
    choice2 = menu('Select last subject',options);
end
logical1 = subject >= uniqueSubjects(choice1) & subject <= uniqueSubjects(choice2);
index1 = 1:length(logical1);

%% Perform vectorized calculations

% Set start and stop times for analysis
actiStart(isnan(actiStart)) = 0;
daysimStart(isnan(daysimStart)) = 0;
startTime = max([actiStart,daysimStart],[],2);
stopTime = startTime + days;

%% Begin main loop

fig = figure; % Create the figure window
set(fig, 'Position', get(0,'Screensize')); % Maximize figure
for i1 = index1(logical1)
    
    % Creates a header title with information about the loop
    header = ['Subject: ',num2str(subject(i1)),...
              ' Week: ',num2str(week(i1)),...
              ' Iteration: ',num2str(i1),...
              ' of ',num2str(sum(logical1))];
    disp(header);
    
    % Check if file paths are listed
    if isempty(actiPath{i1,1}) || isempty(daysimPath{i1,1})
        continue;
    end
    
    % Attempt to import the data
    try
        [aTime,PIM,dTime,CS,AI] = ...
            importData(actiPath{i1,1},daysimPath{i1,1},daysimSN(i1));
    catch err
        reportError( header, err.message, errorPath );
        continue;
    end
    
    % Resample and normaliz Actiwatch data to Daysimeter data
    [dTime,CS,AI] = ...
        combineData(aTime,PIM,dTime,CS,AI,...
        startTime(i1),stopTime(i1),rmStart(i1),rmStop(i1));
    
    % Attempt to plot the data
    try
        %Plot
        [~, name, ~] = fileparts(daysimPath{i1});
        savePath = fullfile(saveDir, [name,'.jpg']);
        figTitle = {['Subject: ',num2str(subject(i1)),...
            ' Week: ',num2str(week(i1)),...
            ' Daysimeter SN: ',num2str(daysimSN(i1))];...
            daysimPath{i1};...
            [datestr(startTime(i1)),' - ',datestr(stopTime(i1))]};
        plotCSAI(dTime, CS, AI, fig, figTitle, savePath);
    catch err
            reportError( header, err.message, errorPath );
            continue;
    end
end

close(fig); % Close the figure window
end

function plotCSAI(dTime, CS, AI, fig, figTitle, savePath)
clf(fig); % Clear the figure window

% Plot CS
subplot(2, 1, 1);
area(dTime, CS);
ylabel('CS');
ylim([0 1]);
if (dTime(end) - dTime(1)) > 1
    datetick('x',2,'keeplimits');
else
    datetick('x','mm/dd/yy HH:MM','keeplimits');
end
% Plot AI
subplot(2, 1, 2);
area(dTime, AI);
ylabel('activity');
if (dTime(end) - dTime(1)) > 1
    datetick('x',2,'keeplimits');
else
    datetick('x','mm/dd/yy HH:MM','keeplimits');
end

% Plot the title
title(figTitle,'Interpreter','none');

%Saves the graph
saveas(fig, savePath);
end