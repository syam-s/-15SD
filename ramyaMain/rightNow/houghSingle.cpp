#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <iostream>
#include <stdio.h>

using namespace cv;

int main(int argc, char** argv)
{
  Mat src, src_gray;

  /// Read in image
  src = imread( argv[1], 1 );

  if( !src.data )
    { return -1; }

  /// Convert to grayscale
  cvtColor( src, src_gray, cv::COLOR_BGR2GRAY );

  /// Reduce noise to avoid false circle detection
  GaussianBlur( src_gray, src_gray, Size(9, 9), 2, 2 );

  std::vector<Vec3f> circles;

  /// Apply Hough Transform to find the circles
  HoughCircles( src_gray, circles, HOUGH_GRADIENT, 1, src_gray.rows/8, 200, 100, 0, 0 );

  /// Draw detected circles
  int radius;
  for( size_t i = 0; i < circles.size(); i++ )
  {
      Point center(cvRound(circles[i][0]), cvRound(circles[i][1]));
      radius = cvRound(circles[i][2]);
      // Output to user terminal the detected circle radius
      // std::cout << radius << std::endl; 
      // circle center
      circle( src, center, 3, Scalar(0,255,0), -1, 8, 0 );
      // circle outline
      circle( src, center, radius, Scalar(0,0,255), 3, 8, 0 );
   }

  /// Display results: image with fitted circle
  namedWindow( "Hough Circle Transform Demo", WINDOW_AUTOSIZE );
  imshow( "Hough Circle Transform Demo", src );

  std::cout << radius << std::endl; 
  waitKey(0);
  return 0;
}