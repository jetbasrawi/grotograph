//
//  NSManagedObject-IsNew.h
//  Grotograph
//
//  Created by Jet Basrawi on 09/10/2011.
//  Copyright 2011 Free for all products Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSManagedObject(IsNew)
/**
 Returns YES if this managed object is new and has not yet been saved in the
 persistent store.
 */
-(BOOL)isNew;
@end