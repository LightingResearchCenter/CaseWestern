function [bedTime,getupTime] = staticBedLog(staticBedTime,staticGetupTime,minTime,maxTime)
%STATICBEDLOG Create bedTime and getupTime array from static times
%   staticBedTime and staticGetupTime must be in fractions of a day
%   minTime and maxTime are datenums specifying the desired range

% Create a list of dates that need bed and get up times
days = floor(minTime):floor(maxTime);

% Create a list of bed times
bedTime = days + staticBedTime;

% Create a list of get up times that occur after their matching bed time
if staticBedTime > staticGetupTime
    getupTime = days + 1 + staticGetupTime;
else
    getupTime = days + staticGetupTime;
end

% Remove any bed and get up times outside the time range
idxBef = (bedTime < minTime) | (getupTime < minTime); % before the min time
idxAft = (bedTime > maxTime) | (getupTime > maxTime); % after the max time
idxRmv = idxBef | idxAft; % indices of out of range entries to be removed

bedTime(idxRmv) = [];
getupTime(idxRmv) = [];

end

