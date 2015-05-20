%STEP 1:
%Solicit user input
%   a. Prompt user for complete file path
%   b. Prompt user for the first image to start the analysis
%   c. Prompt user for the file extension.

%Prompt user for complete file path
%Uncomment this later
%directory = input('Would you kindly enter a file path? ','s');
%Remove this later
%directory = 'E272K03A';

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
%files = dir(strcat(directory,'//','*',file_extension));
%unix version
files = dir('/media/rylan/Windows8_OS/Users/Rylan/193/simulated images/Image Sequence 5/*.tif');

%STEP 3:
%Create a number-of-images-by-3 matrix. For each image, this matrix
%will store the following:
%   Column 1 will be the x-coordinate of the estimated circle.
%   Column 2 will be the y-coordinate of the estimated circle.
%   Column 3 will be the radius of the estimated circle.
%   All values are initialized to NaN (Not a Number).
Circle_Estimation = nan(length(files),4);

%STEP 4:
%To find potential circles, the Circular Hough Transform requires a lower bound
%and an upper bound to limit the number of possible circles.  We initialize
%the lower bound to a high estimate and iteratively decrease the lower
%bound until we catch a good initial value.

%Since our algorithm works backwards (from end to start), we need to make sure
%that the initially chosen value is correct. To do so, we calculate the radius
% of five circles towards the end of the sequence. If the calculated
% circles' centers and radii differ substantially, we prompt the user to
% select the circle manually.
centersDark = [];
radiiDark = [];
metric = [];

image1 = rgb2gray(imread('/media/rylan/Windows8_OS/Users/Rylan/193/simulated images/Image Sequence 5/frame-0348.tif'));
image2 = rgb2gray(imread('/media/rylan/Windows8_OS/Users/Rylan/193/simulated images/Image Sequence 5/frame-0336.tif'));
image3 = rgb2gray(imread('/media/rylan/Windows8_OS/Users/Rylan/193/simulated images/Image Sequence 5/frame-0324.tif'));
image4 = rgb2gray(imread('/media/rylan/Windows8_OS/Users/Rylan/193/simulated images/Image Sequence 5/frame-0312.tif'));
image5 = rgb2gray(imread('/media/rylan/Windows8_OS/Users/Rylan/193/simulated images/Image Sequence 5/frame-0300.tif'));

images = {image1, image2, image3, image4, image5};

clear image1 image2 image3 image4 image5;

imageResults = [];

for iter = 1:5
    imageCell = images(iter);
    image = imageCell{1};
    
    finalRadiusLowerBound = 60;
    centersDark = [];
    
    while (isempty(centersDark))
        finalRadiusLowerBound = finalRadiusLowerBound - 10;

        if (finalRadiusLowerBound <= 5)
            break;
        end

        [centersDark, radiiDark, metric] = imfindcircles(image,...,
            [finalRadiusLowerBound (finalRadiusLowerBound+20)],'ObjectPolarity','dark','Sensitivity',0.95);

        if(~isempty(radiiDark))
            imageResults(iter,1:2) = centersDark(1,1:2);
        end
    end
end

clear iter

%Having estimated circles for five images, determine whether the estimated
%circles' centers substantially differ.  If yes, prompt the user to
%manually select the circle.  If not, proceed.
meanX = mean(imageResults(:,1));
meanY = mean(imageResults(:,2));

%Calculate mean squared error
mse = (sum((imageResults(:,1)-meanX).^2) + sum((imageResults(:,2)-meanY).^2))/10;

%If mean squared error is larger than five percent of the circle's center,
%request that the user manually highlight the circle.
if ((mse > 0.05 * meanX) || (mse > 0.05 * meanY))
    
    user_input = 0;
    iter = 1;
    
    while (user_input == 0)
        disp('The circle of interest is unclear.  We need you to select it for us.');
        imshow(images{iter});
        disp('If the image has a circle that you can identify, please type "1" and press Enter.');
        user_input = input('If circle is not clear to you, please type "0" and press Enter: ');
    
        iter = iter + 1;
        
    end
    
    
    
    disp('Please draw and position a circle around the droplet');
    circle = imellipse;
    
    pos = circle.getPosition;
    
    finalRadiusLowerBound = (pos(3) + pos(4))/2 - 10;
    
