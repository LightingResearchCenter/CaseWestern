function [timeOut, varargout] = trimData(timeIn, startTime, stopTime, cropStart, cropEnd, varargin)
	% Find indices within specified range
	one_milli = 1.15741e-8;
	startTime = startTime - one_milli;
    stopTime = stopTime + one_milli;
	if (~isnan(cropStart))
		idx = timeIn >= startTime & timeIn <= stopTime & (timeIn <= cropStart | timeIn >= cropEnd);
	else
		idx = timeIn >= startTime & timeIn <= stopTime;
	end
	% Trim time
	timeOut = timeIn(idx);
	% Trim other inputs
	for i1 = 1:nargin-5
		varargout{i1} = varargin{i1}(idx);
	end
end