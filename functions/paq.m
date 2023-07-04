function [PAQ] = paq(A,refcomp)

%PAQ Paq value -- See Ficken et al. (2000)
%   PAQ = paq(A,refcomp) returns the Paq value of the peak areas
%   A corresponding to the components refcomp. A and refcomp must be the 
%   same length. Input refcomp must include the C23, C25, C29, and C31 
%   peaks. If not included, the function will return NaN.

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

c = [23 25 29 31];
[~,idx] = intersect(nc,c,'stable');
Ai = A(idx);

if length(idx) ~= 4
    PAQ = NaN;
else
    PAQ = (Ai(1) + Ai(2)) / (Ai(1) + Ai(2) + Ai(3) + Ai(4));
end

if PAQ == 0
    PAQ = NaN;
end


end
