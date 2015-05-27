% concatenate tiff images into a video file
% assume images are ordered by filename
% outputs video to same directory as the image files

clear all;
ImagesFolder=uigetdir;
tiffFiles = dir(strcat(ImagesFolder,'\*.tif'));
S={};
for t= 1:length(tiffFiles)
    S{t}=[tiffFiles(t).name '  '];
end
[S,S] = sort(S);
tiffFilesS = tiffFiles(S);
VideoFile=strcat(ImagesFolder,'\MyVideo');
writerObj = VideoWriter(VideoFile);
fps= 10; 
writerObj.FrameRate = fps;
open(writerObj);
for t= 1:length(tiffFilesS)
     Frame=rgb2gray(imread(strcat(ImagesFolder,'\',tiffFilesS(t).name)));
     [Frame,map]=gray2ind(flipdim(Frame,1));
     writeVideo(writerObj,im2frame(Frame,map));
end
close(writerObj);
