function organizeResultsExcel(datasetin,saveFile)
%ORGANIZEEXCEL Organize input data and save to Excel
%   Format for Mariana

%% Determine size of input and variable names
% Make varNames pretty
uglyVarNames = get(datasetin,'VarNames');
varNames = lower(regexprep(uglyVarNames,'([^A-Z])([A-Z])','$1 $2'));
% Set nonrepeating variables
nonrepNames = {'subject','repeat subject','exclude repeat','season','week'};
nonrepCount = numel(nonrepNames) - 1; % not including week
% Remove variables that do not get repeated from varNames
varNameIdx = strcmpi(varNames,nonrepNames{1});
for i0 = 2:nonrepCount+1
    varNameIdx = strcmpi(varNames,nonrepNames{i0}) | varNameIdx;
end
varNames(varNameIdx) = [];
varCount = numel(varNames);

%% Create header labels
% Prepare first header row
week0Txt = 'baseline (0)';
week0Head = [{week0Txt},cell(1,varCount-1)];

week1Txt = 'intervention (1)';
week1Head = [{week1Txt},cell(1,varCount-1)];

week2Txt = 'post intervention (2)';
week2Head = [{week2Txt},cell(1,varCount-1)];

header1 = [cell(1,nonrepCount),week0Head,week1Head,week2Head]; % Combine parts of header1

% Prepare second header row
header2 = [{'subject'},{'repeat subject'},{'exclude repeat'},{'season'},varNames,varNames,varNames];

% Combine headers
header = [header1;header2];

%% Organize data
% Seperate nonrepeating variables from inputData
inputData1 = dataset;
inputData1.subject = datasetin.subject;
inputData1.repeatSubject = datasetin.repeatSubject;
inputData1.excludeRepeat = datasetin.excludeRepeat;
inputData1.week = datasetin.week;
inputData1.season = datasetin.season;

% Copy inputData and remove nonrepeating
inputData2 = datasetin;
inputData2.subject = [];
inputData2.repeatSubject = [];
inputData2.excludeRepeat = [];
inputData2.week = [];
inputData2.season = [];

% Convert inputData2 to cells
inputData2Cell = dataset2cell(inputData2);
inputData2Cell(1,:) = []; % Remove variable names

% Seperate patients and caregivers
subIdx = mod(inputData1.subject,1) == 0;
[patient,iP,~] = unique(inputData1.subject(subIdx));
tempPR = inputData1.repeatSubject(subIdx);
patientRepeat = tempPR(iP);
tempPE = inputData1.excludeRepeat(subIdx);
patientExclude = tempPE(iP);
[caregiver,iC,~] = unique(inputData1.subject(~subIdx));
tempCR = inputData1.repeatSubject(~subIdx);
caregiverRepeat = tempCR(iC);
tempCE = inputData1.excludeRepeat(~subIdx);
caregiverExclude = tempCE(iC);

% Organize patient data by week
nPatients = length(patient);
outputData1 = cell(nPatients,varCount*3+1);
for i1 = 1:nPatients
    % Subject number
    outputData1{i1,1} = patient(i1);
    % Repeat number
    outputData1{i1,2} = patientRepeat{i1};
    % Repeat exclude
    outputData1{i1,3} = patientExclude{i1};
    % Week 0
    idx0 = inputData1.subject == patient(i1) & inputData1.week == 0;
    if sum(idx0) == 1
        outputData1{i1,4} = inputData1.season{idx0}; %assign season
        outputData1(i1,nonrepCount+1:varCount+nonrepCount) = inputData2Cell(idx0,:);
    end
    % Week 1
    idx1 = inputData1.subject == patient(i1) & inputData1.week == 1;
    if sum(idx1) == 1
        outputData1(i1,varCount+nonrepCount+1:varCount*2+nonrepCount) = inputData2Cell(idx1,:);
    end
    % Week 2
    idx2 = inputData1.subject == patient(i1) & inputData1.week == 2;
    if sum(idx2) == 1
        outputData1(i1,varCount*2+nonrepCount+1:varCount*3+nonrepCount) = inputData2Cell(idx2,:);
    end
end

% Organize caregiver data by week
nCaregivers = length(caregiver);
outputData2 = cell(nCaregivers,varCount*3+1);
for i2 = 1:nCaregivers
    % Subject number
    outputData2{i2,1} = caregiver(i2);
    % Repeat number
    outputData2{i2,2} = caregiverRepeat{i2};
    % Repeat exclude
    outputData2{i2,3} = caregiverExclude{i2};
    % Week 0
    idx0 = inputData1.subject == caregiver(i2) & inputData1.week == 0;
    if sum(idx0) == 1
        outputData2{i2,4} = inputData1.season{idx0}; %assign season
        outputData2(i2,nonrepCount+1:varCount+nonrepCount) = inputData2Cell(idx0,:);
    end
    % Week 1
    idx1 = inputData1.subject == caregiver(i2) & inputData1.week == 1;
    if sum(idx1) == 1
        outputData2(i2,varCount+nonrepCount+1:varCount*2+nonrepCount) = inputData2Cell(idx1,:);
    end
    % Week 2
    idx2 = inputData1.subject == caregiver(i2) & inputData1.week == 2;
    if sum(idx2) == 1
        outputData2(i2,varCount*2+nonrepCount+1:varCount*3+nonrepCount) = inputData2Cell(idx2,:);
    end
end

%% Combine headers and data
output1 = [header;outputData1];
output2 = [header;outputData2];

%% Create Excel file and write output to appropriate sheet
% Set sheet names
sheet1 = 'patient';
sheet2 = 'caregiver';
% Write to file
xlswrite(saveFile,output1,sheet1); % Create sheet1
xlswrite(saveFile,output2,sheet2); % Create sheet2

end

