function SleepEfficiency = calcEff(Activity,Time,bedTime,wakeTime,threshold)
%CALCSLEEPPARAMS Calculate sleep parameters using Actiware method
%   Values and calculations are taken from Avtiware-Sleep
%   Version 3.4 documentation Appendix: A-1 Actiwatch Algorithm

% Find epoch length in seconds rounded to the nearest second
Epoch = round((Time(2)-Time(1))*24*60*60);

% Trim Activity and Time to times within the Start and End of the analysis
% period
buffer = 5/(60*24); % 5 minute buffer
idx = Time >= (bedTime - buffer) & Time <= (wakeTime + buffer);
Time = Time(idx);
Activity = Activity(idx);

% Find the sleep state
sleepState = FindSleepState(Activity,threshold);

% Find sleep state in a 10 minute window
n10 = ceil(600/Epoch); % Number of points in a 10 minute interval
n5 = floor((n10)/2);
notSleepState = ~sleepState;
activeState10 = notSleepState;
for i1 = -n5:n5
    activeState10 = activeState10 + circshift(notSleepState,i1);
end
sleepState10 = activeState10 <= 1;
Time2 = Time;

% Remove first and last 10 minutes
last = length(Time2);
Time2((last-n5):last) = [];
sleepState10((last-n5):last) = [];
Time2(1:n5) = [];
sleepState10(1:n5) = [];

% Find Sleep Start
idxStart = find(sleepState10,true,'first');
SleepStart = Time2(idxStart);

% Find Sleep End
idxEnd = find(sleepState10,true,'last');
SleepEnd = Time2(idxEnd);

%% Calculate the parameters
if isempty(SleepStart) || isempty(SleepEnd)
    inBedSleeping = false(size(Time));
else
    inBedSleeping = Time >= SleepStart & Time <= SleepEnd;
end
% Calculate Actual Sleep Time in minutes
ActualSleep = sum(sleepState(inBedSleeping))*Epoch/60;

% Calculate Sleep Efficiency in minutes
TimeInBed = etime(datevec(wakeTime),datevec(bedTime))/60;
SleepEfficiency = ActualSleep/TimeInBed;


end