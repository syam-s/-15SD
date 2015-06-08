#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <iostream>
#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>
#include <errno.h>
#include <vector>
#include <string>
#include <fstream>
#include <typeinfo>
using namespace std;
using namespace cv;

/*function... might want it in some class?*/
int getdir (string dir, vector<string> &files)
{
    DIR *dp;
    struct dirent *dirp;
    if((dp  = opendir(dir.c_str())) == NULL) {
        cout << "Error(" << errno << ") opening " << dir << endl;
        return errno;
    }

    while ((dirp = readdir(dp)) != NULL) {
        files.push_back(string(dirp->d_name));
    }
    closedir(dp);
    return 0;
}

int mainHough(const char* arg, int fileNumber){

  Mat src, src_gray;

  /// Read in image
  src = imread( arg, 1 );

  if( !src.data )
    { return -1; }

  /// Convert to grayscale
  cvtColor( src, src_gray, cv::COLOR_BGR2GRAY );

  /// Reduce noise to avoid false circle detection
  GaussianBlur( src_gray, src_gray, Size(9, 9), 2, 2 );

  std::vector<Vec3f> circles;

  /// Apply Hough Transform to find the circles
  HoughCircles( src_gray, circles, HOUGH_GRADIENT, 1, src_gray.rows/8, 200, 30, 0, 0 );

  /// Draw detected circles
  int radius;
  for( size_t i = 0; i < circles.size(); i++ )
  {
    Point center(cvRound(circles[i][0]), cvRound(circles[i][1]));
    radius = cvRound(circles[i][2]);
    // Output to user terminal the detected circle radius
    if (!radius){
      radius = 0;
    }
    // std::cout << radius << std::endl; 
    // circle center
    circle( src, center, 3, Scalar(0,255,0), -1, 8, 0 );
    // circle outline
    circle( src, center, radius, Scalar(0,0,255), 3, 7, 0 );
  }

  /// Display results: image with fitted circle
  // namedWindow( "Hough Circle Transform", WINDOW_AUTOSIZE );
  // imshow( "Hough Circle Transform", src );

  stringstream ss;  
  // the number is converted to string with the help of stringstream
  ss << fileNumber; 
  string ret;
  ss >> ret;
  
  // Append zero chars
  int str_length = ret.length();
  for (int i = 0; i < 5 - str_length; i++){
    ret = "0" + ret;
  }

  imwrite( "../realDemo/Gray_Image" + ret + ".jpeg", src );

  return radius*float(2);
}

int main()
{

    std::cout << "Welcome to dropletFinder. Press Enter to continue." << std::endl;
    cin.get();
    std::cout << "Before we begin, please read the information below carefully:" << std::endl;
    cin.get();
    std::cout << "This program can perform the following functions:" << std::endl;
    std::cout << "     -can locate a droplet in reasonable amount of noise";
    cin.get();
    std::cout << "     -can produce a set of image files with the dropletFinder";
    cin.get();
    std::cout << "      drawing the calculated measurement around object of interest";
    cin.get();
    std::cout << "     -return a calculated MSE value for the dataset of interest (Under Construction)" << std::endl;
    cin.get();
    std::cout << "     -create a video file of the analyzed images (Under Construction)" << std::endl;
    cin.get();
    std::cout << "This program assumes that the user has read the user manual " << std::endl;
    std::cout << "of how to edit the main file dropletFinder.cpp to transfer " << std::endl;
    std::cout << " files into the correct directory and to compile after each change." << std::endl;
    cin.get();
    std::cout << "dropletFinder currenty works on all files within the current directory" << std::endl;
    std::cout << "and assumes that the user wants all image files to be the file of concern" << std::endl;
    std::cout << "dropletFinder begins analysis now, as soon as user presses Enter key." << std::endl;
    std::cout << "Press control + c to exit program to make changes or abort." << std::endl;
    cin.get();

    string dir = string(".");
    vector<string> files = vector<string>();
    ofstream myFile("../radii/realDemo.csv", ios::out);

    getdir(dir,files);
    int j = 0;
    for (unsigned int i = 0; i < files.size(); i++) {
      if (files[i] != "." && files[i] != ".." && files[i] != ".DS_Store" && 
          files[i] != "cmake_install.cmake" && files[i] != "CMakeCache.txt" && 
          files[i] != "CMakeFiles" && files[i] != "CMakeLists.txt" && 
          files[i] != "dropletFinder" && files[i] != "dropletFinder.cpp" && 
          files[i] != "Makefile" && files[i] != "HowTo.txt"){
        if (mainHough(files[i].c_str(), j) != (-1)){
          myFile << mainHough(files[i].c_str(), j) << endl;
           cout << j << endl;
           j++;
        }
      }
    }


    if (j== 1){
      cout << "No image files were present." << std::endl;
    }
    else{
      cout << "Run Finished." << std::endl;
    }
    
    myFile.close();

    return 0;
}
