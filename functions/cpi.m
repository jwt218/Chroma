function [CPI2,CPIBE] = cpi(A,refcomp,varargin)

%CPI Carbon Preference Index -- See Bray & Evans (1961), Marzi et al.
%   (1993), and Herrera-Herrera et al. (2020)
%
%   CPI2 = cpi(A, refcomp) returns the CPI2 value by Marzi et al. (1993) of
%   the peak areas in A corresponding to the components in refcomp. A and 
%   refcomp must be the same length.
%
%   [CPI2,CPIBE] = cpi(A,refcomp) returns the CPI2 value and the original
%   CPI value proposed by Bray & Evans (1961). 
%
%   cpi(A,refcomp,crange) returns the CPI value calculated over the
%   component range specified by crange. If not specified, CPI is
%   calculated by default for all components C23 and higher. When crange is
%   a single element vector, CPI is calculated over all components of crange
%   and higher. When crange is a two element vector, CPI is calculated
%   between the specified range of crange. 
%


p = inputParser; 

defcrange = [];

validcrange = @(x) isnumeric(x) && length(x) <= 2;

addRequired(p,'A');
addRequired(p,'refcomp');

addOptional(p,'crange',defcrange,validcrange);

parse(p,A,refcomp,varargin{:})

if ~isempty(fieldnames(p.Unmatched))
   disp('Extra inputs:')
   disp(p.Unmatched)
end

Ap = p.Results.A(:);
nc = p.Results.refcomp(:);
crange = p.Results.crange(:);

if isempty(crange)
    fnc = find(nc == 23):length(nc);
elseif length(crange) == 2
    fnc = find(nc == crange(1)):find(nc == crange(2));
elseif length(crange) == 1
    fnc = find(nc == crange):length(nc);
end

evens = nc(mod(nc(fnc),2)==0);
odds = nc(mod(nc(fnc),2)~=0);

[~,ide] = intersect(nc,evens,'stable');
[~,ido] = intersect(nc,odds,'stable');

ido1 = ido(1:end-1);
ido2 = ido(2:end);
ide1 = ide(1:end-1);
ide2 = ide(2:end);

A = Ap(fnc);

%%% Both BE1961 (CPIBE) and Marzi CPI (CPI2) calculated
%%% Recommended to use Marzi result!
CPIBE = 0.5 * (sum(A(ido)) / sum(A(ide1))) + (sum(A(ido)) / sum(A(ide2)));
CPI2 = (sum(A(ido1)) + sum(A(ido2))) / (2 * sum(A(ide)));

if CPIBE == 0
    CPIBE = NaN;
end

if CPI2 == 0
    CPI2 = NaN;
end

if CPIBE == Inf
    CPIBE = NaN;
end

if CPI2 == Inf
    CPI2 = NaN;
end


end
