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
I = image;
[BW1, threshold1] = edge(I, 'Sobel');
figure, imshow(BW1);
%worst, but needed for BW7
[BW2, threshold2] = edge(I, 'Canny');
figure, imshow(BW2);
%the best
%[BW3, threshold3] = edge(I, 'log');
%figure, imshow(BW3);
%meh
%[BW6, threshold6] = edge(I, 'zerocross');
%figure, imshow(BW6);
%meh


fudgeFactor = .1;
BW7 = edge(I,'canny', threshold1 * fudgeFactor);
figure, imshow(BW7), title('binary gradient mask');
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