function [timeOut, varargout] = trimData(timeIn, startTime, stopTime, cropStart, cropEnd, varargin)
	% Find indices within specified range
    stopTime = stopTime + 1.15741e-8;
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