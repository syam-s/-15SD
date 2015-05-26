%STEP 1:
%Solicit user input
%   a. Prompt user for complete file path
%   b. Prompt user for the first image to start the analysis
%   c. Prompt user for the file extension.

%Prompt user for complete file path
%Uncomment this later
%directory = input('Would you kindly enter a file path? ','s');
%Remove this later
directory = 'Image Sequence 4';

%Prompt user for first image to start the analysis
%first_image = input('Would you kindly enter the first image in the sequence? ');
first_image = 1;

%Prompt user for the file extension.  Default file extension is .tif
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
%   Column 1 will be the x-coordinate of the estimated circle.
%   Column 2 will be the y-coordinate of the estimated circle.
%   Column 3 will be the radius of the estimated circle.
%   All values are initialized to NaN (Not a Number).
Circle_Estimation = nan(length(files),3);

%STEP 4:
%To find circles faster, the algorithm takes a lower bound
%and an upper bound to limit the number of possible circles. We enlist the
%user to help us generate these boundaries.

%Show user the first image in the sequence. Prompt the user to inscribe the
%droplet in a square.  Assume that the "square" is imperfectly drawn.
%Assume further that
%   1. Upper radius bound is 1.10 of half the "square's" longest dimension
%   2. Lower radius bound is 0.85 of half the "square's" longest dimension
disp('Please inscribe the droplet in a square.');
imshow('Image Sequence 4//frame-0001.tif');
h = imellipse;
wait(h);
position_i = getPosition(h);
width_i = position_i(3);
height_i = position_i(4);
centerx_i = position_i(1) + position_i(3)/2;
centery_i = position_i(2) + position_i(4)/2;
initial_radius = width_i/2;
radius_i = initial_radius;
close all;

%Step 5:
%Iterate through every file in the directory, starting with the user
%selected image.  Use imfindcircles to calculate possible circles.  We
%assume that the most likely circle is the correct circle.
count = 0;
for file = files'
    %Skip all images before the user selected first image
    %if(count < first_image)
    %    count = count + 1;
    %    continue;
    %end
    disp(strcat('Working on ', '/ ',file.name));
    if(count < first_image)
        count = count + 1;
        continue;
    end
    
    %Open image
    I = rgb2gray(imread(strcat(directory,'//',file.name)));
    image = imread(strcat(directory,'//',file.name));
    
    [BW1, threshold1] = edge(I, 'Sobel');
    %worst, but needed for BW7
    [BW2, threshold2] = edge(I, 'Canny');
    fudgeFactor = .1;
    BW7 = edge(I,'Canny', threshold1 * fudgeFactor);
    %Use imfindcircles to find potential circles for original image
    try
        [centersDark, radiiDark, metric] = imfindcircles(image,...
            [floor(initial_radius-5) ceil(initial_radius+5)],'ObjectPolarity','dark',...
            'Sensitivity',0.99);
    catch
    end
    %Use imfindcircles to find potential circles for the binary gradient
    %image
    try
        [centersDark2, radiiDark2, metric2] = imfindcircles(BW7,...
            [floor(initial_radius-5) ceil(initial_radius+5)],'ObjectPolarity','dark',...
            'Sensitivity',0.99);
    %Can't detect circles at all
    catch
        continue;
    end
    %Find the circle ranked by imfindcircles with center and radius closes to drawn circle.
     if(count == first_image)
         xhat = centerx_i; %get the x-coord of drawn image
         yhat = centery_i; %get the y-coord of drawn image
         rhat = initial_radius; %get the radius of the drawn image
         try%try to see if you can calculate a best fit circle on original image
         [min1, pos] = min(abs(centersDark(:,1)-xhat) + ...
            abs(centersDark(:,2)-yhat) + abs(radiiDark(:)-rhat));
         catch%can't calculate a circle of best fit on the original image
             pos = 100000;
         end
         %Calculate circle of best fit of the binary gradient image
         [min2, pos2] = min(abs(centersDark2(:,1)-xhat) + ...
            abs(centersDark2(:,2)-yhat) + abs(radiiDark2(:)-rhat));
        if( pos == 100000)%Can't detect a circle in original image
            Circle_Estimation(count,:) = [centersDark2(pos2,1:2) radiiDark2(pos2,1)];
        else
        %Can detect a circle in original image. So determine whether circle 
        %of best fit is original image or binary gradient mask of oringal image
            if(min1 < min2)
                Circle_Estimation(count,:) = [centersDark(pos,1:2) radiiDark(pos,1)];
            else
                Circle_Estimation(count,:) = [centersDark2(pos2,1:2) radiiDark2(pos2,1)];
            end            
        end              
     end
    
    %If the current image is subsequent to the first image in the sequence,
    %assume that the correct circle is the circle with center closest to
    %the previous circle's center.
    if(count > first_image)
        xhat = Circle_Estimation(count-1,1);
        yhat = Circle_Estimation(count-1,2);
        rhat = Circle_Estimation(count-1,3);
        
        try
        [min1, pos] = min(abs(centersDark(:,1)-xhat) + ...
            abs(centersDark(:,2)-yhat) + abs(radiiDark(:)-rhat));
        catch
            pos = 100000;
        end
        [min2, pos2] = min(abs(centersDark2(:,1)-xhat) + ...
            abs(centersDark2(:,2)-yhat) + abs(radiiDark2(:)-rhat));
        if(pos == 100000)
            Circle_Estimation(count,:) = [centersDark2(pos2,1:2) radiiDark2(pos2,1)];
        else
            if(min1 < min2)
                try
                    Circle_Estimation(count,:) = [centersDark(pos,1:2) radiiDark(pos,1)];
                catch
                    Circle_Estimation(count,:) = [centersDark2(pos2,1:2) radiiDark2(pos2,1)];
                end
            else
                Circle_Estimation(count,:) = [centersDark2(pos2,1:2) radiiDark2(pos2,1)];
            end            
        end
    end
    
    initial_radius = Circle_Estimation(count,3);
    count = count + 1;
%     if(count >14)
%         break;
%     end
end
