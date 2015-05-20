%image = imread('E272K03A//E272K03A_00202.tif');
%[Gmag,Gdir] = imgradient(image);
%[Gx, Gy] = imgradientxy(image);

%imshow(image);
%figure; imshowpair(Gmag,Gdir);

% 
% temp = im2bw(imread('E272K03A//E272K03A_00175.tif'),0.08);
% imshow(temp);
% [centersDark, radiiDark, metric] = imfindcircles(temp,[50 60],'ObjectPolarity','dark');  
% viscircles(centersDark,radiiDark, 'LineStyle','-');
% 

%promising solutions
%contour(image);

%edge detection

BW = rgb2gray(imread('/media/rylan/Windows8_OS/Users/Rylan/193/simulated images/Image Sequence 5/frame-0207.tif'));
imshow(BW);

CC = bwconncomp(BW);
numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idx] = max(numPixels);
BW(CC.PixelIdxList{idx}) = 0;

[centersDark, radiiDark, metric] = imfindcircles(BW,[30 50], 'ObjectPolarity','dark','Sensitivity',0.95);
imshow(BW);
viscircles(centersDark(1,1:2),radiiDark(1,1),'LineStyle','-');


[BW1, threshold1] = edge(BW, 'Sobel');
figure, imshow(BW1);
%worst, but needed for BW7
[BW2, threshold2] = edge(BW, 'Canny');
figure, imshow(BW2);
%the best
%[BW3, threshold3] = edge(I, 'log');
%figure, imshow(BW3);
%meh
%[BW6, threshold6] = edge(I, 'zerocross');
%figure, imshow(BW6);
%meh


fudgeFactor = .1;
BW7 = edge(BW,'canny', threshold2 * fudgeFactor);
figure, imshow(BW);

[centersDark, radiiDark, metric] = imfindcircles(BW7,[30 50], 'ObjectPolarity','dark','Sensitivity',0.95);
figure, imshow(BW);
viscircles(centersDark(1,1:2),radiiDark(1,1),'LineStyle','-');

mask = ones(size(BW7));
mask(25:end-25,25:end-25) = 0;

mask = activecontour(BW7,mask, 10);
imshow(mask);


%number 2

%create mask
%mask = zeros(size(I));

%mask(462:562,462:562) = 1; %specific to 202
%mask(467:557,467:557) = 0;
%imshow(mask);
%imshow(activecontour(BW2,mask,1));



%[~,idx] = max(struct2array(perimtr));
%BW2(px(idx).PixelIdxList) = 0;

    %[~, threshold] = edge(image, 'sobel');
    %fudgeFactor = fudgeFactor + 0.0001;
    %edgeimage = edge(image,'canny', threshold * fudgeFactor);