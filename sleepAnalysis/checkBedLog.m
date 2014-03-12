function [bedTime,getupTime] = checkBedLog(bedLog,time,activity)
%CHECKBEDLOG Finds or creates appropriate sleep log entries
%   datasetout = checkSleepLog(sleepLog,time,activity)

logStart = floor(time(1)) + 0.5;
logStop = ceil(time(end)) - 0.5;
days = logStart:logStop-1;
nDays = numel(days);

% Preallocate variables
bedTime = zeros(nDays,1);
getupTime = zeros(nDays,1);

for i1 = 1:nDays
    dayStart = days(i1);
    dayStop = dayStart + 1;

    % Check for a bed time

    bedIdx = bedLog.bedtime >= dayStart & bedLog.bedtime < dayStop;
    % no valid bed time found
    if sum(bedIdx) == 0 
         bedTime(i1) = floor(dayStart) + varargin{1};
    % one valid bed time found
    elseif sum(bedIdx) == 1 
        bedTime(i1) = bedLog.bedtime(bedIdx);
    % too many possible bed times
    else 
        error(['Multiple bed times for 1 day (',...
            datestr(dayStart),' to ',datestr(dayStop),') not allowed.']);
    end

    % Check for a get up time
    upIdx = bedLog.getuptime >= dayStart + .5 & bedLog.getuptime < dayStop + .5;
    % no valid bed time found
    if sum(upIdx) == 0
        getupTime(i1) = floor(dayStop) + varargin{2};
    % one valid bed time found
    elseif sum(upIdx) == 1
        getupTime(i1) = bedLog.getuptime(upIdx);
    % too many possible bed times
    else
        error(['Multiple get up times for 1 day (',...
            datestr(dayStart),' to ',datestr(dayStop),') not allowed.']);
    end
    % check that get up time occurs after bed time
    if datasetout.getuptime(i1) < datasetout.bedtime(i1)
        error(['Bed time (',datestr(datasetout.bedtime(i1)),...
            ') is after get up time (',datestr(datasetout.getuptime(i1)),')']);
    end
end


end

