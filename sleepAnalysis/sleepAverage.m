function param = sleepAverage(time,activity,bedTime,getupTime,analysisStartTime,analysisEndTime)

% Preallocate sleep parameters
nNights = numel(bedTime);
nightlyParam = cell(nNights,1);

% Call function to calculate sleep parameters for each day
for i1 = 1:nNights
    try
        nightlyParam{i1} = sleepAnalysis(time,activity,...
                analysisStartTime(i1),analysisEndTime(i1),...
                bedTime(i1),getupTime(i1),'auto');
    catch err
        display(err.message);
        display(err.stack);
    end
end

% Unnest sleep parameters
flatParam = cat(1,nightlyParam{:});
varNames = fieldnames(flatParam)';
tempCell = struct2cell(flatParam)';

% Remove empty rows
emptyIdx = cellfun(@isempty,tempCell);
emptyRow = any(emptyIdx,2);
tempCell1 = tempCell(~emptyRow,:);

% Separate numeric parameters
idx1 = cellfun(@isnumeric,tempCell1);
idx2 = ~any(~idx1,1);
varNames2 = varNames(idx2);
tempCell2 = tempCell1(:,idx2);
tempMat = cell2mat(tempCell2);

% Find sleep efficiency
idxSleepEfficiency = strcmpi('sleepEfficiency',varNames2);
sleepEfficiency = tempMat(:,idxSleepEfficiency);

% Find sleep efficiency greater than 50%
idx50pct = sleepEfficiency >= .5;
tempMat2 = tempMat(idx50pct,:);

% Average numeric parameters
tempMat3 = mean(tempMat2,1);

% Create structure for output
tempCell3 = num2cell(tempMat3);
param = cell2struct(tempCell3,varNames2,2);

% Count the nights averaged
param.nightsAveraged = sum(idx50pct);

end