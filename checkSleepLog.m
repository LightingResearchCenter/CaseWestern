function datasetout = checkSleepLog(sleepLog,subject,dTime,AI)
%CHECKSLEEPLOG Finds or creates appropriate sleep log entries
%   Detailed explanation goes here

% find the entries that pertain to the subject if they exist
idxSub = sleepLog.subject == subject;
sleepLog = sleepLog(idxSub,:);

% 
logStart = floor(min(dTime)) + 0.5;
logStop = ceil(max(dTime)) - 0.5;
days = logStart:logStop-1;
nDays = numel(days);
% Preallocate variables
datasetout = dataset; % Create dataset array
datasetout.bedtime = zeros(nDays,1);
datasetout.bedlog = false(nDays,1);
datasetout.getuptime = zeros(nDays,1);
datasetout.uplog = false(nDays,1);

for i1 = 1:nDays
    dayStart = days(i1);
    dayStop = dayStart + 1;
    dayIdx = dTime >= dayStart & dTime < dayStop;
    % check for a bed time
    bedIdx = sleepLog.bedtime >= dayStart & sleepLog.bedtime < dayStop;
    if sum(bedIdx) == 0 % no valid bed time found
        datasetout.bedtime(i1) = createBedTime(dTime(dayIdx),AI(dayIdx));% create a bed time
    elseif sum(bedIdx) == 1 % one valid bed time found
        datasetout.bedtime(i1) = sleepLog.bedtime(bedIdx);
        datasetout.bedlog(i1) = true;
    else % too many possible bed times
        error('Multiple bed times for 1 day not allowed.');
    end
    % check for a bed time
    upIdx = sleepLog.getuptime >= dayStart & sleepLog.getuptime < dayStop;
    if sum(upIdx) == 0 % no valid bed time found
        datasetout.getuptime(i1) = createGetUpTime(dTime(dayIdx),AI(dayIdx));% create a bed time
    elseif sum(upIdx) == 1 % one valid bed time found
        datasetout.getuptime(i1) = sleepLog.getuptime(upIdx);
        datasetout.getuplog(i1) = true;
    else % too many possible bed times
        error('Multiple get up times for 1 day not allowed.');
    end
end


end

