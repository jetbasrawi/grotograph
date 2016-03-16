//
//  GrotographTableViewController.h
//  Grotograph
//
//  Created by Jet Basrawi on 17/09/2011.
//  Copyright 2011 Free for all products Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectListView : UITableViewController <UINavigationControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
