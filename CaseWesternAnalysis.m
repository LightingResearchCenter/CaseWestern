function CaseWesternAnalysis
addpath('IO','phasorAnalysis');

%% Read in data from excel spreadsheet of dimesimeter/actiwatch info
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
%as the results
fid = fopen( fullfile( savePath, 'Error Report.txt' ), 'w' );
fprintf( fid, 'Error Report \r\n' );
fclose( fid );

%%
%Matches actiwatch and dimesimeter data: variables with 'd' prefix come
%from dimesimeter and variables without the 'd' come from actiwatch data
%sub = subject #, int = intervention #, dime = dimesimeter #, start = start
%time, file = datafile path, numdays = # of days to be analyzed after the
%start date

% Set start and stop times for analysis
startTime = max([actiStart,dimeStart],[],2);
stopTime = startTime + days;

% Preallocate output dataset
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

for s = 1:lengthSub
    disp(['s = ',num2str(s),' Subject: ',num2str(subject(s)),...
        ' Intervention: ',num2str(week(s))]);
    
    if(~isempty(actiPath{s,1}))
		
		%Creates a title and savepath from the Subject name and
		%intervention number
		title = ['Subject ',num2str(subject(s)),...
            ' Intervention ',num2str(week(s))];
		subjectSavePath = fullfile( savePath, num2str(subject(s)) );
		if ~exist(subjectSavePath, 'dir')
			mkdir(subjectSavePath);
		end
		
        %Checks if there is a listed actiwatch file for the subject and if
        %there is not it moves to the next subject
        if (isempty(actiPath(s)) == 1)
			reportError( title, 'No actiwatch data available', savePath );
            continue;
        end
		
        %Reads the data from the actiwatch data file
        [pimTS] = deal(0);
        try
            pimTS = importActiwatch(actiPath{s});
        catch err
            reportError( title, err.message, savePath );
            continue;
        end
        %Reads the data from the dimesimeter data file
        [dtime, lux, CLA, CS, dactivity, temp, x, y] =...
            dimedata(dimePath{s, 1},dimeSN(s));
		
        % Crops data
        
        %Determine the season
        if week(s) == 0
            month = str2double(datestr(startTime,'mm'));
            if month < 3 || month >= 11
                outputData.season{s} = 'winter';
            else
                outputData.season{s} = 'summer';
            end
        end
        
        % Continues if there is an error in the dates of the actiwatch
        if length(time) ~= length(dtime)
			reportError(title,'Mismatch in number of actiwatch values',...
                savePath);
            continue
        end

        %sets time from dimesimeter and actiwatch equal in order to avoid
        %discrepancies on the order of 1^-3 seconds
        if (max(abs(dtime-time)) < 1e-3)
            time = dtime;
		else
			reportError(title,...
                'Difference in times between dimesimeter and actiwatch is more than 00.001 seconds',...
                savePath);
            disp(['Error: the difference in times between dimesimeter and actiwatch is more than 00.001 seconds',...
                '\nSubject: ',num2str(subject(s)),'\nIntervention: ',...
                num2str(int(s))])
            continue
        end    

        [time,lux,CLA,CS,activity,ZCM,TAT, dactivity, temp, x, y] =...
			trimData(time,startTime,stopTime,rmStart(s),rmStop(s),lux,...
			CLA,CS,activity,ZCM,TAT,dactivity,temp,x,y);

        nactivity = (mean(dactivity)/mean(activity))*activity;
		try
			[outputData.phasorMagnitude(s),outputData.phasorAngle(s),...
				outputData.IS(s),outputData.IV(s),outputData.meanCS(s),...
				outputData.magnitudeWithHarmonics(s),...
				outputData.magnitudeFirstHarmonic(s)] =...
                phasorAnalysis(time,CS,nactivity);
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