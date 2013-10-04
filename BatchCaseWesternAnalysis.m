function BatchCaseWesternAnalysis
%CASEWESTERNANALYSIS Desciption goes here
%   Detailed description goes here

%% Trun warning off
s = warning('off','MATLAB:linearinter:noextrap');

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

%% Preallocate output dataset
lengthSub = length(subject);
outputData = dataset;
outputData.subject = subject;
outputData.week = week;
outputData.phasorMagnitude = zeros(lengthSub,1);
outputData.phasorAngle = zeros(lengthSub,1);
outputData.IS = zeros(lengthSub,1);
outputData.IV = zeros(lengthSub,1);
outputData.meanCS = zeros(lengthSub,1);
outputData.magnitudeWithHarmonics = zeros(lengthSub,1);
outputData.magnitudeFirstHarmonic = zeros(lengthSub,1);
outputData.season = cell(lengthSub,1);

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
        outputData.season{i1} = 'winter';
    else
        outputData.season{i1} = 'summer';
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
    
    % Resample and normaliz Actiwatch data to Daysimeter data
    [dTime,CS,AI] = ...
        combineData(aTime,PIM,dTime,CS,AI,...
        startTime(i1),stopTime(i1),rmStart(i1),rmStop(i1));
    
    % Attempt to perform phasor analysis on the combined data
    try
        [outputData.phasorMagnitude(i1),outputData.phasorAngle(i1),...
            outputData.IS(i1),outputData.IV(i1),outputData.meanCS(i1),...
            outputData.magnitudeWithHarmonics(i1),...
            outputData.magnitudeFirstHarmonic(i1)] =...
            phasorAnalysis(dTime,CS,AI);
    catch err
            reportError(header,err.message,saveDir);
            continue;
    end
end

%% Save output
outputFile = fullfile(saveDir,'output_',datestr(now,'yy-mm-dd'),'.mat');
save(outputFile,'outputData');
% Convert to Excel
organizeExcel(outputFile);

%% Turn warnings back on
warning(s);
end