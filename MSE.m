pradius = ((double(dpixels1(1:347)))./2);
difference = double(Circle_Estimation(1:347,3)) - pradius;
MSE1 = mean(difference.^2);