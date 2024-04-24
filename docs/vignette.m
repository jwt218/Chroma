%%% -----------------------------------------------------------------------

%%% Tutorial vignette for using the Chroma package
%%% -> Run from the Chroma parent directory
%%% -> Run each section one at a time
%%% -> See corresponding document for detailed descriptions

%%% -----------------------------------------------------------------------

%%% 1. Prepare files into Chroma structure <===============================
% -> (see Excel files for format) 

DF = prepfiles('./data/exampleDF.xlsx','headerrow',2); % sample
RM = prepfiles('./data/B4_CG.xlsx','headerrow',2); % standard

%%% 2. Run chroma <========================================================

refcomp = 16:30;    % component numbers for RM
[MA] = chroma(DF,RM,refcomp,'view','no');
disp(MA)

%%% 3. Add more arguments <================================================
% -> (adjust these to see how they affect the output)

refcomp = 16:30;    % component numbers for RM
pad = [21.55 31; 22.32 32; 23.20 33];   % look for additional components
ds = 40; % reference detection window
view = 'yes';   % plotting option
smth = 3000;  % minimum sample peak threshold
rmth = 25000;    % minimum standard peak threshold
xrange = [11 25];   % plotting xlim
out = 'tab';    % output data format
cutoff = 10;    % start time for analysis
meth = 'drop'; % method for integration ('drop','gauss','deriv2', 'tan', or 'base')

[MA] = chroma(DF,RM,refcomp,'pad',pad,'ds',ds,'view',view,'smthreshold',...
    smth,'rmthreshold',rmth,'xrange',xrange,'out',out,'cutoff',cutoff,...
    'method',meth);
disp(MA)

%%% 4. Run chromall <======================================================
% -> (this section recreates the data in the corresponding paper)

clear
load('./data/cgprof.mat') % load in depth profile information
load('./data/ljmprof.mat')
load('./data/hgzprof.mat')
load('./data/qgqprof.mat')
load('./data/wssprof.mat')
load('./data/xcgprof.mat')

CG = prepfiles('./data/cg.xlsx','headerrow',2); % read in sample files
HGZ = prepfiles('./data/hgz.xlsx','headerrow',2);
LJM = prepfiles('./data/ljm.xlsx','headerrow',2); 
QGQ = prepfiles('./data/qgq.xlsx','headerrow',2); 
WSS = prepfiles('./data/wss.xlsx','headerrow',2);
XCG = prepfiles('./data/xcg.xlsx','headerrow',2);

B4 = prepfiles('./data/B4_CG.xlsx','headerrow',2);% read in standard files
A6 = prepfiles('./data/A6_HGZ_LJM_QGQ_WSS.xlsx','headerrow',2);
A6_2 = prepfiles('./data/A6_XCG.xlsx','headerrow',2);

refcomp = 16:30; % define component range for standards

padB4 = [21.56 31; 22.32 32; 23.20 33]; % define the extra components
padA6_1 = [21.87 31; 22.65 32; 23.57 33];
padA6_2 = [21.70 31; 22.54 32; 23.45 33];
padA6_3 = [22.29 31; 23.18 32; 24.20 33];
ds = 100; % define reference detection window (pts)
view = 'yes'; % output figures to directory
meth = 'base';

% -> run chroma for all samples (chromall) 
% -> *this will take a few minutes if view = 'yes'
[CGT] = chromall(CG,B4,refcomp,'prof',cgprof,'ds',ds,'rmthreshold',2.5e4,'pad',padB4,'nfold','figs/CG','view',view,'method',meth);
[HGZT] = chromall(HGZ,A6,refcomp,'prof',hgzprof,'ds',ds,'rmthreshold',6e4,'pad',padA6_2,'nfold','figs/HGZ','view',view,'method',meth);
[LJMT] = chromall(LJM,A6,refcomp,'prof',ljmprof,'ds',ds,'rmthreshold',6e4,'pad',padA6_1,'nfold','figs/LJM','view',view,'method',meth);
[QGQT] = chromall(QGQ,A6,refcomp,'prof',qgqprof,'ds',ds,'rmthreshold',6e4,'pad',padA6_1,'nfold','figs/QGQ','view',view,'method',meth);
[WSST] = chromall(WSS,A6,refcomp,'prof',wssprof,'ds',ds,'rmthreshold',6e4,'pad',padA6_1,'nfold','figs/WSS','view',view,'method',meth);
[XCGT] = chromall(XCG,A6_2,refcomp,'prof',xcgprof,'ds',ds,'rmthreshold',6e4,'pad',padA6_3,'nfold','figs/XCG','view',view,'method',meth);


% -> Check the newly created ./figs folder for the output figures.

%%% 5. Use pkcomp to compare peaks of two samples <========================

DF1 = prepfiles('./data/example1.xlsx','headerrow',2);
DF2 = prepfiles('./data/example2.xlsx','headerrow',2);
RM1 = prepfiles('./data/A6_HGZ_LJM_QGQ_WSS.xlsx','headerrow',2); 
RM2 = prepfiles('./data/B4_CG.xlsx','headerrow',2); 

RM2.X.M(:,2) = RM2.X.M(:,2)*2; 
% -> changing reference intensity to reach peak threshold 

refcomp = 16:30;   
plt = 'yes';

T = pkcomp(DF2,DF1,RM2,RM1,refcomp,refcomp,'plt',plt,'rmthreshold',5e4);
disp(T)

%%% 6. Use indall to determine several index values of a sample <==========

DF = prepfiles('./data/exampleDF.xlsx','headerrow',2);
RM = prepfiles('./data/B4_CG.xlsx','headerrow',2);

refcomp = 16:30;     
pad = [21.56 31; 22.32 32; 23.20 33]; 

[MA] = chroma(DF,RM,refcomp,'pad',pad,'out','mat','view','no');

D = MA(:,4); % get areas from output table
ncs = MA(:,1); % get components

[I] = indall(D,ncs); % input areas and components
disp(I)

%%% 7. Use plotchrom to visualize data <===================================

CG = prepfiles('./data/cg.xlsx','headerrow',2); 

plotchrom(CG,'xrange',[11 25],'plt','layer'); 
% -> also try 'stack', 'layout', '3d1', '3d2'

%%% 8. Use prph to find pristane and phytane <=============================

DF = prepfiles('./data/example_prph.xlsx','headerrow',2);
RM = prepfiles('./data/b4_prph.xlsx','headerrow',2);

refcomp = 16:30;     
[PRPH,PR,PH] = prph(DF,RM,refcomp,'view','yes','ds',30,'rmthreshold',...
    2.5e4,'xrange',[12 16]);


%%% 9. Use compcpi and compacl to compare calculation methods <============

LJM = prepfiles('./data/ljm.xlsx','headerrow',2); 
A6 = prepfiles('./data/A6_HGZ_LJM_QGQ_WSS.xlsx','headerrow',2);
padA6_1 = [21.87 31; 22.65 32; 23.57 33];
refcomp = 16:30;  

[CPI2,CPIBE] = compcpi(LJM,A6,refcomp,'rmthreshold',6e4,'pad',...
    padA6_1,'plt','profile');
% -> also try '1:1'

[A1,A2,A3] = compacl(LJM,A6,refcomp,'rmthreshold',6e4,'pad',...
    padA6_1,'plt','layer');
% -> also try '1:1'

% -> For documentation on any function in the Chroma package, check help.




