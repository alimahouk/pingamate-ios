//
//  PMModelManager.m
//  Pingamate
//
//  Created by Ali Mahouk on 12/29/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "PMModelManager.h"

#import "constants.h"

@implementation PMModelManager


- (instancetype)init
{
        self = [super init];
        
        if ( self ) {
                
        }
        
        return self;
}

#pragma mark -

+ (NSString *)pathForKeyDirectory
{
        NSString *documentsDirectory;
        
        documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        
        return [documentsDirectory stringByAppendingPathComponent:PM_DIR_KEYS];
}

+ (NSString *)pathForClientPrivateKey
{
        return [[self pathForKeyDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pem", PM_FILE_CLIENT_PRIVATE_KEY]];
}

+ (NSString *)pathForClientPublicKey
{
        return [[self pathForKeyDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pem", PM_FILE_CLIENT_PUBLIC_KEY]];
}

+ (NSString *)pathForImageDirectory
{
        NSString *documentsDirectory;
        
        documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        
        return [documentsDirectory stringByAppendingPathComponent:PM_DIR_IMAGES];
}

+ (NSString *)pathForPartnerPublicKey:(NSString *)partnerID
{
        return [[self pathForKeyDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pem", partnerID]];
}

+ (NSString *)pathForVideoDirectory
{
        NSString *documentsDirectory;
        
        documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        
        return [documentsDirectory stringByAppendingPathComponent:PM_DIR_IMAGES];
}

+ (NSURL *)pathForImage:(NSString *)messageID ofType:(NSString *)type
{
        return [[NSURL fileURLWithPath:[self pathForImageDirectory]] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", messageID, type]];
}

+ (NSURL *)pathForLiveReactionBuffer
{
        NSString *documentsDirectory;
        
        documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        
        return [[NSURL fileURLWithPath:documentsDirectory] URLByAppendingPathComponent:@"LiveReaction.mp4"];
}

+ (NSURL *)pathForVideo:(NSString *)messageID ofType:(NSString *)type
{
        return [[NSURL fileURLWithPath:[self pathForVideoDirectory]] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", messageID, type]];
}

- (void)bootstrap
{
        NSError *error;
        NSString *keyDirectory;
        NSString *imageDirectory;
        NSString *videoDirectory;
        
        keyDirectory   = [PMModelManager pathForKeyDirectory];
        imageDirectory = [PMModelManager pathForImageDirectory];
        videoDirectory = [PMModelManager pathForVideoDirectory];
        
        if ( ![NSFileManager.defaultManager fileExistsAtPath:keyDirectory] )
                if ( ![NSFileManager.defaultManager createDirectoryAtPath:keyDirectory withIntermediateDirectories:YES attributes:nil error:&error] )
                        NSLog(@"%@", error);
        
        if ( ![NSFileManager.defaultManager fileExistsAtPath:imageDirectory] )
                if ( ![NSFileManager.defaultManager createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:&error] )
                        NSLog(@"%@", error);
        
        if ( ![NSFileManager.defaultManager fileExistsAtPath:videoDirectory] )
                if ( ![NSFileManager.defaultManager createDirectoryAtPath:videoDirectory withIntermediateDirectories:YES attributes:nil error:&error] )
                        NSLog(@"%@", error);
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer
{
        // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
        @synchronized ( self ) {
                if ( !_persistentContainer ) {
                        _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Pingamate"];
                        
                        [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error){
                                if ( error ) {
                                        // Replace this implementation with code to handle the error appropriately.
                                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                        
                                        /*
                                         Typical reasons for an error here include:
                                         * The parent directory does not exist, cannot be created, or disallows writing.
                                         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                                         * The device is out of space.
                                         * The store could not be migrated to the current model version.
                                         Check the error message to determine what the actual problem was.
                                         */
                                        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                                        abort();
                                }
                        }];
                }
        }
        
        return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext
{
        NSError *error;
        
        if ( [self.persistentContainer.viewContext hasChanges] &&
            ![self.persistentContainer.viewContext save:&error] ) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                abort();
        }
}


@end
