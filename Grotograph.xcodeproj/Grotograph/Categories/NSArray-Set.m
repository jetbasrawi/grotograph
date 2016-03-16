//
//  NSArray-Set.m
//  Grotograph
//
//  Created by Jet Basrawi on 09/10/2011.
//  Copyright 2011 Free for all products Ltd. All rights reserved.
//

#import "NSArray-Set.h"

@implementation NSArray(Set)

+ (id)arrayByOrderingSet:(NSSet *)set byKey:(NSString *)key ascending:(BOOL)ascending {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[set count]];
    for (id oneObject in set)
        [ret addObject:oneObject];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:key
                                                               ascending:ascending];
    [ret sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    return ret;
} 

@end