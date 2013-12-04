function [bedTime,getUpTime] = createSleepLog(Time,AI)
% CREATEBEDTIME

try
    AI = gaussian(AI(idx),4);
catch
end

% Find the bed state
bedState = FindSleepState(AI,.5);

% Find bed state in a 10 minute window
Epoch = etime(datevec(Time(2)),datevec(Time(1))); % Find epoch length in seconds
n10 = ceil(600/Epoch); % Number of points in a 10 minute interval
n5 = floor((n10)/2);
notBedState = ~bedState;
activeState10 = notBedState;
for i1 = -n5:n5
    activeState10 = activeState10 + circshift(notBedState,i1);
end
bedState10 = activeState10 <= 1;
Time2 = Time;

% Remove first and last 10 minutes
last = length(Time2);
Time2((last-n5):last) = [];
bedState10((last-n5):last) = [];
Time2(1:n5) = [];
bedState10(1:n5) = [];

% Find bed time
idxStart = find(bedState10,true,'first');
bedTime = Time2(idxStart);

% Find get up time
idxEnd = find(bedState10,true,'last');
getUpTime = Time2(idxEnd);

end

