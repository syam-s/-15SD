%STEP 1:
%Solicit user input
% a. Prompt user for complete file path
% b. Prompt user for the first image to start the analysis
% c. Prompt user for the file extension.
%Prompt user for complete file path
%Uncomment this later
%directory = input('Would you kindly enter a file path? ','s');
%Remove this later
directory = 'E272K03A';
%Prompt user for first image to start the measurement
first_image = input('Would you kindly enter the first image in the sequence? ');
%Prompt user for the last image to start the measurement
last_image = input('Would you kindly enter the last image in the sequence? ');
%Prompt user for the file extension. Default file extension is .tif
file_extension = '.tif';
%Uncomment this later
%file_extension = input('Would you kindly enter a file format? ','s');
%Remove this later
%STEP 2:
%Open the directory containing all the image files
files = dir(strcat(directory,'//','*',file_extension));
%STEP 3:
%Create a number-of-images-by-3 matrix. For each image, this matrix
%will store the following:
% Column 1 will be the x-coordinate of the estimated circle.
% Column 2 will be the y-coordinate of the estimated circle.
% Column 3 will be the radius of the estimated circle.
% All values are initialized to NaN (Not a Number).
Circle_Measurement = nan(length(files),3);
%STEP 4:
%Open the image and draw a circle where the droplet is.
for i = first_image:last_image
    disp('Please inscribe the droplet in a circle.');
    imshow(strcat(directory,'//',directory,'_',sprintf('%05d',i),file_extension));
    h = imellipse;
    wait(h);
    position = getPosition(h);
    width = position(3);
    height = position(4);
    centerx = position(1) + position(3)/2;
    centery = position(2) + position(4)/2;
    radius = width/2;
    Circle_Measurement(i+1,:,:) = [centerx centery radius];
    close all;
end