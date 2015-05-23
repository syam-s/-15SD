results = zeros(347,2);
results(:,1) = 1:347;
results(:,2) = Circle_Estimation(:,3).*2;
prompt = 'Where would you like to save the diameters to? Please input a filename';
str = input(prompt, 's');
str = strcat(str,'.csv');
csvwrite(str,results);
clear;