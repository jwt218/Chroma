function [LCHSCH] = lchsch(A,refcomp)

%LCHSCH Long Chain/Short Chain Hydrocarbons (LCH/SCH)
%   LCHSCH = lchsch(A,refcomp) returns the LCH/SCH value of the peak areas
%   A corresponding to the components refcomp. A and refcomp must be the 
%   same length.

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

c1 = [27 29 31];
c2 = [15 17 19];

[~,idx1] = intersect(nc,c1,'stable');
[~,idx2] = intersect(nc,c2,'stable');


LCHSCH = sum(A(idx1))/sum(A(idx2));

if sum(A(idx1)) == 0 
    LCHSCH = NaN;
end

if sum(A(idx2)) == 0
    LCHSCH = NaN;
end


end