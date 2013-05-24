function BulkProcess
%BULKPROCESS Summary of this function goes here
%   Detailed explanation goes here

% Select source and output folders
startPath = fullfile('\\root','projects','NIH Light Mask','daysimeter_data');
rawPath = uigetdir(fullfile(startPath,'raw_files'),...
    'Select folder containing raw files.');
processedPath = uigetdir(fullfile(startPath,'processed_files'),...
    'Select folder to save output to.');

% Check if source folder is on current drive
current = regexp(pwd,filesep,'split');
drive = current{1};
inParts = regexp(rawPath,filesep,'split');
inDrive = inParts{1};
if ~strcmp(drive,inDrive)
    copyfile(rawPath,fullfile(pwd,'tempIn'));
    folderIn = 'tempIn';
    inStatus = 1;
else
    folderIn = rawPath;
    inStatus = 0;
end

% Check if destination folder is on current drive
outParts = regexp(rawPath,filesep,'split');
outDrive = outParts{1};
if ~strcmp(drive,outDrive)
    folderOut = 'tempOut';
    copyfile(processedPath,fullfile(pwd,folderOut));
    outStatus = 1;
else
    folderOut = processedPath;
    outStatus = 0;
end

dirData = dir(fullfile(folderIn,'*log_info*'));
headerFiles = {dirData.name}';
dataFiles = regexprep(headerFiles,'log_info','data_log');
saveFiles = regexprep(headerFiles,'log_info','processed');

n = length(headerFiles);

for i1 = 1:n
    WriteProcessed(fullfile(folderIn,headerFiles{i1}),...
        fullfile(folderIn,dataFiles{i1}),...
        fullfile(folderOut,saveFiles{i1}));
end


% Clean up any temporary folders
if inStatus
    rmdir(folderIn,'s');
end

if outStatus
    copyfile(folderOut,processedPath);
    rmdir(folderOut,'s');
end
end

