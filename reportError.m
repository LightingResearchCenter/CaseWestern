function [] = reportError( title, error, savePath )
%REPORTERROR If there is an error with the dataand the subject
%   is skipped, the Subject number and intervention number will
%	be output to a file in the results folder

	fid = fopen(savePath,'a');
	fprintf( fid, '\r\n %s: %s', title, error );
	fclose( fid );

end

