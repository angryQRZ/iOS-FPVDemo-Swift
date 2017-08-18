//
//  OpenCVWrapper.h
//  iOS-FPVDemo-Swift
//
//  Created by my Mac on 2017/8/10.
//  Copyright © 2017年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
@interface OpenCVWrapper : NSObject
+ (double) processImage: (UIImage *)inputImage;

@end
