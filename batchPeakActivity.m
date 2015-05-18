function batchPeakActivity
%BATCHPEAKACTIVITY Desciption goes here
%   Detailed description goes here

% Mark time of analysis
runTime = now;

%% Turn warnings off
s1 = warning('off','MATLAB:linearinter:noextrap');
s2 = warning('off','MATLAB:xlswrite:AddSheet');

%% Enable paths to required subfunctions
addpath('phasorAnalysis','IO','CDF');
[parentDirectory, ~, ~] = fileparts(pwd);
addpath(fullfile(parentDirectory, 'DaysimeterSleepAlgorithm'), '-end');

%% File handling
caseWesternHome = fullfile([filesep,filesep],'root','projects',...
    'NIH Alzheimers','CaseWesternData');
% Read in data from excel spreadsheet of dimesimeter/actiwatch info
indexPath = fullfile(caseWesternHome,'index.xlsx');
[subject,week,days,daysimStart,daysimSN,daysimPath,actiStart,~,...
    actiPath,rmStart,rmStop] = importIndex(indexPath);


% Set an output location
saveDir = fullfile(caseWesternHome,'Analysis');
errorPath = fullfile(saveDir,[datestr(runTime,'yyyy-mm-dd_HH-MM'),...
    '_error_log.txt']);

% Creates a text file that records any errors in the data in the same path
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
rvs = '';
for i1 = 1:numSub
    %% Creates an iteration title with information about the loop
    iteration = sprintf('Subject: %4.1f  Week: %i  Iteration: %3i of %3i',...
        subject(i1),week(i1),i1,numSub);
    rvs = tempDisp(iteration,rvs);
    
    % Assign a text value for season
    if month(i1) < 3 || month(i1) >= 11
        season = 'winter';
    else
        season = 'summer';
    end
    
    % Check if the subject is a repeat
    if any(subject(i1) == repeats1)
        repeatSubject = repeats2(subject(i1) == repeats1);
    elseif any(subject(i1) == repeats2)
        repeatSubject = repeats1(subject(i1) == repeats2);
    else
        repeatSubject = [];
    end
    
    if any(subject(i1) == repeatsEx)
        excludeRepeat = 'true';
    else
        excludeRepeat = 'false';
    end
    
    %% Check if Actiwatch file path is listed and exists
    if isempty(actiPath{i1,1})
        continue;
    elseif exist(actiPath{i1,1},'file') ~= 2
        errMsg = ['Actiwatch file does not exist. File: ',actiPath{i1,1}];
        reportError(iteration,errMsg,errorPath);
        continue;
    end
    %% Import the actiwatch data
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
    
    % Remove excess data and not a number values
    idx3b = aTime < startTime(i1) | aTime > stopTime(i1);
    % Remove specified sections if any
    if (~isnan(rmStart(i1)))
        idx4b = aTime >= rmStart(i1) & aTime <= rmStop(i1);
    else
        idx4b = false(numel(aTime),1);
    end
    idx5b = ~(idx3b | idx4b);
    aTime = aTime(idx5b);
    PIM = PIM(idx5b);
    
    %% Attempt to perform phasor analysis
    try
        [mesor,amplitude,phi] = cosinorFit(aTime,PIM,1,1);
        acrophase = mod(24*(1-phi/(2*pi)),24);
        output{i1} = struct('subject',subject(i1),'season',season,...
            'repeatSubject',repeatSubject,'excludeRepeat',excludeRepeat,...
            'week',week(i1),'mesor',mesor,'amplitude',amplitude,...
            'phi',phi,'acrophase',acrophase);
    catch err
        reportError(iteration,err.message,errorPath);
        continue;
    end
end

%% Update displayed message
msg = 'Analysis complete. Saving output to files.';
rvs = tempDisp(msg,rvs);

%% Save output
outputFile = fullfile(saveDir,[datestr(runTime,'yyyy-mm-dd_HH-MM'),...
    '_peakActivityOutput.mat']);
save(outputFile,'output');

%% Turn warnings back on
warning(s2);
warning(s1);

%% Update displayed message
msg = 'Results saved to file. Program has completed.';
rvs = tempDisp(msg,rvs);
end


function rvs = tempDisp(msg,rvs)
% TEMPDISP Clear out previously displayed message and write new message

disp([rvs,msg]);
rvs = repmat(sprintf('\b'), 1, numel(msg)+1);

end