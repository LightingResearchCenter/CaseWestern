function [aTime, PIM] = importActiwatch(filename, startRow, endRow)
%IMPORTACTIWATCH Import data from an actiwatch CSV file and return as a
%   timeseries
%
%   PIMTS = IMPORTACTIWATCH(FILENAME)
%   Reads data from text file FILENAME for the default selection.
%
%   PIMTS = IMPORTACTIWATCH(FILENAME, STARTROW, ENDROW)
%   Reads data from rows STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   [pimTS] = importActiwatch('13-0_wk0_acti4033.csv',2, 14497);
%
%    See also TEXTSCAN.

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Format string for each line of text:
%   column1: text (%s)
%	column2: text (%s)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
%	column6: double (%f)
%   column7: double (%f)
%	column8: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%f%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1,...
    'Delimiter', delimiter, 'EmptyValue' ,NaN,...
    'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
date1 = dataArray{:, 1};
hour = dataArray{:, 2};
PIM = dataArray{:, 3};

%% remove not a number or empty values
idx = isnan(PIM) | isempty(PIM);
PIM = PIM(~idx);
date1 = date1(~idx);
hour = hour(~idx);

%% Create time array in MATLAB serial date format
aTime = datenum(date1,'mm/dd/yyyy') + datenum(hour,'HH:MM:SS') - datenum('00:00');


end
