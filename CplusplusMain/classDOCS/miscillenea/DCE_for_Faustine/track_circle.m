%===============================================%
% Author:   Vincent K. Tam                      %
% Title:    Circle     Tracker                  %
% Updated:  08/31/06                            %
% Notes:    Allow tracking of circular object   %
%           such as soot shells.                %
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
disp('This program tracks droplet outline and area in AVI video files and JPEG images.')
disp('This program is for use with DCE where the fiber must be accounted for.')
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
fprintf(fid, 'Frame; D; xc; yc\n');

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
disp('Note:  Select a Region of Interest that includes the droplet AND a short length')
disp('       of the fiber protruding from each side.  The protruding fiber will allow this')
disp('       program to differentiate the fiber from the droplet.')
disp('       *Do not include other objects such as igniters in the Region of Interest.*')
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
    disp('Note:  Select a Region of Interest that includes the droplet AND a short length')
    disp('       of the fiber protruding from each side.  The protruding fiber will allow this')
    disp('       program to differentiate the fiber from the droplet.')
    disp('       *Do not include other objects such as igniters in the Region of Interest.*')
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
    dim = size(IRotCrop);
    
    % REMAP IMAGE INTENSITY
    I_adjusted = IRotCrop;
    
    % LOCATE FLAME
    figure(1)
    imshow(I_adjusted)
    frame_text = int2str(Image);
    frame_title = ['Frame: ' frame_text];
    title(frame_title)
    [x,y] = (getpts(1));

    % -----Bucher Izhak Circle Fit Method---------------
    n=length(x); xx=x.*x; yy=y.*y; xy=x.*y;
    A=[sum(x) sum(y) n;sum(xy) sum(yy) sum(y);sum(xx) sum(xy) sum(x)];
    B=[-sum(xx+yy) ; -sum(xx.*y+yy.*y) ; -sum(xx.*x+xy.*y)];
    a=A\B;
    xc = -.5*a(1);
    yc = -.5*a(2);
    R = sqrt((a(1)^2+a(2)^2)/4-a(3));
    % --------------------------------------------------
  
    % PLOT CIRCLE AND CHOSEN POINTS
    figure(1)
    hold on,
    N=256;
    t=(0:N)*2*pi/N;
    plot( R*cos(t)+xc, R*sin(t)+yc, 'g');
    plot(x,y,'r.' )     % Chosen points
    plot(xc,yc, 'b.')   % Center
    
    % CENTER
    xc_CartROI = xc;
    yc_CartROI = dim(1)-yc;
    IRotSize = size(IRot);
    xc_cart = xc+start_col;
    yc_cart = IRotSize(1,1)-(yc+start_row);
    
    % STORE RESULTS IN MATRIX
    resultsMatrix(1,Image+1) = Image;      % Frame (1,:)
    resultsMatrix(2,Image+1) = round(2*R);        % Diameter (2,:)
    resultsMatrix(3,Image+1) = round(xc_cart);         % xc (3,:)
    resultsMatrix(4,Image+1) = round(yc_cart);         % yc (4,:)    
    
    if R==0
        resultsMatrix(3,Image+1) = resultsMatrix(3,Image);    
        resultsMatrix(4,Image+1) = resultsMatrix(4,Image);   
    end
      
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
        resultsMatrix(3,Image+1) = resultsMatrix(3,Image);     % xc (3,:)     
        resultsMatrix(4,Image+1) = resultsMatrix(4,Image);     % yc (4,:)

        % SAVE RESULTS FIGURE AS A JPEG FILE
        outputImageCurrent = OnameArray(Image+1,:);
        saveas(1,outputImageCurrent);

        % WRITE RESULTS TO TXT FILE
        fprintf(fid,'%d; %d; %d; %d\n',resultsMatrix(1,Image+1),resultsMatrix(2,Image+1),resultsMatrix(3,Image+1),resultsMatrix(4,Image+1));
        
    end
end
        if errorCount>0
            fprintf('\n Unable to analyze %d frame(s). \n',errorCount)
            disp('   - Sudden changes in light levels during ignition can cause tracking errors.')
            disp('   - Objects overlapping with the droplet (e.g., igniters) can cause edge detection errors.')
            disp('   - Try adjusting the Region of Interest for better results.')
        end

   
        
        
% PLOT FLAME PROPERTIES   
figure(2)
hold on, plot(resultsMatrix(1,start+1:Image+1), resultsMatrix(2,start+1:Image+1), 'b.') % Plot point
plot(resultsMatrix(1,start+1:Image+1), resultsMatrix(2,start+1:Image+1)) % Plot line        
axis normal
title('Diameter (Pixels) vs. Frames')
        
      
        
%   CLOSE RESULTS TXT FILE
fclose(fid);
disp(' ')
    
%   WRITE RESULTS TO XLS FILE
disp('---------------------------------------------------------------------------------------')
disp('     Results saved to Text File "results.txt" and EXCEL Spreadsheet "results.xls".     ')
disp('---------------------------------------------------------------------------------------')
disp(' ')
xlswrite('results',{'Frame', 'D', 'xc', 'yc'},'Results',xlsCol_A(3,:));
resultsXLS = resultsMatrix';
resultsXLS = resultsXLS(start+1:last+1,:);
xlswrite('results',resultsXLS,'Results',xlsCol_A(4,:));

%   ELAPSED TIME
toc
disp(' ')

%   END PROGRAM
