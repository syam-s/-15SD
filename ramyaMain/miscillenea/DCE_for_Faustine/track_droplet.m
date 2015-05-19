%===============================================%
% Author:   Vincent K. Tam                      %
% Title:    Droplet Tracker                     %
% Updated:  08/31/06                            %
% Notes:    Tracks droplet area and centroid.   %
%           For use with thin fibers.           %
%===============================================% 

clear all
close all
clc
format compact
warning off

%   CREATE FILENAME ARRAYS
filename = 'IMG_0000.jpg';
outputImage = 'OUT_0000.jpg';
zero = 48;
counter = 0;
for num3 = 0:9  % Third's place
    place3 = zero+num3;
    filename(1,6) = place3;
    outputImage(1,6) = place3;
    for num2 = 0:9  % Second's place
        place2 = zero+num2;
        filename(1,7) = place2;
        outputImage(1,7) = place2;
        for num = 0:9   %First's place
            counter = counter+1;
            place1 = zero+num;
            filename(1,8) = place1;
            outputImage(1,8) = place1;
            InameArray(counter,:) = filename;
            OnameArray(counter,:) = outputImage;
        end
    end
end

%   CREATE XLS CELL ARRAY
xlsA = 'A0000';
xlsB = 'B0000';
zero = 48;
counter = 0;
for num3 = 0:9  % Third's place
    place3 = zero+num3;
    xlsA(1,3) = place3;
    xlsB(1,3) = place3;
    for num2 = 0:9  % Second's place
        place2 = zero+num2;
        xlsA(1,4) = place2;
        xlsB(1,4) = place2;
        for num = 0:9   %First's place
            counter = counter+1;
            place1 = zero+num;
            xlsA(1,5) = place1;
            xlsB(1,5) = place1;
            xlsCol_A(counter,:) = xlsA;
            xlsCol_B(counter,:) = xlsB;
        end
    end
end

%   SELECT MEDIA FORMAT:  IMAGES OR VIDEO
disp('This program tracks droplet outline and area in AVI video files and JPEG images.')
disp('Results will be saved in "results.txt" (Text File) and "results.xls" (Excel File).')
disp(' ')
disp('-----------------------')
disp('     CONFIGURATION     ')
disp('-----------------------')
disp(' ')
disp('Select one: ')
disp('(1) Analyze an AVI video file.  (Video frames will be converted into images.)')
disp('(2) Analyze images. (Images must use IMG_####.jpg convention.)')
selection = input('Enter 1 or 2: ');
disp(' ')
while ( (selection~=1) && (selection~=2) )
    disp('Select one: ')
    disp('(1) Analyze an AVI video file.')
    disp('(2) Analyze images. (Images must use IMG_####.jpg convention)')
    selection = input('Enter 1 or 2: ');
    disp(' ')
end

if (selection == 1)    
    videoName = input('INPUT AVI filename: ', 's'); % Set videoName = AVI filename w/o extension
    disp('Reading AVI file...')
    mov = aviread(videoName);
    info = aviinfo(videoName)
    NumFrames = info.NumFrames;
    disp(' ')
    disp('Saving video frames as JPEG image files...')
    disp(' ')
    for frameNum = 1:NumFrames
        [image,Map] = frame2im(mov(frameNum));
        switch info.ImageType
            case 'truecolor'
            grayImage = rgb2gray(image);   % Use if video is in color
            case 'indexed'
            grayImage = image;              % Use if video is in grayscale
        end
        ImageCurrent = InameArray(frameNum+1,:);
        imwrite(grayImage, ImageCurrent);
    end
end

%   CREATE TXT FILE FOR RESULTS DATA
delete('results.txt'); % Delete any existing results.txt file.
fid = fopen('results.txt','wt');     
if (fid < 0)
    error('could not open file "results.txt"');
end
if (selection == 1)
    fprintf(fid, 'AVI File: %s\n', videoName);
elseif (selection ==2)
    wd=cd;
    fprintf(fid, 'Images in: %s\n', wd); 
end
fprintf(fid, 'Frame; Area; Centroid X; Centroid Y\n');

%   CREATE XLS FILE FOR RESULTS DATA
delete('results.xls'); % Delete any existing results.xls file.
if (selection == 1)
    xlswrite('results',{'AVI:', videoName},'Results',xlsCol_A(2,:));
elseif (selection == 2)
    xlswrite('results',{'Images in:', wd},'Results',xlsCol_A(2,:));  
