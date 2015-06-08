# Simple MSE calculator.

import sys
import csv
import os
import numpy
import scipy
import math
import matplotlib
import matplotlib.pyplot as plt

file1 = open("dropletSizeVsFrameNumber.csv", 'rU')
file2 = open("radii5.csv", 'rU')
A = []
B = []
try:
    known = csv.reader(file1)
    file1.next()
    test = csv.reader(file2)
    for row in known:
        data1 = row
        A.append(float(data1[1]))
    for row in test:
        data2 = row
        data2 =  str(data2).strip('[]')
        data2 =  str(data2).strip("'")
        B.append(float(data2))
finally:
    file1.close()
    file2.close()

A = asarray(A)
B = asarray(B)
with open('sytheticImagesMSE.txt', 'a') as new:
	MSE =  (sum((A-B)**2))/(size(A))
	print str(MSE)
	new.write("MSE for Sythetic Sequence 5: ")
	new.write(str(MSE))
	new.write("\n")

# MSE = float((1/size(A) * float(sum((A - B)**2) ))