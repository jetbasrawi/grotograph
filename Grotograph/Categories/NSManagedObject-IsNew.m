//
//  NSManagedObject-IsNew.m
//  Grotograph
//
//  Created by Jet Basrawi on 09/10/2011.
//  Copyright 2011 Free for all products Ltd. All rights reserved.
//

#import "NSManagedObject-IsNew.h"

@implementation NSManagedObject(IsNew)
-(BOOL)isNew
{
    NSDictionary *vals = [self committedValuesForKeys:nil];
    return [vals count] == 0;
}

@end