end
xlswrite('results',{'ERROR:  Program did not reach completion.  Results were not written into this XLS file.  Incomplete results can be found in "results.txt."'},'Results',xlsCol_A(3,:));
xlswrite('results',{'NOTE:  Results in "results.txt" are written in real time during analysis whereas results in this XLS file are written after all selected images have been analyzed.  This has been implemented to speed up runtime.'},'Results',xlsCol_A(4,:));

%   AUTOMATED TRACKING LOOP
home
disp('IMAGE SELETION: Select images to be analyzed.')
disp(' ')
disp('This program analyzes images in sequential order.')
disp('Open the current folder in Windows Explorer to preview the images ') 
disp('and decide the first and last image to analyze.')
disp(' ')
start = input('INPUT number of first image file (IMG_####.jpg): ');
last = input('INPUT number of last image file  (IMG_####.jpg): ');
disp(' ')

%   DEFINE ROTATION ANGLE
filenameCurrent = InameArray(start+1,:);
home
disp('IMAGE ROTATION: Rotate the image to orient the fiber horizontally.')
disp(' ')
disp('You will now preview the first image to select a rotation angle.')
disp(' ')
disp('Press ENTER when ready to proceed.')
disp(' ')
pause
imshow(filenameCurrent)
rotationAngle = input('Input desired rotation angle in degrees to orient fiber horizontally: ');
close
previewNormal = imread(filenameCurrent);
previewRot = imrotate(previewNormal, rotationAngle);
imshow(previewRot)
rotateOK = input('Accept rotation angle? [y/n]: ', 's');
disp(' ')
while (strcmp(rotateOK,'y') ~= 1)
    rotationAngle = input('Input desired rotation angle in degrees to orient fiber horizontally: ');
    close
    previewNormal = imread(filenameCurrent);
    previewRot = imrotate(previewNormal, rotationAngle);
    imshow(previewRot)
    rotateOK = input('Accept rotation angle? [y/n]: ', 's');
    disp(' ')
end

%   DEFINE REGION OF INTEREST (ROI)
home
disp('REGION OF INTEREST: Select a rectangular Region of Interest.')
disp(' ')        
disp('You will now preview the first image to select a Region of Interest.')
disp('You will use the mouse to click and drag a rectangle around the Region of Interest.')
disp('Note:  Select a Region of Interest that includes the droplet AND a short length')
disp('       of the fiber protruding from each side.  The protruding fiber will allow this')
disp('       program to differentiate the fiber from the droplet.')
disp('       *Do not include other objects such as igniters in the Region of Interest.*')
disp(' ')
disp('Press ENTER when ready to proceed.')
pause
figure(1)
rect = getrect(1);
rect = round(rect);
start_row = rect(1,2);
end_row = rect(1,2)+rect(1,4);
start_col = rect(1,1);
end_col = rect(1,1)+rect(1,3);
previewRotCrop = previewRot(start_row:end_row,start_col:end_col,:);
imshow(previewRotCrop)
disp(' ')
disp('Preview Region of Interest...')
figure(1)
ROIok = input('Accept Region of Interest? [y/n]: ', 's');
disp(' ')

while (strcmp(ROIok,'y') ~= 1)
    close
    imshow(previewRot)
    home
    disp('REGION OF INTEREST: Select another rectangular Region of Interest.')
    disp(' ')        
    disp('Preview the first image to select a Region of Interest.')
    disp('Use the mouse to click and drag a rectangle around the Region of Interest.')
    disp('Note:  Select a Region of Interest that includes the droplet AND a short length')
    disp('       of the fiber protruding from each side.  The protruding fiber will allow this')
    disp('       program to differentiate the fiber from the droplet.')
    disp('       *Do not include other objects such as igniters in the Region of Interest.*')
    disp(' ')
    figure(1)
    rect = getrect(1);
    start_row = rect(1,2);
    end_row = rect(1,2)+rect(1,4);
    start_col = rect(1,1);
    end_col = rect(1,1)+rect(1,3);
    previewRotCrop = previewRot(start_row:end_row,start_col:end_col,:);
    imshow(previewRotCrop)
    disp(' ')
    disp('Preview Region of Interest...')
    figure(1)
    ROIok = input('Accept Region of Interest? [y/n]: ', 's');
    disp(' ')
