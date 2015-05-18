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

  imwrite( "../images4/Gray_Image" + ret + ".jpg", src );

  return radius;
}

int main()
{

    std::cout << "Hough Circle Transform Running on All Files in Directory..." << std::endl;
    string dir = string(".");
    vector<string> files = vector<string>();
    ofstream myFile("radii.csv", ios::out);

    getdir(dir,files);
    int j = 0;
    for (unsigned int i = 0; i < files.size(); i++) {
      if (files[i] != "." && files[i] != ".." && files[i] != ".DS_Store" && files[i] != "cmake_install.cmake" && files[i] != "CMakeCache.txt" && 
          files[i] != "CMakeFiles" && files[i] != "CMakeLists.txt" && files[i] != "houghDirectory" && files[i] != "houghDirectory.cpp" && 
          files[i] != "houghSingle" && files[i] != "houghSingle.cpp" && files[i] != "Makefile" && files[i] != "myFile.txt" && files[i] != "radii.csv"){
        // cout << files[i] << endl;
        myFile << mainHough(files[i].c_str(), j) << endl;
        cout << j << endl;
        j++;
      }
    }
    cout << "Run Finished." << std::endl;

    myFile.close();

    // waitKey(0);

    return 0;
}
