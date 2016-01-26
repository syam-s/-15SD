% Prompt the user for the total images in the sequence
total_images = input('Please input the total number of images: ');
% Creates a total images by 5 matrix to save results.
results = zeros(total_images,5);
% Store the Sequence number in the first column
results(:,1) = 1:total_images;
% Store the radiuses in pixels in the second column
results(:,2) = Circle_Estimation(:,3);
% Store the dimater in pixels in the third column
results(:,3) = Circle_Estimation(:,3).*2;
% Store the radius in millimeters in the fourth column
results(:,4) = Circle_Estimation(:,3) .*(30.25/1024);
% Store the diameter in millimeters in the fifth column
results(:,5) = results(:,4).*2;
% Prompt the user for the filename to save as the CSV
prompt = 'Where would you like to save the results to? Please input a filename: ';
str = input(prompt, 's');
str = strcat(str,'.csv');
% Write the results to the CSV file
csvwrite(str,results);
% Tell the user that it was successful
disp('The results have been saved. The results are shown in this format: Frame number, Radius in pixels, Diameter in pixels, Radius in mm, Diameter in mm');