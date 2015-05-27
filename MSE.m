%Prompt user for the number for actual measured values
a_measured = input('Please enter the number for actual measured values: ');
% Calculate the pixel radius
pradius = ((double(dpixels(1:a_measured))./2));
% Prompt user for the range of the predicted measured values
i_measured = input('Please enter where the predicted measurements start: ');
f_measured = input('Please enter where the predicted measurements end: ');
% Calculate the difference between actual and predicted
difference = double(Circle_Estimation(i_measured:f_measured,3)) - pradius;
% Calculate the mean squared error
MSE1 = mean(difference.^2);