function [T,sc] = conc(DF,RM,refcomp,varargin)


defsmthreshold = 3000;
defrmthreshold = 15000;
defcutoff = 10;
defds = 40;
defpad = [];
defout = 'tab';
defiscomp = [37.64 40]; % [time comp]
defdw = repmat(40,1,length(DF.X));
defisconc = 900/19000; % ug/uL
defsvol = 1000; % uL
definjv = 1;    % uL

expout = {'tab','mat'};

p = inputParser; 
validDF = @(x) isstruct(DF);
validsmthreshold = @(x) isnumeric(x) && isscalar(x);
validrmthreshold = @(x) isnumeric(x) && isscalar(x);
validcutoff = @(x) isnumeric(x) && isscalar(x);
validds = @(x) isnumeric(x) && isscalar(x);
validpad = @(x) isnumeric(x);
validout = @(x) any(validatestring(x,expout));

addRequired(p,'DF',validDF);
addRequired(p,'RM');
addRequired(p,'refcomp');

addParameter(p,'iscomp',defiscomp);
addParameter(p,'dw',defdw);
addParameter(p,'isconc',defisconc);
addParameter(p,'svol',defsvol);
addParameter(p,'injv',definjv);
addParameter(p,'smthreshold',defsmthreshold,validsmthreshold)
addParameter(p,'rmthreshold',defrmthreshold,validrmthreshold)
addParameter(p,'cutoff',defcutoff,validcutoff)
addParameter(p,'ds',defds,validds)
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

smth = p.Results.smthreshold;
rmth = p.Results.rmthreshold; 
cut = p.Results.cutoff; 
ds = p.Results.ds;
nc = p.Results.refcomp(:);
out = p.Results.out;
pad = p.Results.pad;
dw = p.Results.dw(:);
iscomp = p.Results.iscomp;
isconc = p.Results.isconc(:);
svol = p.Results.svol(:);
injv = p.Results.injv(:);

svial = svol/injv;
padk = [pad; iscomp];
nk = length(DF.X);
sc = zeros([length(nc)+length(padk(:,1)) nk]);
salk = zeros([1 nk]); salk = salk(:);
varn = strings(nk,1);
isn = padk(end,2);

for i = 1:nk

    DFk.X = DF.X(i);

    [MA] = chroma(DFk,RM,nc,'ds',ds,'rmthreshold',rmth, ...
        'pad',padk,'view','no','out','mat','smthreshold',smth, ...
        'cutoff',cut);

    SA = MA(:,4);
    AIS = MA(MA(:,1)==isn,4);

    dwk = dw(i);
    m = (isconc/AIS).*SA;
    tm = m*svial;
    sc(:,i) = tm/dwk;
    salk(i) = sum(sc(:,i));
    varn(i) = DFk.X.VN;
    
end

vn = string(varn); vn = vn(:);
T = table(vn,salk,'VariableNames',{'ID','Sum n-alk'});

if strcmp(out,'tab')
    % do nothing
elseif strcmp(out,'mat')
    tk = table2array(T(:,2));
    id = 1:nk;
    T = [id' tk];
end

end

