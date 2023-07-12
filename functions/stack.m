function [S,tx,int] = stack(DF,varargin)

%STACK Sum of chromatograms in DF
%   S = stack(DF) returns the stack of all chromatograms in DF. 
%
%   [S,tx] = stack(DF) returns intensity and time.
%
%   [S,tx,int] = stack(DF) returns a matrix of the individual chromatograms.
%
%   S = stack(DF,'view',v) gives the option for generating a
%   figure after the analysis. Enter v = 'yes' to view the plot or v = 'no'
%   otherwise. The default is v = 'yes'. 
%
%   S = stack(DF,'xrange',x) defines the plotting range if the
%   view option is activated. For chromatograms with time units in minutes,
%   x = [11 25] plots only for the range 11-25 minutes. The default is x =
%   [11 25].

defview = 'yes';
defxrange = [11 25];

expview = {'yes','no'};

p = inputParser; 
validview = @(x) any(validatestring(x,expview));
validxrange = @(x) isnumeric(x) && length(x) == 2;

addRequired(p,'DF');
addParameter(p,'view',defview,validview)
addParameter(p,'xrange',defxrange,validxrange)

parse(p,DF,varargin{:})

DF = p.Results.DF;
nx = length(DF.X);
xrange = p.Results.xrange(:);
view = p.Results.view;

int = zeros([length(DF.X(1).M(:,1)) nx]);
for i = 1:nx
    ch = DF.X(i).M; 
    int(:,i) = ch(:,2);
end

ti = ch(:,1);
t1 = find(ti == xrange(1));
t2 = find(ti == xrange(2));
tx = ti(t1:t2);

Si = sum(int,2);
Sint = Si(t1:t2);
S = (Sint-min(Sint))./(max(Sint)-min(Sint))*100;

if strcmp(view,'yes')

    plot(tx,S,'-k')
    %plot([1 4 5 6], [3 6 25 46])
    xlim(xrange);
    xlabel('Retention Time');
    ylabel('Relative Abundance (Normalized)');

end

if strcmp(view,'no')
    
    % do nothing
    
end


end
