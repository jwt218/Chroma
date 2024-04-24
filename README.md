# Chroma
Chroma is a MATLAB package for efficient and reproducible analysis of chromatogram data. 

## Installation

Download the Chroma-main repository to a desired location on your desktop. In MATLAB, add the functions directory (/Chroma-main/functions) to the environment set path. 

## Directory Structure

All operations in this document and the accompanying vignette files should be run from the parent directory /Chroma-main. All data needed for running the examples and to reproduce data reported in the corresponding publication are stored in /Chroma-main/data. The MATLAB and corresponding Word vignette files are found in /Chroma-main/docs. Functions are called from the /Chroma-main/functions directory (set this folder to your MATLAB environment path). 

## Citing This Work

If used for producing published data, please cite this work with the following reference:

pending...

## Basic Usage

See corresponding vignette files in /Chroma-main/docs/vignette.m and /Chroma-main/docs/vignette_chroma.docx. All operations should be run from the parent directory (/Chroma-main).

The function "chroma" operates reads in one sample and one standard chromatogram. Target peaks (e.g., n-alkanes) are identified by correlating the peak times of the standard to peaks in the sample. Non-target peaks (e.g., noise, contaminants, and other compounds) are automatically filtered out of the analysis. Input data must be read into MATLAB using the "prepfiles" function for proper formatting. Most file extensions (e.g., .csv, .xslx, etc.) are acceptible. Data files must have the time in the first column and the intensity in the second column to be properly formatted by prepfiles. 

```Matlab
DF = prepfiles('./data/exampleDF.xlsx','headerrow',2); % sample
RM = prepfiles('./data/B4_CG.xlsx','headerrow',2); % standard

refcomp = 16:30; % component numbers

[MA] = chroma(DF,RM,refcomp)
disp(MA) % output with standard-referenced sample peak areas and heights
```

Add more arguments to refine the target peak search (adjust these to see how they affect the output). Use the "help" function in MATLAB for more information on "chroma" arguments.

```Matlab
refcomp = 16:30;    % component numbers for RM
pad = [21.56 31; 22.32 32; 23.20 33];   % look for additional components
ds = 40; % reference detection window
view = 'yes';   % plotting option
smth = 3000;  % minimum sample peak threshold
rmth = 25000;    % minimum standard peak threshold
xrange = [11 25];   % plotting xlim
out = 'tab';    % output data format
cutoff = 10;    % start time for analysis
meth = 'drop'; % method for integration ('drop','gauss','deriv2', 'tan', or 'base')

[MA] = chroma(DF,RM,refcomp,'pad',pad,'ds',ds,'view',view,'smthreshold',...
    smth,'rmthreshold',rmth,'xrange',xrange,'out',out,'cutoff',cutoff,'method',meth);
disp(MA)
```

If reading in multiple samples to be analyzed by "chromall", data from each sample should be included in the data file following this column sequence (time, intensity; time, intensity; time, intensity…) with no space between columns (see Excel spreadsheets in /Chroma-main/data). Output figures will be stored in /Chroma-main/figs. 

```Matlab
load('./data/cgprof.mat') % load in depth profile information

CG = prepfiles('./data/cg.xlsx','headerrow',2); % read in Excel sample files
B4 = prepfiles('./data/B4_CG.xlsx','headerrow',2);% read in Excel standard files
refcomp = 16:30; % define component range for standards

padB4 = [21.56 31; 22.32 32; 23.20 33]; % define the extra components
ds = 100; % define the reference detection window
view = 'yes'; % output figures to directory
meth = 'base';

% run chroma for all samples (chromall) 
% *this will take a few minutes if view = 'yes'
[CGT] = chromall(CG,B4,refcomp,'prof',cgprof,'ds',ds,'rmthreshold',2.5e4,'pad',padB4,'nfold','figs/CG','view',view,'method',meth);
```

Compare peaks of two analyses using "pkcomp".

```Matlab
DF1 = prepfiles('./data/example1.xlsx','headerrow',2);
DF2 = prepfiles('./data/example2.xlsx','headerrow',2);
RM1 = prepfiles('./data/A6_HGZ_LJM_QGQ_WSS.xlsx','headerrow',2); RM1.X.M(:,2) = RM1.X.M(:,2)*1.5;
RM2 = prepfiles('./data/B4_CG.xlsx','headerrow',2); RM2.X.M(:,2) = RM2.X.M(:,2)*3;

refcomp = 16:30;   
plt = 'yes';

T = pkcomp(DF2,DF1,RM2,RM1,refcomp,refcomp,'plt',plt,'rmthreshold',9e4);
disp(T)
```

Use indall to determine index values of a sample

```
DF = prepfiles('./data/exampleDF.xlsx','headerrow',2);
RM = prepfiles('./data/B4_CG.xlsx','headerrow',2);

refcomp = 16:30;     
pad = [21.56 31; 22.32 32; 23.20 33]; 

[MA] = chroma(DF,RM,refcomp,'pad',pad,'out','mat','view','no');

D = MA(:,4); % get areas
ncs = MA(:,1); % get components

[I] = indall(D,ncs);
disp(I)
```
Additional operations for data visualization and interpretation can be found in the Chroma vignettes (\docs subdirectory). All examples are provided as basic guidelines. Outputs can be adjusted by changing various input parameters and optional arguments. All functions in Chroma include ```help``` documentation for syntax and assistance.

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://github.com/jwt218/Chroma/blob/main/LICENSE)
