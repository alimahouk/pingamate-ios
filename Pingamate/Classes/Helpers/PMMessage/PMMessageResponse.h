//
//  PMMessageResponse.h
//  Pingamate
//
//  Created by Ali Mahouk on 1/8/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

#import "PMMessage.h"

@interface PMMessageResponse : PMMessage

@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSString *referenceID;

@end
