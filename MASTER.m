fov_path = '/data/user/mdefende/Im2Surf/images/center_fov.bmp';
im2plot_path = '/data/user/mdefende/Im2Surf/images/bar_stim.bmp';
subdir = '/data/project/vislab/a/MDP/FreeSurfer_Subjects/';
subj = 'MDP050';
region = 'V1';
labelbase = 'bar_overlap';
outdir = 'MKD_labels';
max_ecc = 60;
dpp = [];

convertBinaryToSurface(fov_path,im2plot_path,subdir,subj,region,labelbase,outdir,max_ecc,dpp)