function BatchCaseWesternAnalysis
%CASEWESTERNANALYSIS Desciption goes here
%   Detailed description goes here

% Mark time of analysis
runTime = now;

%% Turn warning off
s1 = warning('off','MATLAB:linearinter:noextrap');
s2 = warning('off','MATLAB:xlswrite:AddSheet');

%% Enable paths to required subfunctions
addpath('sleepAnalysis','IO','CDF');
[parentDirectory, ~, ~] = fileparts(pwd);
addpath(fullfile(parentDirectory, 'DaysimeterSleepAlgorithm'));

%% Ask user what sleep time to use
sleepLogMode = menu('Select what sleep time mode to use','fixed','logs/dynamic');
if sleepLogMode == 1
    bedStr = input('Enter bed time (ex. 21:00): ','s');
    bedTokens = regexp(bedStr,'^(\d{1,2}):(\d\d)','tokens');
    bedHour = str2double(bedTokens{1}{1});
    bedMinute = str2double(bedTokens{1}{2});
    fixedBedTime = bedHour/24 + bedMinute/60/24;
    
    wakeStr = input('Enter wake time (ex. 07:00): ','s');
    wakeTokens = regexp(wakeStr,'^(\d{1,2}):(\d\d)','tokens');
    wakeHour = str2double(wakeTokens{1}{1});
    wakeMinute = str2double(wakeTokens{1}{2});
    fixedWakeTime = wakeHour/24 + wakeMinute/60/24;
    
    % Create a file name suffix from the fixed sleep time
    suffix = ['_',num2str(bedHour,'%02.0f'),num2str(bedMinute,'%02.0f'),...
        '-',num2str(wakeHour,'%02.0f'),num2str(wakeMinute,'%02.0f')];
else
    fixedBedTime = 0;
    fixedWakeTime = 0;
    
    % Create an empty file name suffix
    suffix = '';
end

%% File handling
caseWesternHome = fullfile([filesep,filesep],'root','projects',...
    'NIH Alzheimers','CaseWesternData');
% Read in data from excel spreadsheet of dimesimeter/actiwatch info
indexPath = fullfile(caseWesternHome,'index.xlsx');
[subject,week,days,daysimStart,daysimSN,daysimPath,actiStart,~,...
    actiPath,rmStart,rmStop] = importIndex(indexPath);
% Import sleepLog
sleepLogPath = fullfile(caseWesternHome,'sleepLog.xlsx');
sleepLog = importSleepLog(sleepLogPath);

% Set an output location
saveDir = fullfile(caseWesternHome,'Analysis');
errorPath = fullfile(saveDir,[datestr(runTime,'yyyy-mm-dd_HH-MM'),...
    '_error_log',suffix,'.txt']);

%% Creates a text file that records any errors in the data in the same path
% as the results
fid = fopen(errorPath,'w');
fprintf( fid, 'Error Report \r\n' );
fclose( fid );

%% Preallocate result variables
numSub = numel(subject);

%% Specify repeat subjects and which ones to be excluded
repeats1  = [13,22,30,38,42,44,47,48,60,64]; % Subject on first run
repeats2  = [35,41,55,54,53,58,62,61,69,67]; % Subject on second run
repeatsEx = [35,41,42,47,48,54,55,58,67,69]; % Subjects to be excluded
% include caregiver subject numbers
repeats1  = [repeats1,repeats1+.1];
repeats2  = [repeats2,repeats2+.1];
repeatsEx = [repeatsEx,repeatsEx+.1];

%% Perform vectorized calculations

% Set start and stop times for analysis
actiStart(isnan(actiStart)) = 0;
daysimStart(isnan(daysimStart)) = 0;
startTime = max([actiStart,daysimStart],[],2);
stopTime = startTime + days;

% Determine the month
monthStr = datestr(startTime,'mm');
monthCell =  mat2cell(monthStr,ones(length(monthStr),1));
month = str2double(monthCell);

output = cell(numSub, 1);

%% Begin main loop
reverseStr = '';
for i1 = 1:numSub
    % Creates an iteration title with information about the loop
    iteration = sprintf('Subject: %4.1f  Week: %i  Iteration: %3i of %3i',...
        subject(i1),week(i1),i1,numSub);
    disp([reverseStr,iteration]);
    reverseStr = repmat(sprintf('\b'), 1, numel(iteration)+1);
    
    %% Check if Actiwatch file path is listed and exists
    if isempty(actiPath{i1,1}) || (exist(actiPath{i1,1},'file') ~= 2)
        if exist(actiPath{i1,1},'file') ~= 2
            reportError(iteration,...
                ['Actiwatch file does not exist. File: ',actiPath{i1,1}],...
                errorPath);
        end
        continue;
    else
        % Import the actiwatch data
        % Create CDF file name
        CDFactiPath = regexprep(actiPath{i1,1},'\.csv','.cdf');
        % Check if CDF versions exist
        if exist(CDFactiPath,'file') == 2 % CDF Actiwatch file exists
            actiData = ProcessCDF(CDFactiPath);
            aTime = actiData.Variables.Time;
            PIM = actiData.Variables.Activity;
        else % CDF Actiwatch file does not exist
            % Reads the data from the actiwatch data file
            [aTime,PIM] = importActiwatch(actiPath{i1,1});
            % Create a CDF version
            WriteActiwatchCDF(CDFactiPath,aTime,PIM);
        end
        
        % Convert PIM to total activity counts
        epoch = round((aTime(2) - aTime(1))*24*60*100)/100;
        totActi = pim2totActi(PIM,epoch);
        
        % Crop actiwatch data
        [aTime,totActi] = cropData(aTime,totActi,startTime(i1),stopTime(i1),rmStart(i1),rmStop(i1));
        
        %% Attempt to perform sleep analysis
        try
            subLog = checkSleepLog(sleepLog,subject(i1),aTime,totActi,sleepLogMode,fixedBedTime,fixedWakeTime);
        catch err
            reportError(iteration,err.message,errorPath);
        end
        
        try
                 output{i1} = AnalyzeFile(subject(i1), aTime, totActi, subLog.bedtime,...
                    subLog.getuptime);
        catch err
            reportError(iteration,err.message,errorPath);
        end 
    end    
end

%% Update displayed message
msg = 'Analysis complete. Saving output to files.';
disp([reverseStr,msg]);
reverseStr = repmat(sprintf('\b'), 1, numel(msg)+1);

%% Save output
outputFile = fullfile(saveDir,[datestr(runTime,'yyyy-mm-dd_HH-MM'),...
    '_output',suffix,'.mat']);
save(outputFile,'output');
% Convert to Excel
organizeExcel(outputFile);

%% Turn warnings back on
warning(s2);
warning(s1);

%% Update displayed message
msg = 'Results saved to file. Program has completed.';
disp([reverseStr,msg]);
end