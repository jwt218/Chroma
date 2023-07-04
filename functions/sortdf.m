function [SDF,B,ndx] = sortdf(DF)

%SORTDF Alphanumerically sort the data in structure DF by name DF.X.VN
%   SDF = sortdf(DF) alphanumerically sorts the IDs in DF.X.VN using the
%   the function natsortfiles by Stephen Cobeldick and returns the data in
%   Chroma structure SDF.
%
%   [SDF,B] = sortdf(DF) returns a list of the IDs in the new order.
%
%   [SDF,B,ndx] = sortdf(DF) returns the index order from the original list
%   of file names.

st = {DF.X.VN}; st = st(:); 
[B,ndx,~] = natsortfiles(st);
SDF.X = DF.X(ndx);

end
