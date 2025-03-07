//
//  PMMessage.h
//  Pingamate
//
//  Created by Ali Mahouk on 12/30/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import UIKit;

#import "constants.h"

@interface PMMessage : NSObject

@property (strong, nonatomic) NSDate *timeSent;
@property (strong, nonatomic) NSString *identifier;

/**
 * Subclasses should override this method.
 */
- (instancetype)initWithData:(NSData *)data;

/**
 * Subclasses should override this method.
 */
- (NSData *)serialize;

@end
