function [SleepStart,SleepEnd,ActualSleep,ActualSleepPercent,...
    ActualWake,ActualWakePercent,SleepEfficiency,Latency,SleepBouts,...
    WakeBouts,MeanSleepBout,MeanWakeBout] = ...
    CalcSleepParams(Activity,Time,AnalysisStart,AnalysisEnd,...
    BedTime,GetUpTime,Threshold,f)
%CALCSLEEPPARAMS Calculate sleep parameters using Actiware method
%   Values and calculations are taken from Avtiware-Sleep
%   Version 3.4 documentation Appendix: A-1 Actiwatch Algorithm

% Trim Activity and Time to times within the Start and End of the analysis
% period
i = find(Time > AnalysisStart,1);
if i >= length(Time);
    error(['index = ',num2str(i)]);
elseif i > 1
    Activity(1:i) = [];
    Time(1:i) = [];
end
i = find(Time < AnalysisEnd,1,'last');
if i == 1
    error(['index = ',num2str(i)]);
elseif i < length(Time)
    Activity(i+1:end) = [];
    Time(i+1:end) = [];
end
clear i

% Find the sleep state
SleepState = FindSleepState(Activity,Threshold,f);

Epoch = etime(datevec(Time(2)),datevec(Time(1))); % Find epoch length
n = ceil(300/Epoch); % Number of points in a 5 minute interval

% Find Sleep Start
i = 1+n;
while i <= length(SleepState)-n
    if length(find(SleepState(i-n:i+n)==0)) == 1
        SleepStartIndex = i;
        SleepStart = Time(i);
        break
    else
        i = i+1;
    end
end

% Set Sleep Start to Bed Time if it was not found
if exist('SleepStart','var') == 0
    SleepStart = BedTime;
    SleepStartIndex = find(Time > BedTime,1);
end

% Find Sleep End
j = length(Time)-n;
while j > n+1
    if length(find(SleepState(j-n:j+n)==0)) == 1
        SleepEndIndex = j;
        SleepEnd = Time(j);
        break
    else
        j = j-1;
    end
end
% Returns zero values for all parameters if data is unusable
if exist('SleepEnd','var') == 0 || AnalysisStart > datenum(2013,1,1)
    SleepStart = datenum(0,1,1);
    SleepEnd = datenum(0,1,1);
    ActualSleep = 0;
    ActualSleepPercent = 0;
    ActualWake = 0;
    ActualWakePercent = 0;
    SleepEfficiency = 0;
    Latency = 0;
    SleepBouts = 0;
    WakeBouts = 0;
    MeanSleepBout = 0;
    MeanWakeBout = 0;
else % Otherwise calculate the parameters
    % Calculate Assumed Sleep in minutes
    AssumedSleep = etime(datevec(Time(SleepEndIndex)),datevec(Time(SleepStartIndex)))/60;
    % Calculate Actual Sleep Time in minutes
    ActualSleep = sum(SleepState(SleepStartIndex:SleepEndIndex))*Epoch/60;
    % Calculate Actual Sleep Time Percentage
    ActualSleepPercent = ActualSleep*100/AssumedSleep;
    % Calculate Actual Wake Time in minutes
    ActualWake = length(find(SleepState(SleepStartIndex:SleepEndIndex)==0))*Epoch/60;
    % Calculate Actual Wake Time Percentage
    ActualWakePercent = ActualWake*100/AssumedSleep;
    % Calculate Sleep Efficiency in minutes
    TimeInBed = etime(datevec(GetUpTime),datevec(BedTime))/60;
    SleepEfficiency = ActualSleep*100/TimeInBed;
    % Calculate Sleep Latency in minutes
    Latency = etime(datevec(SleepStart),datevec(BedTime))/60;
    % Find Sleep Bouts and Wake Bouts
    SleepBouts = 0;
    WakeBouts = 0;
    for i = 2:length(SleepState)
        if SleepState(i) == 1 && SleepState(i-1) == 0
            SleepBouts = SleepBouts+1;
        end
        if SleepState(i) == 0 && SleepState(i-1) == 1
            WakeBouts = WakeBouts+1;
        end
    end
    % Calculate Mean Sleep Bout Time in minutes
    MeanSleepBout = ActualSleep/SleepBouts;
    % Claculate Mean Wake Bout Time in minutes
    MeanWakeBout = ActualWake/WakeBouts;
end

end