function data = ProcessCDF(FileName)
%PROCESSCDF Processes a CDF file and converts variables to MatLab readable 
%format.
%	INPUT: FileName
%	OUTPUT: Struct <data> containing variables & attributes

cdfID = cdflib.open(FileName);
info = cdfinfo(FileName);

varInfo  = info.Variables;
gAttInfo = info.GlobalAttributes;
vAttInfo = info.VariableAttributes;

varNames = varInfo(:,1);
varTypes = varInfo(:,4);

numVars = length(varNames);
rawData = cdfread(FileName,'ConvertEpochToDatenum',true);

gNumAtts = cdflib.getNumgAttributes(cdfID);
gAttNames = fieldnames(gAttInfo);
vNumAtts = cdflib.getNumAttributes(cdfID);
vAttNames = fieldnames(vAttInfo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For each variable, check to see if it needs to be       %
% converted from epoch to matlab time. Put variables into %
% a struct named Variables that is part of a struct named %
% data.                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if numVars > 0
    for i1 = 1:numVars
        data.('Variables').(varNames{i1}) =  cell2mat(rawData(:,i1));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For each global attribute, put into struct named        %
% GlobalAttributes that is a part of a struct named data. %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if gNumAtts > 0
    for i2 = 1:gNumAtts
            data.('GlobalAttributes').(gAttNames{i2}) =...
                gAttInfo.(gAttNames{i2});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For each variable attribute, put into struct named      %
% VariableAttributes that is a part of a struct named     %
% data.                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if gNumAtts > 0
    for i3 = 1:vNumAtts
            data.('VariableAttributes').(vAttNames{i3}) =...
                vAttInfo.(vAttNames{i3});
    end
end


end