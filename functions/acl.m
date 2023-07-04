function [B,R] = acl(A,refcomp,varargin)

%ACL Average Chain Length -- see Poynter & Eglinton (1990)
%   B = acl(A,refcomp) returns the ACL value of the available component 
%   areas in A. The argument refcomp should contain the component numbers
%   corresponding to the peak areas of A. A and refcomp must be the 
%   same length.
%   
%   B = acl(A,refcomp,t) returns the ACL value of the component range
%   defined by t. For example, if A contains the areas of components 16-33,
%   adding the argument t, where t = [25 31], will return the ACL value of
%   only the areas corresponding to components 25-31. If not included, t
%   defaults to the full range of available components. 
%
%   [B,R] = acl(A,refcomp,t) returns the ACL value in B and the adjusted
%   component range used in R if the range of t is outside the available
%   components in refcomp. The range will be automatically adjusted to fit
%   the max range of refcomp.

deft = [min(refcomp) max(refcomp)];

p = inputParser; 

addRequired(p,'A');
addRequired(p,'refcomp');

addOptional(p,'t',deft);

parse(p,A,refcomp,varargin{:})

if ~isempty(fieldnames(p.Unmatched))
   disp('Extra inputs:')
   disp(p.Unmatched)
end


A = p.Results.A(:);
nc = p.Results.refcomp(:);
t1 = p.Results.t(:);


if min(nc) > min(t1) || max(nc) < max(t1)
    disp('ACL: component range adjusted to match available components.')
end
if min(nc) > min(t1)
    t1 = [min(nc) max(t1)];
end
if max(nc) < max(t1)
    t1 = [min(t1) max(nc)];
end


tt1 = t1(1):t1(2); tt1 = tt1(:);
[~,idx] = intersect(nc,tt1,'stable');
At = A(idx);

ACLT = sum(tt1.*At)/sum(At);


if ACLT == 0
    ACLT = NaN;
end

R = t1;
B = ACLT;

end