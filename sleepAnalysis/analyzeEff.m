function SleepEfficiency = analyzeEff(Time,Activity,BedTime,WakeTime,average,k)

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
SleepEfficiency = cell(Days,1);
% Call function to calculate sleep parameters for each day
for i = 1:Days
    SleepEfficiency{i} = calcEff(Activity,Time,BedTime(i),WakeTime(i),threshold);
end

if average
    SleepEfficiency = mean(cell2mat(SleepEfficiency));
end

end