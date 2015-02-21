%Run after running identify_circle
%Gives the user the ability to select an image and visualize the
%circle-of-best-fit for that image.

user_input = input('Would you kindly enter an image to visualize? (Press 0 to Exit) ');

while(user_input ~= 0)
    imshow(strcat(directory,'//',files(user_input).name));
    viscircles(Circle_Estimation(user_input,1:2),Circle_Estimation(user_input,3),'LineStyle','-');
    user_input = input('Would you kindly enter an image to visualize? (Press 0 to Exit) ');
end

close figure 1