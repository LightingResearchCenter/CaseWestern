function Case_Western_Sleep_Analysis
close all
fclose('all');
addpath('IO');

%reads in data from excel spreadsheet of dimesimeter/actiwatch info
startingFile = fullfile('\\ROOT','Public','malhor','AIM3',...
                        'AIM3 lookup actigraph file included.xlsx');
[fileName, pathName] = uigetfile(startingFile,...
                        'Select Subject Information Spreadsheet');
[num,txt,~] = xlsread( [pathName, fileName]);

username = getenv('USERNAME');
savePath = uigetdir(fullfile('C:','Users',username,'Desktop','CaseWestern'));

%Creates a text file that records any errors in the data in the same path
%as the results
fid = fopen( fullfile( savePath, 'Error Report.txt' ), 'w' );
fprintf( fid, 'Error Report \r\n' );
fclose( fid );


sub = num(:,1);                         %Subject number
intervention = num(:,2);                %Intervention stage
aim = num(:,3);                         %AIM number
start = datenum(char(txt(2:end,5)));    %Start date
numdays = num(:,13);                    %Number of days ecperiment lasted (7)
emptyNumDays =  isnan(numdays) ;        %Find all the entries with an empty numDays value
numdays(emptyNumDays) = 7;  			%Set the default value for the numDays to 7
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

%% Create figure
figure1 = figure(1);
paperPosition = [0 0 11 8.5];
set(figure1,'PaperUnits','inches',...
    'PaperType','usletter',...
    'PaperOrientation','landscape',...
    'PaperPositionMode','manual',...
    'PaperPosition',paperPosition,...
    'Units','inches',...
    'Position',paperPosition);
%%
lengthSub = length(sub);
phasorMagnitude = zeros(lengthSub,1);
phasorAngle = zeros(lengthSub,1);
IS = zeros(lengthSub,1);
IV = zeros(lengthSub,1);
mCS = zeros(lengthSub,1);
MagH = zeros(lengthSub,1);
f24abs = zeros(lengthSub,1);
for s = 1:lengthSub
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
		
		matFilePath = fullfile(subjectSavePath, 'dime_watch_data.mat');
		if (~exist(matFilePath, 'file'))
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
			
			
			save(matFilePath, 'activity', 'ZCM', 'TAT', 'time', 'dtime', 'lux', 'CLA', 'CS', 'dactivity', 'temp', 'x', 'y');
			%srate = 1/(dtime(3) - dtime(2));
		else
			load(matFilePath);
		end
		
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

        activity = ( mean(dactivity)/mean(activity) )*activity;
        PhasorFile = fullfile( subjectSavePath, [title, '.pdf'] );

        [phasorMagnitude(s),phasorAngle(s),IS(s),IV(s),mCS(s),MagH(s),f24abs(s)] = PhasorReport( time, CS, activity, title );
        print( gcf, '-dpdf', PhasorFile );
        clf(1);
   
    end
end
close all;
%% Create Excel file
excelFile = fullfile(savePath,'output.xlsx');
xlswrite(excelFile,{'subject','intervention','phasor magnitude',...
    'phasor angle','IS','IV','mean CS','magnitude with harmonics',...
    'magnitude of 1st harmonic'},'A1:I1'); % Create Header row
dataRange = ['A2:I',num2str(length(sub))];
xlswrite(excelFile,[sub,intervention,phasorMagnitude,phasorAngle,IS,...
    IV,mCS,MagH,f24abs],dataRange);
end