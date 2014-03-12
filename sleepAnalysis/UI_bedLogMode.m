function [bedLogMode,varargout] = UI_bedLogMode
%UI_BEDLOGMODE Summary of this function goes here
%   Detailed explanation goes here

% Ask user what sleep time to use
bedLogMode = menu('Select what sleep time mode to use',...
    'static (default)','static (manual)','logs/dynamic');

switch bedLogMode
    case 1 % static (default)
        staticBedTime = 22/24; % 22:00
        staticGetupTime = 8/24; % 08:00
        suffix = '_2200-0800';
        
    case 2 % static (manual)
        bedStr = input('Enter bed time (ex. 22:00): ','s');
        bedTokens = regexp(bedStr,'^(\d{1,2}):(\d\d)','tokens');
        bedHour = str2double(bedTokens{1}{1});
        bedMinute = str2double(bedTokens{1}{2});
        staticBedTime = bedHour/24 + bedMinute/60/24;

        wakeStr = input('Enter wake time (ex. 08:00): ','s');
        wakeTokens = regexp(wakeStr,'^(\d{1,2}):(\d\d)','tokens');
        wakeHour = str2double(wakeTokens{1}{1});
        wakeMinute = str2double(wakeTokens{1}{2});
        staticGetupTime = wakeHour/24 + wakeMinute/60/24;

        % Create a file name suffix from the fixed sleep time
        suffix = ['_',num2str(bedHour,'%02.0f'),num2str(bedMinute,'%02.0f'),...
            '-',num2str(wakeHour,'%02.0f'),num2str(wakeMinute,'%02.0f')];
        
    case 3 % logs/dynamic
        staticBedTime = 0;
        staticGetupTime = 0;
        % Create an empty file name suffix
        suffix = '';
    otherwise % no option selected
        error('No bed log mode was selected');
end

% Return extra variables if requested
if (max(nargout,1)-1) == 3
    varargout = {staticBedTime,staticGetupTime,suffix};
end

end

