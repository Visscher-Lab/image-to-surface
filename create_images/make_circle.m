% Create a logical image of a circle with specified
% diameter, center, and image size.
% First create the image.
imageSizeX = 1001;
imageSizeY = 1001;
[columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.
centerX = 500;
centerY = 500;
radius = 20;
circlePixels = (rowsInImage - centerY).^2 ...
    + (columnsInImage - centerX).^2 <= radius.^2;
% circlePixels is a 2D "logical" array.
% Now, display it.
imshow(circlePixels)