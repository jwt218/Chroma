# Chroma
Chroma is a MATLAB package for efficient and reproducible analysis of chromatogram data. 

## Installation

Download the Chroma-main repository to a desired location on your desktop. In MATLAB, add the functions directory (/Chroma-main/functions) to the environment set path. 

## Basic Usage

See corresponding vignette files in /Chroma-main/docs/vignette.m and /Chroma-main/docs/vignette_chroma.docx. 

```Matlab
DF = prepfiles('./data/exampleDF.xlsx','headerrow',2); % sample
RM = prepfiles('./data/B4_CG.xlsx','headerrow',2); % standard

refcomp = 16:30; % component numbers

[MA] = chroma(DF,RM,refcomp)
disp(MA) % output with standard-referenced sample peak areas and heights
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://github.com/jwt218/Chroma/blob/main/LICENSE)
