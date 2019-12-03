function convertBinaryToSurface(fov_path,im2plot_path,subdir,subj,region,labelbase,outdir,max_ecc,dpp,binary)
%{
This function takes in images of foveal location and some shape with
position relative to the fovea and converts them to surface space on the
subject's hemispheres. For this function, you will need to have completed a
recon-all on a subject and transferred the new Benson atlas v4.0 to both
left and right hemisphere (see github.com/noahbenson/neuropythy for
instructions). The function has the following workflow:
    
    1. Center the image to plot based on the fovea location
    2. For each vertex in the selected region:
        a. find the pixel with closest eccentricity and polar angle to the
           current vertex
        b. create a 2D gaussian that represents the pRF of that vertex in
           the image space
        c. find weighted overlap of the pRF with the input image and divide
           by the total area under the pRF gaussian
        d. assign the resulting percentage to that vertex location in an array
    3. A label is created for the left and right hemispheres containing all
       vertices in the selected area with their assigned percentage values

Standard output are two labels files containing each vertex in the region
passed in to the function. Each of the vertices will have a value assigned
to it between 0 and 1. This represents the weighted overlap of the object
in the image with the gaussian that represents the pRF. 

Inputs: 
    fov_path <string>: file path to the image showing the fovea location
        ex. '/data/user/mdefende/Im2Surf/MDP050_OD_OS_fovea.bmp'
    im2plot_path <string>: file path to the image to be converted to surface space
        ex. '/data/user/mdefende/Im2Surf/MDP050_OD_OS_lpx.bmp';
    subdir <string>: file path containing the subject's freesurfer output
        ex. '/data/project/vislab/a/MDP/FreeSurfer_Subjects/';
    subj <string>: name of the subject in subdir
        ex. 'MDP050'
    region <string>: which region to convert the image to. Possible values
        are 'V1','V2', and 'V3' for now.
    outdir <string>: subfolder in the subject's freesurfer label folder to
        save the output labels. Leave [] to store in the main label folder.
        The folder will be made if it does not already exist. 
        ex. for input 'MKD_labels', labels will be stored in
        subdir/subj/label/MKD_labels
    labelbase <string>: label names will be saved as
        ?h.<region>.<labelbase>.label
    max_ecc <double>: radial eccentricity to pad the image to. This works
        around the issue that most inputs from MAIA images or likewise will
        only have a radial eccentricity of ~20 degrees. Leaving images this
        size would cause centers for far field vertices to be estimated as
        much closer than they are in reality which, based on the size of
        the scotoma, stimulus, or otherwise, could cause a measureable
        overlap in the farfield vertices when there actually shouldn't be.
        By default, this value will is 50 degrees, but a decent rule of
        thumb would be to set this value to be ~20% higher than the maximum
        radial eccentricity of the area of interest in your image. Leave []
        to use default 60.
    dpp <double>: conversion factor between pixels and degrees. dpp stands
        for degrees per pixel. This is used to convert from an image space
        to a retinotopic space. By default, this value is 0.0356
        corresponding to the dpp for the current MAIA in Callahan 405. If
        using images derived from sources other than this MAIA, this value
        absolutely must be set, otherwise the retinotopic estimates will be
        shrunk or extended compared to expected. Leave [] to use default
        0.0356. 
    binary <logical>: if true, the algorithm will create a label with
        only vertices whose centers are within the extent of the object in
        the image to plot (scotoma, stimulus, etc.). If false, the
        algorithm will calculate the % association metric described above.
        Leave [] to use defaults value of false.

Written by: Matt Defenderfer
Date: 11/19/19
Updated: 12/3/19
%}
%% Initial Setup

if isempty(dpp)
    dpp = 0.0356;
end

if isempty(max_ecc)
    max_ecc = 60;
end

if isempty(binary)
    binary = false;
end

% Set the SUBJECTS_DIR env variable
setenv('SUBJECTS_DIR',subdir);

% set region to loop through
switch region
    case 'V1'
        area_val = 1;
    case 'V2'
        area_val = 2;
    case 'V3'
        area_val = 3;
end
%% Import Images, Binarize, and Resize
fov_im = im2bw(imread(fov_path)); %#ok<*IM2BW>
im2plot = im2bw(imread(im2plot_path));

% need to invert images to where 1's correspond to areas of interest (fovea
% or scotoma) and 0's are background
fov_im = ~fov_im;
im2plot = ~im2plot;

% Calculate size of matrix necessary to have ~50 deg radial eccentricity
% using dpp calculation
max_deg_size = ceil(max_ecc/dpp*2);

% Add columns and rows to make the images equal the max_deg_size. If images
% are larger, make number of rows and columns equal.
if size(fov_im,1) < max_deg_size
    fov_im(end+1:max_deg_size,:) = 0;
    im2plot(end+1:max_deg_size,:) = 0;
