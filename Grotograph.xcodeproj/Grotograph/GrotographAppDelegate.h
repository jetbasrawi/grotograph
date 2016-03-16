//
//  GrotographAppDelegate.h
//  Grotograph
//
//  Created by Jet Basrawi on 17/09/2011.
//  Copyright 2011 Free for all products Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GrotographAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) UINavigationController *navController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end
