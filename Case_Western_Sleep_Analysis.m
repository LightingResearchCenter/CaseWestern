clear
close all
%hold off
clc
fclose('all');
addpath('IO');
% savefile = fullfile('\\ROOT','projects',...
%     'Daysimeter and dimesimeter reference files','Dimesimeters',...
%     'Case Western Subjects','Actigraph Routine.xls');

%reads in data from excel spreadsheet of dimesimeter/actiwatch info
startingFile = fullfile('\\ROOT','Public','malhor','AIM3',...
                        'AIM3 lookup actigraph file included.xlsx');
[fileName, pathName] = uigetfile(startingFile,...
                        'Select Subject Information Spreadsheet');
[num,txt,raw] = xlsread( [pathName, fileName]);

username = getenv('USERNAME');
savePath = uigetdir(fullfile('C:','Users',username,'Desktop','CaseWestern'));

%Creates a text file that records any errors in the data in the same path
%as the results
fid = fopen( fullfile( savePath, 'Error Report.txt' ), 'w' );
fprintf( fid, 'Error Report \n' );
fclose( fid );


sub = num(:,1);                         %Subject number
intervention = num(:,2);                %Intervention stage
aim = num(:,3);                         %AIM number
start = datenum(char(txt(2:end,5)));    %Start date
numdays = num(:,13);                    %Number of days ecperiment lasted (7)
emptyNumDays = find( isnan(numdays) );	%Find all the entries with an empty numDays value
numdays( emptyNumDays ) = 7;			%Set the default value for the numDays to 7
stop = start + numdays;                 %End date
file = char(txt(2:end,7));              %Path to the subject's dimesimeter data file
dime = num(:,6);
sub_check = num(9,:);
intervention_check = num(:,10);
aim_check = num(:,11);
path2 = char(txt(2:end,15)); % Path to actiwatch data file

%Look for files that need cropping and store the date
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


row = 0;
lastsub = 0;

for s = 1:length(sub)
    disp(['s = ', num2str(s),' Subject: ', num2str(sub(s)),' Intervention: ', num2str(intervention(s))])
    if(aim(s) == 3 && path2(s,1) == '\')
		
		title = ['Subject ' num2str(sub(s)) ' Intervention ' num2str(intervention(s))];
		subjectSavePath = fullfile( savePath, num2str(sub(s)) );
		mkdir( subjectSavePath );
		
        %Checks if there is a listed actiwatch file for the subject and if
        %there is not it moves to the next subject
        if (isempty(path2(s)) == 1)
			reportError( title, 'No actiwatch data available', savePath );
			continue;
		end

 		try
			[PIM, ZCM, TAT, time] = read_actiwatch_data(path2(s,:), start(s), stop(s));
		catch err
			reportError( title, err.message, savePath );
			if (strcmp( err.message, 'Invalid Actiwatch Data path' ))
				continue;
			end
		end
		
		activity = PIM;


        [dtime, lux, CLA, CS, dactivity, temp, x, y] = dimedata(num, txt, s, numdays);
        srate = 1/(dtime(3) - dtime(2));

        %%Continues if there is an error in the dates of the actiwatch
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
            disp(['Error: the difference in times between dimesimeter and actiwatch is more than 00.001 seconds', '\nSubject: ', num2str(sub(s)), '\nIntervention: ', num2str(int(s))])
            continue
        end    

        [dtime, lux, CLA, dactivity, temp,x , y] = selectDays(start(s), datestr(start(s) + numdays(s)), dtime, lux, CLA, dactivity, temp, x, y, crop_start, crop_end);

		%Error cause here
        activity = ( mean(dactivity)/mean(activity) )*activity;
%         t = time(1):(60/85400):time(end);
% %       dactivity = interp1(dtime, dactivity, t, 'linear', 0.0);
%         activity = interp1(time, activity, t, 'linear', 0.0); 
%         CS = interp1(dtime, CS, t, 'linear', 0.0);
%         lux = interp1(dtime, lux, t, 'linear', 0.0);

        existingPhasorFile = fullfile( subjectSavePath, [title, '.fig'] );
		if (~exist( existingPhasorFile, 'file' ))
			PhasorReport( time, CS, activity, title, subjectSavePath );
		end;
   
    end
    close all
end