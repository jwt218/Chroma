function [nr] = ratio(A,refcomp,numer,denom)

%RATIO Normalized n-Alkane Ratio -- See Aichner et al., (2018)
%
%   nr = ratio(A,refcomp,numer,denom) returns the ratio of the sum of
%   components in the numerator (numer) and denominator (denom). Values
%   given to numer and denom should be in numeric vector form (e.g., [28
%   32], [23 25 27]). Component areas in the numerator and 
%   denominator will be summed. 
%

p = inputParser; 

addRequired(p,'A');
addRequired(p,'refcomp');
addRequired(p,'numer');
addRequired(p,'denom')

parse(p,A,refcomp,numer,denom)

if ~isempty(fieldnames(p.Unmatched))
   disp('Extra inputs:')
   disp(p.Unmatched)
end

Ap = p.Results.A(:);
nc = p.Results.refcomp(:);
numer = p.Results.numer(:);
denom = p.Results.denom(:);

[~,ni1] = intersect(nc,numer,'stable');
[~,di1] = intersect(nc,denom,'stable');
r = sum(Ap(ni1)) / sum(Ap(di1));


if r == 0
    r = NaN;
end

if r == Inf
    r = NaN;
end

if min(nc) > min(numer) || max(nc) < max(numer)
    r = NaN;
end

if min(nc) > min(denom) || max(nc) < max(denom)
    r = NaN;
end

nr = r;

end