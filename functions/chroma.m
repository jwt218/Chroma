function [MA] = chroma(DF,RM,refcomp,varargin)

%CHROMA Determine peak areas of components in a single sample
%   MA = chroma(DF,RM,refcomp) returns a table or matrix of the times,
%   areas, and heights of target peaks of a sample chromatogram DF
%   referenced to a standard chromatogram RM with components refcomp.
%   DF and RM must be in the output data structure generated by the 
%   prepfiles function. 
%
%   MA = chroma(DF,RM,refcomp,'smthreshold',smth) sets the minimum 
%   threshold smth for peak detections in the sample chromatogram. The
%   default is 100.
%
%   MA = chroma(DF,RM,refcomp,'rmthreshold',rmth) sets the minimum 
%   threshold rmth for peak detections in the standard chromatogram. The
%   default is 25000.
%
%   MA = chroma(DF,RM,refcomp,'cutoff',cut) sets the start time for the
%   analysis. For example, if the analysis window begins after 10 minutes,
%   cut = 10 will remove all peaks before 10 minutes. This is intended for
%   the removal of detector responses from the solvent. The default is 10.
%
%   MA = chroma(DF,RM,refcomp,'ds',ds) sets the acceptable uncertainty 
%   window for standard peak to sample peak correlations. Detected sample
%   peaks outside the number of points specified by ds will be filtered
%   out. The default is 40.
%
%   MA = chroma(DF,RM,refcomp,'view',v) gives the option for generating a
%   figure after the analysis. Enter v = 'yes' to view the plot or v = 'no'
%   otherwise. The default is v = 'yes'. 
%
%   MA = chroma(DF,RM,refcomp,'xrange',x) defines the plotting range if the
%   view option is activated. For chromatograms with time units in minutes,
%   x = [11 25] plots only for the range 11-25 minutes. The default is x =
%   [11 25].
%
%   MA = chroma(DF,RM,refcomp,'pad',p) allows for sample peak detections
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
%
%   MA = chroma(DF,RM,refcomp,'out',m) specifies the output data format as
%   a table m = 'tab' or matrix m = 'mat'.


defsmthreshold = 100;
defrmthreshold = 25000;
defcutoff = 10;
defds = 40;
defview = 'yes';
defxrange = [11 25];
defpad = [];
defout = 'tab';

expview = {'yes','no'};
expout = {'tab','mat'};

p = inputParser; 
validDF = @(x) length(DF.X) == 1;
validsmthreshold = @(x) isnumeric(x) && isscalar(x);
validrmthreshold = @(x) isnumeric(x) && isscalar(x);
validcutoff = @(x) isnumeric(x) && isscalar(x);
validds = @(x) isnumeric(x) && isscalar(x);
validview = @(x) any(validatestring(x,expview));
validxrange = @(x) isnumeric(x) && length(x) == 2;
validpad = @(x) isnumeric(x);
validout = @(x) any(validatestring(x,expout));

addRequired(p,'DF',validDF);
addRequired(p,'RM');
addRequired(p,'refcomp');

addParameter(p,'smthreshold',defsmthreshold,validsmthreshold)
addParameter(p,'rmthreshold',defrmthreshold,validrmthreshold)
addParameter(p,'cutoff',defcutoff,validcutoff)
addParameter(p,'ds',defds,validds)
addParameter(p,'view',defview,validview)
addParameter(p,'xrange',defxrange,validxrange)
addParameter(p,'pad',defpad,validpad)
addParameter(p,'out',defout,validout)

parse(p,DF,RM,refcomp,varargin{:})

if ~isempty(fieldnames(p.Unmatched))
   disp('Extra inputs:')
   disp(p.Unmatched)
end

%%% input files

DF = p.Results.DF;
RM = p.Results.RM;

ch = DF.X.M;
rs = RM.X.M;

%%% input parameters: may need to adjust these depending on data
smthreshold = p.Results.smthreshold; % min peak criterion (fA above baseline)
rmthreshold = p.Results.rmthreshold; % min peak criterion (fA above baseline)
xl = p.Results.xrange; % plotting x-range
cut = p.Results.cutoff; % start of analysis (min) -- remove hexane peak
ds = p.Results.ds; % maximum distance permitted from standard (s)
nc = p.Results.refcomp(:);
out = p.Results.out;
view = p.Results.view;

%%% reorganize data
x = ch(:,1); y = ch(:,2);
rx = rs(:,1); ry = rs(:,2);

dt = mean(diff(x));

%%% find baseline and subtract it out
ci = find(x == cut);
yc = y(ci:end); xc = x(ci:end);
rcx = rx(ci:end); rcy = ry(ci:end);
sep = 100;
tf = islocalmin(yc, 'MinProminence',5,'MinSeparation',sep);

yf = interp1(xc(tf),yc(tf),xc,'spline');
ysub = yc-yf; % baseline subtracted data

%%% find peaks above threshold
thr = smthreshold; th2 = rmthreshold;
[~,locs] = findpeaks(ysub,'MinPeakDistance',250,'MinPeakHeight',thr);
[~,rloc1] = findpeaks(rcy,'MinPeakHeight',th2);

