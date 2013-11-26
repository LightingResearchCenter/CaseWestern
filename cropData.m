function [aTime,PIM] = cropData(aTime,PIM,startTime,stopTime,rmStart,rmStop)
%CROPDATA combine data from Actiwatch and Daysimeter
%   Detailed description goes here

% Remove data outside limits
idx1 = aTime < startTime | aTime > stopTime;
% Remove specified sections if any
if (~isnan(rmStart))
    idx2 = aTime >= rmStart & aTime <= rmStop;
else
    idx2 = false(numel(aTime),1);
end
aTime = aTime(~(idx1 | idx2));
PIM = PIM(~(idx1 | idx2));

end