end
close
imshow(previewRotCrop)
home
backlit = input('Is the droplet darker than the background (i.e., back-lit)?  [y/n]:  ', 's');
disp(' ')
close all
home
disp('--------------------------------------------------------------------------------------------------')
disp('                          Configuration complete.  Press ENTER to begin.                          ')
disp('     Results will be saved in Text File "results.txt" and in EXCEL Spreadsheet "results.xls".     ')
disp('--------------------------------------------------------------------------------------------------')
disp(' ')
pause
tic

    errorCount=0;

for Image = start:last
    try     %   Error catcher
        
    %___________________TRACE DROPLET CODE START_____________________
    clf
    % LOAD IMAGE
    filenameCurrent = InameArray(Image+1,:);
    I = imread(filenameCurrent);
  
    % ROTATION FOR HOIZONTAL FIBER ORIENTATION
    IRot = imrotate(I,rotationAngle);
    
    % CROP ROI
    
    if Image>(start+1)
        delta_Cx = resultsMatrix(3,Image)-resultsMatrix(3,Image-1);
        delta_Cy = resultsMatrix(4,Image)-resultsMatrix(4,Image-1);
        start_col = round(start_col + delta_Cx);
        end_col = round(end_col + delta_Cx);
        start_row = round(start_row - delta_Cy);
        end_row = round(end_row - delta_Cy);
    end
 
    IRotCrop = IRot(start_row:end_row,start_col:end_col,:);

    % THRESHOLD AND GENERATE BINARY
    threshMod = 0; % Enter adjustment to auto-threshold (%), such as "-5" for darker, "5" for lighter.
    threshImage = IRotCrop;
    threshold = graythresh(threshImage)*(1+threshMod/100);
    BW = im2bw(IRotCrop,threshold);
    if strcmp(backlit,'y') == 1
        BW = ~BW;      % Use for dark droplet over light background
    end
    BW = imfill(BW,'holes');
    figure(1), subplot(2,2,1), imshow(BW), title('Binary')

    % CALCULATE PROPERTIES
    [labeled, numObjects] = bwlabel(BW,8);
    data = regionprops(labeled, 'basic');
    maxArea = max([data.Area]);
    droplet = find([data.Area]==maxArea);
    diameter = sqrt(4*maxArea/pi);
    resultsMatrix(1,Image+1) = Image;           % Frame (1,:)
    resultsMatrix(2,Image+1) = maxArea;         % Area (2,:)
    
    % TRACE DROPLET BOUNDARY
    %  Locate a point on the droplet boundary to initiate trace
    dim = size(BW);
    centroid = data(droplet).Centroid;
    col = round(centroid(1,1));
    row = min(find(BW(:,col)));
    boundary = bwtraceboundary(BW,[row,col],'N');
    %  Plot the boundary onto original image
    subplot(2,2,2), imshow(IRotCrop)
    frame_text = int2str(Image);
    frame_title = ['Frame: ' frame_text];
    title(frame_title)

    hold on
    plot(boundary(:,2),boundary(:,1),'g','LineWidth',1)
    %  Pixel-to-cartesian transformation
    clear CartBoundROI CartBound   
    CartBoundROI(:,1) = boundary(:,2);
    CartBoundROI(:,2) = dim(1) - boundary(:,1);
    minCartBound1 = min(CartBoundROI(:,1));
    minCartBound2 = min(CartBoundROI(:,2));
    CartBound(:,1) = CartBoundROI(:,1) - minCartBound1;
    CartBound(:,2) = CartBoundROI(:,2) - minCartBound2;
      
    % LOCATE FIBER
    %  Find the widest row
    for roww = 1:dim(1)
        rowPixels(roww) = length(find(BW(roww,:)));
    end
    [R,widestRows] = find(rowPixels==max(rowPixels));
    %  Choose middle row (in case of multiple widest rows)
    multiWidestRows = size(widestRows);
    widestRowAvg = round(multiWidestRows(1,2)/2);
    widestRow = widestRows(widestRowAvg);
    %  Plot fiber line onto grayscale image
    subplot(2,2,2), plot(1:dim(2), widestRow,'r'), hold off
    
    %  CENTROID
    Centroid = round([data(droplet).Centroid]);
    subplot(2,2,2), hold on,
    plot(Centroid(1,1),Centroid(1,2),'b.')
    hold off
    CentroidCartX_ROI = Centroid(1,1);
    CentroidCartY_ROI = dim(1)-Centroid(1,2);
       
    %  Calculate Droplet and Centroid Coordinates and Plot
    IRotSize = size(IRot);
    CentroidCartX = Centroid(1,1)+start_col;
    CentroidCartY = IRotSize(1,1)-(Centroid(1,2)+start_row);
    CartBoundX = boundary(:,2)+start_col;
    CartBoundY = IRotSize(1,1)-(boundary(:,1)+start_row);
    subplot(2,2,3), hold on
    plot(CartBoundX, CartBoundY, 'g','LineWidth',1)
    axis image
    D_text = int2str(diameter);
    D_title = ['D = ' D_text ' pixels'];
    title(D_title)
    plot(CentroidCartX,CentroidCartY,'b.')
    plot(0: IRotSize(1,2), IRotSize(1,1)-(widestRow+start_row), 'r'), hold off
    hold off

    resultsMatrix(3,Image+1) = CentroidCartX;   % Centroid Column(3,:)
    resultsMatrix(4,Image+1) = CentroidCartY;   % Centroid Row (4,:)
    
    % PLOT DROPLET PROPERTIES    
    subplot(2,2,4), hold on, plot(resultsMatrix(1,start+1:Image+1), resultsMatrix(2,start+1:Image+1), 'b.') % Plot point
    subplot(2,2,4), plot(resultsMatrix(1,start+1:Image+1), resultsMatrix(2,start+1:Image+1)) % Plot line        
    axis normal
    title('Area (Pixels) vs. Frames')
    
    %___________________TRACE DROPLET CODE END_______________________

    % SAVE RESULTS FIGURE AS A JPEG FILE
    outputImageCurrent = OnameArray(Image+1,:);
    saveas(1,outputImageCurrent);
    
    % WRITE RESULTS TO TXT FILE
        fprintf(fid,'%d; %d; %d; %d; %d\n',resultsMatrix(1,Image+1),resultsMatrix(2,Image+1),resultsMatrix(3,Image+1),resultsMatrix(4,Image+1),resultsMatrix(5,Image+1));
    
    %   ERROR CATCHER
    catch
        errorCount=errorCount+1;
        if errorCount==1
            home
            disp('An error occured while analyzing the following image files: ')
        end
        disp(filenameCurrent)

        %   Store results in a matrix
        resultsMatrix(1,Image+1) = Image;       % Frame (1,:)
        resultsMatrix(2,Image+1) = 0;           % Area (2,:)
        resultsMatrix(3,Image+1) = resultsMatrix(3,Image);           % Centroid Column(3,:)
        resultsMatrix(4,Image+1) = resultsMatrix(4,Image);           % Centroid Row (4,:)
             
        % PLOT DROPLET PROPERTIES    
        subplot(2,2,4), hold on, plot(resultsMatrix(1,start+1:Image+1), resultsMatrix(2,start+1:Image+1), 'b.') % Plot point
        subplot(2,2,4), plot(resultsMatrix(1,start+1:Image+1), resultsMatrix(2,start+1:Image+1)) % Plot line        
        axis normal
        title('Area (Pixels) vs. Frames')

        % SAVE RESULTS FIGURE AS A JPEG FILE
        outputImageCurrent = OnameArray(Image+1,:);
        saveas(1,outputImageCurrent);

        % WRITE RESULTS TO TXT FILE
        fprintf(fid,'%d; %d; %d; %d; %d\n',resultsMatrix(1,Image+1),resultsMatrix(2,Image+1),resultsMatrix(3,Image+1),resultsMatrix(4,Image+1),resultsMatrix(5,Image+1));
        
    end
end
        if errorCount>0
            fprintf('\n Unable to analyze %d frame(s). \n',errorCount)
            disp('   - Sudden changes in light levels during ignition can cause tracking errors.')
            disp('   - Objects overlapping with the droplet (e.g., igniters) can cause edge detection errors.')
            disp('   - Try adjusting the Region of Interest for better results.')
        end

%   CLOSE RESULTS TXT FILE
fclose(fid);
disp(' ')
    
%   WRITE RESULTS TO XLS FILE
disp('---------------------------------------------------------------------------------------')
disp('     Results saved to Text File "results.txt" and EXCEL Spreadsheet "results.xls".     ')
disp('---------------------------------------------------------------------------------------')
disp(' ')
xlswrite('results',{'Frame', 'Area', 'Centroid X', 'Centroid Y'},'Results',xlsCol_A(3,:));
resultsXLS = resultsMatrix';
resultsXLS = resultsXLS(start+1:last+1,:);
xlswrite('results',resultsXLS,'Results',xlsCol_A(4,:));

%   ELAPSED TIME
toc
disp(' ')

%   END PROGRAM
