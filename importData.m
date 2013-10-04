function [aTime,PIM,dTime,CS,AI] = importData(actiPath,daysimPath,daysimSN)
%IMPORTDATA Import data from Actiwatch and Daysimeter files
%   Detailed description goes here

%% Check if files exist
% Check if actiwatch file exists
if exist(actiPath,'file') ~= 2
    error(['Actiwatch file does not exist. File: ',actiPath]);
end

% Check if Daysimeter file exists
if exist(daysimPath,'file') ~= 2
    error(['Daysimeter file does not exist. File: ',daysimPath]);
end

%% Import the files
% Reads the data from the actiwatch data file
[aTime, PIM] = importActiwatch(actiPath);

% Reads the data from the dimesimeter data file
[dTime, CS, AI] = importDime(daysimPath,daysimSN);

end

