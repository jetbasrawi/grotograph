//
//  NSManagedObject-insert.h
//  Grotograph
//
//  Created by Jet Basrawi on 29/11/2011.
//  Copyright (c) 2011 Free for all products Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSManagedObjectContext(insert)
-(NSManagedObject *)insertNewEntityWithName:(NSString *)name;
@end
