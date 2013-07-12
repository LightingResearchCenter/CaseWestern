function Case_Western_Sleep_Analysis
addpath('IO');

%% Read in data from excel spreadsheet of dimesimeter/actiwatch info
startingFile = fullfile([filesep,filesep],'root','projects',...
    'NIH Alzheimers','CaseWesternData','index.xlsx');
[workbookName, workbookPath] = uigetfile(startingFile,...
    'Select Subject Information Spreadsheet');
workbookFile = fullfile(workbookPath,workbookName);
[subject,week,days,dimeStart,dimeSN,dimePath,actiStart,actiSN,...
    actiPath,rmStart,rmStop] = importIndex(workbookFile);

%% Parse data from excel spreadsheet
emptyNumDays =  isnan(days) ;       %Find all the entries with an empty numDays value
days(emptyNumDays) = 7;  			%Set the default value for the numDays to 7

%% Select an output location
username = getenv('USERNAME');
savePath = uigetdir(fullfile('C:','Users',username,'Desktop','CaseWestern'));

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

for s = 61:lengthSub
    disp(['s = ', num2str(s), ' Subject: ', num2str(subject(s)), ...
		  ' Intervention: ', num2str(week(s))])
    if(~isempty(actiPath{s,1}))
		
		%Creates a title and savepath from the Subject name and
		%intervention number
		title = ['Subject ' num2str(subject(s)) ' Intervention ' num2str(week(s))];
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
		
		%Gets the file location of the .mat file. If it doesn't exist, then
		%information about the subjects will be generated from the data
		%files
		matFilePath = fullfile(subjectSavePath, ['dime_watch_data_', num2str(week(s)), '.mat']);
		
		startTime = max(actiStart(s), dimeStart(s));
		stopTime = startTime + days(s);
		if (~exist(matFilePath, 'file'))
			%Reads the data from the actiwatch data file
			[activity, ZCM, TAT, time] = deal(0);
            try
				[activity, ZCM, TAT, time] = read_actiwatch_data(actiPath{s}, ...
																 startTime, ...
																 stopTime);
			catch err
				reportError( title, err.message, savePath );
				continue;
			end
			%Reads the data from the dimesimeter data file
			[dtime, lux, CLA, CS, dactivity, temp, x, y] = dimedata(dimePath{s, 1}, ...
																	dimeSN(s), ...
																	startTime, ...
																	stopTime);
			
			
			save(matFilePath, 'activity', 'ZCM', 'TAT', 'time', 'dtime', 'lux', ...
 				 'CLA', 'CS', 'dactivity', 'temp', 'x', 'y');
		else
			load(matFilePath);
		end
		
        % Crops data
		startTime = max(time(1), dtime(1));
		stopTime = min(time(end), dtime(end));
		if length(time) > length(dtime)
			[time, activity, ZCM, TAT] = trimData(time, startTime, stopTime, ...
										 rmStart(s), rmStop(s), time, activity, ZCM, TAT);
		else
			[dtime, lux, CLA, CS, dactivity, temp, x, y] = trimData(dtime, startTime, stopTime, ...
														   rmStart(s), rmStop(s), dtime, lux, CLA, CS, ...
													       dactivity, temp, x, y);
		end
        % Continues if there is an error in the dates of the actiwatch
        if length(time) ~= length(dtime)
			reportError( title, 'Mismatch in number of actiwatch values', savePath );
            continue
        end

        %sets time from dimesimeter and actiwatch equal in order to avoid
        %discrepancies on the order of 1^-3 seconds
        if (max(abs(dtime-time)) < 1e-3)
            time = dtime;
		else
			reportError( title, 'Difference in times between dimesimeter and actiwatch is more than 00.001 seconds', savePath );
            disp(['Error: the difference in times between dimesimeter and actiwatch is more than 00.001 seconds', '\nSubject: ', num2str(subject(s)), '\nIntervention: ', num2str(int(s))])
            continue
        end    

        [time, lux, CLA, CS, activity, ZCM, TAT, dactivity, temp, x, y] = ...
			trimData(time, startTime, stopTime, rmStart(s), rmStop(s), lux, ...
			CLA, CS, activity, ZCM, TAT, dactivity, temp, x, y);

        activity = ( mean(dactivity)/mean(activity) )*activity;
		try
			[outputData.phasorMagnitude(s), outputData.phasorAngle(s),...
				outputData.IS(s), outputData.IV(s), outputData.meanCS(s),...
				outputData.magnitudeWithHarmonics(s), ...
				outputData.magnitudeFirstHarmonic(s)] = phasorAnalysis(time, CS, activity);
		catch err
				reportError( title, err.message, savePath );
				continue;
		end
    end
end

%% Save output
outputFile = fullfile(savePath,'output.mat');
save(outputFile,'outputData')
end