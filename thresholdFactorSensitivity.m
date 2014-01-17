function thresholdFactorSensitivity
%THRESHOLDFACTORSENSITIVITY Desciption goes here
%   Detailed description goes here

%% Enable use of parallel processing if not already turned on
poolsize = matlabpool('size');
if poolsize < 1
    matlabpool open;
end

%% Mark time of analysis
runTime = now;
runTimeStr = datestr(runTime,'yyyy-mm-dd_HH-MM');

%% Turn warning off
s1 = warning('off','MATLAB:linearinter:noextrap');

%% Enable paths to required subfunctions
addpath('phasorAnalysis','sleepAnalysis','IO','CDF');

%% Ask user what sleep time to use
choice = questdlg('What bed time mode would you like to use?', ...
	'Bed Time Mode Menu', ...
	'fixed','dynamic','fixed');
if strcmpi(choice,'fixed')
    bedLogMode = 1;
elseif strcmpi(choice,'dynamic');
    bedLogMode = 2;
else
    warning('Bed time mode slection failed. Proceeding using fixed bed time mode');
    bedLogMode = 1;
end

switch bedLogMode
    case 1
        answer1 = cell(2,1);
        prompt1 = {'Bed time (HH:MM)','Wake time (HH:MM)'};
        dlgTitle1 = 'Enter fixed bed times.';
        numLines1 = 1;
        def1 = {'21:00','07:00'};
        while isempty(answer1{1}) || isempty(answer1{2})
            answer1 = inputdlg(prompt1,dlgTitle1,numLines1,def1);
            
            bedStr = answer1{1};
            try
                bedTokens = regexp(bedStr,'^(\d{1,2}):(\d\d)','tokens');
                bedHour = str2double(bedTokens{1}{1});
                bedMinute = str2double(bedTokens{1}{2});
                if bedHour > 24 || bedMinute > 60 || bedHour < 0 || bedMinute < 0
                    answer1{1} = [];
                else
                    def1{1} = bedStr;
                end
                fixedBedTime = bedHour/24 + bedMinute/60/24;
            catch err
                warning(err);
                answer1{1} = [];
            end
            
            wakeStr = answer1{2};
            try
                wakeTokens = regexp(wakeStr,'^(\d{1,2}):(\d\d)','tokens');
                wakeHour = str2double(wakeTokens{1}{1});
                wakeMinute = str2double(wakeTokens{1}{2});
                if wakeHour > 24 || wakeMinute > 60 || wakeHour < 0 || wakeMinute < 0
                    answer1{2} = [];
                else
                    def1{2} = wakeStr;
                end
                fixedWakeTime = wakeHour/24 + wakeMinute/60/24;
            catch err
                warning(err);
                answer1{2} = [];
            end
            
        end
        
        % Create a file name suffix from the fixed sleep time
        suffix = ['_',num2str(bedHour,'%02.0f'),num2str(bedMinute,'%02.0f'),...
            '-',num2str(wakeHour,'%02.0f'),num2str(wakeMinute,'%02.0f')];
    otherwise
        fixedBedTime = 0;
        fixedWakeTime = 0;

        % Create an empty file name suffix
        suffix = '';
end

%% Ask user to set threshold factor range
answer2 = cell(3,1);
prompt2 = {'First threshold factor','Increment','Last threshold factor'};
dlgTitle2 = 'Enter threshold factor range.';
numLines2 = 1;
def2 = {'0','.01','1'};
while isempty(answer2{1}) || isempty(answer2{2}) || isempty(answer2{3})
    answer2 = inputdlg(prompt2,dlgTitle2,numLines2,def2);
    
    try
        kFirst = str2double(answer2{1});
        def2{1} = answer2{1};
    catch err
        warning(err);
        answer2{1} = [];
    end
    try
        kInc = str2double(answer2{2});
        def2{2} = answer2{2};
    catch err
        warning(err);
        answer2{2} = [];
    end
    try
        kLast = str2double(answer2{3});
        def2{3} = answer2{3};
    catch err
        warning(err);
        answer2{3} = [];
    end
    
    if (kInc > 0 && kLast < kFirst) || (kInc < 0 && kLast > kFirst) || ...
            (kFirst == kLast) || (abs(kInc) > abs(kLast - kFirst))
        answer2 = cell(3,1);
        def2 = {'0','.05','1'};
    end
end
k = kFirst:kInc:kLast;
nK = numel(k);

