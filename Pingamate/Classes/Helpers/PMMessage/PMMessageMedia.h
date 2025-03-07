//
//  PMMessageMedia.h
//  Pingamate
//
//  Created by Ali Mahouk on 1/1/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

#import "PMMessage.h"

#import "constants.h"

@interface PMMessageMedia : PMMessage

@property (strong, nonatomic) NSAttributedString *caption;
@property (strong, nonatomic) NSURL *fileURL;
@property (nonatomic) PMMediaType mediaType;

- (instancetype)initWithMediaType:(PMMediaType)mediaType;

@end
