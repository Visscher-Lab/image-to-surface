% all inputs
fov_path = '/data/user/mdefende/image-to-surface/images/cones_fov_lores.bmp';
im2plot_path = '/data/user/mdefende/image-to-surface/images/cones5deg.bmp';
subdir = '/data/project/vislab/a/MDP/FreeSurfer_Subjects/';
subj = 'MDP050';
region = 'V1';
labelbase = 'cones_5deg_overlap_binary';
outdir = 'MKD_labels';
max_ecc = 60;
dpp = 30/500;
binary = true;

% create parallel pool if one does not exist and number of cores > 1
p = gcp('nocreate');
if isempty(p)
    numcores = feature('numcores');
    if numcores > 1
        parpool(numcores)
    end
end

convertBinaryToSurface(fov_path,im2plot_path,subdir,subj,region,labelbase,outdir,max_ecc,dpp,binary)