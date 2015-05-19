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
files = dir('/home/rylan/Documents/193/simulated images/Image Sequence 4/*.tif');

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
%bound until we catch a good initial value.  We do this twice, once for the
%initial image in the sequence and again for the final image in the
%sequence.

centersDark = [];
radiiDark = [];
metric = [];

%Calculate radius of first image
%image = imread('E272K03A//E272K03A_00134.tif');
image = rgb2gray(imread('/home/rylan/Documents/193/simulated images/Image Sequence 4/frame-0001.tif'));
initialRadiusLowerBound = 100;

while (isempty(centersDark))
    initialRadiusLowerBound = initialRadiusLowerBound - 10;
    
    if (initialRadiusLowerBound <= 10)
        initialRadiusLowerBound = 1;
        break;
    end
    
    [centersDark, radiiDark, metric] = imfindcircles(image,...,
        [initialRadiusLowerBound (initialRadiusLowerBound+15)],'ObjectPolarity','dark','Sensitivity',0.95);

    %if (isempty(centersDark))
    %    [centersDark, radiiDark, metric] = imfindcircles(image,...,
    %    [initialRadiusLowerBound (initialRadiusLowerBound+15)],'ObjectPolarity',...
    %    'dark','Sensitivity',0.95,'EdgeThreshold',0);
    %end

end
disp(initialRadiusLowerBound);

%Calculate radius of last image
%image = imread('E272K03A//E272K03A_01364.tif');
image = imread('/home/rylan/Documents/193/simulated images/Image Sequence 4/frame-0300.tif');
finalRadiusLowerBound = 100;
centersDark = [];
while (isempty(centersDark))
    finalRadiusLowerBound = finalRadiusLowerBound - 10;
    
    if (finalRadiusLowerBound <= 10)
        finalRadiusLowerBound = 1;
        break;
    end
    
    [centersDark, radiiDark, metric] = imfindcircles(image,...,
        [finalRadiusLowerBound (finalRadiusLowerBound+15)],'ObjectPolarity','dark','Sensitivity',0.95);
end
disp(finalRadiusLowerBound);

if (finalRadiusLowerBound == 5)
    disp('NOTE: Droplet size may be too small to detect towards the end of the image sequence');
end


temp = zeros(length(files),1);

%Step 5:
%Iterate through each file in the directory, starting with the final image.
count = length(files);
estimatedRadiusLowerBound = finalRadiusLowerBound;
for file = flipud(files)'
    %if (count > 300)
    %    count = count - 1;
    %    continue;
    %end
    %Open image
    
    %image = imread(strcat(directory,'//',file.name));
    image = rgb2gray(imread(strcat('/home/rylan/Documents/193/simulated images/Image Sequence 4/',file.name)));
     
    %Use imfindcircles to find potential circles for the particular image
    [centersDark, radiiDark, metric] = imfindcircles(image,...
        [estimatedRadiusLowerBound (estimatedRadiusLowerBound+15)],...
        'ObjectPolarity','dark','Sensitivity',0.95);
    
    Circle_Estimation(count,4) = estimatedRadiusLowerBound;
    %Describe what's happening here
    if(~isempty(centersDark))
        Circle_Estimation(count,1:3) = [centersDark(1,1:2) radiiDark(1,1)];
        count = count - 1;
        
        estimatedRadiusLowerBound = floor(radiiDark(1,1)) - 5;
        if (estimatedRadiusLowerBound <= 0)
            estimatedRadiusLowerBound = 1;
        end
        
        continue;
    end
    
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
    imshow(strcat('/home/rylan/Documents/193/simulated images/Image Sequence 4/',files(user_input).name));
    viscircles(Circle_Estimation(user_input,1:2),Circle_Estimation(user_input,3),'LineStyle','-');
    user_input = input('Would you kindly enter an image to visualize? (Press 0 to Exit) ');
end