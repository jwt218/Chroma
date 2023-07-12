function [CPI2,CPIBE] = compcpi(DF,RM,refcomp,varargin)

%COMPCPI Compare different CPI calculation methods
%   CPI2 = compcpi(DF,RM,refcomp) returns the CPI values using the Marzi et
%   al., (1993) method.
%
%   [CPI2,CPIBE] = compcpi(DF,RM,refcomp) returns the CPI values using the 
%   Marzi et al., (1993) and Bray & Evans (1961) methods.
%
%   compcpi(DF,RM,refcomp,'plt',p) generates a figure for comparing
%   different methods of calculating CPI. When p = 'none' (default), no
%   plot is produced. When p = '1:1', the CPI values are plotted against
%   each other. When p = 'profile', the CPI values are plotted by profile
%   position according to the argument 'prof' (default 1,2,3,4...). 
%
%   compcpi(DF,RM,refcomp,'smthreshold',smth) sets the minimum 
%   threshold smth for peak detections in the sample chromatogram. The
%   default is 100.
%
%   compcpi(DF,RM,refcomp,'rmthreshold',rmth) sets the minimum 
%   threshold rmth for peak detections in the standard chromatogram. The
%   default is 25000.
%
%   compcpi(DF,RM,refcomp,'cutoff',cut) sets the start time for the
%   analysis. For example, if the analysis window begins after 10 minutes,
%   cut = 10 will remove all peaks before 10 minutes. This is intended for
%   the removal of detector responses from the solvent. The default is 10.
%
%   compcpi(DF,RM,refcomp,'ds',ds) sets the acceptable uncertainty 
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

cpi2 = table2array(T(:,2));
cpibe = table2array(T(:,3)); 


if strcmp(plt,'1:1')

    figure(1); clf
    plot(cpi2,cpibe,'s','MarkerFaceColor','b'); hold on 
    hr = refline(1,0); hold off
    hr.Color = 'k';  hr.LineStyle = '--';
    grid minor
    xlabel('CPI - Marzi et al., (1993)');
    ylabel('CPI - Bray & Evans (1961)');
    legend('','1:1 Reference line','box','off','Location','northeast')

elseif strcmp(plt,'profile')

    figure(1); clf
    plot(prof,cpibe,'-ob','MarkerFaceColor','w'); hold on 
    plot(prof,cpi2,'-sr','MarkerFaceColor','w'); hold off
    grid minor
    xlabel('Profile Position');
    ylabel('CPI');
    legend('Bray & Evans (1961)','Marzi et al., (1993)',...
        'box','off','Location','northeast')

elseif strcmp(plt,'none')
    %do nothing
end

CPI2 = cpi2;
CPIBE = cpibe;

end



