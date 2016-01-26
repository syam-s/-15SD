% Prompt user for the first image
first = input('First image to save is: ');
% Prompt user for the last image
last = input('Last image to save is: ');
for j = first:last %last_image
    % Show the user
    imshow(strcat(directory,'//',files(j).name));
    % Show the predicted circle
    viscircles(Circle_Estimation(j,1:2),Circle_Estimation(j,3),'LineWidth',.5);
    % Save the predicted circle as an image
    print(strcat(directory,'_',sprintf('%05d',j)),'-dtiff');
    % Close the shown image
    close all;
end