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
emptyNumDays =  isnan(days) ;        %Find all the entries with an empty numDays value
days(emptyNumDays) = 7;  			%Set the default value for the numDays to 7
dimeStop = dimeStart + days;                 %End date

%% Select an output location
username = getenv('USERNAME');
savePath = uigetdir(fullfile('C:','Users',username,'Desktop','CaseWestern'));

%% Creates a text file that records any errors in the data in the same path
%as the results
fid = fopen( fullfile( savePath, 'Error Report.txt' ), 'w' );
fprintf( fid, 'Error Report \r\n' );
fclose( fid );

%% Look for files that need cropping and store the date
crop_start = zeros( 1, length(txt));
crop_end = zeros( 1, length(txt));
for iCrop = 2:length(txt)
	if (~strcmpi( '', txt(iCrop, 16) ))
		crop_start(1, iCrop) = datenum(char(txt(iCrop,16)));
		crop_end(1, iCrop) = datenum(char(txt(iCrop,17)));
	end
end


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

for s = 1:lengthSub
    disp(['s = ', num2str(s),' Subject: ', num2str(subject(s)),' Intervention: ', num2str(week(s))])
    if(aim(s) == 3 && actiPath(s,1) == '\')
		
		title = ['Subject ' num2str(subject(s)) ' Intervention ' num2str(week(s))];
		subjectSavePath = fullfile( savePath, num2str(subject(s)) );
		mkdir( subjectSavePath );
		
        %Checks if there is a listed actiwatch file for the subject and if
        %there is not it moves to the next subject
        if (isempty(actiPath(s)) == 1)
			reportError( title, 'No actiwatch data available', savePath );
            continue;
        end
		
		matFilePath = fullfile(subjectSavePath, ['dime_watch_data_',num2str(week(s)),'.mat']);
		if (~exist(matFilePath, 'file'))
            try
				[activity, ZCM, TAT, time] = read_actiwatch_data(actiPath(s,:), dimeStart(s), dimeStop(s));
			catch err
				reportError( title, err.message, savePath );
				if (strcmp( err.message, 'Invalid Actiwatch Data path' ))
					continue;
				end
            end

			[dtime, lux, CLA, CS, dactivity, temp, x, y] = dimedata(num, txt, s, dimeStart(s), dimeStop(s));
			
			
			save(matFilePath, 'activity', 'ZCM', 'TAT', 'time', 'dtime', 'lux', 'CLA', 'CS', 'dactivity', 'temp', 'x', 'y');
			%srate = 1/(dtime(3) - dtime(2));
		else
			load(matFilePath);
		end
		
        % Crops data
        if length(time) ~= length(dtime)
            try
                dimeStop(s) = min(time(end),dtime(end));
            catch err
                reportError( title, err.message, savePath );
                continue;
            end
            q = time <= dimeStop(s);
            time = time(q);
            activity = activity(q);
            TAT = TAT(q);
            ZCM = ZCM(q);
            dq = dtime <= dimeStop(s);
            dtime = dtime(dq);
            lux = lux(dq);
            CLA = CLA(dq);
            dactivity = dactivity(dq);
            CS = CS(dq);
            temp = temp(dq);
            x = x(dq);
            y = y(dq);
        end
        % Continues if there is an error in the dates of the actiwatch
        if length(time) ~= length(dtime)
			reportError( title, 'Error in actiwatch dates', savePath );
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

        [dtime, lux, CLA, dactivity, temp,x , y] = selectDays(dimeStart(s), datestr(dimeStart(s) + days(s)), dtime, lux, CLA, dactivity, temp, x, y, crop_start, crop_end);

        activity = ( mean(dactivity)/mean(activity) )*activity;

        [outputData.phasorMagnitude(s),outputData.phasorAngle(s),...
            outputData.IS(s),outputData.IV(s),outputData.meanCS(s),...
            outputData.magnitudeWithHarmonics(s),...
            outputData.magnitudeFirstHarmonic(s)] = phasorAnalysis( time, CS, activity, title );
   
    end
end

%% Save output
outputFile = fullfile(savePath,'output.mat');
save(outputFile,'outputData')
end