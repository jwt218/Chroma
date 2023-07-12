function [I] = indall(D,refcomp)

%INDALL Calculate multiple indices from peak areas
%   I = indall(D,refcomp) returns a table I of multiple indices determined
%   from the sample peak areas D corresponding to the components refcomp. 
%   A and refcomp must be the same length.

p = inputParser; 

addRequired(p,'D');
addRequired(p,'refcomp');

parse(p,D,refcomp)

if ~isempty(fieldnames(p.Unmatched))
   disp('Extra inputs:')
   disp(p.Unmatched)
end

D = p.Results.D(:);
nc = p.Results.refcomp(:);

tnc = [min(nc) max(nc)];
c31 = D(nc == 31);
c29 = D(nc == 29);
c27 = D(nc == 27);
c23 = D(nc == 23);
c33 = D(nc == 33);
c35 = D(nc == 35);

if isempty(c31)
    c31 = NaN;
end
if isempty(c29)
    c29 = NaN;
end
if isempty(c27)
    c27 = NaN;
end
if isempty(c23)
    c23 = NaN;
end
if isempty(c35)
    c35 = NaN;
end
if isempty(c33)
    c33 = NaN;
end
if isempty(c33)
    c35 = NaN;
end

[CPI2,CPIBE] = cpi(D,nc);
PAQ = paq(D,nc);
ACL = acl(D,nc,tnc);
TAR = tarhc(D,nc);
Salk = sum(D);
OEP = oep(D,nc);
LH = lh(D,nc);
WI = wi(D,nc);
LCHSCH = lchsch(D,nc);
C31C19 = c31c19(D,nc);
ratio1 = c31/(c29+c31);
ratio2 = c31/(c27+c31);
ratio3 = c23/(c23+c29);
ratio4 = c33/(c29+c33);
ratio5 = c35/(c29+c35);
rnames = {'CPI2','CPIBE','Paq','ACL','TAR','S-alk','OEP','L/H','WI',...
    'LCH/SCH','C31/C19','C_{31}/(C_{29}+C_{31})','C_{31}/(C_{27}+C_{31})',...
    'C_{23}/(C_{23}+C_{29})','C_{33}/(C_{29}+C_{33})','C_{35}/(C_{29}+C_{35})'};
ct = [CPI2;CPIBE;PAQ;ACL;TAR;Salk;OEP;LH;WI;LCHSCH;C31C19;ratio1;ratio2;ratio3;ratio4;ratio5];
I = array2table(ct,'RowNames',rnames,'VariableNames',{'Index'});


end
