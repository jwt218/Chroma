function [T] = chromall(DF,RM,refcomp,varargin)

%CHROMALL Determine indices of components in multiple samples at once
%   T = chromall(DF,RM,refcomp) returns a table or matrix of the 
%   hydrocarbon index values of target peaks of multiple sample 
%   chromatograms DF referenced to a standard chromatogram RM with 
%   components refcomp. DF and RM must be in the output data structure 
%   generated by the prepfiles function. 
%
%   T = chromall(DF,RM,refcomp,'smthreshold',smth) sets the minimum 
%   threshold smth for peak detections in the sample chromatogram. The
%   default is 100.
%
%   T = chromall(DF,RM,refcomp,'rmthreshold',rmth) sets the minimum 
%   threshold rmth for peak detections in the standard chromatogram. The
%   default is 25000.
%
%   T = chromall(DF,RM,refcomp,'cutoff',cut) sets the start time for the
%   analysis. For example, if the analysis window begins after 10 minutes,
%   cut = 10 will remove all peaks before 10 minutes. This is intended for
%   the removal of detector responses from the solvent. The default is 10.
%
%   T = chromall(DF,RM,refcomp,'ds',ds) sets the acceptable uncertainty 
%   window for standard peak to sample peak correlations. Detected sample
%   peaks outside the number of points specified by ds will be filtered
%   out. The default is 40.
%
%   T = chromall(DF,RM,refcomp,'view',v) gives the option for generating
%   diagnostic figures into folder during the analysis. Output figure
%   destination can be specified using the 'nfold' argument. Enter 
%   v = 'yes' to view the plot or v = 'no' otherwise. 
%   The default is v = 'yes'. 
%
%   T = chromall(DF,RM,refcomp,'xrange',x) defines the plotting range if the
%   view option is activated. For chromatograms with time units in minutes,
%   x = [11 25] plots only for the range 11-25 minutes. The default is x =
%   [11 25].
%
%   T = chromall(DF,RM,refcomp,'pad',p) allows for sample peak detections
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
%   T = chromall(DF,RM,refcomp,'out',m) specifies the output data format as
%   a table m = 'tab' or matrix m = 'mat'.
%
%   T = chromall(DF,RM,refcomp,'nfold',dir) specifies the output directory
%   for figures if 'view' is set to 'yes', where dir is a string containing
%   the path and name of the directory. The function will create a
%   directory called ./chroma_figs by default if not specified. 

tic

defprof = 1:1:length(DF.X);
defsmthreshold = 100;
defrmthreshold = 25000;
defcutoff = 10;
defds = 40;
defview = 'yes';
defxrange = [11 25];
defpad = [];
defnfold = [];

expview = {'yes','no'};

p = inputParser; 
validDF = @(x) length(DF.X) > 1;
validprof = @(x) isnumeric(x) && length(x) == length(DF.X);
validsmthreshold = @(x) isnumeric(x) && isscalar(x);
validrmthreshold = @(x) isnumeric(x) && isscalar(x);
validcutoff = @(x) isnumeric(x) && isscalar(x);
validds = @(x) isnumeric(x) && isscalar(x);
validview = @(x) any(validatestring(x,expview));
validxrange = @(x) isnumeric(x) && length(x) == 2;
validpad = @(x) isnumeric(x);

addRequired(p,'DF',validDF);
addRequired(p,'RM');
addRequired(p,'refcomp');

addParameter(p,'prof',defprof,validprof)

addParameter(p,'smthreshold',defsmthreshold,validsmthreshold)
addParameter(p,'rmthreshold',defrmthreshold,validrmthreshold)
addParameter(p,'cutoff',defcutoff,validcutoff)
addParameter(p,'ds',defds,validds)
addParameter(p,'view',defview,validview)
addParameter(p,'xrange',defxrange,validxrange)
addParameter(p,'pad',defpad,validpad)
addParameter(p,'nfold',defnfold)

parse(p,DF,RM,refcomp,varargin{:})


