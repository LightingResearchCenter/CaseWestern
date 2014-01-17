function [ActualSleep,ActualSleepPercent,ActualWake,...
    ActualWakePercent,SleepEfficiency,Latency,SleepBouts,...
    WakeBouts,MeanSleepBout,MeanWakeBout] = ...
    AnalyzeFile(Time,Activity,BedTime,WakeTime,average,k)

Days = length(BedTime);

% Calculate threshold from activity
bedIdx = false(size(Time));
for i0 = 1:Days
    bedIdx = (Time >= BedTime(i0) & Time <= WakeTime(i0)) | bedIdx;
end
activeIdx = ~bedIdx;
meanActive = mean(Activity(activeIdx));
epoch = round((Time(2)-Time(1))*24*60*60)/60; % Epoch in minutes
threshold = meanActive*k/epoch;

% Preallocate sleep parameters
SleepStart = cell(Days,1);
SleepEnd = cell(Days,1);
ActualSleep = cell(Days,1);
ActualSleepPercent = cell(Days,1);
ActualWake = cell(Days,1);
ActualWakePercent = cell(Days,1);
SleepEfficiency = cell(Days,1);
Latency = cell(Days,1);
SleepBouts = cell(Days,1);
WakeBouts = cell(Days,1);
MeanSleepBout = cell(Days,1);
MeanWakeBout = cell(Days,1);
% Call function to calculate sleep parameters for each day
for i = 1:Days
    [SleepStart{i},SleepEnd{i},ActualSleep{i},...
        ActualSleepPercent{i},ActualWake{i},ActualWakePercent{i},...
        SleepEfficiency{i},Latency{i},SleepBouts{i},WakeBouts{i},...
        MeanSleepBout{i},MeanWakeBout{i}] = ...
        CalcSleepParams(Activity,Time,BedTime(i),WakeTime(i),threshold);
end

if average
    ActualSleep = mean(cell2mat(ActualSleep));
    ActualSleepPercent = mean(cell2mat(ActualSleepPercent));
    ActualWake = mean(cell2mat(ActualWake));
    ActualWakePercent = mean(cell2mat(ActualWakePercent));
    SleepEfficiency = mean(cell2mat(SleepEfficiency));
    Latency = mean(cell2mat(Latency));
    SleepBouts = mean(cell2mat(SleepBouts));
    WakeBouts = mean(cell2mat(WakeBouts));
    MeanSleepBout = mean(cell2mat(MeanSleepBout));
    MeanWakeBout = mean(cell2mat(MeanWakeBout));
end

end