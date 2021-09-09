addpath(genpath('/share/apps/rc/software/FreeSurfer/6.0.0-centos6_x86_64/matlab/'))

% all inputs
fov_path = '/data/user/mdefende/image-to-surface/images/cort-loc-paper/MDP050-OS-fovea.png';
im2plot_path = '/data/user/mdefende/image-to-surface/images/cort-loc-paper/MDP050-OS-scotoma.png';
subdir = '/data/user/mdefende/datasets/MDP/subs';
subj = 'sub-MDP050';
region = {'V1','V2','V3'};
labelbase = 'OS-scot-bin';
outdir = 'MKD_labels';
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
    
    %for ii = 1:length(subs)
        %subj = ['sub-' subs(ii).name];
        %fov_path = dir(fullfile(subs(ii).folder,subs(ii).name,'*ovea*'));
        %fov_path = fullfile(fov_path.folder,fov_path.name);
        
        %ims = dir(fullfile(subs(ii).folder,subs(ii).name,'*RL*'));
        %for jj = 1:length(ims)
            %im2plot_path = fullfile(ims(jj).folder,ims(jj).name);
            
            %rl = regexp(ims(jj).name,'[PU]RL','match'); rl = rl{1};
            %labelbase = [subj '-' rl '-grad'];
            
            convertBinaryToSurface(fov_path,im2plot_path,subdir,subj,reg,labelbase,outdir,max_ecc,dpp,inRetinalSpace,binary,force)
        %end
    %end
end
