function vertIm = calcVertImage(im,im_ecc,im_pol,im_x,im_y,ecc,pol,sigma,varea,area_val)
%{
This is a helper function for the convertBinaryToSurface function for
converting a binary image to surface space. It loops through each vertex in
the supplied surfaces, creates a gaussian weight matrix with fwhm equal to the sigma
value at that vertex centered at the ecc and pol values for that vertex. It
will then multiply this weight matrix by the given image, average across
the resultant weighted image, and store this mean in an indexed location
for later.

Written by: Matt Defenderfer
Date Created: 11/19/19
%}


% initialize an array to contain our output averages
vertIm = zeros(length(ecc),1);
areaInd = find(varea == area_val);
tmp = [];
parfor ii = 1:length(areaInd)
    loop_ind = areaInd(ii);
    % first step, find the index with the closest polar angle +
    % eccentricity match to our current vertex
    
    % distance formula for polar coordinates is sqrt(r1^2 + r2^2 +
    % 2*r1*r2*cos(th2 - th1)), calculate for every index in im_ecc and
    % im_pol, find index with min dist
    d = sqrt(ecc(loop_ind)^2 + im_ecc.^2 - 2*ecc(loop_ind)*im_ecc.*cosd(pol(loop_ind)-im_pol));
    
    % find the index with the minimum distance. this will be the center
    % index for our gaussian
    [indx, indy] = find(d == min(d(:)));
    
    % calculate gaussian weight matrix with center at
    % [im_x(indx,indy),im_y(indx,indy)]. both sigx and sigy are equal
    % to sigma at that vertex
    numerator = (im_x-im_x(indx,indy)).^2 + (im_y-im_y(indx,indy)).^2;
    denominator = 2*sigma(loop_ind)^2;
    gauss = exp(-numerator/denominator);
    
    % divide overlapped area of gaussian by area under full gaussian
    weightedIm = im.*gauss;
    tmp(ii) = sum(weightedIm(:))/sum(gauss(:));
end

vertIm(areaInd) = tmp;
end
