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
%% Preallocate variables

% Create dataset array
datasetout = dataset;
datasetout.bedtime = zeros(nDays,1);
datasetout.bedlog = false(nDays,1);
datasetout.getuptime = zeros(nDays,1);
datasetout.getuplog = false(nDays,1);
switch mode
    case 1
        %% Fixed sleep times
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
        %% Sleep log
        for i1 = 1:nDays
            dayStart = days(i1);
            dayStop = dayStart + 1;

            %% Check for a bed time
            
            bedIdx = sleepLog.bedtime >= dayStart & sleepLog.bedtime < dayStop;
            % no valid bed time found
            if sum(bedIdx) == 0 
                 datasetout.bedtime(i1) = floor(dayStart) + varargin{1};
            % one valid bed time found
            elseif sum(bedIdx) == 1 
                datasetout.bedtime(i1) = sleepLog.bedtime(bedIdx);
                datasetout.bedlog(i1) = true;
            % too many possible bed times
            else 
                error(['Multiple bed times for 1 day (',...
                    datestr(dayStart),' to ',datestr(dayStop),') not allowed.']);
            end
            
            %% Check for a get up time
            upIdx = sleepLog.getuptime >= dayStart + .5 & sleepLog.getuptime < dayStop + .5;
            % no valid bed time found
            if sum(upIdx) == 0
                datasetout.getuptime(i1) = floor(dayStop) + varargin{2};
            % one valid bed time found
            elseif sum(upIdx) == 1
                datasetout.getuptime(i1) = sleepLog.getuptime(upIdx);
                datasetout.getuplog(i1) = true;
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
    otherwise
        error('Unknown sleep log mode');
end


end

