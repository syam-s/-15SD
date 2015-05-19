%solicit whether the user is a client or developer
while(1)
    user = input('Are you a user or a developer? Enter 1 for developer or 0 for user: ');
    if(user == 1)
        directory = 'E272K03A';
        first_image = 134;
        file_extension = '.tif';
        break;
    elseif (user == 0)
        %STEP 1:
        %Solicit user input
        %   a. Prompt user for complete file path
        %   b. Prompt user for the first image to start the analysis
        %   c. Prompt user for the file extension.

        %Prompt user for complete file path
        directory = input('Would you kindly enter a file path? ','s');

        %Prompt user for first image to start the analysis
        first_image = input('Would you kindly enter the first image in the sequence? ');

        %Prompt user for the file extension.  Default file extension is .tif
        file_extension = input('Would you kindly enter a file format? ','s');
        break;
    else
        continue;
    end
end

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
imshow('E272K03A//E272K03A_00134.tif');
rect = getrect;
initial_upper_radius_bound = 1.10*max([rect(3) rect(4)])/2;
initial_lower_radius_bound = 0.85*max([rect(3) rect(4)])/2;

%Show user the last image in the sequence. Prompt the user to inscribe the
%droplet in a square.  Assume that the "square" is imperfectly drawn.
%Assume further that
%   1. Upper radius bound is 1.10 of half the "square's" longest dimension
%   2. Lower radius bound is 0.85 of half the "square's" longest dimension
disp('Please inscribe the droplet in a square.');
imshow('E272K03A//E272K03A_01364.tif');
rect = getrect;
close figure 1
final_upper_radius_bound = 1.10*max([rect(3) rect(4)])/2;
final_lower_radius_bound = 0.85*max([rect(3) rect(4)])/2;

%With each subsequent image in the sequence, the radius should shrink by a
%small but not insignificant amount.  We assume that the radius will
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
%selected image.  Use imfindcircles to calculate possible circles.  We
%assume that the most likely circle is the correct circle.
count = 0;
for file = files'
    %initialize sensitivity value
    sensitivity_threshold = 0.01;
    %initialize edge value
    edge_threshold = 0.99;
    %Skip all images before the user selected first image
    if(count < first_image)
        count = count + 1;
        continue;
    end
    %filename being worked on
    disp(strcat('File being worked on is ', ' ', file.name));
    
    %Open image
    image = imread(strcat(directory,'//',file.name));
    
    %Calculate bounds for the particular image
    lower_radius_bound = lower_radius_bound + lower_bound_reduction_constant;
    upper_radius_bound = upper_radius_bound + upper_bound_reduction_constant;
    
    %Use imfindcircles to find potential circles for the particular image
    while(1)
        try 
            %try to find circle with high sensitivity and edge thresholds
            %high sensitivity = more circles detected
            %low edge threshold = more circles detected
            [centersDark, radiiDark, metric] = imfindcircles(image,...
                [floor(lower_radius_bound) ceil(upper_radius_bound)],'ObjectPolarity','dark',...
                'Sensitivity',sensitivity_threshold,'Method','twostage','EdgeThreshold',edge_threshold);
            %if it can't find a circle
            if(isempty(centersDark))
                %try increasing sensitivity to detect more circles
                sensitivity_threshold = sensitivity_threshold + 0.05;
                if (sensitivity_threshold > 0.99)
                    sensitivity_threshold = 0.99;        
                end
                %try finding circle with adjusted sensitivity value
                [centersDark, radiiDark, metric] = imfindcircles(image,...
                    [floor(lower_radius_bound) ceil(upper_radius_bound)],'ObjectPolarity','dark',...
                    'Sensitivity',sensitivity_threshold,'Method','twostage','EdgeThreshold',0.2);
                %still can't find circle with decreased sensitivity
                if(isempty(centersDark))
                    %try just decreasing edge threshold only
                    sensitivity_threshold = sensitivity_threshold - 0.05;
                    edge_threshold = edge_threshold - 0.05;
                    if (edge_threshold < 0)
                        edge_threshold = .05;
                    end
                    % try finding a circle again with adjusted edge
                    % threshold
                    [centersDark, radiiDark, metric] = imfindcircles(image,...
                        [floor(lower_radius_bound) ceil(upper_radius_bound)],'ObjectPolarity','dark',...
                        'Sensitivity',sensitivity_threshold,'Method','twostage','EdgeThreshold',0.2);
                    if(isempty(centersDark))
                        sensitivity_threshold = sensitivity_threshold + 0.05;
                    end
                    %try again with both values modified
                    continue;
                end
            end
            break;
        catch
            sensitivity_threshold = sensitivity_threshold + 0.05;
            if (sensitivity_threshold > 0.99)
                sensitivity_threshold = 0.99;        
            end
            continue;
        end
    end

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
        
        [~, pos] = min(abs(centersDark(:,1)-xhat) + ...
            abs(centersDark(:,2)-yhat) + (radiiDark(:)-rhat));
        Circle_Estimation(count,:) = [centersDark(pos,1:2) radiiDark(pos,1)];
        
    end
    
    count = count + 1;
end

%STEP 6:
%Provide the user with a way to visually test how well the algorithm works
%Let user_input be the image the user wants to see.  If user_input equals
%zero, exit.
user_input = input('Would you kindly enter an image to visualize? (Press 0 to Exit) ');

while(user_input ~= 0)
    imshow(strcat(directory,'//',files(user_input).name));
    viscircles(Circle_Estimation(user_input,1:2),Circle_Estimation(user_input,3),'LineStyle','-');
    user_input = input('Would you kindly enter an image to visualize? (Press 0 to Exit) ');
end

close all

%Provide the user with a way to save all visualized images
save_all = input('Would you like to save all the visualized images? (Y or N): ');
if (save_all == 'Y')
    for j = first_image:last_image
        image = imread(strcat(directory,'//',files(j).name));
        [im_height, im_width, im_color] = size(image);
        imshow(strcat(directory,'//',files(j).name));
        viscircles(Circle_Estimation(j,1:2),Circle_Estimation(j,3),'LineStyle','-');
        print(strcat(directory,'_',sprintf('%05d',j)),'-dtiff');
        close all;
    end 
end

%Provde the user with a way to save results as CSV
save_results = input('Would you like to save all the visualized images? (Y or N): ');
if (save_results == 'Y')
    results_file = input('Where would you like to save the radiuses to?' )
    csvwrite(results_file,Circle_Estimation,:,3);
end
    