if ~isempty(fieldnames(p.Unmatched))
   disp('Extra inputs:')
   disp(p.Unmatched)
end

vo = varargin;
if isempty(find(strcmp(vo,'prof'), 1))
    % do nothing
else
    prind = find(strcmp(vo,'prof'), 1);
    vo(prind) = [];
    vo(prind) = [];
end
if isempty(find(strcmp(vo,'nfold'), 1))
    % do nothing
else
    nfind = find(strcmp(vo,'nfold'), 1);
    vo(nfind) = [];
    vo(nfind) = [];
end

DF = p.Results.DF;
RM = p.Results.RM;
comp = p.Results.refcomp(:);
view = p.Results.view;
xrange = p.Results.xrange;
prof = p.Results.prof;
pad = p.Results.pad;
nfold = p.Results.nfold;

nx = length(DF.X);
out = 'mat';
dpt = prof(:);

cpis2 = zeros([nx 1]);
cpibes = zeros([nx 1]);
paqs = zeros([nx 1]);
acls1 = zeros([nx 1]);
acls2 = zeros([nx 1]);
acls3 = zeros([nx 1]);
tars = zeros([nx 1]);
oeps = zeros([nx 1]);
salks = zeros([nx 1]);
lhs = zeros([nx 1]);
wis = zeros([nx 1]);
lchschs = zeros([nx 1]);
ratio1 = zeros([nx 1]);
ratio2 = zeros([nx 1]);
ratio3 = zeros([nx 1]);
c31c19s = zeros([nx 1]);
prphs = zeros([nx 1]);
pc17s = zeros([nx 1]);
pc18s = zeros([nx 1]);
pr = zeros([nx 1]); ph = zeros([nx 1]);

fno = string({DF.X.VN}); fno = fno(:);

if isempty(pad)
    nca = zeros([length(comp) nx+1]);
    aasi = zeros([length(comp) nx]);
else
    nca = zeros([length(comp)+length(pad(:,1)) nx+1]);
    aasi = zeros([length(comp)+length(pad(:,1)) nx]);
end


if strcmp(view,'yes')
    
for i = 1:nx
    
    if isempty(nfold)
        fold = 'chroma_figs';
        if ~exist(fold, 'dir')
            mkdir(mkdir)
        end
    end
    if ~isempty(nfold)
        fold = nfold;
        if ~exist(fold, 'dir')
            mkdir(mkdir)
        end
    end    
   
    f1 = figure('visible','off');
    f1.Position = [25 25 1000 1000];
    
    DFT.X = DF.X(i);
    [MAi] = chroma(DFT,RM,refcomp,'out',out,vo{:});
    D = MAi(:,4); ncs = MAi(:,1);
    [Ii] = indall(D,ncs);
    tab = table2array(Ii);

    saveas(f1,sprintf('./%s/peaks_%s.png',fold,fno{i}));

    f1b = figure('visible','off');
    f1b.Position = [25 25 1000 1000];
    [PRPH,PR,PH] = prph(DFT,RM,refcomp,vo{:});
    saveas(f1b,sprintf('./%s/prph_%s.png',fold,fno{i}));

    aasi(:,i) = MAi(:,4);
    c17 = D(ncs == 17); c18 = D(ncs == 18);
    pc17 = PR/c17; pc18 = PH/c18;
    
    ai = (D ~= 0);
    if i == 1
        nca(:,1) = ncs(:);
        nca(:,2) = ai(:);
    else
        nca(:,i+1) = ai(:);
    end
    
    if pc17 == 0
        pc17 = NaN;
    end
    if pc17 == Inf
        pc17 = NaN;
    end
    if pc18 == 0
        pc18 = NaN;
    end
    if pc18 == Inf
        pc18 = NaN;
    end

    cls1 = [25 33]; cls2 = [14 33]; cls3 = [27 33];
    
    cpis2(i,:) = tab(1);
    cpibes(i,:) = tab(2);
    paqs(i,:) = tab(3);
    [acls1(i,:),R1] = acl(D,ncs,'t',cls1);
    [acls2(i,:),R2] = acl(D,ncs,'t',cls2);
    [acls3(i,:),~] = acl(D,ncs,'t',cls3);
    cls1 = R1; cls2 = R2; 
    tars(i,:) = tab(5);
    salks(i,:) = tab(6);
    oeps(i,:) = tab(7);
    lhs(i,:) = tab(8);
    wis(i,:) = tab(9);
    lchschs(i,:) = tab(10);
    c31c19s(i,:) = tab(11);
    ratio1(i,:) = tab(12);
    ratio2(i,:) = tab(13);
    ratio3(i,:) = tab(14);
    prphs(i,:) = PRPH;
    pc17s(i,:) = pc17;
    pc18s(i,:) = pc18;
    pr(i,:) = PR; ph(i,:) = PH;

    fprintf('Working on sample %d of %d\n',i,nx)

