function [WI] = wi(A,refcomp)

%WI Weathering Index
%   WI = wi(A,refcomp) returns the WI value of the peak areas
%   A corresponding to the components refcomp. A and refcomp must be the 
%   same length. Input refcomp must include the C8, C10, C12, C14, C22,
%   C24, C26, and C28 peaks. If not included, the function will return NaN.

p = inputParser; 

addRequired(p,'A');
addRequired(p,'refcomp');

parse(p,A,refcomp)

if ~isempty(fieldnames(p.Unmatched))
   disp('Extra inputs:')
   disp(p.Unmatched)
end

A = p.Results.A(:);
nc = p.Results.refcomp(:);
c1 = [8 10 12 14];
c2 = [22 24 26 28];

[~,idx1] = intersect(nc,c1,'stable');
[~,idx2] = intersect(nc,c2,'stable');


WI = sum(A(idx1))/sum(A(idx2));

if WI == 0
    WI = NaN;
end
if WI == Inf
    WI = NaN;
end

end