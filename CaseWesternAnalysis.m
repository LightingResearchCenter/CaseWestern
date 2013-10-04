function CaseWesternAnalysis
%CASEWESTERNANALYSIS Desciption goes here
%   Detailed description goes here

%% Trun warning off
s = warning('off','MATLAB:DELETE:Permission');

%% Enable paths to rewuired subfunctions
addpath('IO','phasorAnalysis');

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
savePath = uigetdir(fullfile(workbookPath,'Analysis'),...
    'Select an output location');

%% Creates a text file that records any errors in the data in the same path
% as the results
fid = fopen( fullfile( savePath, 'Error Report.txt' ), 'w' );
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
dimeStart(isnan(dimeStart)) = 0;
startTime = max([actiStart,dimeStart],[],2);
stopTime = startTime + days;

% Determine the season
monthStr = datestr(startTime,'mm');
monthCell =  mat2cell(monthStr,ones(length(monthStr),1));
month = str2double(monthCell);
idxSeason = month < 3 | month >= 11; % true = winter, false = summer

%% Begin main loop
for i1 = 1:lengthSub
    disp(['s = ',num2str(i1),' Subject: ',num2str(subject(i1)),...
        ' Intervention: ',num2str(week(i1))]);
    
    if idxSeason(i1)
        outputData.season{i1} = 'winter';
    else
        outputData.season{i1} = 'summer';
    end
    
    if(isempty(actiPath{i1,1}))
        continue;
    end

    % Creates a title from the Subject name and intervention number
    title = ['Subject ',num2str(subject(i1)),...
        ' Intervention ',num2str(week(i1))];

    % Checks if there is a listed actiwatch file for the subject and if
    % there is not it moves to the next subject
    if (isempty(actiPath(i1)) == 1)
        reportError( title, 'No actiwatch data available', savePath );
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
        reportError( title, err.message, savePath );
        continue;
    end
    % Reads the data from the dimesimeter data file
    try
        [dTime, CS, AI] = importDime(dimePath{i1, 1},dimeSN(i1));
    catch err
        reportError( title, err.message, savePath );
        continue;
    end
    
    % Crop data to overlapping section
    cropStart = max(min(dTime),min(aTime));
    cropEnd = min(max(dTime),max(aTime));
    idx1 = dTime < cropStart | dTime > cropEnd;
    dTime(idx1) = [];
    CS(idx1) = [];
    AI(idx1) = [];
    idx2 = aTime < cropStart | aTime > cropEnd;
    aTime(idx2) = [];
    PIM(idx2) = [];
    
    % Resample the actiwatch activity for dimesimeter times
    PIMts = timeseries(PIM,aTime);
    PIMts = resample(PIMts,dTime);
    PIMrs = PIMts.Data;

    % Remove excess data and not an number values
    idx3 = isnan(PIMrs) | dTime < startTime(i1) | dTime > stopTime(i1);
    % Remove specified sections if any
    if (~isnan(rmStart(i1)))
        idx4 = dTime >= rmStart(i1) & dTime <= rmStop(i1);
    else
        idx4 = false(length(dTime),1);
    end
    idx5 = ~(idx3 | idx4);
    dTime = dTime(idx5);
    PIM = PIMrs(idx5);
    AI = AI(idx5);
    CS = CS(idx5);

    % Normalize Actiwatch activity to Dimesimeter activity
    AIn = PIM*(mean(AI)/mean(PIM));

    try
        [outputData.phasorMagnitude(i1),outputData.phasorAngle(i1),...
            outputData.IS(i1),outputData.IV(i1),outputData.meanCS(i1),...
            outputData.magnitudeWithHarmonics(i1),...
            outputData.magnitudeFirstHarmonic(i1)] =...
            phasorAnalysis(dTime,CS,AIn);
    catch err
            reportError(title,err.message,savePath);
            continue;
    end
end

%% Save output
outputFile = fullfile(savePath,'output.mat');
save(outputFile,'outputData')

%% Turn warning back on
warning(s);
end