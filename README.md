# image-to-surface
image-to-surface
A small toolbox built to convert a 2-D representation of an object from image space to a label on the cortical surface. A common problem for visual neuroscience using MRI is cortical placement of regions of interest. If you are stimulating a region or having a participant perform a task at a specific location in the visual field, you want to be able to accurately localize where that region falls on the cortical surface. image-to-surface utilizes a retinotopic atlas (Benson et al. 2018) for general spatial localization of a visual object of interest while also taking into account properties of population receptive fields (pRFs). Essentially, if an object only partially falls within a pRF, the vertex on the cortical surface is only going to be affected proportional to the area of the pRF covered by the object. The end result is a FreeSurfer label containing a value for all vertices in the chosen area that equals this proportion.

Author
Matthew Defenderfer <mdefende@uab.edu>

Installation
This toolbox was written in MATLAB version R2018a but is most likely compatible with earlier versions as well. Download the git repo, unzip, and add it to your MATLAB path.

Dependencies
While the toolbox itself does not call any neuropythy commands, the neuropythy toolbox is required for transferring the retinotopic atlas to FreeSurfer output subjects. The retinotopic atlas is necessary for the toolbox to run correctly. See instructions for installing and using neuropythy here
FreeSurfer 6.0.0 is recommended for surface reconstruction of structural MRI images although the scripts will work with outputs from earlier versions as well as the intermediate FreeSurfer outputs downloaded from the Human Connectome Project as well.

Instructions
The toolbox is run through the convertBinaryToSurface function. calcVertImage is a helper function called in convertBinaryToSurface. The function needs the following inputs:

fov_path : file path to the image showing the fovea location. ex. '/data/user/mdefende/Im2Surf/MDP050_OD_OS_fovea.bmp'
im2plot_path : file path to the image to be converted to surface space. ex. '/data/user/mdefende/Im2Surf/MDP050_OD_OS_lpx.bmp';
subdir : file path containing the subject's freesurfer output. ex. '/data/project/vislab/a/MDP/FreeSurfer_Subjects/';
subj : name of the subject in subdir. ex. 'MDP050'
region : which region to convert the image to. Possible values are 'V1','V2', and 'V3' for now.
outdir : subfolder in the subject's freesurfer label folder to save the output labels. Leave [] to store in the main label folder. The folder will be made if it does not already exist. ex. for input 'MKD_labels', labels will be stored in subdir/subj/label/MKD_labels
labelbase : label names will be saved as ?h...label
max_ecc : radial eccentricity to pad the image to. This works around the issue that most inputs from MAIA images or likewise will only have a radial eccentricity of ~20 degrees. Leaving images this size would cause centers for far field vertices to be estimated as much closer than they are in reality which, based on the size of the scotoma, stimulus, or otherwise, could cause a measureable overlap in the farfield vertices when there actually shouldn't be. By default, this value will is 50 degrees, but a decent rule of thumb would be to set this value to be ~20% higher than the maximum radial eccentricity of the area of interest in your image. Leave [] to use default 60.
dpp : conversion factor between pixels and degrees. dpp stands for degrees per pixel. This is used to convert from an image space to a retinotopic space. By default, this value is 0.0356 corresponding to the dpp for the current MAIA in Callahan 405. If using images derived from sources other than this MAIA, this value absolutely must be set, otherwise the retinotopic estimates will be shrunk or extended compared to expected. Leave [] to use default 0.0356.
binary : if true, the algorithm will create a label with only vertices whose centers are within the extent of the object in the image to plot (scotoma, stimulus, etc.). If false, the algorithm will calculate the % association metric described above. Leave [] to use defaults value of false.

An example can be seen in the MASTER.m script.
Images should only be binary with the background being white and the object of interest being black. Be sure to use the correct dpp value, otherwise object placement will be incorrect. Calculate this value by counting the number of pixels from the center of the fovea to the center of a known location in the visual field, and divide by that known location's eccentricity. For example, if you have a stimulus with center set at 10 degrees horizontal eccentricity that is 500 pixels from the fovea, the dpp value will be 10/500 = 0.02.

Future Additions

Input grayscale images that could represent features such as differences in light intensity or non-dense scotoma.
Input color images.
Use individual retinotopy outputs as opposed to retinotopic atlas.
