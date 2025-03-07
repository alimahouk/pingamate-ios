//
//  PMUtil.h
//  Pingamate
//
//  Created by Ali Mahouk on 12/29/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import UIKit;

@interface PMUtil : NSObject

+ (BOOL)isClearImage:(UIImage *)image;
+ (BOOL)isValidURL:(NSString *)string;

+ (FILE *)makeFile:(NSString *)path;
+ (FILE *)openFile:(NSString *)path;

+ (NSString *)btostr:(unsigned char *)uc  size:(size_t)size;

+ (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size;

+ (unsigned long)compress:(unsigned char *)src size:(unsigned long)size buffer:(unsigned char **)output;
+ (unsigned long)decompress:(unsigned char *)src size:(unsigned long)size buffer:(unsigned char **)output;

+ (void)fetchLastItemInCameraRoll:(void (^)(UIImage *thumbnail))completionHandler;

@end
