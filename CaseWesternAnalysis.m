function CaseWesternAnalysis
%CASEWESTERNANALYSIS Desciption goes here
%   Detailed description goes here

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
savePath = uigetdir(fullfile(workbookPath,'Analysis'));

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
startTime = max([actiStart,dimeStart],[],2);
stopTime = startTime + days;

% Determine the season
month = str2double(datestr(startTime,'mm'));
idxSeason = month < 3 | month >= 11;
outputData.season{idxSeason} = 'winter';
outputData.season{~idxSeason} = 'summer';

%% Begin main loop
for s = 1:lengthSub
    disp(['s = ',num2str(s),' Subject: ',num2str(subject(s)),...
        ' Intervention: ',num2str(week(s))]);
    
    if(~isempty(actiPath{s,1}))
		
		% Creates a title and savepath from the Subject name and
		% intervention number
		title = ['Subject ',num2str(subject(s)),...
            ' Intervention ',num2str(week(s))];
		subjectSavePath = fullfile( savePath, num2str(subject(s)) );
        if ~exist(subjectSavePath, 'dir')
			mkdir(subjectSavePath);
        end
		
        % Checks if there is a listed actiwatch file for the subject and if
        % there is not it moves to the next subject
        if (isempty(actiPath(s)) == 1)
			reportError( title, 'No actiwatch data available', savePath );
            continue;
        end
		
        % Reads the data from the actiwatch data file
        try
            [aTime, PIM] = importActiwatch(actiPath{s});
        catch err
            reportError( title, err.message, savePath );
            continue;
        end
        % Reads the data from the dimesimeter data file
        try
            [dTime, CS, AI] = importDime(dimePath{s, 1},dimeSN(s));
        catch err
            reportError( title, err.message, savePath );
            continue;
        end
		
        % Resample the actiwatch activity for dimesimeter times
        PIMts = timeseries(PIM,aTime);
        PIMts = resample(PIMts,dTime);
        PIMrs = PIMts.Data;
        
        % Remove excess data and not an number values
        idx1 = isnan(PIMrs) | dTime < startTime(s) | dTime > stopTime(s);
        % Remove specified sections if any
        if (~isnan(cropStart))
            idx2 = dTime >= rmStart(s) & dTime <= rmStop(s);
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
        
		try
			[outputData.phasorMagnitude(s),outputData.phasorAngle(s),...
				outputData.IS(s),outputData.IV(s),outputData.meanCS(s),...
				outputData.magnitudeWithHarmonics(s),...
				outputData.magnitudeFirstHarmonic(s)] =...
                phasorAnalysis(dTime,CS,AIn);
		catch err
				reportError(title,err.message,savePath);
				continue;
		end
    end
end

%% Save output
outputFile = fullfile(savePath,'output.mat');
save(outputFile,'outputData')
end