function organizeExcel
%ORGANIZEEXCEL Organize input data and save to Excel
%   Format for Mariana
username = getenv('USERNAME');
savePath = fullfile('C:','Users',username,'Desktop','CaseWestern');
[inputName, inputPath] = uigetfile(fullfile(savePath,'*.mat'));
inputFile = fullfile(inputPath,inputName);
load(inputFile);
saveFile = regexprep(inputFile,'\.mat','\.xlsx');
inputData = outputData;
clear outputData;

%% Determine size of input and variable names
[~,varCount] = size(inputData);
varCount = varCount - 2; % Do not count subject number or week
varNames = get(inputData,'VarNames');
% Remove subject and week from varNames
varNameIdx = strcmpi(varNames,'subject') | strcmpi(varNames,'week');
varNames(varNameIdx) = [];

%% Create header labels
% Prepare first header row
week0Txt = 'baseline (0)';
week0Mat = repmat(week0Txt,varCount,1);
week0Head =  mat2cell(week0Mat,ones(1,varCount),length(week0Txt))';

week1Txt = 'intervention (1)';
week1Mat = repmat(week1Txt,varCount,1);
week1Head =  mat2cell(week1Mat,ones(1,varCount),length(week1Txt))';

week2Txt = 'post intervention (2)';
week2Mat = repmat(week2Txt,varCount,1);
week2Head =  mat2cell(week2Mat,ones(1,varCount),length(week2Txt))';

header1 = [{[]},week0Head,week1Head,week2Head]; % Combine parts of header1

% Prepare second header row
header2 = [{'subject'},varNames,varNames,varNames];

% Combine headers
header = [header1;header2];

%% Organize data
% Remove empty lines
idx = inputData.phasorMagnitude == 0 & inputData.phasorAngle == 0 & inputData.IS == 0 & inputData.IV == 0 & inputData.meanCS == 0;
inputData(idx,:) = [];
% Seperate subject and week from rest of inputData
inputData1 = dataset;
inputData1.subject = inputData.subject;
inputData1.week = inputData.week;

% Copy inputData and remove subject and week
inputData2 = inputData;
inputData2.subject = [];
inputData2.week = [];

% Convert inputData2 to cells
inputData2Cell = dataset2cell(inputData2);
inputData2Cell(1,:) = []; % Remove variable names

% Seperate patients and caregivers
subIdx = mod(inputData1.subject,1) == 0;
patient = unique(inputData1.subject(subIdx));
caregiver = unique(inputData1.subject(~subIdx));

% Organize patient data by week
nPatients = length(patient);
outputData1 = cell(nPatients,varCount*3+1);
for i1 = 1:nPatients
    % Subject number
    outputData1{i1,1} = patient(i1);
    % Week 0
    idx0 = inputData1.subject == patient(i1) & inputData1.week == 0;
    if sum(idx0) == 1
        outputData1(i1,2:varCount+1) = inputData2Cell(idx0,:);
    end
    % Week 1
    idx1 = inputData1.subject == patient(i1) & inputData1.week == 1;
    if sum(idx1) == 1
        outputData1(i1,varCount+2:varCount*2+1) = inputData2Cell(idx1,:);
    end
    % Week 2
    idx2 = inputData1.subject == patient(i1) & inputData1.week == 2;
    if sum(idx2) == 1
        outputData1(i1,varCount*2+2:varCount*3+1) = inputData2Cell(idx2,:);
    end
end

% Organize caregiver data by week
nCaregivers = length(caregiver);
outputData2 = cell(nCaregivers,varCount*3+1);
for i2 = 1:nCaregivers
    % Subject number
    outputData2{i2,1} = caregiver(i2);
    % Week 0
    idx0 = inputData1.subject == caregiver(i2) & inputData1.week == 0;
    if sum(idx0) == 1
        outputData2(i2,2:varCount+1) = inputData2Cell(idx0,:);
    end
    % Week 1
    idx1 = inputData1.subject == caregiver(i2) & inputData1.week == 1;
    if sum(idx1) == 1
        outputData2(i2,varCount+2:varCount*2+1) = inputData2Cell(idx1,:);
    end
    % Week 2
    idx2 = inputData1.subject == caregiver(i2) & inputData1.week == 2;
    if sum(idx2) == 1
        outputData2(i2,varCount*2+2:varCount*3+1) = inputData2Cell(idx2,:);
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