end


%remove this manually


%temp = zeros(length(files),1);

%Step 5:
%Iterate through each file in the directory, starting with the final image
%OR the image that the user used to manually input the radius.
count = length(files);
estimatedRadiusLowerBound = finalRadiusLowerBound;
for file = flipud(files)'
    if (count > 336)
        count = count - 1;
        continue;
    end
    %Open image
    
    %image = imread(strcat(directory,'//',file.name));
    image = rgb2gray(imread(strcat('/media/rylan/Windows8_OS/Users/Rylan/193/simulated images/Image Sequence 5/',file.name)));

    %Use imfindcircles to find potential circles for the particular image
    [centersDark, radiiDark, metric] = imfindcircles(image,...
        [estimatedRadiusLowerBound (estimatedRadiusLowerBound+20)],...
        'ObjectPolarity','dark','Sensitivity',0.95);
    %imshow(BW);
    %viscircles(centersDark(1,1:2),radiiDark(1,1),'LineStyle','-');
    
    
    %[centersDark, radiiDark, metric] = imfindcircles(image,...
    %    [estimatedRadiusLowerBound (estimatedRadiusLowerBound+20)],...
    %    'ObjectPolarity','dark','Sensitivity',0.95);
    
    Circle_Estimation(count,4) = estimatedRadiusLowerBound;
    
    %If a circle has been found, enter the values into Circle_Estimate
    %matrix and continue to the next image.
    if(~isempty(centersDark))
        Circle_Estimation(count,1:3) = [centersDark(1,1:2) radiiDark(1,1)];
        count = count - 1;
        
        estimatedRadiusLowerBound = floor(radiiDark(1,1)) - 5;
        if (estimatedRadiusLowerBound <= 0)
            estimatedRadiusLowerBound = 1;
        end
        
        continue;
    end
    
    %Otherwise, if a circle has not been found, attempt to find a circle
    %using edge detection.
    
    BW = image;
    CC = bwconncomp(BW);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [biggest,idx] = max(numPixels);
    BW(CC.PixelIdxList{idx}) = 0;
    
    [centersDark, radiiDark, metric] = imfindcircles(BW,[30 50], 'ObjectPolarity','dark','Sensitivity',0.95);

    
    %If the current image is subsequent to the first image in the sequence,
    %assume that the correct circle is the circle with center closest to
    %the previous circle's center.
    % if(count < length(files))
    %     disp(count);
    %     xhat = Circle_Estimation(count+1,1);
    %     yhat = Circle_Estimation(count+1,2);
    %     rhat = Circle_Estimation(count+1,3);
         
    %     [~, pos] = min(abs(centersDark(:,1)-xhat) + ...
    %         abs(centersDark(:,2)-yhat) + (radiiDark(:)-rhat));
         
    %     Circle_Estimation(count,:) = [centersDark(1,1:2) radiiDark(1,1)];
         
     %end
    
    count = count - 1;
end

%Step 6:
%Provde the user with a way to save results as CSV
%save_results = input('Would you like to save all the visualized images? (Y or N): ');
%if (save_results == 'Y')
%    results_file = input('Where would you like to save the radiuses to?' );
%    csvwrite(results_file,Circle_Estimation,:,3);
%end

%STEP 7:
%Provide the user with a way to visually test how well the algorithm works
%Let user_input be the image the user wants to see.  If user_input equals
%zero, exit.
user_input = input('Would you kindly enter an image to visualize? (Press 0 to Exit) ');

while(user_input ~= 0)
    imshow(strcat('/media/rylan/Windows8_OS/Users/Rylan/193/simulated images/Image Sequence 5/',files(user_input).name));
    viscircles(Circle_Estimation(user_input,1:2),Circle_Estimation(user_input,3),'LineStyle','-');
    user_input = input('Would you kindly enter an image to visualize? (Press 0 to Exit) ');
end