end
    
    
    f2 = figure('visible','off');
    tp = tiledlayout(2,6); tp.TileSpacing = 'compact'; tp.Padding = 'compact';
    f2.Position = [20 100 2000 1200];

    
    tc = [dpt,cpis2,cpibes,paqs,acls1,acls2,acls3,tars,salks,oeps,lhs,wis,...
        lchschs,c31c19s,ratio1,ratio2,ratio3,prphs,pc17s,pc18s];
    t = sortrows(tc,1);
    
    xlmin = min(dpt)-1/min(dpt);
    xlmax = max(dpt)+1/max(dpt);
    ms = 5; fs = 7; fst = 7; xl = [xlmin xlmax];
    mcb = [57 106 177]./255; mcr = [204 37 41]./255; mcy = [0.9290, 0.6940, 0.1250];
    
    
    nexttile
    yn = t(:,2); yna1 = yn(~isnan(yn));
    xn = t(:,1); xna1 = xn(~isnan(yn));
    %yn = t(:,3); yna2 = yn(~isnan(yn));
    %xn = t(:,1); xna2 = xn(~isnan(yn));
    plot(yna1,xna1,'-ok','MarkerSize',ms,'MarkerFaceColor',mcb); hold on
    %plot(yna2,xna2,'-ok','MarkerSize',ms,'MarkerFaceColor',mcr); hold off
    axis ij; grid minor; ylim(xl);
    %legend('CPI2','CPI (B&E)','box','off','Location','northwest')
    xlabel('CPI'); ylabel('Position');

    nexttile
    %yn = t(:,5); yna1 = yn(~isnan(yn));
    %xn = t(:,1); xna1 = xn(~isnan(yn));
    yn = t(:,6); yna2 = yn(~isnan(yn));
    xn = t(:,1); xna2 = xn(~isnan(yn));
    %yn = t(:,7); yna3 = yn(~isnan(yn));
    %xn = t(:,1); xna3 = xn(~isnan(yn));
    %plot(yna1,xna1,'-ok','MarkerSize',ms,'MarkerFaceColor',mcb); hold on
    plot(yna2,xna2,'-ok','MarkerSize',ms,'MarkerFaceColor',mcb);
    %plot(yna3,xna3,'-ok','MarkerSize',ms,'MarkerFaceColor',mcy); hold off
    axis ij; grid minor;
    xlabel(sprintf('ACL_{%d-%d}',cls2(1),cls2(2)));  ylim(xl);
    %lgdtxt1 = sprintf('ACL_{%d-%d}',cls1(1),cls1(2));
    %lgdtxt2 = sprintf('ACL_{%d-%d}',cls2(1),cls2(2));
    %legend(lgdtxt1,lgdtxt2,'AHPCL','box','off','Location','northwest')
    set(gca,'YTickLabel',[])

    nexttile
    yn = t(:,9); yna = yn(~isnan(yn));
    xn = t(:,1); xna = xn(~isnan(yn));
    plot(yna,xna,'-ok','MarkerSize',ms,'MarkerFaceColor',mcb);
    axis ij; grid minor;
    xlabel('S-alk');  ylim(xl);
    set(gca,'YTickLabel',[])

    nexttile
    yn = t(:,4); yna = yn(~isnan(yn));
    xn = t(:,1); xna = xn(~isnan(yn));
    plot(yna,xna,'-ok','MarkerSize',ms,'MarkerFaceColor',mcb);
    axis ij; grid minor; ylim(xl);
    xlabel('Paq'); 
    set(gca,'YTickLabel',[])
    
    nexttile
    yn = t(:,8); yna = yn(~isnan(yn));
    xn = t(:,1); xna = xn(~isnan(yn));
    plot(yna,xna,'-ok','MarkerSize',ms,'MarkerFaceColor',mcb);
    axis ij; grid minor;
    xlabel('TAR');  ylim(xl);
    set(gca,'YTickLabel',[])

    nexttile
    yn = t(:,18); yna = yn(~isnan(yn));
    xn = t(:,1); xna = xn(~isnan(yn));
    plot(yna,xna,'-ok','MarkerSize',ms,'MarkerFaceColor',mcb);
    axis ij; grid minor;
    xlabel('Pr/Ph');  ylim(xl);
    set(gca,'YTickLabel',[])
    
    nexttile
    yn = t(:,10); yna = yn(~isnan(yn));
    xn = t(:,1); xna = xn(~isnan(yn));
    plot(yna,xna,'-ok','MarkerSize',ms,'MarkerFaceColor',mcb);
    axis ij; grid minor; ylim(xl);
    xlabel('OEP'); ylabel('Position');
    
    nexttile
    yn = t(:,11); yna = yn(~isnan(yn));
    xn = t(:,1); xna = xn(~isnan(yn));
    plot(yna,xna,'-ok','MarkerSize',ms,'MarkerFaceColor',mcb);
    axis ij; grid minor; ylim(xl);
    xlabel('L/H'); 
    set(gca,'YTickLabel',[])
    
    nexttile
    yn = t(:,12); yna = yn(~isnan(yn));
    xn = t(:,1); xna = xn(~isnan(yn));
    plot(yna,xna,'-ok','MarkerSize',ms,'MarkerFaceColor',mcb);
    axis ij; grid minor; ylim(xl);
    xlabel('WI (U/R)'); 
    set(gca,'YTickLabel',[])
    
    nexttile
    yn = t(:,13); yna = yn(~isnan(yn));
    xn = t(:,1); xna = xn(~isnan(yn));
    plot(yna,xna,'-ok','MarkerSize',ms,'MarkerFaceColor',mcb);
    axis ij; grid minor; ylim(xl);
    xlabel('LCH/SCH'); 
    set(gca,'YTickLabel',[])
    
    nexttile
    yn = t(:,15); yna1 = yn(~isnan(yn));
    xn = t(:,1); xna1 = xn(~isnan(yn));
    %yn = t(:,16); yna2 = yn(~isnan(yn));
    %xn = t(:,1); xna2 = xn(~isnan(yn));
    %yn = t(:,17); yna3 = yn(~isnan(yn));
    %xn = t(:,1); xna3 = xn(~isnan(yn));
    plot(yna1,xna1,'-ok','MarkerSize',ms,'MarkerFaceColor',mcb); hold on
    %plot(yna2,xna2,'-ok','MarkerSize',ms,'MarkerFaceColor',mcr);
    %plot(yna3,xna3,'-ok','MarkerSize',ms,'MarkerFaceColor',mcy); hold off
    axis ij; grid minor; ylim(xl);
    xlabel('Ratio'); 
    set(gca,'YTickLabel',[])

    nexttile
    yn = t(:,19); yna = yn(~isnan(yn));
    xn = t(:,1); xna = xn(~isnan(yn));
    %yn = t(:,20); yna2 = yn(~isnan(yn));
    %xn = t(:,1); xna2 = xn(~isnan(yn));
    plot(yna,xna,'-ok','MarkerSize',ms,'MarkerFaceColor',mcb); hold on
    %plot(yna2,xna2,'-ok','MarkerSize',ms,'MarkerFaceColor',mcr); hold off
    axis ij; grid minor; ylim(xl);
    xlabel('Pr/C_{17}'); 
    %legend('Pr/C_{17}','Ph/C_{18}','box','off','Location','northwest')
    set(gca,'YTickLabel',[])
    
    saveas(f2,sprintf('./%s/hc_indices.png',fold));


    f3 = figure('visible','off');
    f3.Position = [20 50 1200 1000];
    ncci = [ncs(:) sum(nca(:,2:end),2)];
    sas = [ncs(:) mean(aasi,2)];

    tp = tiledlayout(2,2); tp.TileSpacing = 'compact'; tp.Padding = 'compact';
    
    nexttile
    bar(ncci(:,1),ncci(:,2),0.01,'k')
    ylim([0 max(ncci(:,2)+max(ncci(:,2))/6)])
    xlabel('Component');
    ylabel('Count');

    nexttile
    stack(DF,'xrange',xrange,'view','yes');

    nexttile
    bar(sas(:,1),sas(:,2),0.01,'k')
    ylim([0 max(sas(:,2))+max(sas(:,2)/6)])
    xlabel('Component');
    ylabel('Average Area');

    nexttile
    warning('off')
    boxplot(aasi','Color','k','Label',ncs,'Symbol','+k')
    xlabel('Component');
    ylabel('Area');
    

    saveas(f3,sprintf('./%s/summary.png',fold));


elseif strcmp(view,'no')

for i = 1:nx

    DFT.X = DF.X(i);
    [MAi] = chroma(DFT,RM,refcomp,'out',out,vo{:});
    [PRPH,PR,PH] = prph(DFT,RM,refcomp,vo{:});

    D = MAi(:,4); ncs = MAi(:,1);
    [Ii] = indall(D,ncs);
    tab = table2array(Ii);

    c17 = D(ncs == 17); c18 = D(ncs == 18);
    pc17 = PR/c17; pc18 = PH/c18;
   
    
    if pc17 == 0
        pc17 = NaN;
    end
    if pc17 == Inf
        pc17 = NaN;
    end
    if pc18 == 0
        pc18 = NaN;
    end
    if pc18 == Inf
        pc18 = NaN;
    end

    cpis2(i,:) = tab(1);
    cpibes(i,:) = tab(2);
    paqs(i,:) = tab(3);
    acls1(i,:) = acl(D,ncs,[25 33]);
    acls2(i,:) = acl(D,ncs,[16 33]);
    acls3(i,:) = acl(D,ncs,[27 31]);
    tars(i,:) = tab(5);
    salks(i,:) = tab(6);
    oeps(i,:) = tab(7);
    lhs(i,:) = tab(8);
    wis(i,:) = tab(9);
    lchschs(i,:) = tab(10);
    c31c19s(i,:) = tab(11);
    ratio1(i,:) = tab(12);
    ratio2(i,:) = tab(13);
    ratio3(i,:) = tab(14);
    prphs(i,:) = PRPH;
    pc17s(i,:) = pc17;
    pc18s(i,:) = pc18;
    
    fprintf('Working on sample %d of %d\n',i,nx)


end
end

cnames = {'Profile Position','CPI2','CPIBE','Paq','ACL25-33','ACL16-33','AHPCL',...
    'TAR','S-alk','OEP','L/H','WI (U/R)','LCH/SCH','C31/C19',...
    'C31/(C29+C31)','C31/(C27+C31)','C23/(C23+C29)',...
    'Pr/Ph','Pr/C17','Ph/C18'};
ct = [dpt,cpis2,cpibes,paqs,acls1,acls2,acls3,tars,salks,oeps,lhs,wis,...
        lchschs,c31c19s,ratio1,ratio2,ratio3,prphs,pc17s,pc18s];
Tk = array2table(ct,'VariableNames',cnames,'RowNames',fno);
T = sortrows(Tk,1);

toc

end