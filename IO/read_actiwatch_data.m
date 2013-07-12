function [PIM, ZCM, TAT, time] = read_actiwatch_data(path, start, stop)
	
	try
		dataArray = importfile(path); %Imports data as a struct from actiwatch data files
	catch
		error('Invalid Actiwatch Data path');
	end
		
    %Following are three methods used to determine sleep times: PIM (Proportional Integral Mode), TAT (Time Above Threshold), ZCM (Zero
    %Cross Mode)
    %% Allocate imported array to column variable names
    PIM = dataArray{:, 3};
    ZCM = dataArray{:, 4};
    TAT = dataArray{:, 5};
    light = dataArray{:, 6};
    events = dataArray{:, 7};
	
    date1 = dataArray{:, 1};
    hour = dataArray{:, 2};
    
    time = datenum(date1, 'mm/dd/yyyy') + datenum(hour, 'HH:MM:SS') - datenum('00:00');
	if abs(time(1) - start) > 7
		error('Actiwatch start times mismatch')
	end
	
    %Eliminates data outside of start and end times
    q = find((time >= start) & (time <= stop));
    time = time(q);
    PIM = PIM(q);
    TAT = TAT(q);
    ZCM = ZCM(q);
    %sleep = sleep(q);
    
end

function dataArray = importfile(filename)
%% Initialize variables.
delimiter = ',';
startRow = 2;
endRow = inf;

%% Format string for each line of text:
%   column1: text (%s)
%	column2: text (%s)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
%	column6: double (%f)
%   column7: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

end
