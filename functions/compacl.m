function [A1,A2,A3] = compacl(DF,RM,refcomp,varargin)

%COMPACL Compare different ACL calculation methods
%   A1 = compacl(DF,RM,refcomp) returns the value of ACL for components
%   C25 to C33.
%
%   [A1,A2] = compacl(DF,RM,refcomp) returns the value of ACL for all
%   components available in refcomp. 
%
%   [A1,A2,A3] = compacl(DF,RM,refcomp) returns the value of AHPCL.
%
%   compacl(DF,RM,refcomp,'plt',p) generates a figure for comparing
%   different methods of calculating ACL. When p = 'none' (default), no
%   plot is produced. When p = '1:1', the ACL values are plotted against
%   each other. When p = 'profile', the ACL values are plotted by profile
%   position according to the argument 'prof' (default 1,2,3,4...). 
%
%   compacl(DF,RM,refcomp,'smthreshold',smth) sets the minimum 
%   threshold smth for peak detections in the sample chromatogram. The
%   default is 100.
%
%   compacl(DF,RM,refcomp,'rmthreshold',rmth) sets the minimum 
%   threshold rmth for peak detections in the standard chromatogram. The
%   default is 25000.
%
%   compacl(DF,RM,refcomp,'cutoff',cut) sets the start time for the
%   analysis. For example, if the analysis window begins after 10 minutes,
%   cut = 10 will remove all peaks before 10 minutes. This is intended for
%   the removal of detector responses from the solvent. The default is 10.
%
%   compacl(DF,RM,refcomp,'ds',ds) sets the acceptable uncertainty 
%   window for standard peak to sample peak correlations. Detected sample
%   peaks outside the number of points specified by ds will be filtered
%   out. The default is 40.
%
%   compacl(DF,RM,refcomp,'pad',p) allows for sample peak detections
%   outside the availabe components in RM. For example, if the reference
%   chromatogram RM contains components in the range 16-30, adding the 
%   argument p = [21.5 31] will tell chroma to search for a sample peak in 
%   DF at time 21.5 and assume it is the component C31. The 'pad' argument
%   can include multiple components using the format:
% 
%   p = [21.5 31; 22.3 32; 23.2 33];
%
%   where the left column is time and the the right column is the component
%   number.

defprof = 1:1:length(DF.X);
defsmthreshold = 100;
defrmthreshold = 25000;
defcutoff = 10;
defds = 40;
defpad = [];
defplt = 'none';

expplt = {'1:1','profile','none'};

p = inputParser; 
validDF = @(x) length(DF.X) > 1;
validprof = @(x) isnumeric(x) && length(x) == length(DF.X);
validsmthreshold = @(x) isnumeric(x) && isscalar(x);
validrmthreshold = @(x) isnumeric(x) && isscalar(x);
validcutoff = @(x) isnumeric(x) && isscalar(x);
validds = @(x) isnumeric(x) && isscalar(x);
validpad = @(x) isnumeric(x);
validplt = @(x) any(validatestring(x,expplt));

addRequired(p,'DF',validDF);
addRequired(p,'RM');
addRequired(p,'refcomp');

addParameter(p,'prof',defprof,validprof)

addParameter(p,'smthreshold',defsmthreshold,validsmthreshold)
addParameter(p,'rmthreshold',defrmthreshold,validrmthreshold)
addParameter(p,'cutoff',defcutoff,validcutoff)
addParameter(p,'ds',defds,validds)
addParameter(p,'pad',defpad,validpad)
addParameter(p,'plt',defplt,validplt)

parse(p,DF,RM,refcomp,varargin{:})


if ~isempty(fieldnames(p.Unmatched))
   disp('Extra inputs:')
   disp(p.Unmatched)
end

DF = p.Results.DF;
RM = p.Results.RM;
refcomp = p.Results.refcomp(:);
prof = p.Results.prof;
ds = p.Results.ds;
pad = p.Results.pad;
smth = p.Results.smthreshold;
rmth = p.Results.rmthreshold;
plt = p.Results.plt;

[T] = chromall(DF,RM,refcomp,'ds',ds,'smthreshold',smth,...
    'rmthreshold',rmth,'pad',pad,'view','no','prof',prof);

acl2533 = table2array(T(:,5));
aclfull = table2array(T(:,6)); 
ahpcl = table2array(T(:,7)); 
rmn = [min(refcomp) min(pad)];
rmx = [max(refcomp) max(pad)];
al = [acl2533; aclfull; ahpcl];

if strcmp(plt,'profile')

    figure(1); clf
    plot(prof,acl2533,'-ob','MarkerFaceColor','w'); hold on 
    plot(prof,ahpcl,'-dg','MarkerFaceColor','w');
    plot(prof,aclfull,'-sr','MarkerFaceColor','w'); hold off
    grid minor
    xlabel('Profile Position');
    ylabel('ACL');
    legend('ACL_{25-33}','AHPCL',sprintf('ACL_{%d-%d}',min(rmn),max(rmx)),...
        'box','off','Location','northeast')

elseif strcmp(plt,'1:1')

    one = min(al):0.01:max(al);
    figure(1); clf
    scatter3(acl2533,ahpcl,aclfull,'Marker','s','MarkerFaceColor','b'); hold on
    plot3(one,one,one,'--k');hold off
    xlabel('ACL_{25-33}'); ylabel('AHPCL'); 
    zlabel(sprintf('ACL_{%d-%d}',min(rmn),max(rmx)));
    grid minor
    legend('','1:1:1 Reference line','box','off','Location','northeast')

elseif strcmp(plt,'none')
    %do nothing
end

A1 = acl2533;
A2 = aclfull;
A3 = ahpcl;

end