%% File handling
caseWesternHome = fullfile([filesep,filesep],'root','projects',...
    'NIH Alzheimers','CaseWesternData');
% Read in data from excel spreadsheet of dimesimeter/actiwatch info
indexPath = fullfile(caseWesternHome,'index.xlsx');
[subject,week,days,daysimStart,~,~,actiStart,~,...
    actiPath,rmStart,rmStop] = importIndex(indexPath);
% Import sleepLog
sleepLogPath = fullfile(caseWesternHome,'sleepLog.xlsx');
sleepLog = importSleepLog(sleepLogPath);

% Set an output location
saveDir = fullfile(caseWesternHome,'ThresholdFactor');
errorPath = fullfile(saveDir,[runTimeStr,'_error_log',suffix,'.txt']);

%% Creates a text file that records any errors in the data in the same path
% as the results
fid = fopen(errorPath,'w');
fprintf( fid, 'Error Report \r\n' );
fclose( fid );

%% Preallocate result variables
numSub = numel(subject);
results = dataset;
results.subject = subject;
results.repeatSubject = cell(numSub,1);
results.excludeRepeat = cell(numSub,1);
results.week = week;
results.season = cell(numSub,1);

% Preallocate sleep results
thresholdFactor = cell(numSub,nK);
sleepEfficiency = cell(numSub,nK);

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

%% Begin main loop
reverseStr = '';
for i1 = 1:numSub
    % Creates an iteration title with information about the loop
    iteration = sprintf('Subject: %4.1f  Week: %i  Iteration: %3i of %3i',...
        subject(i1),week(i1),i1,numSub);
    disp([reverseStr,iteration]);
    reverseStr = repmat(sprintf('\b'), 1, numel(iteration)+1);
    
    % Assign a text value for season
    if month(i1) < 3 || month(i1) >= 11
        results.season{i1} = 'winter';
    else
        results.season{i1} = 'summer';
    end
    
    % Check if the subject is a repeat
    if any(subject(i1) == repeats1)
        results.repeatSubject{i1} = repeats2(subject(i1) == repeats1);
    elseif any(subject(i1) == repeats2)
        results.repeatSubject{i1} = repeats1(subject(i1) == repeats2);
    end
    if any(subject(i1) == repeatsEx)
        results.excludeRepeat{i1} = 'true';
    else
        results.excludeRepeat{i1} = 'false';
    end
    
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
            subLog = checkSleepLog(sleepLog,subject(i1),aTime,totActi,bedLogMode,fixedBedTime,fixedWakeTime);
            bedtime = subLog.bedtime;
            getuptime = subLog.getuptime;
        catch err
            reportError(iteration,err.message,errorPath);
        end

        try
            parfor j1 = 1:nK
                sleepEfficiency{i1,j1} = ...
                    analyzeEff(aTime,totActi,bedtime,getuptime,true,k(j1));
                thresholdFactor{i1,j1} = k(j1);
            end
        catch err
            reportError(iteration,err.message,errorPath);
        end
    end
end

%% Update displayed message
msg = 'Analysis complete. Plotting results.';
disp([reverseStr,msg]);
reverseStr = repmat(sprintf('\b'), 1, numel(msg)+1);

%% Plot histogram
% reshape data
temp1 = cell2mat(thresholdFactor);
Factors = temp1(:);
temp2 = cell2mat(sleepEfficiency);
SleepEfficiencies = temp2(:)*100;

bins = floor(nK/2);
hist3([Factors,SleepEfficiencies],[bins bins]);
xlabel({'Threshold';'Factor'});
ylabel({'Sleep';'Efficiency'});
set(gcf,'renderer','opengl');
set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
view(gca,[-80 75]);

%% Update displayed message
msg = 'Saving results to disk.';
disp([reverseStr,msg]);
reverseStr = repmat(sprintf('\b'), 1, numel(msg)+1);

%% Save output
outputFile = fullfile(saveDir,[runTimeStr,'_output',suffix,'.mat']);
save(outputFile);
plotFig = fullfile(saveDir,[runTimeStr,'_histogram',suffix,'.fig']);
saveas(gcf,plotFig);
plotPNG = fullfile(saveDir,[runTimeStr,'_histogram',suffix,'.png']);
saveas(gcf,plotPNG);

%% Turn warnings back on
warning(s1);

%% Update displayed message
msg = 'Program has completed.';
disp([reverseStr,msg]);
end