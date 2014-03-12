function [analysisStartTime,analysisEndTime,bedTime,getupTime] = analysisBounds(buffer,bedTime,getupTime,minTime,maxTime)
%ANALYSISBOUNDS Summary of this function goes here
%   buffer is in minutes
%   all other inputs are in datenum

analysisStartTime = bedTime - buffer/60/24;
analysisEndTime = getupTime + buffer/60/24;

% Remove analysis start and end times outside the time range
idxBef = (analysisStartTime < minTime) | (analysisEndTime < minTime); % before the min time
idxAft = (analysisStartTime > maxTime) | (analysisEndTime > maxTime); % after the max time
idxRmv = idxBef | idxAft; % indices of out of range entries to be removed

analysisStartTime(idxRmv) = [];
analysisEndTime(idxRmv) = [];
bedTime(idxRmv) = [];
getupTime(idxRmv) = [];

end

