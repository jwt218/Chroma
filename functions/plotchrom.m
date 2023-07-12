function plotchrom(DF,varargin)

%PLOTCHROM Visualize your chromatograms
%   plotchrom(DF) plots all chromatograms in DF.
% 
%   plotchrom(DF,'plt',p) -- p is one of the following strings: 'layer' 
%   (default), 'stack', 'layout', and'3d'. 'layer' plots all
%   chromatograms in DF together in one plot. 'stack' uses the stack
%   function to sum all chromatograms (normalized). 'layout' plots all 
%   chromatograms on individual plots. '3d1' plots the time series on a 3d 
%   rotatable (click and drag) figure colored by sample #. '3d2' plots the 
%   time series on a 3d rotatable (click and drag) figure colored by
%   intensity. 'single' plots a single chromatogram from DF -- when 'sn' is
%   not specified, the default is the first chromatogram in DF.
% 
%   plotchrom(DF,'xrange',x) specifies the x-axis limits of the plotted
%   chromatograms. x should be a 2 element vector with the values going
%   from small to large. 
%
%   plotchrom(DF,'plt','single','sn',s) specifies the sample number to be
%   plotted when 'plt' is set to 'single. When s = 1 (default), the first
%   chromatogram in DF is plotted. 
%

defplt = 'layer';
defxrange = [11 25];
defsn = 1;

expplt = {'layer','stack','layout','3d1','3d2','single'};

p = inputParser; 
validplt = @(x) any(validatestring(x,expplt));
validxrange = @(x) isnumeric(x) && length(x) == 2;
validsn = @(x) isnumeric(x) && length(x) == 1;

addRequired(p,'DF');

addParameter(p,'plt',defplt,validplt)
addParameter(p,'xrange',defxrange,validxrange)
addParameter(p,'sn',defsn,validsn)

parse(p,DF,varargin{:})

if ~isempty(fieldnames(p.Unmatched))
   disp('Extra inputs:')
   disp(p.Unmatched)
end

DF = p.Results.DF; 
xrange = p.Results.xrange;
plt = p.Results.plt;
sn = p.Results.sn;


if strcmp(plt,'layer')
        
    lgdstr = cell(length(DF.X),1);
    
    clf
    figure(1);
    hold on
    for i = 1:length(DF.X)
        ch = DF.X(i).M;
        x = ch(:,1); y = ch(:,2);
        ti = find(x == xrange(1));
        ti(2) = find(x == xrange(2));
        x = x(ti(1):ti(2)); y = y(ti(1):ti(2));
        plot(x,y,'-'); 
        xlim(xrange);
        lgdstr{i} = strcat('Sample #',num2str(i));
    end
    hold off;
    box off;
    xlabel('Time'); ylabel('Intensity');
    legend(lgdstr,'box','off','Location','eastoutside');
    
elseif strcmp(plt,'stack')
    
    [S, tx] = stack(DF,'view','no');
    
    clf
    figure(1);
    plot(tx,S,'-k'); 
    xlim(xrange); 
    box off;
    xlabel('Time'); ylabel('Intensity (Normalized)');
    
elseif strcmp(plt,'layout')
        
    clf
    figure(1);
    tiledlayout(length(DF.X),1,'TileSpacing','tight');
    for i = 1:length(DF.X)
        nexttile;
        ch = DF.X(i).M;
        x = ch(:,1); y = ch(:,2);
        plot(x,y,'-'); 
        xlim(xrange); 
        legend(strcat('Sample #',num2str(i)),'box','off','Location','eastoutside');
        box off;
        set(gca,'XTick',[]);
    end
    set(gca,'XTickMode','auto');
    xlabel('Time'); 


elseif strcmp(plt,'3d1')

    lgdstr = cell(length(DF.X),1);
    ch = DF.X(1).M;

    x = ch(:,1);
    ti = find(x == xrange(1));
    ti(2) = find(x == xrange(2));
    x = zeros([length(x(ti(1):ti(2))) length(DF.X)]);
    y = zeros([length(x(ti(1):ti(2))) length(DF.X)]);
    
    for i = 1:length(DF.X)
        ch = DF.X(i).M;
        xk = ch(ti(1):ti(2),1); yk = ch(ti(1):ti(2),2);
        x(:,i) = xk; y(:,i) = yk;
        lgdstr{i} = strcat('Sample #',num2str(i));
    end

    figure(1); clf

    ribbon(x,y,0.06);
    shading flat; axis tight; ylim(xrange)
    ylabel('Time'); xlabel('Sample #'); zlabel('Intensity');
    grid minor;
    colormap('parula');
    set(gca,'Ydir','reverse');


elseif strcmp(plt,'3d2')

    lgdstr = cell(length(DF.X),1);
    ch = DF.X(1).M;

    x = ch(:,1);
    ti = find(x == xrange(1));
    ti(2) = find(x == xrange(2));
    x = zeros([length(x(ti(1):ti(2))) length(DF.X)]);
    y = zeros([length(x(ti(1):ti(2))) length(DF.X)]);
    
    for i = 1:length(DF.X)
        ch = DF.X(i).M;
        xk = ch(ti(1):ti(2),1); yk = ch(ti(1):ti(2),2);
        x(:,i) = xk; y(:,i) = yk;
        lgdstr{i} = strcat('Sample #',num2str(i));
    end

    figure(1); clf
    axh = axes;

    h = ribbon(axh,x,y,0.06);
    shading flat; axis tight; ylim(xrange)
    ylabel('Time'); xlabel('Sample #'); zlabel('Intensity');
    grid minor;
    set(gca,'Ydir','reverse');
    for i = 1:length(h)
        h(i).CData = h(i).ZData;
        h(i).FaceColor = 'interp';
        h(i).FaceLighting = 'gouraud';
        h(i).MeshStyle = 'column';
    end
    colormap('turbo')
    cb = colorbar(axh,'eastoutside');
    xlabel(cb,'Intensity');

elseif strcmp(plt,'single')
    
    ch = DF.X(sn).M;
    x = ch(:,1); y = ch(:,2);
    
    clf
    figure(1);
    plot(x,y,'-k'); 
    xlim(xrange); 
    box off; grid minor;
    xlabel('Time'); ylabel('Intensity');

end


end
  