function datasetout = checkSleepLog(sleepLog,subject,dTime,AI,mode,varargin)
%CHECKSLEEPLOG Finds or creates appropriate sleep log entries
%   datasetout = checkSleepLog(sleepLog,subject,dTime,AI,1,bedTime,wakeTime)
%   datasetout = checkSleepLog(sleepLog,subject,dTime,AI,2)
%   mode = 1, fixed sleep times
%   mode = 2, dynamic sleep log
%   for mode = 1
%   varargin1 = bed time in fraction of a day
%   varargin2 = wake up time in fraction of a day

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
datasetout.getuplog = false(nDays,1);
switch mode
    case 1
        for i1 = 1:nDays
            dayStart = days(i1);
            dayStop = dayStart + 1;

            % set bed time
            datasetout.bedtime(i1) = floor(dayStart) + varargin{1};
            % set get up time
            datasetout.getuptime(i1) = floor(dayStop) + varargin{2};
            % check that get up time occurs after bed time
            if datasetout.getuptime(i1) < datasetout.bedtime(i1)
                error(['Bed time (',datestr(datasetout.bedtime(i1)),...
                    ') is after get up time (',datestr(datasetout.getuptime(i1)),')']);
            end
        end
    case 2
        for i1 = 1:nDays
            dayStart = days(i1);
            dayStop = dayStart + 1;

            dayIdx = dTime >= dayStart & dTime < dayStop;
            % calculate bed and get up times in case needed
            [tempBedTime,tempGetUpTime] = createSleepLog(dTime(dayIdx),AI(dayIdx));
            % check for a bed time
            bedIdx = sleepLog.bedtime >= dayStart & sleepLog.bedtime < dayStop;
            if sum(bedIdx) == 0 % no valid bed time found
                datasetout.bedtime(i1) = tempBedTime;% use artificial a bed time
        %         datasetout.bedtime(i1) = floor(dayStart) + 23/24; % 11 PM
            elseif sum(bedIdx) == 1 % one valid bed time found
                datasetout.bedtime(i1) = sleepLog.bedtime(bedIdx);
                datasetout.bedlog(i1) = true;
            else % too many possible bed times
                error(['Multiple bed times for 1 day (',...
                    datestr(dayStart),' to ',datestr(dayStop),') not allowed.']);
            end
            % check for a get up time
            upIdx = sleepLog.getuptime >= dayStart + .5 & sleepLog.getuptime < dayStop + .5;
            if sum(upIdx) == 0 % no valid bed time found
                datasetout.getuptime(i1) = tempGetUpTime;% use artificial get up time
        %         datasetout.getuptime(i1) = floor(dayStop) + 7/24; % 7 AM
            elseif sum(upIdx) == 1 % one valid bed time found
                datasetout.getuptime(i1) = sleepLog.getuptime(upIdx);
                datasetout.getuplog(i1) = true;
            else % too many possible bed times
                error(['Multiple get up times for 1 day (',...
                    datestr(dayStart),' to ',datestr(dayStop),') not allowed.']);
            end
            % check that get up time occurs after bed time
            if datasetout.getuptime(i1) < datasetout.bedtime(i1)
                error(['Bed time (',datestr(datasetout.bedtime(i1)),...
                    ') is after get up time (',datestr(datasetout.getuptime(i1)),')']);
            end
        end
    otherwise
        error('Unknown sleep log mode');
end


end

