//
//  NSArray-Set.h
//  Grotograph
//
//  Created by Jet Basrawi on 09/10/2011.
//  Copyright 2011 Free for all products Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray(Set)
+ (id)arrayByOrderingSet:(NSSet *)set byKey:(NSString *)key ascending:(BOOL)ascending;
@end