function WriteActiwatchCDF(SaveName,time,activity)
%%WRITEDAYSIMETERCDF Write processed data to CDF File.
%   Note: Only works if filename is not already taken. If file exists,
%   creation will fail. Deletion of files may be manual, or by using
%	cdflib.open() and cdflib.delete()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert time to CDF_EPOCH format                          %
% -Matlab creates 1x6 time vectors, but needs 1x7 to create %
% a CDF_EPOCH value. This method adds 0 ms to each vector.  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timeVecT = datevec(time);
timeVec = zeros(length(time),7);
timeVec(:,1:6) = timeVecT;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create CDF file                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cdfID = cdflib.create(SaveName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Variables                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

varTime = cdflib.createVar(cdfID,'Time','CDF_EPOCH',1,[],true,[]);
varActivity = cdflib.createVar(cdfID,'Activity','CDF_REAL8',1,[],true,[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Allocate Records                                          %
% -Finds the number of entries from Daysimeter device and   %
% allocates space in each variable.                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numRecords = length(time);
cdflib.setVarAllocBlockRecords(cdfID,varTime,1,numRecords);
cdflib.setVarAllocBlockRecords(cdfID,varActivity,1,numRecords);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find varNum                                               %
% -CDF assigns a number to each variable. Records are       %
% written to variables using the appropriate number.        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timeVarNum = cdflib.getVarNum(cdfID,'Time');
activityVarNum = cdflib.getVarNum(cdfID,'Activity');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write Records                                             %
% -Loops and writes data to records. Note: CDF uses 0       %
% indexing while MatLab starts indexing at 1.               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i1 = 1:numRecords
    cdflib.putVarData(cdfID,timeVarNum,i1-1,[],cdflib.computeEpoch(timeVec(i1,:)));
    cdflib.putVarData(cdfID,activityVarNum,i1-1,[],activity(i1));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close File                                                %
% -If file is not closed properly, it could corrupt entire  %
% file, making it un-openable/un-readable.                  %
% file, making it un-openable.                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cdflib.close(cdfID);
end



