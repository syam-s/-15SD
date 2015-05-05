close all;clear all;
%STEP 1:
%Solicit user input
% a. Prompt user for complete file path
% b. Prompt user for the first image to start the analysis
% c. Prompt user for the file extension.

%Prompt user for complete file path
%Uncomment this later
%directory = input('Would you kindly enter a file path? ','s');
%Remove this later
directory = 'E267J02A';

%Prompt user for first image to start the analysis
%first_image = input('Would you kindly enter the first image in the sequence? ');
first_image = 400;

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
Circle_Estimation = nan(length(files),3);
Circle_EstimationZoom = nan(length(files),3);

%STEP 4:
%To find circles faster, the algorithm takes a lower bound
%and an upper bound to limit the number of possible circles. We enlist the
%user to help us generate these boundaries.

%Show user the first image in the sequence. Prompt the user to inscribe the
%droplet in a square. Assume that the "square" is imperfectly drawn.
%Assume further that
% 1. Upper radius bound is 1.10 of half the "square's" longest dimension
% 2. Lower radius bound is 0.85 of half the "square's" longest dimension
disp('Please inscribe the droplet in a square.');
imshow('E267J02A//E267J02A_00400.tif');
rect = getrect;
initial_upper_radius_bound = 1.10*max([rect(3) rect(4)])/2;
initial_lower_radius_bound = 0.85*max([rect(3) rect(4)])/2;

%Show user the last image in the sequence. Prompt the user to inscribe the
%droplet in a square. Assume that the "square" is imperfectly drawn.
%Assume further that
% 1. Upper radius bound is 1.10 of half the "square's" longest dimension
% 2. Lower radius bound is 0.85 of half the "square's" longest dimension
disp('Please inscribe the droplet in a square.');
imshow('E267J02A//E267J02A_00750.tif');
rect = getrect;
imtool close all;
final_upper_radius_bound = 1.10*max([rect(3) rect(4)])/2;
final_lower_radius_bound = 0.85*max([rect(3) rect(4)])/2;

%With each subsequent image in the sequence, the radius should shrink by a
%small but not insignificant amount. We assume that the radius will
%decrease linearly between the initial bounds and the final bounds.
lower_bound_reduction_constant = ...
(final_lower_radius_bound - initial_lower_radius_bound)/length(files);
upper_bound_reduction_constant = ...
(final_upper_radius_bound - initial_upper_radius_bound)/length(files);

%Set the initial bounds to the variable bounds
lower_radius_bound = initial_lower_radius_bound;
upper_radius_bound = initial_upper_radius_bound;

%Step 5:
%Iterate through every file in the directory, starting with the user
%selected image. Use imfindcircles to calculate possible circles. We
%assume that the most likely circle is the correct circle.
count = 0;
for file = files'

%Skip all images before the user selected first image
if(count < first_image)
count = count + 1;
continue;
end

%Open image
image = imread(strcat(directory,'//',file.name));
imshow(image);

%Calculate bounds for the particular image
lower_radius_bound = lower_radius_bound + lower_bound_reduction_constant;
upper_radius_bound = upper_radius_bound + upper_bound_reduction_constant;

%Use imfindcircles to find potential circles for the particular image
[centersDark, radiiDark, metric] = imfindcircles(image,...
[floor(lower_radius_bound) ceil(upper_radius_bound)],'ObjectPolarity','dark',...
'Sensitivity',0.99,'Method','twostage','EdgeThreshold',0.1);

%If the current image is the first image in the sequence, assume that
%the correct circle is the circle ranked most likely by imfindcircles.
if(count == first_image)
Circle_Estimation(count,:) = [centersDark(1,1:2) radiiDark(1,1)];
end

%If the current image is subsequent to the first image in the sequence,
%assume that the correct circle is the circle with center closest to
%the previous circle's center.
if(count > first_image)
xhat = Circle_Estimation(count-1,1);
yhat = Circle_Estimation(count-1,2);
rhat = Circle_Estimation(count-1,3);

[~, pos] = min((centersDark(:,1)-xhat).^2 + ...
(centersDark(:,2)-yhat).^2 + (radiiDark(:)-rhat).^2);
Circle_Estimation(count,:) = [centersDark(pos,1:2) radiiDark(pos,1)];

end

% get zoomed-in image by cropping around circle
% make cropped rectangle 4x4 circle radius
croppedImage = imcrop(image,[Circle_Estimation(count,1)-2*Circle_Estimation(count,3) ...
                             Circle_Estimation(count,2)-2*Circle_Estimation(count,3) ...
                             4*Circle_Estimation(count,3)...
                             4*Circle_Estimation(count,3)]);
%figure(3);imshow(croppedImage);
% enlarge cropped image by a factor of 4
enlargedImage = imresize(croppedImage,4);
%figure(4);imshow(enlargedImage);
%Use imfindcircles to find potential circles for the enlarged image
[centersDarkZoom, radiiDarkZoom, metricZoom] = imfindcircles(enlargedImage,...
[floor(0.9*4*Circle_Estimation(count,3)) ceil(1.1*4*Circle_Estimation(count,3))],'ObjectPolarity','dark',...
'Sensitivity',0.99,'Method','twostage','EdgeThreshold',0.1);
% store new coordinate and radii for zoomed image
Circle_EstimationZoom(count,:) = [centersDarkZoom(1,1)/4+(Circle_Estimation(count,1)-2*Circle_Estimation(count,3)) ...
                                  centersDarkZoom(1,2)/4+(Circle_Estimation(count,2)-2*Circle_Estimation(count,3)) ...
                                  radiiDarkZoom(1,1)/4];

count = count + 1;
if (count> 750) % stop before circle disappears
    break;
end
end
hold=horzcat(Circle_Estimation,Circle_EstimationZoom);
save('output','hold','-ascii');
%STEP 6:
%Provide the user with a way to visually test how well the algorithm works
%Let user_input be the image the user wants to see. If user_input equals
%zero, exit.
% user_input = 10;
% 
% while(user_input ~= 0)
% user_input = input('Would you kindly enter an image to visualize? (Press 0 to Exit) ');
% imshow(strcat(directory,'//',files(user_input).name));
% viscircles(Circle_Estimation(user_input,1:2),Circle_Estimation(user_input,3),'LineStyle','-');
% end