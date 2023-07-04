function [LH] = lh(A,refcomp)

%LH Light Molecular Weight/Heavy Molecular Weight Hydrocarbons (L/H)
%   LH = lh(A,refcomp) returns the L/H value of the peak areas
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

c1 = 15:20; c2 = 21:34;

[~,idx1] = intersect(nc,c1,'stable');
[~,idx2] = intersect(nc,c2,'stable');


LH = sum(A(idx1))/sum(A(idx2));

if LH == 0
    LH = NaN;
end


end