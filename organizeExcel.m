function organizeExcel(inputFile)
%ORGANIZEEXCEL Organize input data and save to Excel
%   Format for Mariana
load(inputFile);
saveFile = regexprep(inputFile,'\.mat','\.xlsx');

idxEmpty = cellfun(@isempty,output);
flatOut = output(~idxEmpty);

% flatOut = cat(1,output{:});
% Determine variable names
varNames = fieldnames(flatOut{1})';

% Flatten nested data and convert to dataset
tempCell = cellfun(@struct2cell,flatOut,'UniformOutput',false);
dataCell = cat(2,tempCell{:})';

%% Create header labels
% Remove week from varNames
weekIdx = strcmpi(varNames,'week');
varNames(weekIdx) = [];
% Count the number of variables
varCount = length(varNames);
% Make variable names pretty
prettyNames = lower(regexprep(varNames,'([^A-Z])([A-Z0-9])','$1 $2'));

% Prepare first header row
wk0Txt = 'baseline (0)';
wk1Txt = 'intervention (1)';
wk2Txt = 'post intervention (2)';
spacer = cell(1,varCount-1);
header1 = [{[],[],[],[]},wk0Txt,spacer,{[]},wk1Txt,spacer,{[]},wk2Txt,spacer]; % Combine parts of header1

% Prepare second header row
header2 = [{'subject','season','exclude',[]},prettyNames,{[]},prettyNames,{[]},prettyNames];

% Combine headers
header = [header1;header2];

%% Organize data
% Seperate week from rest of inputData
week = cell2mat(dataCell(:,weekIdx));
% Remove line number from input data
dataCell(:,weekIdx) = [];

subject = cell2mat(dataCell(:,strcmpi(varNames,'subject')));

patientIdx = mod(subject,1) == 0;
patientData = organize(dataCell(patientIdx,:),subject(patientIdx),week(patientIdx),header2,varCount,varNames);
caregiverData = organize(dataCell(~patientIdx,:),subject(~patientIdx),week(~patientIdx),header2,varCount,varNames);
    
%% Combine headers and data
patientOutput = [header;patientData];
caregiverOutput = [header;caregiverData];

%% Write to file
xlswrite(saveFile,patientOutput,'patient'); % Create sheet1
xlswrite(saveFile,caregiverOutput,'caregiver'); % Create sheet2

end

function organizedData = organize(dataCell,subject,week,header2,varCount,varNames)
season = dataCell(:,strcmpi(varNames,'season'));
exclude = dataCell(:,strcmpi(varNames,'excludeRepeat'));

% Identify unique line numbers numbers
[unqSub,ia,~] = unique(subject);
subSeason = season(ia);
subExclude = exclude(ia);

% Organize data by week
nRows = numel(unqSub);
nColumns = numel(header2);
organizedData = cell(nRows,nColumns);

wk0start = 5;
wk0end = wk0start + varCount - 1;

wk1start = wk0end + 2;
wk1end = wk1start + varCount - 1;

wk2start = wk1end + 2;
wk2end = wk2start + varCount - 1;

for i1 = 1:nRows
	% Subject
    organizedData{i1,1} = unqSub(i1);
    
    % Season
    organizedData{i1,2} = subSeason{i1};
    
    % Exclude Repeat
    organizedData{i1,3} = subExclude{i1};
    
    % AIM 0
    idx0 = subject == unqSub(i1) & week == 0;
    if sum(idx0) == 1
        organizedData(i1,wk0start:wk0end) = dataCell(idx0,:);
    end
    % AIM 1
    idx1 = subject == unqSub(i1) & week == 1;
    if sum(idx1) == 1
        organizedData(i1,wk1start:wk1end) = dataCell(idx1,:);
    end
    % AIM 2
    idx2 = subject == unqSub(i1) & week == 2;
    if sum(idx2) == 1
        organizedData(i1,wk2start:wk2end) = dataCell(idx2,:);
    end
end

end