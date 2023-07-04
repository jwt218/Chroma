function [OEP] = oep(A,refcomp)

%OEP Odd-Even Predominance -- See Scanlan & Smith (1970)
%   OEP = oep(A,refcomp) returns the OEP value of the peak areas
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

c = [27 28 29 30 31]; c = c(:);

[~,idx] = intersect(nc,c,'stable');

Ai = A(idx);

if length(idx) ~= 5
    OEP = NaN;
else
    OEP = (Ai(1)+(6*Ai(3)+Ai(5)))/(4*(Ai(2)+Ai(4)));
end


if OEP == 0
    OEP = NaN;
end
if OEP == Inf
    OEP = NaN;
end



end