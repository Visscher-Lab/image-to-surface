% add path to FreeSurfer's MATLAB folder for access to scripts to load mgz
% files
addpath(genpath('/path/to/FreeSurfer/MATLAB/folder'))

% all inputs
fov_path = '/path/to/fovea/image';
im2plot_path = '/path/to/image/to/convert';
subdir = '/path/to/FreeSurfer/subjects/directory';
subj = 'subject-name';
region = {'V1','V2','V3'};
labelbase = 'label-base';
outdir = 'custom-labels';
max_ecc = 70;
dpp = 0.023;
inRetinalSpace = true;
binary = true;
force = 0;

% create parallel pool if one does not exist and number of cores > 1
p = gcp('nocreate');
if isempty(p)
    numcores = feature('numcores');
    if numcores > 1
        parpool(numcores)
    end
end

for rr = 1:length(region)
    reg = region{rr};
            
    convertBinaryToSurface(fov_path,im2plot_path,subdir,subj,reg,labelbase,outdir,max_ecc,dpp,inRetinalSpace,binary,force)
end
