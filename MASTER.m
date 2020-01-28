% all inputs
fov_path = '/data/user/mdefende/image-to-surface/images/MDP005_OS_Large_fovea.bmp';
im2plot_path = '/data/user/mdefende/image-to-surface/images/MDP005_OS_Large_PRL.bmp';
subdir = '/data/project/vislab/a/MDP/FreeSurfer_Subjects/';
subj = 'MDP005';
region = 'V3';
labelbase = 'OS_PRL';
outdir = 'MKD_labels';
max_ecc = 70;
dpp = 0.0356;
binary = false;

% create parallel pool if one does not exist and number of cores > 1
p = gcp('nocreate');
if isempty(p)
    numcores = feature('numcores');
    if numcores > 1
        parpool(numcores)
    end
end

convertBinaryToSurface(fov_path,im2plot_path,subdir,subj,region,labelbase,outdir,max_ecc,dpp,binary)