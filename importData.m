function [aTime,PIM,dTime,CS,AI] = importData(actiPath,daysimPath,daysimSN)
%IMPORTDATA Import data from Actiwatch and Daysimeter files
%   Detailed description goes here

%% Enable paths to required subfunctions
addpath('IO','CDF');

%% Check if files exist
% Check if actiwatch file exists
if exist(actiPath,'file') ~= 2
    error(['Actiwatch file does not exist. File: ',actiPath]);
end

% Check if Daysimeter file exists
if exist(daysimPath,'file') ~= 2
    error(['Daysimeter file does not exist. File: ',daysimPath]);
end

%% Load Actiwatch file
% Create CDF file name
CDFactiPath = regexprep(actiPath,'\.csv','.cdf');
% Check if CDF versions exist
if exist(CDFactiPath,'file') == 2 % CDF Actiwatch file exists
    actiData = ProcessCDF(CDFactiPath);
    aTime = actiData.Time;
    PIM = actiData.Activity;
else % CDF Actiwatch file does not exist
    % Reads the data from the actiwatch data file
    [aTime,PIM] = importActiwatch(actiPath);
    % Create a CDF version
    WriteActiwatchCDF(CDFactiPath,aTime,PIM);
end

%% Load Daysimeter file
% Create CDF file name
CDFdaysimPath = regexprep(daysimPath,'\.txt','.cdf');
% Check if CDF versions exist
if exist(CDFdaysimPath,'file') == 2 % CDF Daysimeter file exists
    daysimData = ProcessCDF(CDFdaysimPath);
    dTime = daysimData.Time;
    CS = daysimData.CS;
    AI = daysimData.Activity;
else % CDF Actiwatch file does not exist
    % Reads the data from the dimesimeter data file
    [dTime,lux,CLA,CS,AI] = importDime(daysimPath,daysimSN);
    % Create a CDF version
    WriteDaysimeterCDF(CDFdaysimPath,dTime,lux,CLA,CS,AI);
end


end

