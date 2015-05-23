first = input('First image to save is: ');
last = input('Last image to save is: ');
for j = first:last %last_image
    image = imread(strcat(directory,'//',files(j).name));
    [im_height, im_width, im_color] = size(image);
    imshow(strcat(directory,'//',files(j).name));
    viscircles(Circle_Estimation(j,1:2),Circle_Estimation(j,3),'LineWidth',.5);
    print(strcat(directory,'_',sprintf('%05d',j)),'-dtiff');
    close all;
end