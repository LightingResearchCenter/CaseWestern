function [PIM, ZCM, TAT, time] = read_actiwatch_data(path, start, stop)
	
	try
		data = importdata(path); %Imports data as a struct from actiwatch data files
	catch
		error( 'Invalid Actiwatch Data path');
	end
		
    %Following are three methods used to determine sleep times: PIM (Proportional Integral Mode), TAT (Time Above Threshold), ZCM (Zero
    %Cross Mode)
    PIM = data.data(:,1);
    ZCM = data.data(:,2);
    TAT = data.data(:,3);
    light = data.data(:,4);
    events = data.data(:,5);
    %sleep = data.data(:,6);
	
    date = data.textdata(2:end,1);
    hour = data.textdata(2:end,2);
    
    time = datenum(date, 'mm/dd/yyyy') + datenum(hour, 'HH:MM:SS') - datenum('00:00');
   
    %Eliminates data outside of start and end times
    q = find((time >= start) & (time <= stop));
    time = time(q);
    PIM = PIM(q);
    TAT = TAT(q);
    ZCM = ZCM(q);
    %sleep = sleep(q);
    
end
