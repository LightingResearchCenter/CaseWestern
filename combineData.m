function [dTime,CS,AI,aTime,PIM] = combineData(aTime,PIM,dTime,CS,AI,startTime,stopTime,rmStart,rmStop)
%COMBINEDATA combine data from Actiwatch and Daysimeter
%   Detailed description goes here

% Crop data to overlapping section
cropStart = max(min(dTime),min(aTime));
cropEnd = min(max(dTime),max(aTime));
idx1 = dTime < cropStart | dTime > cropEnd;
dTime(idx1) = [];
CS(idx1) = [];
AI(idx1) = [];
idx2 = aTime < cropStart | aTime > cropEnd;
aTime(idx2) = [];
PIM(idx2) = [];

% Resample the actiwatch activity for dimesimeter times
PIMts = timeseries(PIM,aTime);
PIMts = resample(PIMts,dTime);
PIMrs = PIMts.Data;

% Remove excess data and not a number values
idx3a = isnan(PIMrs) | dTime < startTime | dTime > stopTime;
idx3b = aTime < startTime | aTime > stopTime;
% Remove specified sections if any
if (~isnan(rmStart))
    idx4a = dTime >= rmStart & dTime <= rmStop;
    idx4b = aTime >= rmStart & aTime <= rmStop;
else
    idx4a = false(numel(dTime),1);
    idx4b = false(numel(aTime),1);
end
idx5a = ~(idx3a | idx4a);
idx5b = ~(idx3b | idx4b);
dTime = dTime(idx5a);
aTime = aTime(idx5b);
PIM = PIM(idx5b);
PIM2 = PIMrs(idx5a);
AI = AI(idx5a);
CS = CS(idx5a);

% Normalize Actiwatch activity to Dimesimeter activity
AI = PIM2*(mean(AI)/mean(PIM2));

end