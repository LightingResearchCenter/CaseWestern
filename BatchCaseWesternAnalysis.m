function BatchCaseWesternAnalysis
%CASEWESTERNANALYSIS Desciption goes here
%   Detailed description goes here

%% Trun warning off
s1 = warning('off','MATLAB:linearinter:noextrap');
s2 = warning('off','MATLAB:xlswrite:AddSheet');

%% Enable paths to required subfunctions
addpath('phasorAnalysis');

%% File handling
caseWesternHome = fullfile([filesep,filesep],'root','projects',...
    'NIH Alzheimers','CaseWesternData');
% Read in data from excel spreadsheet of dimesimeter/actiwatch info
workbookFile = fullfile(caseWesternHome,'index.xlsx');
% Import contents of lookup file
[subject,week,days,daysimStart,daysimSN,daysimPath,actiStart,~,...
    actiPath,rmStart,rmStop] = importIndex(workbookFile);

%% Select an output location
saveDir = uigetdir(fullfile(caseWesternHome,'Analysis'),...
    'Select an output location');

%% Creates a text file that records any errors in the data in the same path
% as the results
fid = fopen( fullfile( saveDir, 'Error Report.txt' ), 'w' );
fprintf( fid, 'Error Report \r\n' );
fclose( fid );

%% Preallocate variables
lengthSub = length(subject);
% Preallocate phasor struct
phasorData = struct;
phasorData.subject = subject;
phasorData.week = week;
phasorData.phasorMagnitude = zeros(lengthSub,1);
phasorData.phasorAngle = zeros(lengthSub,1);
phasorData.IS = zeros(lengthSub,1);
phasorData.IV = zeros(lengthSub,1);
phasorData.meanCS = zeros(lengthSub,1);
phasorData.magnitudeWithHarmonics = zeros(lengthSub,1);
phasorData.magnitudeFirstHarmonic = zeros(lengthSub,1);
phasorData.season = cell(lengthSub,1);
% Preallocate sleep struct
sleepData = struct;
sleepData.subject = subject;
sleepData.week = week;
sleepData.season = cell(lengthSub,1);
sleepData.ActualSleep = cell(lengthSub,1);
sleepData.ActualSleepPercent = cell(lengthSub,1);
sleepData.ActualWake = cell(lengthSub,1);
sleepData.ActualWakePercent = cell(lengthSub,1);
sleepData.SleepEfficiency = cell(lengthSub,1);
sleepData.Latency = cell(lengthSub,1);
sleepData.SleepBouts = cell(lengthSub,1);
sleepData.WakeBouts = cell(lengthSub,1);
sleepData.MeanSleepBout = cell(lengthSub,1);
sleepData.MeanWakeBout = cell(lengthSub,1);

%% Perform vectorized calculations

% Set start and stop times for analysis
actiStart(isnan(actiStart)) = 0;
daysimStart(isnan(daysimStart)) = 0;
startTime = max([actiStart,daysimStart],[],2);
stopTime = startTime + days;

% Determine the season
monthStr = datestr(startTime,'mm');
monthCell =  mat2cell(monthStr,ones(length(monthStr),1));
month = str2double(monthCell);
idxSeason = month < 3 | month >= 11; % true = winter, false = summer

%% Begin main loop
for i1 = 1:lengthSub
    % Creates a header title with information about the loop
    header = ['Subject: ',num2str(subject(i1)),...
              ' Week: ',num2str(week(i1)),...
              ' Iteration: ',num2str(i1),...
              ' of ',num2str(lengthSub)];
    disp(header);
    
    % Assign a text value for season
    if idxSeason(i1)
        phasorData.season{i1} = 'winter';
        sleepData.season{i1} = 'winter';
    else
        phasorData.season{i1} = 'summer';
        sleepData.season{i1} = 'summer';
    end
    
    % Check if file paths are listed
    if isempty(actiPath{i1,1}) || isempty(daysimPath{i1,1})
        continue;
    end
    
    % Attempt to import the data
    try
        [aTime,PIM,dTime,CS,AI] = ...
            importData(actiPath{i1,1},daysimPath{i1,1},daysimSN(i1));
    catch err
        reportError( header, err.message, saveDir );
        continue;
    end
    
    % Resample and normalize Actiwatch data to Daysimeter data
    [dTime,CS,AI] = ...
        combineData(aTime,PIM,dTime,CS,AI,...
        startTime(i1),stopTime(i1),rmStart(i1),rmStop(i1));
    
    % Attempt to perform phasor analysis on the combined data
    try
        [phasorData.phasorMagnitude(i1),phasorData.phasorAngle(i1),...
            phasorData.IS(i1),phasorData.IV(i1),phasorData.meanCS(i1),...
            phasorData.magnitudeWithHarmonics(i1),...
            phasorData.magnitudeFirstHarmonic(i1)] =...
            phasorAnalysis(dTime,CS,AI);
    catch err
            reportError(header,err.message,saveDir);
    end
    
    % Attempt to perform sleep analysis
    try
        [sleepData.ActualSleep(i1),sleepData.ActualSleepPercent(i1),...
            sleepData.ActualWake(i1),sleepData.ActualWakePercent(i1),...
            sleepData.SleepEfficiency(i1),sleepData.Latency(i1),...
            sleepData.SleepBouts(i1),sleepData.WakeBouts(i1),...
            sleepData.MeanSleepBout(i1),sleepData.MeanWakeBout(i1)] = ...
            AnalyzeFile(dTime,AI,BedTime,WakeTime);
    catch err
        reportError(header,err.message,saveDir);
    end
end

%% Save output
outputFile = fullfile(saveDir,['output_',datestr(now,'yy-mm-dd'),'.mat']);
save(outputFile,'phasorData','sleepData');
% Convert to Excel
organizeExcel(phasorData);

%% Turn warnings back on
warning(s2);
warning(s1);
end