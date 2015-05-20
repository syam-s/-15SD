%===============================================%
% Author:   Vincent K. Tam                      %
% Title:    Flame Tracker                       %
% Updated:  08/31/06                            %
% Notes:    Outputs flame diameter.             %
%           Tracks the points of max intensity  %
%           on the fiber caused by the flame    %
%===============================================% 

clear all
close all
clc
format compact
warning off

%   CREATE FILENAME ARRAY
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

%   CONVERT VIDEO FRAMES INTO IMAGE FILES
disp('This program tracks the flame diameter in AVI video files and JPEG images.')
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
fprintf(fid, 'Frame; Dpxl; xc; yc\n');

%   CREATE XLS FILE FOR RESULTS DATA
delete('results.xls'); % Delete any existing results.xls file.
if (selection == 1)
    xlswrite('results',{'AVI:', videoName},'Results',xlsCol_A(2,:));
elseif (selection == 2)
    xlswrite('results',{'Images in:', wd},'Results',xlsCol_A(2,:));  
end
xlswrite('results',{'ERROR:  Program did not reach completion.  Results were not written into this XLS file.  Incomplete results can be found in "results.txt."'},'Results',xlsCol_A(3,:));
xlswrite('results',{'NOTE:  Results in "results.txt" are written in real time during analysis whereas results in this XLS file are written after all selected images have been analyzed.  This has been implemented to speed up runtime.'},'Results',xlsCol_A(4,:));

%   CONFIGURATION
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
figure(1), imshow(filenameCurrent)
rotationAngle = input('Input desired rotation angle in degrees to orient fiber horizontally: ');
close
previewNormal = imread(filenameCurrent);
previewRot = imrotate(previewNormal, rotationAngle);
figure(1), imshow(previewRot)
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
disp('Note:  Select a Region of Interest that includes the glowing portion of the fiber.')
disp(' ')
disp('Press ENTER when ready to proceed.')
pause
figure(1), imshow(previewRot)
rect = getrect(1);
rect = round(rect);
start_row = rect(1,2);
end_row = rect(1,2)+rect(1,4);
start_col = rect(1,1);
end_col = rect(1,1)+rect(1,3);
previewRotCrop = previewRot(start_row:end_row,start_col:end_col,:);
figure(1), imshow(previewRotCrop)
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
    disp('Note:  Select a Region of Interest that includes the glowing portion of the fiber.')      
    disp(' ')
    figure(1), imshow(previewRot)
    rect = getrect(1);
    rect = round(rect);
    start_row = rect(1,2);
    end_row = rect(1,2)+rect(1,4);
    start_col = rect(1,1);
    end_col = rect(1,1)+rect(1,3);
    previewRotCrop = previewRot(start_row:end_row,start_col:end_col,:);
    figure(1), imshow(previewRotCrop)
    disp(' ')
    disp('Preview Region of Interest...')
    figure(1)
    ROIok = input('Accept Region of Interest? [y/n]: ', 's');
    disp(' ')
end
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
    Dthick = 0;

