function [TARHC] = tarhc(A,refcomp)

%TARHC TAR value -- See Bourbonniere & Meyers (1996)
%   TARHC = tarhc(A,refcomp) returns the TAR value of the peak areas
%   A corresponding to the components refcomp. A and refcomp must be the 
%   same length. Input refcomp must include the C15, C17, C19, C27, C29,
%   and C31 peaks. If not included, the function will return NaN.

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

c = [15 17 19 27 29 31]; c = c(:);
[~,idx] = intersect(nc,c,'stable');    

Ai = A(idx);

if length(idx) ~= 6
    TARHC = NaN;
else
    TARHC = (Ai(1) + Ai(2)) / (Ai(1) + Ai(2) + Ai(3) + Ai(4));
end


if TARHC == 0
    TARHC = NaN;
end


end