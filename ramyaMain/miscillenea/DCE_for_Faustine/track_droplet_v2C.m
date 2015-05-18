%===============================================%
% Author:   Vincent K. Tam                      %
% Title:    Droplet Tracker v2                  %
% Updated:  05/31/06                            %
% Notes:    Accounts for presence of fiber.     %
%           Differentiates droplet from fiber.  %
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
    clf
    % LOAD IMAGE
    filenameCurrent = InameArray(Image+1,:);
    I = imread(filenameCurrent);
  
    % ROTATION FOR HOIZONTAL FIBER ORIENTATION
    IRot = imrotate(I,rotationAngle);
    
    % CROP ROI
    IRotCrop = IRot(start_row:end_row,start_col:end_col,:);
    
    %   Create binary for input into edge detector    
    threshImage = IRotCrop;
    threshold = graythresh(threshImage);
    BWthresh = im2bw(IRotCrop,threshold);
    BWthresh = imfill(~BWthresh, 'holes');
    imwrite(BWthresh,'BWthresh.jpg');   % Temp image file
    BWthresh2 = imread('BWthresh.jpg');

    %   Apply Edge Detection
    figure(1)
    subplot(2,2,1)
    BW = EDGE(BWthresh2,'canny',[],1.5);
    imshow(BW,[]);
    s=size(BW);
    title('Edge Detection');

    %   Locate points on top and bottom of fiber to begin trace.
    %   Scan columns starting from the left for acceptable initial trace points.
    for column1=1:s(2)
        NumTracePoints = size(find(BW(:,column1)));
        if NumTracePoints(1,1)==2
        fiberTop = find(BW(:,column1), 1, 'first');
        fiberBot = find(BW(:,column1), 1, 'last');
        break
        end
    end    

    %   Exclude points before and after start/end trace columns.
    for columnExclude=1:column1-1
        for rowExclude=1:s(1)
            BW(rowExclude,columnExclude) = 0;
        end
    end

    for columnBackward=0:s(2)
        backward = s(2)-columnBackward;
        NumTracePointsEnd = size(find(BW(:,backward)));
        if NumTracePointsEnd(1,1)==2
        fiberTopEnd = find(BW(:,backward), 1, 'first');
        fiberBotEnd = find(BW(:,backward), 1, 'last');
        break
        end
    end    

    for columnExcludeEnd=backward+1:s(2)
        for rowExcludeEnd=1:s(1)
            BW(rowExcludeEnd,columnExcludeEnd) = 0;
        end
    end

    %   Trace fiber and droplet contour from left to right.
    contourTopPC = bwtraceboundary(BW,[fiberTop,column1],'E',8,Inf);
    contourBotPC = bwtraceboundary(BW,[fiberBot,column1],'E',8,Inf);

    %   Obtain continuous contour curves.
    %   Choose the max where multiple values occur.
    colStart = min(contourTopPC(:,2));
    colEnd = max(contourTopPC(:,2));
    for column2t=colStart:colEnd
        multiIndicesT = find(contourTopPC(:,2)==column2t);
        multiValuesT = contourTopPC(multiIndicesT);
        contourTopCont(column2t,1) = min(multiValuesT);
        contourTop(column2t,1) = s(1)-contourTopCont(column2t,1);
    end 

    for column2b=colStart:colEnd
        multiIndicesB = find(contourBotPC(:,2)==column2b);
        multiValuesB = contourBotPC(multiIndicesB);
        contourBotCont(column2b,1) = max(multiValuesB);
        contourBot(column2b,1) = s(1)-contourBotCont(column2b,1);
    end

    %   Plot continuous contours.
    subplot(2,2,3)
    plot(colStart:colEnd, contourTop(colStart:colEnd,1), 'r'), hold on, plot(colStart:colEnd, contourBot(colStart:colEnd),'r');

    %   Plot continuous contour.
    subplot(2,2,2)
    imshow(IRotCrop);
    hold on
    plot(colStart:colEnd,contourTopCont(colStart:colEnd),'r','LineWidth',1);
    plot(colStart:colEnd,contourBotCont(colStart:colEnd),'r','LineWidth',1);
    title(filenameCurrent)

    % Thickness
    thickness = contourTop-contourBot;
    area = 0;
    for column3=colStart:colEnd
        area = area+thickness(column3,1);
    end

    %   Find slope for thickness curve
    for column4 = (colStart+1):colEnd
        thicknessSlope(column4,1) = thickness(column4,1)-thickness((column4-1),1);   
    end
    
    %   Plot thickness slope on contour plot.
    subplot(2,2,3), hold on
    hold on, plot(colStart:colEnd,thicknessSlope(colStart:colEnd), 'b')

    %   Find max and min slope.
    slopeMax = find((thicknessSlope == max(thicknessSlope)),1,'first' );
    slopeMin = find((thicknessSlope == min(thicknessSlope)),1,'last');

    %   Choose where droplet starts.
    %   Locate point with zero slope on the outside of the max/min slope.
    for column5t = 1: slopeMax
        if thicknessSlope(slopeMax-column5t) == 0
            dropletStart = slopeMax-column5t;
            break
        end
    end

    for column5b = slopeMin:s(2)
        if thicknessSlope(column5b) == 0
            dropletEnd = column5b;
            break
        end
    end

    %   Exclude protruding fiber.
    dropletContourTop = contourTop(dropletStart:dropletEnd);
    dropletContourBot = contourBot(dropletStart:dropletEnd);
    subplot(2,2,3), hold on
    plot(dropletStart:dropletEnd, dropletContourTop,'g'), plot(dropletStart:dropletEnd, dropletContourBot,'g');
    plot(dropletStart,0:dropletContourTop(1,1),'r');
    plot(dropletEnd,0:dropletContourTop(size(dropletContourTop)),'r');
    axis equal;
    title('Droplet/Fiber Detection')

    %   Plot droplet contour over original
    subplot(2,2,2)
    hold on, plot(dropletStart:dropletEnd, (s(1)-dropletContourTop),'g', 'LineWidth', 1);
    plot(dropletStart:dropletEnd, (s(1)-dropletContourBot),'g', 'LineWidth',1);
    title(filenameCurrent);
    hold off

    %  Integrate for droplet area
    thicknessDroplet = dropletContourTop-dropletContourBot;
    areaDroplet = 0;
    for column6=1:(dropletEnd-dropletStart)
        areaDroplet = areaDroplet+thicknessDroplet(column6);
    end
    
    
    %   CENTROID
    BWthreshC = BWthresh;
    for BWrow = 1: s(1)
        for column6L = 1:dropletStart-1
            BWthreshC(BWrow,column6L) = 0;
        end
        for column6R = dropletEnd+1:s(2)
            BWthreshC(BWrow,column6R) = 0;
        end
    end
    
    [labeled, numObjects] = bwlabel(BWthreshC,8);
    data = regionprops(labeled, 'basic');
    maxArea = max([data.Area]);
    droplet = find([data.Area]==maxArea);
    Centroid = round([data(1).Centroid]);
    subplot(2,2,2), hold on,
    plot(Centroid(1,1),Centroid(1,2),'b.')
    hold off
    CentroidCartX_ROI = Centroid(1,1);
    CentroidCartY_ROI = s(1)-Centroid(1,2);
    subplot(2,2,3), hold on
    plot(CentroidCartX_ROI, CentroidCartY_ROI, 'b.');
    hold off
    figure(2), imshow(BWthreshC), hold on, plot(Centroid(1,1),Centroid(1,2),'b.')
    
    %   Plot Droplet Contour and Centroid Results in Cartesian Coordinates
    IRotSize = size(IRot);
    CentroidCartX = CentroidCartX_ROI+start_col;
    CentroidCartY = CentroidCartY_ROI+start_row;
    IRot_dropletStart = dropletStart+start_col;
    IRot_dropletEnd = dropletEnd+start_col;
    IRot_dropletContourTop = dropletContourTop+start_row;
    IRot_dropletContourBot = dropletContourBot+start_row;
    %figure(2), clf, hold on
    %plot(IRot_dropletStart:IRot_dropletEnd, IRot_dropletContourTop,'g'), plot(IRot_dropletStart:IRot_dropletEnd, IRot_dropletContourBot,'g')
    %plot(CentroidCartX,CentroidCartY,'b.')
    %axis([0 IRotSize(1,2) 0 IRotSize(1,1)])
    %axis equal
    %hold off
    
    %   Plot Droplet Contour and Centroid Results in Pixel Coordinates
    IRot_dropletContourTop2 = s(1)-dropletContourTop+start_row;
    IRot_dropletContourBot2 = s(1)-dropletContourBot+start_row;
    %figure(3)
    %imshow(IRot), hold on,
    %plot(IRot_dropletStart:IRot_dropletEnd, IRot_dropletContourTop2,'g'), plot(IRot_dropletStart:IRot_dropletEnd, IRot_dropletContourBot2,'g')
    %plot(CentroidCartX,(Centroid(1,2)+start_row),'b.')
    %hold off

    %   Store results in a matrix
    resultsMatrix(1,Image+1) = Image;           % Frame (1,:)
    resultsMatrix(2,Image+1) = areaDroplet;     % Area (2,:)
    resultsMatrix(3,Image+1) = CentroidCartX;   % Centroid Column(3,:)
    resultsMatrix(4,Image+1) = CentroidCartY;   % Centroid Row (4,:)
    
    % PLOT DROPLET PROPERTIES   
    figure(1)
    subplot(2,2,4), hold on, plot(resultsMatrix(1,start+1:Image+1), resultsMatrix(2,start+1:Image+1), 'b.') % Plot point
    subplot(2,2,4), plot(resultsMatrix(1,start+1:Image+1), resultsMatrix(2,start+1:Image+1)) % Plot line        
    axis normal
    title('Area (Pixels) vs. Frames')
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
        resultsMatrix(2,Image+1) = 0;           % Area (2,:)
        resultsMatrix(3,Image+1) = 0;           % Centroid Column(3,:)
        resultsMatrix(4,Image+1) = 0;           % Centroid Row (4,:)
        
        % PLOT DROPLET PROPERTIES    
        subplot(2,2,4), hold on, plot(resultsMatrix(1,start+1:Image+1), resultsMatrix(2,start+1:Image+1), 'b.') % Plot point
        subplot(2,2,4), plot(resultsMatrix(1,start+1:Image+1), resultsMatrix(2,start+1:Image+1)) % Plot line        
        axis normal
        title('Area (Pixels) vs. Frames')

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

%   CLOSE RESULTS TXT FILE
fclose(fid);
disp(' ')

%   DELETE Temp image file
delete('BWthresh.jpg');
    
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
