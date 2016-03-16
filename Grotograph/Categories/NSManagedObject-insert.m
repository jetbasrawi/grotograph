//
//  NSManagedObject-insert.m
//  Grotograph
//
//  Created by Jet Basrawi on 29/11/2011.
//  Copyright (c) 2011 Free for all products Ltd. All rights reserved.
//

#import "NSManagedObject-insert.h"

@implementation NSManagedObjectContext(insert)

-(NSManagedObject *)insertNewEntityWithName:(NSString *)name {
    return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self];
}

@end
