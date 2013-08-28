function [subject,week,days,dimeStart,dimeSN,dimePath,actiStart,actiSN,actiPath,rmStart,rmStop] = importIndex(workbookFile,sheetName,startRow,endRow)
%IMPORTINDEX Import data from a spreadsheet
%   [subject,week,days,dimeStart,dimeSN,dimePath,actiStart,actiSN,actiPath,rmStart,rmStop]
%   = IMPORTFILE(FILE) reads data from the first worksheet in the Microsoft
%   Excel spreadsheet file named FILE and returns the data as column
%   vectors.
%
%   [subject,week,days,dimeStart,dimeSN,dimePath,actiStart,actiSN,actiPath,rmStart,rmStop]
%   = IMPORTFILE(FILE,SHEET) reads from the specified worksheet.
%
%   [subject,week,days,dimeStart,dimeSN,dimePath,actiStart,actiSN,actiPath,rmStart,rmStop]
%   = IMPORTFILE(FILE,SHEET,STARTROW,ENDROW) reads from the specified
%   worksheet for the specified row interval(s). Specify STARTROW and
%   ENDROW as a pair of scalars or vectors of matching size for
%   dis-contiguous row intervals. To read to the end of the file specify an
%   ENDROW of inf.
%
%	Date formatted cells are converted to MATLAB serial date number format
%	(datenum).
%   Non-numeric cells are replaced with: NaN
%
% Example:
%   [subject,week,days,dimeStart,dimeSN,dimePath,actiStart,actiSN,actiPath,rmStart,rmStop]
%   = importfile('index.xlsx','Sheet1',2,207);
%
%   See also XLSREAD.

% Auto-generated by MATLAB on 2013/07/11 10:19:18

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 3
    startRow = 2;
    temp = xlsread(workbookFile);
    endRow = length(temp)+1;
    clear temp;
end

%% Import the data, extracting spreadsheet dates in MATLAB serial date number format (datenum)
[~, ~, raw, dateNums] = xlsread(workbookFile, sheetName, sprintf('A%d:K%d',startRow(1),endRow(1)),'' , @convertSpreadsheetDates);
for block=2:length(startRow)
    [~, ~, tmpRawBlock,tmpDateNumBlock] = xlsread(workbookFile, sheetName, sprintf('A%d:K%d',startRow(block),endRow(block)),'' , @convertSpreadsheetDates);
    raw = [raw;tmpRawBlock]; %#ok<AGROW>
    dateNums = [dateNums;tmpDateNumBlock]; %#ok<AGROW>
end
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,[6,9]);
raw = raw(:,[1,2,3,4,5,7,8,10,11]);
dateNums = dateNums(:,[1,2,3,4,5,7,8,10,11]);

%% Replace date strings by MATLAB serial date numbers (datenum)
R = ~cellfun(@isequalwithequalnans,dateNums,raw) & cellfun('isclass',raw,'char'); % Find spreadsheet dates
raw(R) = dateNums(R);

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Allocate imported array to column variable names
subject = data(:,1);
week = data(:,2);
days = data(:,3);
dimeStart = data(:,4);
dimeSN = data(:,5);
dimePath = cellVectors(:,1);
actiStart = data(:,6);
actiSN = data(:,7);
actiPath = cellVectors(:,2);
rmStart = data(:,8);
rmStop = data(:,9);

%% Complete file paths replace ...\
[pathstr, ~, ~] = fileparts(workbookFile);
dimePath = fullfile(pathstr,dimePath);
actiPath = fullfile(pathstr,actiPath);
