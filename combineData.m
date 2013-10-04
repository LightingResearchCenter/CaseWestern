function [dTime,CS,AI] = combineData(aTime,PIM,dTime,CS,AI,startTime,stopTime,rmStart,rmStop)
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
idx3 = isnan(PIMrs) | dTime < startTime | dTime > stopTime;
% Remove specified sections if any
if (~isnan(rmStart))
    idx4 = dTime >= rmStart & dTime <= rmStop;
else
    idx4 = false(length(dTime),1);
end
idx5 = ~(idx3 | idx4);
dTime = dTime(idx5);
PIM = PIMrs(idx5);
AI = AI(idx5);
CS = CS(idx5);

% Normalize Actiwatch activity to Dimesimeter activity
AI = PIM*(mean(AI)/mean(PIM));

end