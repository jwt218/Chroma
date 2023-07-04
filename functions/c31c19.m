function [B] = c31c19(A,refcomp)

%C31C19 C31/C19 ratio
%   B = c31c19(A,refcomp) returns the C31/C19 ratio of available components
%   in A defined by refcomp. A and refcomp must be the same length.

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

c31 = 31; c19 = 19;

[~,idx1] = intersect(nc,c31,'stable');
[~,idx2] = intersect(nc,c19,'stable');


C31C19 = A(idx1)/A(idx2);


if isempty(C31C19)
    C31C19 = NaN;
end

if C31C19 == Inf
    C31C19 = NaN;
end

if C31C19 == 0
    C31C19 = NaN;
end

B = C31C19;

end