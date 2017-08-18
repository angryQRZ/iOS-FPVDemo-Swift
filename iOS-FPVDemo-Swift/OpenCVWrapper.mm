//
//  OpenCVWrapper.m
//  iOS-FPVDemo-Swift
//
//  Created by my Mac on 2017/8/10.
//  Copyright © 2017年 DJI. All rights reserved.
//

#import "OpenCVWrapper.h"
#include "OpenCVWrapper.h"
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgcodecs/ios.h>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/features2d.hpp>
#include <opencv2/xfeatures2d/nonfree.hpp>
#include <opencv2/calib3d/calib3d.hpp>
#include <opencv/cv.h>
#include <vector>
using namespace std;
using namespace cv;
using namespace xfeatures2d;
@implementation OpenCVWrapper : NSObject

+ (double) processImage: (UIImage *)inputImage{
    Mat mat, output, rgb, tmp_mean, tmp_sd;
    UIImageToMat(inputImage, mat);
    //vector<KeyPoint> key_points;    //特征点
    //Ptr<FeatureDetector> detector = cv::KAZE::create( "SIFT" );//创建SIFT特征检测器
    //Ptr<ORB> orb = ORB::create(100,1.2f,8,31,0,2,ORB::HARRIS_SCORE,31,20);
    //Ptr<DescriptorExtractor> descriptor_extractor = cv::KAZE::create( "SIFT" );//创建特征向量生成器
    cvtColor(mat, mat, COLOR_RGBA2GRAY);
//    Mat descriptors;
//    orb->detectAndCompute(mat, Mat(), key_points, descriptors);
//    //detector->detect(mat, key_points );
//    //descriptor_extractor->compute( mat, key_points, descriptors );
//    //sift(img,mascara,key_points,descriptors);    //执行SIFT运算
//    //在输出图像中绘制特征点
//    //cvtColor(mat, rgb, COLOR_RGBA2RGB);
//    drawKeypoints(mat,     //输入图像
//                  key_points,      //特征点矢量
//                  rgb,      //输出
//                  Scalar::all(-1),      //绘制特征点的颜色，为随机
//                  //以特征点为中心画圆，圆的半径表示特征点的大小，直线表示特征点的方向
//                  DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
//    cvtColor(rgb, output, COLOR_RGB2RGBA);
    //cvCanny(&mat, &output, 70, 90, 3);
    Laplacian(mat, output, 3, 3);
    convertScaleAbs(output, output);
    meanStdDev(output, tmp_mean, tmp_sd);
    return tmp_sd.at<double>(0, 0);
    
    
    
    
}

@end
