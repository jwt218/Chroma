function [DF] = prepfiles(fname,varargin)

%PREPFILES Prepare data from delimited file (.xlsx, .csv, etc.) into
%readable structure for Chroma functions
%   DF = prepfiles(fname) returns a structure DF from data in the file
%   specified the string fname. Data in the file fname should be in the
%   format [time; intensity]. prepfiles can interpret a file with a single
%   chromatogram or multiple. For a single chromatogram data file, time
%   should be in the first column, and the intensity in the second. For a
%   data file with multiple chromatograms, simply add to the adjacent
%   columns (i.e, time1 intensity1, time2 intensity2, ...).
%
%   DF.X.VN contains the sample names. DF.X.M contains the corresponding
%   data.
%
%   DF = prepfiles(fname,headerrow) specifies the row in the data file
%   fname containing the sample identification. If the sample ID is in the
%   first row, enter 1 for headerrow, and so on. 

defheaderrow = [];
defcrop = [1 0];

p = inputParser; 
validheaderrow = @(x) isnumeric(x) && length(x) == 1;
validcrop = @(x) length(x) == 2;

addRequired(p,'fname');

addParameter(p,'headerrow',defheaderrow,validheaderrow)
addParameter(p,'crop',defcrop,validcrop)

parse(p,fname,varargin{:})

if ~isempty(fieldnames(p.Unmatched))
   disp('Extra inputs:')
   disp(p.Unmatched)
end

filename = p.Results.fname;
crop = p.Results.crop;
headerrow = p.Results.headerrow;

if isempty(headerrow)
    R = readtable(filename);
    Z = readtable(filename,'VariableNamingRule','preserve');
else
    hdr = sprintf('%d:%d',headerrow,headerrow);
    R = readtable(filename);
    Z = readtable(filename,'Range',hdr,'VariableNamingRule','preserve');
end

zp = string(Z.Properties.VariableNames);
zp = zp(:);

ra = table2array(R);
ikx = 1:2:length(ra(1,:));
ncrop = crop;

for i = 1:length(ikx)
    zs = zp(ikx(i)); zs = zs{:};
    zsp = zs(ncrop(1):end-ncrop(2));
    DF.X(i).VN = zsp;
    DF.X(i).M = ra(:,ikx(i):ikx(i)+1);
end


end
