function luxActivityCheck
close all;
clear;
addpath('IO');

%% Read in data from excel spreadsheet of dimesimeter/actiwatch info
workbookFile = fullfile([filesep,filesep],'root','projects',...
    'NIH Alzheimers','CaseWesternData','index.xlsx');
[subject,week,days,dimeStart,dimeSN,dimePath,actiStart,~,...
    actiPath,rmStart,rmStop] = importIndex(workbookFile);

%% Parse data from excel spreadsheet
emptyNumDays =  isnan(days) ;       %Find all the entries with an empty numDays value
days(emptyNumDays) = 7;  			%Set the default value for the numDays to 7

%% Select an output location
username = getenv('USERNAME');
saveDir = uigetdir(fullfile('C:','Users',username,'Desktop'),'Select location to save output.');

%% Creates a text file that records any errors in the data in the same path
%as the results
fid = fopen( fullfile( saveDir, 'Error Report.txt' ), 'w' );
fprintf( fid, 'Error Report \r\n' );
fclose( fid );

%% Have user select input range of subjects
uniqueSubjects = unique(subject);
options = cellstr(num2str(uniqueSubjects));
choice1 = 0;
while choice1 == 0
    choice1 = menu('Select first subject',options);
end
choice2 = 0;
while choice2 == 0
    choice2 = menu('Select last subject',options);
end
logical1 = subject >= uniqueSubjects(choice1) & subject <= uniqueSubjects(choice2);
index1 = 1:length(logical1);
%%
%Matches actiwatch and dimesimeter data: variables with 'd' prefix come
%from dimesimeter and variables without the 'd' come from actiwatch data
%subject = subject #, week = week #, dimeSN = dimesimeter #,
%dimeStart = dimesimeter start time, file = datafile path,
%numdays = # of days to be analyzed after the start date

fig = figure; % Create the figure window
set(fig, 'Position', get(0,'Screensize')); % Maximize figure
for s = index1(logical1)
    disp([' Subject: ',num2str(subject(s)),' Week: ', num2str(week(s))])
    if(~isempty(actiPath{s,1}))
		
		%Creates a title and savepath from the subject # and week #
		errTitle = ['Subject ' num2str(subject(s)) ' Week ' num2str(week(s))];
		
        %Checks if there is a listed actiwatch file for the subject and if
        %there is not it moves to the next subject
        if (isempty(actiPath(s)) == 1)
			reportError( errTitle, 'No actiwatch data available', saveDir );
            continue;
        end
		
        startTime = max(actiStart(s), dimeStart(s));
		stopTime = startTime + days(s);
        %Reads the data from the actiwatch data file
        [activity, ZCM, TAT, time] = deal(0);
        try
            [activity, ZCM, TAT, time] = read_actiwatch_data(actiPath{s}, ...
                                                             startTime, ...
                                                             stopTime);
        catch err
            reportError( errTitle, err.message, saveDir );
            continue;
        end
        %Reads the data from the dimesimeter data file
        try
            [dtime, lux, CLA, CS, dactivity, temp, x, y] = dimedata(dimePath{s, 1}, ...
                                                                dimeSN(s), ...
                                                                startTime, ...
                                                                stopTime);
        catch err
            reportError( errTitle, err.message, saveDir );
            continue;
        end
        % Crops data
		startTime = max(time(1), dtime(1));
		stopTime = min(time(end), dtime(end));
        if length(time) > length(dtime)
			[time, activity, ZCM, TAT] = trimData(time, startTime,...
                stopTime, rmStart(s), rmStop(s), activity, ZCM, TAT);
        end
        if length(time) < length(dtime)
			[dtime, lux, CLA, CS, dactivity, temp, x, y] = ...
                trimData(dtime, startTime, stopTime, ...
				rmStart(s), rmStop(s), lux, CLA, CS, ...
				dactivity, temp, x, y);
        end
        % Continues if there is an error in the dates of the actiwatch
        if length(time) ~= length(dtime)
			reportError( errTitle, 'Mismatch in number of actiwatch values', saveDir );
            continue
        end

        %sets time from dimesimeter and actiwatch equal in order to avoid
        %discrepancies on the order of 1^-3 seconds
        if (max(abs(dtime-time)) < 1e-3)
            time = dtime;
		else
			reportError( errTitle, 'Difference in times between dimesimeter and actiwatch is more than 00.001 seconds', saveDir );
            disp(['Error: the difference in times between dimesimeter and actiwatch is more than 00.001 seconds', '\nSubject: ', num2str(subject(s)), '\nIntervention: ', num2str(int(s))])
            continue
        end    

        [time, lux, CLA, CS, activity, ZCM, TAT, dactivity, temp, x, y] = ...
			trimData(time, startTime, stopTime, rmStart(s), rmStop(s), lux, ...
			CLA, CS, activity, ZCM, TAT, dactivity, temp, x, y);

        activity = ( mean(dactivity)/mean(activity) )*activity;
		try
			%Plot
            [~, name, ~] = fileparts(dimePath{s});
            savePath = fullfile(saveDir, [name,'.jpg']);
            figTitle = {['Subject: ', num2str(subject(s)), ' Week: ', num2str(week(s)), ' Dime SN: ', num2str(dimeSN(s))]; dimePath{s}; [datestr(startTime), ' - ', datestr(stopTime)]};
            plotLuxActivity(time, lux, activity, fig, figTitle, savePath);
		catch err
				reportError( errTitle, err.message, saveDir );
				continue;
		end
    end
end

close(fig); % Close the figure window
end

function plotLuxActivity(time, lux, activity, fig, figTitle, savePath)
clf(fig); % Clear the figure window

loglux = lux;
loglux(loglux < .1) = .1;
loglux = log10(loglux);
subplot(2, 1, 1)
area(time, loglux)
ylabel('log10lux')
ylim([-1 2])
datetick('x')

subplot(2, 1, 2)
area(time, activity)
ylabel('activity')
datetick('x')
title(figTitle,'Interpreter','none')

%Saves the graph
saveas(fig, savePath);
end