for Image = start:last
    try     %   Error catcher
        
    %___________________TRACE DROPLET CODE START_____________________

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
    % REMAP IMAGE INTENSITY
    I_adjusted = IRotCrop;
    Igray = rgb2gray(IRotCrop);
    BrightestPxl = max(Igray);  % Find the max intensity value in each column
    figure(1)
    clf(1)
    figure(1)
    subplot(3,1,1), plot(BrightestPxl,'c'), axis tight, title('Brightest Pixel')
    hold on, plot(BrightestPxl)
    frame_text = int2str(Image);
    frame_title = ['Frame: ' frame_text];
    subplot(3,1,2), imshow(IRotCrop), title(frame_title), hold on
    midpt = round((length(BrightestPxl))/2);    % Find horizontal midpoint
    
    %  LEFT SIDE
    maxLeftValue = max(BrightestPxl(1:midpt));  % Find max intensity value on left side
    maxLeft = find(BrightestPxl(1:midpt)==maxLeftValue);    % Find location of max intensity value on left side
    for num0 = 1:length(maxLeft)    % Find coordinates of all max intensity points on left side
        maxIntColsLeft = 0;
        maxIntColsLeft(num0,1) = maxLeft(num0);
        BrightRowsLeft = find(Igray(:,maxIntColsLeft(num0,1))==maxLeftValue);
        maxIntRowsLeft = 0;
        maxIntRowsLeft(num0,1:length(BrightRowsLeft)) = BrightRowsLeft;
        subplot(3,1,2), plot(maxIntColsLeft(num0,1),maxIntRowsLeft(num0,1:length(BrightRowsLeft)),'b.') % Plot max intensity points on image
    end
    maxLeftFirst = find(BrightestPxl(1:midpt)==maxLeftValue, 1, 'first');   % For multiple max intensity locations, find the first.
    maxLeftLast = find(BrightestPxl(1:midpt)==maxLeftValue, 1, 'last');     % For multiple max intensity locations, find the last.
    maxLeft = round(mean(maxLeft));  % Choose the average of multiple points.
    
    %  RIGHT SIDE
    maxRightValue = max(BrightestPxl((midpt+1):length(BrightestPxl)));
    maxRight = find(BrightestPxl((midpt+1):length(BrightestPxl))==maxRightValue);
    for num0 = 1:length(maxRight)    % Find coordinates of all max intensity points on right side
        maxIntColsRight = 0;
        maxIntColsRight(num0,1) = midpt+maxRight(num0);
        BrightRowsRight = find(Igray(:,maxIntColsRight(num0,1))==maxRightValue);
        maxIntRowsRight = 0;
        maxIntRowsRight(num0,1:length(BrightRowsRight)) = BrightRowsRight;
        subplot(3,1,2), plot(maxIntColsRight(num0,1),maxIntRowsRight(num0,1:length(BrightRowsRight)),'b.') % Plot max intensity points on image
    end
    maxRightFirst = midpt+find(BrightestPxl((midpt+1):length(BrightestPxl))==maxRightValue, 1, 'first');
    maxRightLast = midpt+find(BrightestPxl((midpt+1):length(BrightestPxl))==maxRightValue, 1, 'last');
    maxRight = round(mean(maxRight));
    maxRight = maxRight+midpt;
    
    % Plots
    height = size(Igray);
    subplot(3,1,1), hold on,
    plot(maxLeftFirst,1:maxLeftValue,'b'), plot(maxRightFirst,1:maxRightValue,'b')
    plot(maxLeftLast,1:maxLeftValue,'b'), plot(maxRightLast,1:maxRightValue,'b')
    plot(maxLeft,1:maxLeftValue,'g'), plot(maxRight,1:maxRightValue,'g')
    subplot(3,1,2), hold on,
    Dpxl = maxRight-maxLeft;
    % Find average row on left side
    [Rl,Cl] = find(maxIntRowsLeft~=0);
    RowsLeft = 0;
    for num01 = 1:length(Rl)
    RowsLeft(num01) = maxIntRowsLeft(Rl(num01),Cl(num01));
    end
    avgRowLeft = round(mean(RowsLeft));
    % Find average row on right side
    [Rr,Cr] = find(maxIntRowsRight~=0);
    RowsRight = 0;
    for num02 = 1:length(Rr)
    RowsRight(num02) = maxIntRowsRight(Rr(num02),Cr(num02));
    end
    avgRowRight = round(mean(RowsRight));

    % CENTER
    avgRow = (avgRowLeft+avgRowRight)/2;
    centerCol = (maxLeft+maxRight)/2;
    subplot(3,1,2), hold on, plot(centerCol,avgRow,'r.')    
    circlePts = 256;
    t = (0:N)*2*pi/circlePts;
    plot( (Dpxl/2)*cos(t)+centerCol, (Dpxl/2)*sin(t)+avgRow, 'g');

    dim = size(IRotCrop);
    plot(1:dim(2), avgRow,'r')
    xc_CartROI = centerCol;
    yc_CartROI = dim(1)-avgRow;
    IRotSize = size(IRot);
    xc_cart = centerCol+start_col;
    yc_cart = IRotSize(1,1)-(avgRow+start_row);

    % STORE RESULTS IN MATRIX
        resultsMatrix(1,Image+1) = Image;      % Frame (1,:)
        resultsMatrix(2,Image+1) = round(Dpxl);        % Diameter (2,:)
        resultsMatrix(3,Image+1) = round(xc_cart);         % xc (3,:)
        resultsMatrix(4,Image+1) = round(yc_cart);         % yc (4,:)    
    % Graph diameter results
    figure(1)
    subplot(3,1,3)
    hold on, plot(resultsMatrix(1,start+1:Image+1), resultsMatrix(2,start+1:Image+1), 'g.') % Plot point
    plot(resultsMatrix(1,start+1:Image+1), resultsMatrix(2,start+1:Image+1),'g') % Plot line
    axis normal
    title('Diameter (Pixels) vs. Frames')

    
    %___________________TRACE DROPLET CODE END_______________________

    % SAVE RESULTS FIGURE AS A JPEG FILE
    outputImageCurrent = OnameArray(Image+1,:);
    saveas(1,outputImageCurrent);
    
    % WRITE RESULTS TO TXT FILE
    fprintf(fid,'%d; %d; %d; %d\n',resultsMatrix(1,Image+1),resultsMatrix(2,Image+1),resultsMatrix(3,Image+1),resultsMatrix(4,Image+1));
    
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
        resultsMatrix(2,Image+1) = 0;           % Diameter (2,:)
        resultsMatrix(3,Image+1) = resultsMatrix(3,Image);  % Flame Center X (3,:)
        resultsMatrix(4,Image+1) = resultsMatrix(4,Image);  % Flame Center Y (4,:) 

        % SAVE RESULTS FIGURE AS A JPEG FILE
        outputImageCurrent = OnameArray(Image+1,:);
        saveas(1,outputImageCurrent);

        % WRITE RESULTS TO TXT FILE
        fprintf(fid,'%d; %d; %d; %d\n',resultsMatrix(1,Image+1),resultsMatrix(2,Image+1),resultsMatrix(3,Image+1),resultsMatrix(4,Image+1));
        
    end

end
        if errorCount>0
            fprintf('\n Unable to analyze %d frame(s). \n',errorCount)
        end

%   CLOSE RESULTS TXT FILE
fclose(fid);
disp(' ')
    
%   WRITE RESULTS TO XLS FILE
disp('---------------------------------------------------------------------------------------')
disp('     Results saved to Text File "results.txt" and EXCEL Spreadsheet "results.xls".     ')
disp('---------------------------------------------------------------------------------------')
disp(' ')
xlswrite('results',{'Frame', 'Dpxl', 'xc', 'yc'},'Results',xlsCol_A(3,:));
resultsXLS = resultsMatrix';
resultsXLS = resultsXLS(start+1:last+1,:);
xlswrite('results',resultsXLS,'Results',xlsCol_A(4,:));

%   ELAPSED TIME
toc
disp(' ')

%   END PROGRAM
