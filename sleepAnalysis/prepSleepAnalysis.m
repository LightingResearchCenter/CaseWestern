function param = prepSleepAnalysis(subject,time,activity,staticBedTime,staticGetupTime,subLog,bedLogMode,season,repeatSubject,excludeRepeat,week)
% PREPSLEEPANALYSIS Prepare and perform sleep analysis on data from one file
%   This function is specifically prepared for the Case Western project
%   
%   Time must be in MatLab datenum format

%% Prepare input

% Make time and activity vertical vectors
time = time(:);
activity = activity(:);

% Check that time and activity are of equal length
if numel(time) ~= numel(activity)
    error('The variables "time" and "activity" must be of equal length.');
end

% Check if time is sequential. Sort data sequentially if needed.
[srtTime,srtIdx] = sort(time);
if any(srtTime ~= time)
    warining('The variable "time" is not sequential, it and "activity" will be sorted.');
    time = srtTime;
    activity = activity(srtIdx);
end


% Create bed log
switch bedLogMode
    case 1 || 2
        [bedTime,getupTime] = staticBedLog(staticBedTime,staticGetupTime,time(1),time(end));
    case 3
        [bedTime,getupTime] = checkBedLog(subLog,time,activity);
    otherwise
        error('Unknown bed log mode.');
end

% Set analysis start and end times
[analysisStartTime,analysisEndTime,bedTime,getupTime] = ...
    analysisBounds(20,bedTime,getupTime,time(1),time(end));

%% Call function to calculate average sleep parameters
param = sleepAverage(time,activity,bedTime,getupTime,analysisStartTime,analysisEndTime);
tempFields = fieldnames(param)';

param.subject = subject;
param.week = week;
param.repeatSubject = repeatSubject;
param.excludeRepeat = excludeRepeat;
param.season = season;

param = orderfields(param,[{'subject','week','repeatSubject',...
    'excludeRepeat','season'},tempFields]);

end