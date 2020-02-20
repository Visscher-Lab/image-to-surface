function vert = forceVert(im,im_ecc,im_pol,ecc,pol,varea,area_val)
%{
Occasionally, no vertices will be found when you want them to be when
binary is true. This function will find the single vertex nearest the
centroid of the object in the image. As of now, this assumes there is only
up to a single object per hemifield.

USE WITH CAUTION, THIS HAS NOT BEEN EXTENSIVELY TESTED
%}

%{
 1. Already know pixel location to match to based on region props, so
 determine the polar angle and eccentricity of that location.
 2. calculate distance to up to two locations for each ecc and pol
 combination given in the surfaces.
 3. Find vertex with the lowest overall distance, and return
%}

% set all vertices outside the given area to NaN
ecc(varea ~= area_val) = NaN;
pol(varea ~= area_val) = NaN;

% find the centroids of up to two regions in im
props = regionprops(im,'Centroid');

% get the centroids into a more readable format
if length(props) > 1
    centroids = [props(1).Centroid;props(2).Centroid];
else
    centroids = props(1).Centroid;
end

% for each centroid, find the distances from it to the pRF for each vertex
% in the brain
for ii = 1:size(centroids,1)
    thisecc = im_ecc(centroids(ii,2),centroids(ii,1));
    thispol = im_pol(centroids(ii,2),centroids(ii,1));
    d(:,ii) = sqrt(ecc.^2 + thisecc^2 - 2*ecc*thisecc.*cosd(pol-thispol));
end

% find the absolute minimum distance, and return that index
[vert,~] = find(d == min(min(d)));

% subtract 1 to get to vertex
vert = vert - 1;
end
