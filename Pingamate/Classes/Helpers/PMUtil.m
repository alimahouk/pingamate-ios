//
//  PMUtil.m
//  Pingamate
//
//  Created by Ali Mahouk on 12/29/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import Photos;

#import "PMUtil.h"

#include <zlib.h>

#import "constants.h"

@implementation PMUtil


+ (BOOL)isClearImage:(UIImage *)image
{
        BOOL clear;
        
        clear = YES;
        
        if ( image ) {
                GLubyte *imageData;
                size_t width;
                size_t height;
                CGContextRef imageContext;
                CGImageRef i;
                long bytesPerRow;
                int byteIndex;
                int bytesPerPixel;
                int bitsPerComponent;
                
                bitsPerComponent = 8;
                byteIndex        = 0;
                bytesPerPixel    = 4;
                i                = image.CGImage;
                height           = CGImageGetHeight(i);
                width            = CGImageGetWidth(i);
                bytesPerRow      = bytesPerPixel * width;
                imageData        = malloc(width * height * 4);
                imageContext     = CGBitmapContextCreate(imageData, width, height, bitsPerComponent, bytesPerRow, CGImageGetColorSpace(i), kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
                
                CGContextSetBlendMode(imageContext, kCGBlendModeCopy);
                CGContextDrawImage(imageContext, CGRectMake(0, 0, width, height), i);
                CGContextRelease(imageContext);
                
                for ( ; byteIndex < width * height * 4; byteIndex += 4 ) {
                        CGFloat alpha;
                        CGFloat blue;
                        CGFloat green;
                        CGFloat red;
                        
                        red   = ((GLubyte *)imageData)[byteIndex] / 255.0f;
                        green = ((GLubyte *)imageData)[byteIndex + 1] / 255.0f;
                        blue  = ((GLubyte *)imageData)[byteIndex + 2] / 255.0f;
                        alpha = ((GLubyte *)imageData)[byteIndex + 3] / 255.0f;
                        
                        if ( alpha != 0 ) {
                                clear = NO;
                                
                                break;
                        }
                }
        }
        
        return clear;
}

+ (BOOL)isValidURL:(NSString *)string
{
        if ( string &&
             string.length > 0 ) {
                NSString *URLRegex;
                NSPredicate *URLTest;
                
                URLRegex = @"^(?i)(?:(?:https?|ftp):\\/\\/)?(?:\\S+(?::\\S*)?@)?(?:(?:[1-9]\\d?|1\\d\\d|2[01]\\d|22[0-3])(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}(?:\\.(?:[1-9]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))|(?:(?:[a-z\\u00a1-\\uffff0-9]+-?)*[a-z\\u00a1-\\uffff0-9]+)(?:\\.(?:[a-z\\u00a1-\\uffff0-9]+-?)*[a-z\\u00a1-\\uffff0-9]+)*(?:\\.(?:[a-z\\u00a1-\\uffff]{2,})))(?::\\d{2,5})?(?:\\/[^\\s]*)?$";
                URLTest  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", URLRegex];
                
                return [URLTest evaluateWithObject:string];
        }
        
        return NO;
}

+ (FILE *)makeFile:(NSString *)path
{
        if ( path &&
             path.length > 0 )
                return fopen(path.UTF8String, "w+");
        else
                return NULL;
}

+ (FILE *)openFile:(NSString *)path
{
        if ( path &&
             path.length > 0 )
                return fopen(path.UTF8String, "r");
        else
                return NULL;
}

/**
 * Converts a byte array into a string.
 * @attention Do not use this on digests; use dtostr() instead.
 */
+ (NSString *)btostr:(unsigned char *)uc  size:(size_t)size
{
        NSData *data;
        
        data = [NSData dataWithBytes:(const void *)uc length:sizeof(unsigned char)*size];
        
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size
{
        UIImage *cropped;
        CGImageRef imageRef;
        CGRect cropRect;
        double refWidth;
        double refHeight;
        double x;
        double y;
        
        // Not equivalent to image.size (which depends on the imageOrientation)!
        refWidth  = CGImageGetWidth(image.CGImage);
        refHeight = CGImageGetHeight(image.CGImage);
        x         = (refWidth - size.width) / 2;
        y         = (refHeight - size.height) / 2;
        
        cropRect = CGRectMake(x, y, size.height, size.width);
        imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
        cropped  = [UIImage imageWithCGImage:imageRef scale:0.0 orientation:image.imageOrientation];
        
        CGImageRelease(imageRef);
        
        return cropped;
}

/**
 * Compresses a byte buffer.
 * @return The length of the compressed data, or -1 if an error
 * occured.
 */
+ (unsigned long)compress:(unsigned char *)src size:(unsigned long)size buffer:(unsigned char **)output
{
        if ( output ) {
                *output = malloc(ZLIB_CHUNK);
                
                if ( *output ) {
                        int ret;
                        z_stream stream;
                        
                        stream.zalloc    = Z_NULL;
                        stream.zfree     = Z_NULL;
                        stream.opaque    = Z_NULL;
                        stream.avail_in  = (uInt)size;
                        stream.avail_out = ZLIB_CHUNK;
                        stream.next_in   = (Bytef *)src;
                        stream.next_out  = (Bytef *)*output;
                        
                        deflateInit(&stream, Z_BEST_COMPRESSION);
                        
                        ret = deflate(&stream, Z_FINISH);
                        
                        deflateEnd(&stream);
                        
                        return stream.total_out;
                }
        }
        
        return -1;
}

/**
 * Decompresses a byte buffer.
 * @return The length of the decompressed data, or -1 if an error
 * occured.
 */
+ (unsigned long)decompress:(unsigned char *)src size:(unsigned long)size buffer:(unsigned char **)output
{
        if ( output ) {
                *output = malloc(ZLIB_CHUNK);
                
                if ( *output ) {
                        int ret;
                        z_stream stream;
                        
                        stream.zalloc    = Z_NULL;
                        stream.zfree     = Z_NULL;
                        stream.opaque    = Z_NULL;
                        stream.avail_in  = (uInt)size;
                        stream.avail_out = ZLIB_CHUNK;
                        stream.next_in   = (Bytef *)src;
                        stream.next_out  = (Bytef *)*output;
                        
                        inflateInit(&stream);
                        
                        ret = inflate(&stream, Z_NO_FLUSH);
                        
                        inflateEnd(&stream);
                        
                        return stream.total_out;
                }
        }
        
        return -1;
}

+ (void)fetchLastItemInCameraRoll:(void (^)(UIImage *thumbnail))completionHandler
{
        PHAsset *lastAsset;
        PHFetchOptions *fetchOptions;
        PHFetchResult *fetchResult;
        
        fetchOptions                 = [PHFetchOptions new];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        
        fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
        lastAsset   = [fetchResult lastObject];
        
        [PHImageManager.defaultManager requestImageForAsset:lastAsset
                                                 targetSize:CGSizeMake(40, 40)
                                                contentMode:PHImageContentModeAspectFill
                                                    options:PHImageRequestOptionsVersionCurrent
                                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                              completionHandler(result);
                                                      });
                                              }];
}


@end
