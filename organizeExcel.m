function organizeExcel(inputFile)
%ORGANIZEEXCEL Organize input data and save to Excel
%   Format for Mariana
load(inputFile);
saveFile = regexprep(inputFile,'\.mat','\.xlsx');

flatOut = cat(1,output{:});
% Determine variable names
varNames = fieldnames(flatOut{1})';

% Flatten nested data and convert to dataset
tempCell = cellfun(@struct2cell,flatOut,'UniformOutput',false);
dataCell = cat(2,tempCell{:})';

%% Create header labels
% Remove line and AIM from varNames
lineIdx = strcmpi(varNames,'line');
aimIdx = strcmpi(varNames,'AIM');
varNames(lineIdx | aimIdx) = [];
% Count the number of variables
varCount = length(varNames);
% Make variable names pretty
prettyNames = lower(regexprep(varNames,'([^A-Z])([A-Z0-9])','$1 $2'));

% Prepare first header row
AIM0Txt = 'baseline (0)';
AIM1Txt = 'intervention (1)';
AIM2Txt = 'post intervention (2)';
spacer = cell(1,varCount-1);
header1 = [{[]},{[]},AIM0Txt,spacer,{[]},AIM1Txt,spacer,{[]},AIM2Txt,spacer]; % Combine parts of header1

% Prepare second header row
header2 = [{'line'},{[]},prettyNames,{[]},prettyNames,{[]},prettyNames];

% Combine headers
header = [header1;header2];

%% Organize data
% Seperate line number and AIM from rest of inputData
lineNum = cell2mat(dataCell(:,lineIdx));
AIM = cell2mat(dataCell(:,aimIdx));
% Remove line number from input data
dataCell(:,lineIdx | aimIdx) = [];

% Identify unique line numbers numbers
unqLine = unique(lineNum);

% Organize data by AIM
nRows = numel(unqLine);
nColumns = numel(header2);
organizedData = cell(nRows,nColumns);

aim0start = 3;
aim0end = aim0start + varCount - 1;

aim1start = aim0end + 2;
aim1end = aim1start + varCount - 1;

aim2start = aim1end + 2;
aim2end = aim2start + varCount - 1;

for i1 = 1:nRows
    % Line number
    organizedData{i1,1} = unqLine(i1);
    % AIM 0
    idx0 = lineNum == unqLine(i1) & AIM == 0;
    if sum(idx0) == 1
        organizedData(i1,aim0start:aim0end) = dataCell(idx0,:);
    end
    % AIM 1
    idx1 = lineNum == unqLine(i1) & AIM == 1;
    if sum(idx1) == 1
        organizedData(i1,aim1start:aim1end) = dataCell(idx1,:);
    end
    % AIM 2
    idx2 = lineNum == unqLine(i1) & AIM == 2;
    if sum(idx2) == 1
        organizedData(i1,aim2start:aim2end) = dataCell(idx2,:);
    end
end


%% Combine headers and data
newOutput = [header;organizedData];

%% Write to file
xlswrite(saveFile,newOutput); % Create sheet1

end

