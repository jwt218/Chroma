function [n] = nar(A,refcomp)

%NAR Natural n-Alkane Ratio -- See Mille et al., (2007)
%
%   n = nar(A, refcomp) returns the NAR value of the peak areas
%   A corresponding to the components refcomp. A and refcomp must be the 
%   same length. Input refcomp must include all components between C19 and 
%   C32. If not available, the function will return NaN.
%

p = inputParser; 

addRequired(p,'A');
addRequired(p,'refcomp');

parse(p,A,refcomp)

if ~isempty(fieldnames(p.Unmatched))
   disp('Extra inputs:')
   disp(p.Unmatched)
end

Ap = p.Results.A(:);
nc = p.Results.refcomp(:);

c = 19:32; c = c(:);
evens = nc(mod(nc,2)==0);

[~,idn1] = intersect(nc,c,'stable');
[~,ide] = intersect(nc,evens,'stable');
num = (sum(Ap(idn1))-(2*sum(Ap(ide)))) / sum(Ap(idn1));


if num == 0
    num = NaN;
end

if num == Inf
    num = NaN;
end

if min(nc) > min(c) || max(nc) < max(c)
    num = NaN;
end

n = num;

end