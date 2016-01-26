%clear the command window
clc;
%Try to load a "measured" workspace so that results will be saved incase of
%error
try
    load('measured.mat');
%If the workspace does not exit then create it.
catch
    save('measured.mat');
end
%STEP 1:
%Solicit user input
% a. Prompt user for complete file path
% b. Prompt user for the first image to start the analysis
% c. Prompt user for the file extension.
%Prompt user for complete file path
directory = input('Please enter the directory of image sequence: ','s');
%Prompt user for first image to start the measurement
first_image = input('Would you kindly enter the first image in the sequence to analyze? ');
%Prompt user for the last image to start the measurement
last_image = input('Would you kindly enter the last image in the sequence to analyze? ');
%Prompt user for the file extension. Default file extension is .tif
file_extension = '.tif';
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
if(exist('Circle_Estimation') == 0)
    Circle_Estimation = nan(length(files),3);
end
for i = first_image:last_image
    try
        disp('Please inscribe the droplet in a circle.');
        %STEP 4:
        %Open the image and draw a circle where the droplet is
        imshow(strcat(directory,'//',directory,'_',sprintf('%05d',i),file_extension));
        h = imellipse;
        wait(h);
        %Get the position from thew drawn circle
        position = getPosition(h);
        %Obtain the width
        width = position(3);
        %Obtain the height
        height = position(4);
        %Obtain the x-coodinate of the center
        centerx = position(1) + position(3)/2;
        %Obtain the y-coordinate of the center
        centery = position(2) + position(4)/2;
        %Obtain the radius by dividing width by 2
        radius = width/2;
        %Save the measurement in a matrix
        Circle_Estimation(i+1,:,:) = [centerx centery radius];
        close all;
    catch
        %Save in case of error
        save('measuted.mat');
    end
        
end
%Save when finished
save('measured.mat');