pad = p.Results.pad;

if isempty(pad)
    pad = [];
    rloc = rloc1;
end

if length(pad) > 1
    rloc = [rloc1; round((pad(:,1)-cut)/dt,1)];
    nc = [nc;pad(:,2)];
end

%%% initialize output table [comp,rm pk time,samp pk time,area]
C = [nc,(rloc*dt) + cut,zeros([length(rloc) 1]),zeros([length(rloc) 1]),zeros([length(rloc) 1])];

%%% filter out peaks not in the standard
tr = ds;
cloc = zeros([length(locs) 1]);
co = zeros([length(rloc) 1]);  
for i = 1:length(locs)
    n = locs(i);
    [val,idx]=min(abs(rloc-n));
    if val <= tr
        cloc(i,:) = n;
        co(idx,:) = n;
    else
        cloc(i,:) = nan;
    end
end
nani = isnan(cloc);
cloc(nani) = [];

xoc = xc(cloc); yoc = ysub(cloc);
rox = rcx(rloc); roy = rcy(rloc);

%%% add samp pk times to output table
con = co*dt;
con(con == 0) = NaN;
C(:,3) = con + cut;


%%% find base of peaks (valley-to-valley)
bmin = zeros([length(cloc) 1]); bmax = zeros([length(cloc) 1]);
for k = 1:length(cloc)
   i = cloc(k);
   while i > 1 && ysub(i-1) <= ysub(i)
       i = i - 1;
   end
   bmin(k) = i;
   i = cloc(k);
   while i < length(ysub) && ysub(i+1) <= ysub(i)
       i = i + 1;
   end
   bmax(k) = i;
end


%%% integration
At = zeros([length(bmin) 1]);
mpk = zeros([length(bmin) 1]);

if isempty(At)
    B = zeros([length(co) 1]);
    ph = zeros([length(co) 1]);
else
for k=1:length(bmin)
    rgx = xc(bmin(k):bmax(k));
    rgy = ysub(bmin(k):bmax(k));
    mpk(k,:) = max(rgy);
    mpkt = mpk;
    if min(rgy) < 0
        rgy = rgy + abs(min(rgy));
    end
    At(k,:) = trapz(rgx,rgy);
    A = At;
end

    B = zeros([length(co) 1]);
    B(find(co)) = A;
    ph = zeros([length(co) 1]);
    ph(find(co)) = mpkt;
end

%%% add sample peak areas to table

C(:,4) = B; C(:,5) = ph;
D = sortrows(C,1);


%%% format output table
if strcmp(out,'tab')
    MA = array2table(D,'VariableNames',{'Comp','RM PK Time',...
        'Sample PK Time','Area','Height'});
end
if strcmp(out,'mat')
    MA = D;
end
    

%%% plotting
if strcmp(view,'yes')
    
    t = tiledlayout(3,1); t.TileSpacing = 'tight'; t.Padding = 'tight';
    
    nexttile
    plot(xc, yc,'-b'); hold on
    plot(xc,yf,'-.r','LineWidth',2); 
    plot(xc,ysub,'-r'); hold off
    xlim(xl); box on; grid minor;
    text(0.99,0.95,DF.X.VN,'Units','normalized',...
        'HorizontalAlignment','right','Interpreter','none');
    legend('original chromatogram','calculated baseline',...
        'baseline subtracted response','box','off','Location','northwest')
    set(gca,'XTickLabel',[]);

    nexttile
    if isempty(At)
    plot(xc,ysub,'-r');
    xlim(xl); box on; grid minor;
    ylabel('Intensity');
    text(0.5,0.5,'No referenced peaks detected','HorizontalAlignment','center',...
        'VerticalAlignment','bottom','Units','normalized')
    set(gca,'XTickLabel',[]);
    else
    plot(xc,ysub,'-r'); hold on
    plot(xoc,yoc,'vk');
    plot(xc(bmin),ysub(bmin),'^k');
    plot(xc(bmax),ysub(bmax),'^k'); hold off
    xlim(xl); box on; grid minor;
    for k=1:length(bmin)
        rgx = xc(bmin(k):bmax(k));
        rgy = ysub(bmin(k):bmax(k));
        patch(rgx,rgy,[0.7 0.7 0.7]);
    end
    legend('baseline subtracted response','peak (reference confirmed only)',...
        'integration peak base','box','off','Location','northwest')
    ylabel('Intensity');
    text(xoc,yoc,string(round(A,2)),'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    set(gca,'XTickLabel',[]);
    end

    nexttile
    plot(rcx, rcy,'-k'); hold on
    plot(rox, roy,'vk'); hold off
    xlim(xl); box on; grid minor;
    legend('reference response','peaks',...
        'box','off','Location','northwest')
    xlabel('Retention Time'); 
    text(rox,roy,string(nc),'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    text(0.99,0.95,RM.X.VN,'Units','normalized',...
        'HorizontalAlignment','right','Interpreter','none');
end

if strcmp(view,'no')
    
    % do nothing
    
end




end