end

if size(fov_im,2) < max_deg_size
    fov_im(:,end+1:max_deg_size) = 0;
    im2plot(:,end+1:max_deg_size) = 0;
end

if size(fov_im,1) < size(fov_im,2)
    fov_im(end+1:size(fov_im,2),:) = 0;
    im2plot(end+1:size(im2plot,2),:) = 0;
elseif size(fov_im,1) > size(fov_im,2)
    fov_im(:,end+1:size(fov_im,1)) = 0;
    im2plot(:,end+1:size(im2plot,1)) = 0;
end

% if image has even number of rows or columns, add extra row or column to
% make a true center
if mod(size(fov_im,1),2) == 0
    fov_im(end+1,:) = 0;
    im2plot(end+1,:) = 0;
end

if mod(size(fov_im,2),2) == 0
    fov_im(:,end+1) = 0;
    im2plot(:,end+1) = 0;
end

%% Center Images by Fovea Centroid. Create Distance, Ecc, and Pol Matrices
% get centroid of the foveal image using regionprops
fov_props = regionprops(fov_im,'centroid');

% centroid has c,r order as opposed to r,c, so I mirror that here
im_center = [(size(fov_im,2)-1)/2,(size(fov_im,1)-1)/2];

% adjust image positions to where fovea is in the center. shift by distance
% between centroid and center
shift_vert = im_center(2)-round(fov_props.Centroid(2));
shift_hor = im_center(1)-round(fov_props.Centroid(1));
fov_im = circshift(fov_im, [shift_vert, shift_hor]);
im2plot = circshift(im2plot, [shift_vert, shift_hor]);

% create x and y distance from center matrices, convert to degrees by
% multiplying by dpp
x_dist = repmat(-im_center(1):im_center(1),[size(fov_im,1),1])*dpp;
y_dist = repmat([-im_center(2):im_center(2)]',[1,size(fov_im,2)])*dpp;

[im_pol,im_ecc] = cart2pol(x_dist,y_dist);
im_pol = -im_pol*180/pi;

%% Read in Subject's Surfaces and Labels
lhecc = squeeze(load_mgh(fullfile(subdir,subj,'surf','lh.benson14_eccen.mgz')));
rhecc = squeeze(load_mgh(fullfile(subdir,subj,'surf','rh.benson14_eccen.mgz')));
lhpol = squeeze(load_mgh(fullfile(subdir,subj,'surf','lh.benson14_angle.mgz')));
rhpol = squeeze(load_mgh(fullfile(subdir,subj,'surf','rh.benson14_angle.mgz')));
lhsig = squeeze(load_mgh(fullfile(subdir,subj,'surf','lh.benson14_sigma.mgz')));
rhsig = squeeze(load_mgh(fullfile(subdir,subj,'surf','rh.benson14_sigma.mgz')));
lharea = squeeze(load_mgh(fullfile(subdir,subj,'surf','lh.benson14_varea.mgz')));
rharea = squeeze(load_mgh(fullfile(subdir,subj,'surf','rh.benson14_varea.mgz')));

lhcortex = read_label(subj, 'lh.cortex');
rhcortex = read_label(subj, 'rh.cortex');

% convert polar angle for lh and rh to match values in im_pol
lhpol = -(lhpol-90);

indless = rhpol < 90;
indmore = rhpol >= 90;
rhpol(indless) = rhpol(indless) + 90;
rhpol(indmore) = rhpol(indmore) - 270;    

%% Convert Image to surface space for multiple areas
lhIm = calcVertImage(im2plot,im_ecc,im_pol,x_dist,y_dist,lhecc,lhpol,lhsig,lharea,area_val,binary);
rhIm = calcVertImage(im2plot,im_ecc,im_pol,x_dist,y_dist,rhecc,rhpol,rhsig,rharea,area_val,binary);

%% convert to label
lhvert  = find(lharea == area_val) - 1;
lhlabel = [lhcortex(ismember(lhcortex(:,1),lhvert),1:4),lhIm(lhvert+1)];

rhvert  = find(rharea == area_val) - 1;
rhlabel = [rhcortex(ismember(rhcortex(:,1),rhvert),1:4),rhIm(rhvert+1)];

%% Save to file
if ~isempty(outdir)
    full_outdir = fullfile(subdir,subj,'label',outdir);
else
    full_outdir = fullfile(subdir,subj,'label');
end

if ~exist(full_outdir,'dir')
    mkdir(full_outdir)
end

write_label(lhlabel(:,1),lhlabel(:,2:4),lhlabel(:,5),fullfile(full_outdir,['lh.' region '.' labelbase '.label']), subj)
write_label(rhlabel(:,1),rhlabel(:,2:4),rhlabel(:,5),fullfile(full_outdir,['rh.' region '.' labelbase '.label']), subj)

